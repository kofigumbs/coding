module Sandbox.Page exposing (Model, Msg, init, subscriptions, update, view)

import Editor.View
import Html exposing (..)
import Html.Attributes exposing (..)
import Js


type alias Model =
    { editor : Editor.View.State
    }


init : Js.Flags -> ( Model, Cmd Msg )
init flags =
    applyEdits <| Editor.View.init flags 0 "someVariable = \"Hello, World!\""


type Msg
    = EditorMsg Editor.View.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg childMsg ->
            applyEdits <| Editor.View.update childMsg model.editor


applyEdits : ( Editor.View.State, Cmd Editor.View.Msg ) -> ( Model, Cmd Msg )
applyEdits ( editor, cmds ) =
    ( Model editor, Cmd.map EditorMsg cmds )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map EditorMsg <| Editor.View.subscriptions model.editor


view : Model -> Html Msg
view model =
    div []
        [ div
            [ class "hero" ]
            [ div
                [ class "hero-body" ]
                [ h1 [ class "title" ] [ text "Your sandbox" ]
                , h2 [ class "subtitle" ] [ text """
                    Play around as much as you want!
                    All of your changes are stored locally, on your computer.
                  """ ]
                ]
            ]
        , div
            [ style [ ( "height", "100vh" ) ] ]
            [ Html.map EditorMsg <| Editor.View.view model.editor ]
        ]
