module Main exposing (main)

import Browser
import Editor
import Element exposing (..)


type alias Model =
    { editorNode : String
    , editorValue : String
    }


type alias Flags =
    { editorNode : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { editorNode = flags.editorNode
      , editorValue = "main =\n    text \"Hello, World!\"\n"
      }
    , Cmd.none
    )


type Msg
    = NoOp
    | SetValue String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            s model

        SetValue value ->
            s { model | editorValue = value }


s : Model -> ( Model, Cmd Msg )
s model =
    ( model, Cmd.none )


view : Model -> Element Msg
view model =
    row [ width fill, height fill ]
        [ column
            [ height fill, width (fillPortion 2) ]
            [ el [ height (fillPortion 2), width fill ] (viewEditor model)
            , el [ height (fillPortion 1), width fill ] (viewHint model)
            ]
        , el [ height fill, width (fillPortion 1) ] (viewOutput model)
        ]


viewEditor : Model -> Element Msg
viewEditor model =
    html <|
        Editor.view
            { node = model.editorNode
            , onInput = SetValue
            , value = model.editorValue
            }


viewHint : Model -> Element Msg
viewHint model =
    text "Hint"


viewOutput : Model -> Element Msg
viewOutput model =
    text "Output"


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Test"
    , body = [ Element.layout [] (view model) ]
    }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = viewDocument
        , subscriptions = \_ -> Sub.none
        }
