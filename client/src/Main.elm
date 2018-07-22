module Main exposing (..)

import Html
import Js
import Lesson.Page


type alias Model =
    { flags : Js.Flags
    , lessonPage : Lesson.Page.Model
    }


init : Js.Flags -> ( Model, Cmd Lesson.Page.Msg )
init flags =
    let
        ( lessonPage, cmds ) =
            Lesson.Page.init flags "001-welcome"
    in
    ( Model flags lessonPage, cmds )


update : Lesson.Page.Msg -> Model -> ( Model, Cmd Lesson.Page.Msg )
update msg model =
    let
        ( lessonPage, cmds ) =
            Lesson.Page.update msg model.lessonPage
    in
    ( { model | lessonPage = lessonPage }, cmds )


view : Model -> Html.Html Lesson.Page.Msg
view model =
    Lesson.Page.view model.lessonPage


subscriptions : Model -> Sub Lesson.Page.Msg
subscriptions model =
    Lesson.Page.subscriptions model.lessonPage


main : Program Js.Flags Model Lesson.Page.Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
