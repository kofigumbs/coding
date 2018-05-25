module Main exposing (..)

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
import Transition


type alias Model =
    { page : Page
    , transition : Transition.State Msg
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
        , transition = Transition.initial
        , context = context
        }


type Msg
    = NewUser (Maybe Value)
    | SetRoute (Maybe Route.Route)
    | Loaded Page
    | Transitioned Page
    | Animate Transition.Animation
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
            ( { model | page = page, transition = Transition.queueInitial model.transition }, Cmd.none )

        ( Loaded page, Transitioning _ ) ->
            ( { model | transition = Transition.queueNext (Transitioned page) model.transition }, Cmd.none )

        ( Loaded page, _ ) ->
            ( { model | page = page }, Cmd.none )

        ( Animate animMsg, _ ) ->
            Transition.update animMsg model.transition
                |> Tuple.mapFirst (\new -> { model | transition = new })

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
            , transition = Transition.queueLoading model.transition
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
    Html.main_ (Transition.render model.transition) [ viewPage model.page ]


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
        [ Js.newUser NewUser
        , Transition.subscription Animate model.transition
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
