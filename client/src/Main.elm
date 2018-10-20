port module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation
import Compile
import Editor
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Http
import Json.Encode as E
import Loading
import Markdown
import Url exposing (Url)


type alias Model =
    { key : Browser.Navigation.Key
    , runner : String
    , lesson : Maybe Lesson
    , output : Maybe Compile.Result
    , compile : Compile.State
    }


type Lesson
    = Lesson String
    | Missing


type alias Flags =
    { runner : String }


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key
      , lesson = Nothing
      , output = Nothing
      , compile = Compile.init
      , runner = flags.runner
      }
    , getLesson url.fragment
    )


getLesson : Maybe String -> Cmd Msg
getLesson fragment =
    let
        fetch toMsg extension =
            Http.getString
                ("/content/"
                    ++ Maybe.withDefault defaultLesson fragment
                    ++ "."
                    ++ extension
                )
                |> Http.send
                    (Result.map toMsg >> Result.withDefault (NewLesson Missing))
    in
    Cmd.batch
        [ fetch NewCode "elm"
        , fetch (NewLesson << Lesson) "md"
        ]


type Msg
    = NewUrl Browser.UrlRequest
    | NewLesson Lesson
    | NewCode String
    | NewOutput Compile.Result
    | Resize
    | CompileTick Compile.Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl (Browser.External raw) ->
            ( model, Browser.Navigation.load raw )

        NewUrl (Browser.Internal url) ->
            ( { model | lesson = Nothing }, getLesson url.fragment )

        NewLesson lesson ->
            ( { model | lesson = Just lesson }, Cmd.none )

        NewCode value ->
            let
                ( compile, cmd ) =
                    Compile.pushCode CompileTick value model.compile
            in
            ( { model | compile = compile }, Cmd.batch [ cmd, newEditor value ] )

        NewOutput value ->
            ( { model | output = Just value }, Cmd.none )

        Resize ->
            ( model, resizeEditor )

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


newEditor : String -> Cmd msg
newEditor value =
    send "NEW_EDITOR"
        [ ( "value", E.string value )
        , ( "id", E.string codeEditorId )
        ]


resizeEditor : Cmd msg
resizeEditor =
    send "RESIZE_EDITOR" [ ( "id", E.string codeEditorId ) ]


send : String -> List ( String, E.Value ) -> Cmd msg
send tag data =
    toJs <| E.object (( "tag", E.string tag ) :: data)


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize (\_ _ -> Resize)


view : Model -> Html Msg
view model =
    case model.lesson of
        Nothing ->
            Loading.view

        Just Missing ->
            viewError

        Just (Lesson lesson) ->
            main_
                [ style "min-height" "100vh" ]
                [ halfPanel
                    [ lazy viewLesson lesson
                    , lazy viewOutput model.output
                    ]
                , halfPanel [ viewEditor model.compile ]
                ]


viewLesson : String -> Html Msg
viewLesson =
    Markdown.toHtml frameStyles


viewOutput : Maybe Compile.Result -> Html Msg
viewOutput output =
    case output of
        Nothing ->
            Loading.view

        Just Compile.HttpError ->
            viewError

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


viewError : Html msg
viewError =
    div frameStyles
        [ h1 [] [ text "Oops! Something went wrong with our site." ] ]


halfPanel : List (Html msg) -> Html msg
halfPanel =
    section
        [ style "width" "50%"
        , style "height" "100vh"
        , style "float" "left"
        ]


frameStyles : List (Attribute msg)
frameStyles =
    [ class "wysiwyg", style "padding" "1em" ]


withDocument : Html msg -> Browser.Document msg
withDocument root =
    { title = "Coding", body = [ root ] }


port toJs : E.Value -> Cmd msg


defaultLesson : String
defaultLesson =
    "hello-world"


codeEditorId : String
codeEditorId =
    "main-code-editor"


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = NewUrl << Browser.Internal
        , onUrlRequest = NewUrl
        , update = update
        , subscriptions = subscriptions
        , view = withDocument << view
        }
