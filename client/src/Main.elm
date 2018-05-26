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
    | TransitioningFrom Page
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
    | TransitionedTo Page
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

        ( TransitionedTo page, _ ) ->
            ( { model
                | page = page
                , transition = Transition.queueInitial model.transition
              }
            , Cmd.none
            )

        ( Loaded page, TransitioningFrom _ ) ->
            ( { model
                | transition = Transition.queueNext (TransitionedTo page) model.transition
              }
            , Cmd.none
            )

        ( Loaded page, _ ) ->
            ( { model | page = page }, Cmd.none )

        ( Animate animMsg, _ ) ->
            Transition.update animMsg model.transition |> Tuple.mapFirst (\new -> { model | transition = new })

        ( DashboardMsg pageMsg, Dashboard pageModel ) ->
            Dashboard.Page.update pageMsg pageModel |> mapPage Dashboard DashboardMsg model

        ( LessonMsg pageMsg, Lesson pageModel ) ->
            Lesson.Page.update pageMsg pageModel |> mapPage Lesson LessonMsg model

        ( ReviewMsg pageMsg, Review pageModel ) ->
            Review.Page.update pageMsg pageModel |> mapPage Review ReviewMsg model

        ( _, _ ) ->
            ( model, Cmd.none )


goTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
goTo destination model =
    if model.page == Blank then
        ( model, fromDestination model.context destination )
    else
        ( { model
            | page = TransitioningFrom model.page
            , transition = Transition.queueLoading model.transition
          }
        , fromDestination model.context destination
        )


fromDestination : Global.Context -> Maybe Route.Route -> Cmd Msg
fromDestination context destination =
    case destination of
        Nothing ->
            Route.modifyUrl Route.Dashboard

        Just Route.Dashboard ->
            Task.attempt (load Dashboard) (Dashboard.Page.init context)

        Just (Route.Lesson slug) ->
            Task.perform (Loaded << Lesson) (Lesson.Page.init context slug)

        Just (Route.Review slug) ->
            Task.perform (Loaded << Review) (Review.Page.init context slug)


load : (a -> Page) -> Result Global.Error a -> Msg
load pageFunction result =
    case result of
        Ok page ->
            Loaded <| pageFunction page

        Err _ ->
            Debug.crash {- TODO -} ""


mapPage : (a -> Page) -> (msg -> Msg) -> Model -> ( a, Cmd msg ) -> ( Model, Cmd Msg )
mapPage toPage toMsg model ( pageModel, pageCmds ) =
    ( { model | page = toPage pageModel }, Cmd.map toMsg pageCmds )


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

        TransitioningFrom page ->
            viewPage page


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
