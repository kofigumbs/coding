port module Main exposing (main)

import Browser
import Browser.Events
import Compile
import Editor
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as E
import Loading
import Markdown


type alias Model =
    { runner : String
    , lesson : String
    , output : Maybe Compile.Result
    , compile : Compile.State
    }


type alias Flags =
    { runner : String }


init : Flags -> ( Model, Cmd Msg )
init { runner } =
    let
        ( compile, cmd ) =
            Compile.start CompileTick defaultCode
    in
    ( { lesson = "### Hello, World!"
      , output = Nothing
      , compile = compile
      , runner = runner
      }
    , Cmd.batch
        [ cmd
        , send "NEW_EDITOR"
            [ ( "id", E.string codeEditorId )
            , ( "value", E.string defaultCode )
            ]
        ]
    )


defaultCode : String
defaultCode =
    "abc =\n    123\n\ngreeting =\n    \"Hello, World!\"\n"


type Msg
    = NewCode String
    | NewOutput Compile.Result
    | Resize
    | CompileTick Compile.Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewCode value ->
            Compile.pushCode CompileTick value model.compile
                |> Tuple.mapFirst (\new -> { model | compile = new })

        NewOutput value ->
            ( { model | output = Just value }, Cmd.none )

        Resize ->
            ( model, send "RESIZE_EDITORS" [ ( "id", E.string codeEditorId ) ] )

        CompileTick tick ->
            let
                options =
                    { runner = model.runner
                    , onTick = CompileTick
                    , onOutput = NewOutput
                    }
            in
            Compile.await options tick model.compile
                |> Tuple.mapFirst (\new -> { model | compile = new })


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
        , halfPanel [ viewEditor model.compile ]
        ]


viewLesson : String -> Html Msg
viewLesson =
    Markdown.toHtml [ class "wysiwyg", style "padding" "1em" ]


viewOutput : Maybe Compile.Result -> Html Msg
viewOutput output =
    case output of
        Nothing ->
            Loading.view

        Just Compile.HttpError ->
            mark [] [ text "Oops! Something went wrong with our site." ]

        Just (Compile.ElmError raw) ->
            pre
                [ style "background-color" "#EEEEEE"
                , style "border-radius" "2px"
                , style "padding" "24px"
                ]
                [ text raw ]

        Just (Compile.Html raw) ->
            iframe
                [ srcdoc raw
                , sandbox <|
                    "allow-scripts"
                        ++ " allow-popups"
                        ++ " allow-popups-to-escape-sandbox"
                , style "width" "100%"
                , style "height" "100%"
                , style "border" "none"
                ]
                []


viewEditor : Compile.State -> Html Msg
viewEditor compile =
    Editor.view { id = codeEditorId, onInput = NewCode }


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


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = viewDocument
        }
