module Compile exposing (State, Tick, await, latestCode, pushCode, start)

import Debounce exposing (Debounce)
import Elm.Parser
import Elm.Processing
import Elm.Syntax.Declaration exposing (Declaration(..))
import Elm.Syntax.Node as Node
import Http
import Json.Decode as D
import Json.Encode as E
import Task


type State
    = State String (Debounce String)


type alias Tick =
    Debounce.Msg


start : (Tick -> a) -> String -> ( State, Cmd a )
start onTick initialCode =
    let
        ( debounce, cmds ) =
            Debounce.push (debounceConfig onTick) initialCode Debounce.init
    in
    ( State initialCode debounce, cmds )


latestCode : State -> String
latestCode (State code _) =
    code


pushCode : (Tick -> a) -> String -> State -> ( State, Cmd a )
pushCode onTick new (State _ debounce) =
    let
        ( newDebounce, debounceCmds ) =
            Debounce.push (debounceConfig onTick) new debounce
    in
    ( State new newDebounce, debounceCmds )


await : { runner : String, onOutput : String -> a, onTick : Tick -> a } -> Tick -> State -> ( State, Cmd a )
await options tick ((State _ debounce) as state) =
    let
        ( newDebounce, cmd ) =
            Debounce.update (debounceConfig options.onTick)
                (Debounce.takeLast (compile options.runner options.onOutput << prefixCode))
                tick
                debounce
    in
    ( State (latestCode state) newDebounce, cmd )


prefixCode : String -> String
prefixCode elm =
    "module Main exposing (..)\nimport Show\n" ++ elm


compile : String -> (String -> a) -> String -> Cmd a
compile runner onOutput code =
    case
        Elm.Parser.parse code
            |> Result.map (Elm.Processing.process Elm.Processing.init)
    of
        Err reason ->
            compileRemote runner onOutput code

        Ok { declarations } ->
            compileRemote runner onOutput <|
                code
                    ++ "\n\nmain = Show.table ["
                    ++ String.join "," (List.filterMap showDeclaraion declarations)
                    ++ "]"


compileRemote : String -> (String -> a) -> String -> Cmd a
compileRemote runner onOutput code =
    Http.post runner
        (Http.jsonBody (E.object [ ( "elm", E.string code ) ]))
        (D.field "output" D.string)
        |> Http.send
            (\result ->
                case result of
                    Ok html ->
                        onOutput html

                    Err reason ->
                        Debug.log runner reason
                            |> Debug.todo ""
            )


showDeclaraion : Node.Node Declaration -> Maybe String
showDeclaraion target =
    case Node.value target of
        FunctionDeclaration { declaration } ->
            let
                name =
                    Node.value (Node.value declaration).name
            in
            Just <| "Show.row \"" ++ name ++ "\" " ++ name

        _ ->
            Nothing


debounceConfig : (Tick -> a) -> Debounce.Config a
debounceConfig onTick =
    { strategy = Debounce.later (0.5 * 60), transform = onTick }
