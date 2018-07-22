module Sandbox.Page exposing (Model, Msg, init, subscriptions, update, view)

import Html exposing (..)
import Js


type alias Model =
    {}


init : Js.Flags -> ( Model, Cmd Msg )
init flags =
    ( {}, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update () model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    Html.text "Sandbox"
