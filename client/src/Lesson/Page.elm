module Lesson.Page exposing (Model, Msg, init, subscriptions, update, view)

import Debounce exposing (Debounce)
import Elm.Parser
import Elm.Processing
import Elm.Syntax.Declaration exposing (Declaration(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Js
import Json.Decode as D
import Json.Encode as E
import Lesson.Editor
import Markdown
import Time
import WebSocket as WS


type alias Model =
    { flags : Js.Flags
    , chunks : List Chunk
    }


type Chunk
    = Text String
    | Code Editor


type alias Editor =
    { initialElm : String
    , output : Output
    , debounce : Debounce String
    }


type Output
    = Initial
    | Html String
    | Error String
    | Unknown


init : Js.Flags -> String -> ( Model, Cmd Msg )
init flags slug =
    ( Model flags []
    , Http.getString ("/lessons/" ++ slug ++ ".md")
        |> Http.send
            (\result ->
                case result of
                    Err _ ->
                        Debug.crash {- TODO -} ""

                    Ok markdown ->
                        GetChunks markdown
            )
    )


type Msg
    = NoOp
    | GetChunks String
    | Edit Int String
    | Compiled Int Output
    | DebounceMsg Int Debounce.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            pure model

        GetChunks raw ->
            chunk [] 1 raw
                |> applyDebounces model.flags

        DebounceMsg index childMsg ->
            mapCodeAt index pure (updateDebounce model.flags index childMsg) model.chunks
                |> applyDebounces model.flags

        Edit index code ->
            editCode model.flags index code model
                |> applyDebounces model.flags

        Compiled index output ->
            pure { model | chunks = mapCodeAt index identity (setOutput output) model.chunks }


pure : a -> ( a, Cmd msg )
pure model =
    ( model, Cmd.none )


applyDebounces : Js.Flags -> List ( Chunk, Cmd Msg ) -> ( Model, Cmd Msg )
applyDebounces flags chunkedCmds =
    ( Model flags <| List.map Tuple.first chunkedCmds
    , Cmd.batch <| List.map Tuple.second chunkedCmds
    )


updateDebounce : Js.Flags -> Int -> Debounce.Msg -> Editor -> ( Chunk, Cmd Msg )
updateDebounce flags index msg editor =
    Debounce.update
        (debounceConfig index)
        (Debounce.takeLast (prefixCode >> compile flags index))
        msg
        editor.debounce
        |> Tuple.mapFirst (\debounce -> Code { editor | debounce = debounce })


chunk : List ( Chunk, Cmd Msg ) -> Int -> String -> List ( Chunk, Cmd Msg )
chunk chunks index raw =
    case findFenced raw of
        Nothing ->
            List.reverse (pure (Text raw) :: chunks)

        Just { before, inside, after } ->
            let
                code =
                    Debounce.init
                        |> Debounce.push (debounceConfig index) inside
                        |> Tuple.mapFirst (Code << Editor inside Initial)
            in
            chunk (code :: pure (Text before) :: chunks) (index + 2) after


findFenced : String -> Maybe { before : String, inside : String, after : String }
findFenced input =
    case String.indexes "\n```elm\n" input of
        [] ->
            Nothing

        start :: _ ->
            case
                String.indexes "\n```\n" input
                    |> List.filter (\x -> x > start)
            of
                [] ->
                    Nothing

                end :: _ ->
                    let
                        leftStart =
                            start + 8

                        rightEnd =
                            String.length input - 5 - end
                    in
                    Just
                        { before = String.left start input
                        , inside = String.slice leftStart end input
                        , after = String.right rightEnd input
                        }


editCode : Js.Flags -> Int -> String -> Model -> List ( Chunk, Cmd Msg )
editCode flags target new model =
    let
        pushDebounce editor =
            Debounce.push (debounceConfig target) new editor.debounce
                |> Tuple.mapFirst (\debounce -> Code { editor | debounce = debounce })
    in
    mapCodeAt target pure pushDebounce model.chunks


debounceConfig : Int -> Debounce.Config Msg
debounceConfig index =
    { strategy = Debounce.later (1 * Time.second)
    , transform = DebounceMsg index
    }


compile : Js.Flags -> Int -> String -> Cmd Msg
compile flags id code =
    case
        Elm.Parser.parse code
            |> Result.map (Elm.Processing.process Elm.Processing.init)
    of
        Err reason ->
            let
                _ =
                    Debug.log "ELM SYNTAX ERROR" reason
            in
            compileRemote flags id code

        Ok { declarations } ->
            compileRemote flags id <|
                code
                    ++ "\n\nmain = HiddenContent.drawTable ["
                    ++ String.join "," (List.filterMap showDeclaraion declarations)
                    ++ "]"


showDeclaraion : ( range, Declaration ) -> Maybe String
showDeclaraion ( _, declaration ) =
    case declaration of
        FuncDecl { declaration } ->
            Just <|
                "[\""
                    ++ declaration.name.value
                    ++ "\", Basics.toString "
                    ++ declaration.name.value
                    ++ "]"

        _ ->
            Nothing


compileRemote : Js.Flags -> Int -> String -> Cmd Msg
compileRemote flags id code =
    E.object [ ( "id", E.int id ), ( "elm", E.string code ) ]
        |> E.encode 0
        |> WS.send flags.runnerApi


prefixCode : String -> String
prefixCode elm =
    "module Main exposing (..)\nimport HiddenContent\n" ++ elm


mapCodeAt : Int -> (Chunk -> a) -> (Editor -> a) -> List Chunk -> List a
mapCodeAt target default found =
    List.indexedMap <|
        \i chunk ->
            if i /= target then
                default chunk
            else
                case chunk of
                    Text _ ->
                        default chunk

                    Code editor ->
                        found editor


setOutput : Output -> Editor -> Chunk
setOutput output editor =
    Code { editor | output = output }


subscriptions : Model -> Sub Msg
subscriptions model =
    WS.listen model.flags.runnerApi <|
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
    div [] <| List.indexedMap viewChunk model.chunks


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

        Code { initialElm, output } ->
            div
                [ class "columns is-gapless" ]
                [ div
                    [ class "column is-6" ]
                    [ Lesson.Editor.view (Edit index) initialElm ]
                , div
                    [ class "column is-6" ]
                    [ viewOutput output ]
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
