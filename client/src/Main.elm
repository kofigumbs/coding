module Main exposing (..)

import Animation
import Animation.Messenger
import Dashboard.Page
import Excelsior
import Html
import Landing.Page
import Lesson.Page
import Navigation
import Pricing.Page
import Quiz.Page
import Route
import Task


type alias Model =
    { page : Page
    , style : Animation.Messenger.State Msg
    , context : Excelsior.Context
    }


type Page
    = Blank
    | Transitioning { from : Page }
    | Landing Landing.Page.Model
    | Dashboard Dashboard.Page.Model
    | Pricing
    | Lesson Lesson.Page.Model
    | Quiz Quiz.Page.Model


init : Excelsior.Context -> Navigation.Location -> ( Model, Cmd Msg )
init context location =
    goTo (Route.fromLocation location)
        { page = Blank
        , style = Animation.style properties.initial
        , context = context
        }


properties :
    { initial : List Animation.Property
    , loading : List Animation.Property
    }
properties =
    { initial =
        [ Animation.opacity 1.0
        , Animation.translate (Animation.px 0) (Animation.px 0)
        ]
    , loading =
        [ Animation.opacity 0.0
        , Animation.translate (Animation.px 0) (Animation.px 150)
        ]
    }


queueInitial : Model -> Animation.Messenger.State Msg
queueInitial model =
    Animation.queue [ animate properties.initial ] model.style


queueNext : Page -> Model -> Animation.Messenger.State Msg
queueNext page model =
    Animation.queue [ Animation.Messenger.send (Transitioned page) ] model.style


animate : List Animation.Property -> Animation.Messenger.Step Msg
animate =
    Animation.toWith <| Animation.spring { stiffness = 400, damping = 28 }


type Msg
    = SetRoute (Maybe Route.Route)
    | Loaded Page
    | Transitioned Page
    | Animate Animation.Msg
    | DashboardMsg Dashboard.Page.Msg
    | LessonMsg Lesson.Page.Msg
    | QuizMsg Quiz.Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SetRoute destination, _ ) ->
            goTo destination model

        ( Transitioned page, _ ) ->
            ( { model | page = page, style = queueInitial model }, Cmd.none )

        ( Loaded page, Transitioning _ ) ->
            ( { model | style = queueNext page model }, Cmd.none )

        ( Loaded page, _ ) ->
            ( { model | page = page }, Cmd.none )

        ( Animate animMsg, _ ) ->
            Animation.Messenger.update animMsg model.style
                |> Tuple.mapFirst (\style -> { model | style = style })

        ( DashboardMsg pageMsg, Dashboard pageModel ) ->
            Dashboard.Page.update pageMsg pageModel
                |> Tuple.mapFirst (\new -> { model | page = Dashboard new })
                |> Tuple.mapSecond (Cmd.map DashboardMsg)

        ( LessonMsg pageMsg, Lesson pageModel ) ->
            Lesson.Page.update pageMsg pageModel
                |> Tuple.mapFirst (\new -> { model | page = Lesson new })
                |> Tuple.mapSecond (Cmd.map LessonMsg)

        ( QuizMsg pageMsg, Quiz pageModel ) ->
            Quiz.Page.update pageMsg pageModel
                |> Tuple.mapFirst (\new -> { model | page = Quiz new })
                |> Tuple.mapSecond (Cmd.map QuizMsg)

        ( _, _ ) ->
            ( model, Cmd.none )


goTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
goTo destination model =
    let
        cmd =
            case destination of
                Nothing ->
                    Route.modifyUrl Route.Root

                Just Route.Root ->
                    Task.perform (Loaded << Landing) (Landing.Page.init model.context)

                Just Route.Dashboard ->
                    Task.perform (Loaded << Dashboard) (Dashboard.Page.init model.context)

                Just Route.Pricing ->
                    static Pricing

                Just (Route.Lesson slug) ->
                    Task.perform (Loaded << Lesson) (Lesson.Page.init model.context slug)

                Just (Route.Quiz slug) ->
                    Task.perform (Loaded << Quiz) (Quiz.Page.init model.context slug)
    in
    if model.page == Blank then
        ( model, cmd )
    else
        ( { model
            | page = Transitioning { from = model.page }
            , style = Animation.queue [ animate properties.loading ] model.style
          }
        , cmd
        )


static : Page -> Cmd Msg
static =
    Task.perform Loaded << Task.succeed


view : Model -> Html.Html Msg
view model =
    Html.main_ (Animation.render model.style) [ viewPage model.page ]


viewPage : Page -> Html.Html Msg
viewPage page =
    case page of
        Blank ->
            Html.text ""

        Landing model ->
            Landing.Page.view model

        Dashboard model ->
            Html.map DashboardMsg <| Dashboard.Page.view model

        Pricing ->
            Pricing.Page.view

        Lesson model ->
            Html.map LessonMsg <| Lesson.Page.view model

        Quiz model ->
            Html.map QuizMsg <| Quiz.Page.view model

        Transitioning { from } ->
            viewPage from


subscriptions : Model -> Sub Msg
subscriptions model =
    Animation.subscription Animate [ model.style ]


main : Program Excelsior.Context Model Msg
main =
    Navigation.programWithFlags
        (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
