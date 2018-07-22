module Editor.View exposing (Msg, State, init, subscriptions, update, view)

import Debounce exposing (Debounce)
import Elm.Parser
import Elm.Processing
import Elm.Syntax.Declaration exposing (Declaration(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Js
import Json.Decode as D
import Json.Encode as E
import Time
import WebSocket as WS


type alias State =
    { id : Int
    , flags : Js.Flags
    , initialElm : String
    , output : Output
    , debounce : Debounce String
    }


type Output
    = Initial
    | Html String
    | Error String
    | Unknown


init : Js.Flags -> Int -> String -> ( State, Cmd Msg )
init flags id initialElm =
    let
        ( debounce, cmds ) =
            Debounce.push debounceConfig initialElm Debounce.init
    in
    ( { id = id
      , flags = flags
      , initialElm = initialElm
      , output = Initial
      , debounce = debounce
      }
    , cmds
    )


type Msg
    = NoOp
    | Edit String
    | Compiled Output
    | DebounceMsg Debounce.Msg


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        NoOp ->
            ( state, Cmd.none )

        DebounceMsg childMsg ->
            Debounce.update debounceConfig
                (Debounce.takeLast (prefixCode >> compile state.flags state.id))
                childMsg
                state.debounce
                |> Tuple.mapFirst (\debounce -> { state | debounce = debounce })

        Edit new ->
            Debounce.push debounceConfig new state.debounce
                |> Tuple.mapFirst (\debounce -> { state | debounce = debounce })

        Compiled output ->
            ( { state | output = output }, Cmd.none )


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later (1 * Time.second)
    , transform = DebounceMsg
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


subscriptions : State -> Sub Msg
subscriptions state =
    WS.listen state.flags.runnerApi <|
        D.decodeString
            (D.map2 (,)
                (D.field "id" D.int)
                (D.oneOf
                    [ D.map Html <| D.field "output" D.string
                    , D.map Error <| D.field "error" D.string
                    , D.succeed Unknown
                    ]
                )
                |> D.andThen
                    (\( id, output ) ->
                        if id == state.id then
                            D.succeed (Compiled output)
                        else
                            D.fail ""
                    )
            )
            >> Result.withDefault NoOp


view : State -> Html Msg
view state =
    div
        [ class "columns is-gapless"
        , style [ ( "height", "100%" ) ]
        ]
        [ div [ class "column is-6" ] [ viewEditor state.initialElm ]
        , div [ class "column is-6" ] [ viewOutput state.output ]
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
                , style
                    [ ( "width", "100%" )
                    , ( "height", "100%" )
                    ]
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


viewEditor : String -> Html Msg
viewEditor initial =
    textarea
        [ class "textarea block has-text-white"
        , style
            [ ( "font-family", "monospace" )
            , ( "white-space", "pre" )
            , ( "overflow-wrap", "normal" )
            , ( "background-color", "#2c292d" )
            , ( "border-radius", "2px" )
            , ( "height", "100%" )
            , ( "max-height", "initial" ) -- override Bulma :(
            ]
        , rows <| List.length <| String.lines initial
        , defaultValue initial
        , onInput Edit
        ]
        []
