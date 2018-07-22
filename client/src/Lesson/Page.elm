module Lesson.Page exposing (Model, Msg, init, subscriptions, update, view)

import Editor.View
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Js
import Markdown


type alias Model =
    { flags : Js.Flags
    , chunks : List Chunk
    }


type Chunk
    = Text String
    | Code Editor.View.State


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
    = GetChunks String
    | EditorMsg Int Editor.View.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    applyEdits model <|
        case msg of
            GetChunks raw ->
                chunk model.flags [] 1 raw

            EditorMsg index childMsg ->
                mapCodeAt index
                    pure
                    (Tuple.mapFirst Code << Editor.View.update childMsg)
                    model.chunks


pure : a -> ( a, Cmd msg )
pure model =
    ( model, Cmd.none )


applyEdits : Model -> List ( Chunk, Cmd Editor.View.Msg ) -> ( Model, Cmd Msg )
applyEdits model chunkedCmds =
    ( { model | chunks = List.map Tuple.first chunkedCmds }
    , List.map Tuple.second chunkedCmds
        |> List.indexedMap (EditorMsg >> Cmd.map)
        |> Cmd.batch
    )


chunk :
    Js.Flags
    -> List ( Chunk, Cmd Editor.View.Msg )
    -> Int
    -> String
    -> List ( Chunk, Cmd Editor.View.Msg )
chunk flags chunks index raw =
    case findFenced raw of
        Nothing ->
            List.reverse (pure (Text raw) :: chunks)

        Just { before, inside, after } ->
            let
                code =
                    Tuple.mapFirst Code <|
                        Editor.View.init flags Editor.View.NoTracking index inside
            in
            chunk flags (code :: pure (Text before) :: chunks) (index + 2) after


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


mapCodeAt : Int -> (Chunk -> a) -> (Editor.View.State -> a) -> List Chunk -> List a
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch <| List.indexedMap chunkSubscription model.chunks


chunkSubscription : Int -> Chunk -> Sub Msg
chunkSubscription index chunk =
    case chunk of
        Text _ ->
            Sub.none

        Code editor ->
            Sub.map (EditorMsg index) (Editor.View.subscriptions editor)


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

        Code editor ->
            Html.map (EditorMsg index) (Editor.View.view editor)
