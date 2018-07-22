module Main exposing (..)

import Html
import Js
import Lesson.Page
import Navigation
import Route
import Sandbox.Page


type alias Model =
    { page : Page
    , flags : Js.Flags
    }


type Page
    = Blank
    | Lesson Lesson.Page.Model
    | Sandbox Sandbox.Page.Model


init : Js.Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    goTo (Route.fromLocation location)
        { page = Blank
        , flags = flags
        }


type Msg
    = SetRoute (Maybe Route.Route)
    | LessonMsg Lesson.Page.Msg
    | SandboxMsg Sandbox.Page.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( SetRoute destination, _ ) ->
            goTo destination model

        ( LessonMsg pageMsg, Lesson pageModel ) ->
            Lesson.Page.update pageMsg pageModel
                |> mapPage Lesson LessonMsg model

        ( SandboxMsg pageMsg, Sandbox pageModel ) ->
            Sandbox.Page.update pageMsg pageModel
                |> mapPage Sandbox SandboxMsg model

        ( _, _ ) ->
            ( model, Cmd.none )


goTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
goTo destination model =
    case destination of
        Nothing ->
            ( model, Route.modifyUrl <| Route.Lesson "001-welcome" )

        Just (Route.Lesson slug) ->
            Lesson.Page.init model.flags slug
                |> mapPage Lesson LessonMsg model

        Just Route.Sandbox ->
            Sandbox.Page.init model.flags
                |> mapPage Sandbox SandboxMsg model


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

        Sandbox model ->
            Html.map SandboxMsg <| Sandbox.Page.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        Blank ->
            Sub.none

        Lesson page ->
            Sub.map LessonMsg <| Lesson.Page.subscriptions page

        Sandbox page ->
            Sub.map SandboxMsg <| Sandbox.Page.subscriptions page


main : Program Js.Flags Model Msg
main =
    Navigation.programWithFlags
        (Route.fromLocation >> SetRoute)
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
