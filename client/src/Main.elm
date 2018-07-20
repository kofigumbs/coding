module Main exposing (..)

import Global
import Html
import Lesson.Page


type alias Model =
    { context : Global.Context
    , lessonPage : Lesson.Page.Model
    }


init : Global.Context -> ( Model, Cmd Lesson.Page.Msg )
init context =
    let
        ( lessonPage, cmds ) =
            Lesson.Page.init context "001-welcome"
    in
    ( Model context lessonPage, cmds )


update : Lesson.Page.Msg -> Model -> ( Model, Cmd Lesson.Page.Msg )
update msg model =
    let
        ( lessonPage, cmds ) =
            Lesson.Page.update model.context msg model.lessonPage
    in
    ( { model | lessonPage = lessonPage }, cmds )


view : Model -> Html.Html Lesson.Page.Msg
view model =
    Lesson.Page.view model.lessonPage


subscriptions : Model -> Sub Lesson.Page.Msg
subscriptions model =
    Lesson.Page.subscriptions model.context model.lessonPage


main : Program Global.Context Model Lesson.Page.Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
