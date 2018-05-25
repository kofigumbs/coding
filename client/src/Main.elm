module Main exposing (..)

import Animation
import Animation.Messenger
import Dashboard.Page
import Global
import Html
import Js
import Json.Decode exposing (Value)
import Lesson.Page
import Navigation
import Review.Page
import Route
import Task


type alias Model =
    { page : Page
    , style : Animation.Messenger.State Msg
    , context : Global.Context
    }


type Page
    = Blank
    | Transitioning { from : Page }
    | Dashboard Dashboard.Page.Model
    | Lesson Lesson.Page.Model
    | Review Review.Page.Model


init : Global.Context -> Navigation.Location -> ( Model, Cmd Msg )
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
        , Animation.translate (Animation.px 0) (Animation.px 25)
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
    = NewUser (Maybe Value)
    | SetRoute (Maybe Route.Route)
    | Loaded Page
    | Transitioned Page
    | Animate Animation.Msg
    | DashboardMsg Dashboard.Page.Msg
    | LessonMsg Lesson.Page.Msg
    | ReviewMsg Review.Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context } as model) =
    case ( msg, model.page ) of
        ( NewUser (Just user), _ ) ->
            ( { model | context = { context | user = user } }, Cmd.none )

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

        ( ReviewMsg pageMsg, Review pageModel ) ->
            Review.Page.update pageMsg pageModel
                |> Tuple.mapFirst (\new -> { model | page = Review new })
                |> Tuple.mapSecond (Cmd.map ReviewMsg)

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
                    Route.modifyUrl Route.Dashboard

                Just Route.Dashboard ->
                    Task.attempt (load Dashboard) (Dashboard.Page.init model.context)

                Just (Route.Lesson slug) ->
                    Task.perform (Loaded << Lesson) (Lesson.Page.init model.context slug)

                Just (Route.Review slug) ->
                    Task.perform (Loaded << Review) (Review.Page.init model.context slug)
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


load : (a -> Page) -> Result Global.Error a -> Msg
load pageFunction result =
    case result of
        Ok page ->
            Loaded <| pageFunction page

        Err _ ->
            Debug.crash {- TODO -} ""


view : Model -> Html.Html Msg
view model =
    Html.main_ (Animation.render model.style) [ viewPage model.page ]


viewPage : Page -> Html.Html Msg
viewPage page =
    case page of
        Blank ->
            Html.text ""

        Dashboard model ->
            Html.map DashboardMsg <| Dashboard.Page.view model

        Lesson model ->
            Html.map LessonMsg <| Lesson.Page.view model

        Review model ->
            Html.map ReviewMsg <| Review.Page.view model

        Transitioning { from } ->
            viewPage from


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription Animate [ model.style ]
        , Js.newUser NewUser
        ]


main : Program Global.Context Model Msg
main =
    Navigation.programWithFlags
        (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
