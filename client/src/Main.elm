port module Main exposing (main)

import Browser
import Browser.Events
import Editor
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as E
import Loading
import Markdown


type alias Model =
    { lesson : String
    , output : Output
    , editorValue : String
    }


type Output
    = Loading
    | Html String


init : () -> ( Model, Cmd Msg )
init () =
    ( { lesson = "### Hello, World!"
      , output = Loading
      , editorValue = defaultEditorValue
      }
    , send "NEW_EDITOR" [ ( "id", E.string codeEditorId ) ]
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
        [ halfPanel [ viewLesson model.lesson, viewOutput model.output ]
        , halfPanel [ viewEditor model.editorValue ]
        ]


viewLesson : String -> Html Msg
viewLesson =
    Markdown.toHtml [ class "wysiwyg", style "padding" "1em" ]


viewOutput : Output -> Html Msg
viewOutput output =
    case output of
        Loading ->
            Loading.view

        Html raw ->
            iframe
                [ srcdoc raw
                , sandbox <|
                    "allow-scripts"
                        ++ " allow-popups"
                        ++ " allow-popups-to-escape-sandbox"
                , style "width" "100%"
                ]
                []


viewEditor : String -> Html Msg
viewEditor editorValue =
    Editor.view { id = codeEditorId, value = editorValue, onInput = NewCode }


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
