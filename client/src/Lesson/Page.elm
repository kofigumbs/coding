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
import Route
import Task exposing (Task)
import WebSocket as WS


-- TODO
--  - Add finished/next button
--  - Debounce compile messages
--  - Make some more lessons!


type alias Model =
    { slug : String
    , chunks : List Chunk
    }


type Chunk
    = Text String
    | Code String Output


type Msg
    = NoOp
    | Load
    | Edit Int String
    | Compiled Int Output
    | Finish


type Output
    = Initial
    | Html String
    | Error String
    | Unknown


init : Global.Context -> String -> Task Never Model
init context slug =
    Http.getString ("/lessons/" ++ slug ++ ".md")
        |> Http.toTask
        |> Task.map (Model slug << chunk [])
        |> Task.onError ({- TODO -} toString >> Debug.crash)


chunk : List Chunk -> String -> List Chunk
chunk chunks raw =
    case findFenced raw of
        Nothing ->
            List.reverse (Text raw :: chunks)

        Just { before, inside, after } ->
            let
                fenced =
                    Code (String.trim inside) Initial
            in
            chunk (fenced :: Text before :: chunks) after


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


update : Global.Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
    case msg of
        NoOp ->
            pure model

        Load ->
            ( model
            , Cmd.batch <|
                List.indexedMap (compileCode context) model.chunks
            )

        Edit index code ->
            editCode context index code model

        Compiled index output ->
            let
                save elm _ =
                    Code elm output
            in
            pure { model | chunks = mapCodeAt index identity save model.chunks }

        Finish ->
            ( model, Js.saveProgress model.slug )


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


editCode : Global.Context -> Int -> String -> Model -> ( Model, Cmd Msg )
editCode context target new model =
    let
        updaded =
            mapCodeAt target
                (\chunk -> ( chunk, Cmd.none ))
                (\elm output -> ( Code new output, compile context target new ))
                model.chunks
    in
    ( { model | chunks = List.map Tuple.first updaded }
    , Cmd.batch <| List.map Tuple.second updaded
    )


compile : Global.Context -> Int -> String -> Cmd Msg
compile context id code =
    E.object [ ( "id", E.int id ), ( "elm", E.string code ) ]
        |> E.encode 0
        |> WS.send context.runnerApi


mapCodeAt : Int -> (Chunk -> a) -> (String -> Output -> a) -> List Chunk -> List a
mapCodeAt target default found =
    List.indexedMap <|
        \i chunk ->
            if i /= target then
                default chunk
            else
                case chunk of
                    Text _ ->
                        default chunk

                    Code elm output ->
                        found elm output


subscriptions : Global.Context -> Model -> Sub Msg
subscriptions context model =
    WS.listen context.runnerApi <|
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
    div [] <|
        viewNavbar
            :: dummyLoad
            :: List.indexedMap viewChunk model.chunks


viewNavbar : Html msg
viewNavbar =
    nav
        [ class "navbar is-fixed-top" ]
        [ div
            [ class "navbar-brand" ]
            [ span
                [ class "navbar-item" ]
                [ img [ alt "Logo", src "%PUBLIC_URL%/logo.svg" ] [] ]
            ]
        ]


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
                    [ Lesson.Editor.view (Edit index) elm ]
                , div [ class "column is-6" ] [ viewOutput output ]
                ]


viewOutput : Output -> Html Msg
viewOutput output =
    case output of
        Initial ->
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
