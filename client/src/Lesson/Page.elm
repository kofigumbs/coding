module Lesson.Page exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Task exposing (Task)


type alias Model =
    { code : String
    }


type Msg
    = NoOp


init : String -> Task Never Model
init code =
    Task.succeed { code = code }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view { code } =
    text <| "<CHAPTER " ++ code ++ " COMING SOON...>"
