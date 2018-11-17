module Compile exposing (Diff, Result(..), State, Tick, applyToCode, await, diff, init, pushCode)

import Debounce exposing (Debounce)
import Dict exposing (Dict)
import Elm.Parser
import Elm.Processing
import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Expression as Expression
import Elm.Syntax.File exposing (File)
import Elm.Syntax.Node as Node
import Elm.Syntax.Range exposing (Range)
import Http
import Json.Decode as D
import Json.Encode as E
import Task


type State
    = State (Debounce String) String


type Result
    = Success String
    | ElmError String
    | HttpError


type alias InsertionPoints =
    Dict String Range


type alias Tick =
    Debounce.Msg


init : State
init =
    State Debounce.init ""


pushCode : (Tick -> a) -> String -> State -> ( State, Cmd a )
pushCode onTick new (State debounce _) =
    let
        ( newDebounce, debounceCmds ) =
            Debounce.push (debounceConfig onTick) new debounce
    in
    ( State newDebounce new, debounceCmds )


await :
    { runner : String
    , onOutput : Result -> a
    , onTick : Tick -> a
    }
    -> Tick
    -> State
    -> ( State, Cmd a )
await options tick ((State debounce code) as state) =
    let
        ( newDebounce, cmd ) =
            Debounce.update (debounceConfig options.onTick)
                (Debounce.takeLast (compile options.runner options.onOutput << prefixCode))
                tick
                debounce
    in
    ( State newDebounce code, cmd )


prefixCode : String -> String
prefixCode elm =
    preamble ++ elm


preamble : String
preamble =
    "module Main exposing (..)\nimport Show\n"


compile : String -> (Result -> a) -> String -> Cmd a
compile runner onOutput code =
    case parse code of
        Err reason ->
            sendRequest runner onOutput code

        Ok { declarations } ->
            sendRequest runner onOutput <|
                code
                    ++ "\n\nmain = Show.table ["
                    ++ String.join "," (List.filterMap showDeclaraion declarations)
                    ++ "]"


sendRequest : String -> (Result -> a) -> String -> Cmd a
sendRequest runner onOutput code =
    Http.post runner
        (Http.jsonBody (E.object [ ( "elm", E.string code ) ]))
        (D.oneOf
            [ D.map Success <| D.field "output" D.string
            , D.map ElmError <| D.field "error" D.string
            ]
        )
        |> Http.send (onOutput << Result.withDefault HttpError)


buildInsertionPoints : List (Node.Node Declaration) -> Dict String Range
buildInsertionPoints =
    List.filterMap getFunction
        >> List.map (\function -> ( functionName function, Node.range (Node.value function.declaration).expression ))
        >> Dict.fromList


showDeclaraion : Node.Node Declaration -> Maybe String
showDeclaraion =
    getFunction
        >> Maybe.map
            (\function ->
                let
                    name =
                        functionName function
                in
                "Show.row \"" ++ name ++ "\" " ++ name
            )


getFunction : Node.Node Declaration -> Maybe Expression.Function
getFunction target =
    case Node.value target of
        FunctionDeclaration function ->
            Just function

        _ ->
            Nothing


functionName : Expression.Function -> String
functionName { declaration } =
    Node.value (Node.value declaration).name


debounceConfig : (Tick -> a) -> Debounce.Config a
debounceConfig onTick =
    { strategy = Debounce.later 1500, transform = onTick }



-- DIFFS


type alias Diff =
    -- TODO different types: edit text, edit number, edit graph
    { name : String
    , value : String
    }


diff : D.Decoder Diff
diff =
    D.field "data" <|
        D.map2 Diff
            (D.field "name" D.string)
            (D.field "value" D.string)


applyToCode : State -> Diff -> String
applyToCode (State _ code) { name, value } =
    case parse <| prefixCode code of
        Err _ ->
            code

        Ok { declarations } ->
            Dict.get name (buildInsertionPoints declarations)
                |> Maybe.andThen (applySubstitution value code)
                |> Maybe.withDefault code


applySubstitution : String -> String -> Range -> Maybe String
applySubstitution value input range =
    let
        offset =
            List.length (String.lines preamble)

        lines =
            String.lines input

        beforeLines =
            List.take (range.start.row - offset) lines

        remainingLines =
            List.drop (range.end.row - offset) lines
    in
    case remainingLines of
        [] ->
            Nothing

        targetLine :: afterLines ->
            Just <|
                unlines beforeLines
                    ++ newline
                    ++ String.left (range.start.column - 1) targetLine
                    ++ value
                    ++ String.right (String.length targetLine - range.end.column) targetLine
                    ++ newline
                    ++ unlines afterLines


unlines : List String -> String
unlines =
    String.join newline


newline : String
newline =
    "\n"

parse : String -> Result.Result () File
parse code =
    Elm.Parser.parse code
        |> Result.mapError (\_ -> ())
        |> Result.map (Elm.Processing.process Elm.Processing.init)