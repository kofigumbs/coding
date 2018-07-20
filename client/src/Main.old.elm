module Main exposing (..)

import Global
import Html
import Js
import Json.Decode exposing (Value)
import Lesson.Page
import Navigation
import Route
import Task


type alias Model =
    { page : Page
    , context : Global.Context
    }


type Page
    = Blank
    | Lesson Lesson.Page.Model


init : Global.Context -> Navigation.Location -> ( Model, Cmd Msg )
init context location =
    goTo (Route.fromLocation location)
        { page = Blank
        , context = context
        }


type Msg
    = NewUser (Maybe Value)
    | SetRoute (Maybe Route.Route)
    | Loaded Page
    | LessonMsg Lesson.Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context } as model) =
    case ( msg, model.page ) of
        ( NewUser (Just user), _ ) ->
            ( { model | context = { context | user = user } }, Cmd.none )

        ( SetRoute destination, _ ) ->
            goTo destination model

        ( Loaded page, _ ) ->
            ( { model | page = page }, Cmd.none )

        ( LessonMsg pageMsg, Lesson pageModel ) ->
            Lesson.Page.update model.context pageMsg pageModel
                |> mapPage Lesson LessonMsg model

        ( _, _ ) ->
            ( model, Cmd.none )


goTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
goTo destination model =
    ( model, fromDestination model.context destination )


fromDestination : Global.Context -> Maybe Route.Route -> Cmd Msg
fromDestination context destination =
    case destination of
        Nothing ->
            Route.modifyUrl <| Route.Lesson (.slug Global.lessonOne)

        Just (Route.Lesson slug) ->
            Task.perform (Loaded << Lesson) (Lesson.Page.init context slug)


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
    case model.page of
        Blank ->
            Html.text ""

        Lesson model ->
            Html.map LessonMsg <| Lesson.Page.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Blank ->
            Sub.none

        Lesson page ->
            Sub.map LessonMsg <| Lesson.Page.subscriptions model.context page


main : Program Global.Context Model Msg
main =
    Navigation.programWithFlags
        (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
