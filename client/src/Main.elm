port module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation
import Compile
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Http
import Js
import Js.Editor
import Loading exposing (Loading)
import Markdown
import Url exposing (Url)


type alias Model =
    { key : Browser.Navigation.Key
    , lessonId : LessonId
    , lesson : Loading Lesson
    , output : Loading Compile.Result
    , compile : Compile.State
    , runner : String
    }


type LessonId
    = LessonId String


type Lesson
    = Lesson String
    | Missing


type alias Flags =
    { runner : String }


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        lessonId =
            fromFragment url.fragment
    in
    ( { key = key
      , lessonId = lessonId
      , lesson = Loading.Loading
      , output = Loading.Loading
      , compile = Compile.init
      , runner = flags.runner
      }
    , getLesson lessonId
    )


fromFragment : Maybe String -> LessonId
fromFragment =
    LessonId << Maybe.withDefault defaultLesson


getLesson : LessonId -> Cmd Msg
getLesson (LessonId segment) =
    let
        fetch toMsg extension =
            Http.getString
                ("/content/" ++ segment ++ "." ++ extension)
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
            let
                lessonId =
                    fromFragment url.fragment
            in
            ( { model
                | lessonId = lessonId
                , lesson = Loading.Loading
                , output = Loading.Loading
              }
            , getLesson lessonId
            )

        NewLesson lesson ->
            ( { model | lesson = Loading.Done lesson }, Cmd.none )

        NewCode value ->
            let
                ( compile, cmd ) =
                    Compile.pushCode CompileTick value model.compile
            in
            ( { model | compile = compile }
            , Cmd.batch [ cmd, Js.Editor.new value ]
            )

        NewOutput value ->
            ( { model | output = Loading.Done value }, Cmd.none )

        Resize ->
            ( model, Js.Editor.resize )

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


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onResize (\_ _ -> Resize)


view : Model -> Html Msg
view model =
    case model.lesson of
        Loading.Loading ->
            Loading.view

        Loading.Done Missing ->
            viewError

        Loading.Done (Lesson lesson) ->
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
    Markdown.toHtml contentStyles


viewOutput : Loading Compile.Result -> Html Msg
viewOutput output =
    case output of
        Loading.Loading ->
            Loading.view

        Loading.Done Compile.HttpError ->
            viewError

        Loading.Done (Compile.ElmError raw) ->
            pre
                [ style "background-color" "#EEEEEE"
                , style "border-radius" "2px"
                , style "padding" "24px"
                ]
                [ text raw ]

        Loading.Done (Compile.Html raw) ->
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
    Js.Editor.view { onInput = NewCode }


viewError : Html msg
viewError =
    div contentStyles
        [ h1 [] [ text "Oops! Something went wrong with our site." ] ]


halfPanel : List (Html msg) -> Html msg
halfPanel =
    section
        [ style "width" "50%"
        , style "height" "100vh"
        , style "float" "left"
        ]


contentStyles : List (Attribute msg)
contentStyles =
    [ class "wysiwyg", style "padding" "1em" ]


withDocument : Html msg -> Browser.Document msg
withDocument root =
    { title = "Coding", body = [ root ] }


defaultLesson : String
defaultLesson =
    "hello-world"


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
