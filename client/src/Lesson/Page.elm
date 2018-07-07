module Lesson.Page exposing (Model, Msg, init, subscriptions, update, view)

import Global
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Js
import Json.Decode as D
import Json.Encode as E
import Lesson.Editor
import Markdown
import Navbar
import Route
import Task exposing (Task)
import WebSocket as WS


-- Move string to .md files
-- Compile on input
-- Add finished/next button
-- Debounce compile messages
-- Make some more lessons!


type alias Model =
    { context : Global.Context
    , slug : String
    , chunks : List Chunk
    }


type Chunk
    = Text String
    | Code String Output


type Msg
    = NoOp
    | Load
    | Input Int String
    | Compiled Int Output
    | Finish


type Output
    = Loading
    | Html String
    | Error String
    | Unknown


init : Global.Context -> String -> Task Never Model
init context slug =
    -- Http.getString ("%PUBLIC_PATH%/lessons/" ++ slug ++ ".md")
    -- |> Http.toTask
    Task.succeed """# Guess the secret number

```elm
import Essentials exposing (table, row2, secretNumber)

guess =
  7

main =
  table
    [ row2 "Your guess" guess
    , row2 "Correct?" (secretNumber == guess)
    ]
```
    """
        |> Task.map (Model context slug << chunk [])
        |> Task.onError ({- TODO -} toString >> Debug.crash)


chunk : List Chunk -> String -> List Chunk
chunk chunks raw =
    case findFenced raw of
        Nothing ->
            List.reverse (Text raw :: chunks)

        Just { before, inside, after } ->
            chunk (Code inside Loading :: Text before :: chunks) after


findFenced : String -> Maybe { before : String, inside : String, after : String }
findFenced input =
    case ( String.indexes "```elm" input, String.indexes "```" input ) of
        ( start :: _, _ :: end :: _ ) ->
            let
                leftStart =
                    start + 6

                rightEnd =
                    String.length input - 3 - end
            in
            Just
                { before = String.left start input
                , inside = String.slice leftStart end input
                , after = String.right rightEnd input
                }

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            pure model

        Load ->
            ( model
            , Cmd.batch <|
                List.indexedMap (compileCode model.context) model.chunks
            )

        Input index code ->
            -- ( { model | overlay = Just Loading }, compile model.context code )
            pure model

        Compiled index output ->
            pure
                { model
                    | chunks =
                        List.indexedMap (loadCode index output) model.chunks
                }

        Finish ->
            ( model
            , Cmd.batch
                [ Js.saveProgress model.slug
                , Route.newUrl Route.Dashboard
                ]
            )


pure : Model -> ( Model, Cmd Msg )
pure model =
    ( model, Cmd.none )


compileCode : Global.Context -> Int -> Chunk -> Cmd Msg
compileCode context index chunk =
    case chunk of
        Text _ ->
            Cmd.none

        Code elm _ ->
            compile context index elm


loadCode : Int -> Output -> Int -> Chunk -> Chunk
loadCode target output i current =
    if i /= target then
        current
    else
        case current of
            Text _ ->
                current

            Code elm _ ->
                Code elm output


compile : Global.Context -> Int -> String -> Cmd Msg
compile context id code =
    E.object [ ( "id", E.int id ), ( "elm", E.string code ) ]
        |> E.encode 0
        |> WS.send context.runnerApi


subscriptions : Model -> Sub Msg
subscriptions model =
    WS.listen model.context.runnerApi <|
        D.decodeString
            (D.map2 Compiled
                (D.field "id" D.int)
                (D.oneOf
                    [ D.map Html <| D.field "output" D.string
                    , D.map Error <| D.field "error" D.string
                    , D.succeed Unknown
                    ]
                )
            )
            >> Result.withDefault NoOp


view : Model -> Html Msg
view model =
    div []
        (Navbar.view []
            :: dummyLoad
            :: List.indexedMap viewChunk model.chunks
        )


viewChunk : Int -> Chunk -> Html Msg
viewChunk index chunk =
    case chunk of
        Text raw ->
            section
                [ class "section" ]
                [ div
                    [ class "container" ]
                    [ div
                        [ class "column is-12 content" ]
                        [ Markdown.toHtml [] raw ]
                    ]
                ]

        Code elm output ->
            div
                [ class "columns is-gapless" ]
                [ div [ class "column is-6" ]
                    [ Lesson.Editor.view (Input index) elm ]
                , div [ class "column is-6" ] [ viewOutput output ]
                ]


viewOutput : Output -> Html Msg
viewOutput output =
    case output of
        Loading ->
            div
                [ class "has-text-centered" ]
                [ button
                    [ class "button is-loading is-white", disabled True ]
                    []
                ]

        Html raw ->
            iframe
                [ srcdoc raw
                , sandbox <|
                    "allow-scripts"
                        ++ " allow-popups"
                        ++ " allow-popups-to-escape-sandbox"
                , class "full"
                ]
                []

        Error reason ->
            div
                [ class "has-background-light" ]
                [ pre
                    [ class "has-background-info has-text-white" ]
                    [ text reason ]
                ]

        Unknown ->
            div
                [ class "has-background-warning" ]
                [ strong []
                    [ text "Oops, we messed up somewhere along the line..." ]
                ]


dummyLoad : Html Msg
dummyLoad =
    node "style" [ on "load" (D.succeed Load) ] []
