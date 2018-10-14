port module Main exposing (main)

import Browser
import Browser.Events
import Editor
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as E


type alias Model =
    { editorValue : String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { editorValue = defaultEditorValue
      }
    , send "NEW_EDITOR"
        [ ( "id", E.string codeEditorId )
        , ( "value", E.string defaultEditorValue )
        ]
    )


defaultEditorValue : String
defaultEditorValue =
    "main =\n    text \"Hello, World!\"\n"


type Msg
    = NewCode String
    | Resize


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewCode value ->
            ( { model | editorValue = value }, Cmd.none )

        Resize ->
            ( model, send "RESIZE_EDITORS" [ ( "id", E.string codeEditorId ) ] )


send : String -> List ( String, E.Value ) -> Cmd msg
send tag data =
    toJs <| E.object (( "tag", E.string tag ) :: data)


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize (\_ _ -> Resize)


view : Model -> Html Msg
view model =
    main_
        [ style "min-height" "100vh" ]
        [ halfPanel [ viewLessonOutput model ]
        , halfPanel [ viewEditor model ]
        ]


viewEditor : Model -> Html Msg
viewEditor model =
    Editor.view { id = codeEditorId, onInput = NewCode }


viewLessonOutput : Model -> Html Msg
viewLessonOutput model =
    div [ class "wysiwyg", style "padding" "0 1em" ]
        [ p [] [ text "Output" ]
        ]


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = "Coding", body = [ view model ] }


halfPanel : List (Html msg) -> Html msg
halfPanel =
    section
        [ style "width" "50%"
        , style "height" "100vh"
        , style "float" "left"
        ]


codeEditorId : String
codeEditorId =
    "main-code-editor"


port toJs : E.Value -> Cmd msg


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = viewDocument
        }
