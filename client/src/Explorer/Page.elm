module Explorer.Page exposing (Model, Msg, init, update, view)

import Char
import Explorer.Ast as Ast
import Global
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Markdown
import Task exposing (Task)


type alias Model =
    { context : Global.Context
    , code : Ast.Module
    , hint : Hint
    , results : String
    }


type Hint
    = NoHint
    | ImportHint Ast.Import
    | NameHint String
    | ExprHint Ast.Expr


init : Global.Context -> Task x Model
init context =
    Task.map (Model context demoCode NoHint)
        (compile context (Ast.toElm demoCode))


demoCode : Ast.Module
demoCode =
    { imports = [ Ast.Qualified "Html", Ast.Qualified "Secrets" ]
    , definitions =
        [ ( "guess", Ast.LiteralInt 7 )
        , ( "main"
          , Ast.If (Ast.Binop "==" (Ast.VarLocal "guess") (Ast.VarGlobal "Secrets" "magicNumber"))
                (Ast.Call (Ast.VarGlobal "Html" "text") [ Ast.LiteralString "YOU GOT IT!" ])
                (Ast.Call (Ast.VarGlobal "Html" "text") [ Ast.LiteralString "NOT QUITE, try again..." ])
          )
        ]
    }


type Msg
    = NoOp
    | CompileResponse String
    | SetHint Hint


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CompileResponse html ->
            ( { model | results = html }, Cmd.none )

        SetHint hint ->
            ( { model | hint = hint }, Cmd.none )


compile : Global.Context -> String -> Task x String
compile context code =
    Http.toTask
        (Http.post (context.runnerApi ++ "/compile")
            (Http.jsonBody <| E.object [ ( "elm", E.string code ) ])
            (D.field "output" D.string)
        )
        |> Task.onError ({- TODO -} toString >> Debug.crash)


view : Model -> Html Msg
view model =
    div []
        [ viewEditor model.code
        , viewHint model.hint
        , viewResults model.results
        ]


viewEditor : Ast.Module -> Html Msg
viewEditor code =
    div
        [ background
        , style
            [ ( "font-family", "monospace" )
            , ( "overflow-wrap", "normal" )
            , ( "padding", "60px" )

            -- FILL SCREEN
            , ( "width", "50vw" )
            , ( "height", "80vh" )
            ]
        ]
    <|
        List.map viewImport code.imports
            ++ List.map viewDefinition code.definitions


viewImport : Ast.Import -> Html Msg
viewImport import_ =
    div [ onClick <| SetHint <| ImportHint import_ ] <|
        case import_ of
            Ast.Qualified name ->
                [ span [ pink ] [ text "import", space ]
                , span [ blue ] [ text name ]
                ]


viewDefinition : ( String, Ast.Expr ) -> Html Msg
viewDefinition ( name, body ) =
    div [ style [ ( "margin-top", "40px" ) ] ]
        [ div [] [ span [ white ] [ text name, space, text "=" ] ]
        , div [ indented ] [ viewExpr body ]
        ]


viewExpr : Ast.Expr -> Html Msg
viewExpr expr =
    case expr of
        Ast.LiteralInt i ->
            span [ blue ] [ text <| toString i ]

        Ast.LiteralString s ->
            span [ yellow ] [ quote, text s, quote ]

        Ast.If condition true false ->
            div []
                [ div []
                    [ span [ pink ] [ text "if", space ]
                    , viewExpr condition
                    , span [ pink ] [ space, text "then" ]
                    ]
                , div [ indented ] [ viewExpr true ]
                , div [ pink ] [ text "else" ]
                , div [ indented ] [ viewExpr false ]
                ]

        Ast.Binop symbol left right ->
            span []
                [ viewExpr left
                , span [ pink ] [ space, text symbol, space ]
                , viewExpr right
                ]

        Ast.VarGlobal home name ->
            span []
                [ span [ blue ] [ text home ]
                , span [ white ] [ text ".", text name ]
                ]

        Ast.VarLocal name ->
            span [ white ] [ text name ]

        Ast.Call function args ->
            viewExpr function
                :: List.map viewExpr args
                |> List.intersperse space
                |> span []


quote : Html msg
quote =
    text "\""


space : Html msg
space =
    text " "


indented : Attribute indented
indented =
    style [ ( "margin-left", "40px" ) ]


viewHint : Hint -> Html Msg
viewHint hint =
    div
        [ backgroundLight
        , style
            [ ( "width", "50%" )
            , ( "height", "20vh" )
            , ( "padding", "30px" )
            ]
        ]
        [ case hint of
            NoHint ->
                text ""

            ImportHint (Ast.Qualified name) ->
                Markdown.toHtml [] <|
                    String.join "\n"
                        [ "The `import` keyword lets you reference code from other files."
                        , "In this example, `" ++ name ++ "` is somewhere in another Elm file."
                        , "`import` lets us **split our code up into separate files** but reference them together when we need to."
                        ]

            NameHint _ ->
                text "TODO: __VALUE__"

            ExprHint _ ->
                text "TODO: __EXPRESSION__"
        ]


viewResults : String -> Html msg
viewResults html =
    iframe
        [ srcdoc html
        , sandbox <|
            "allow-scripts"
                ++ " allow-popups"
                ++ " allow-popups-to-escape-sandbox"
        , style
            [ ( "padding", "60px" )

            -- MOVE RIGHT
            , ( "position", "absolute" )
            , ( "top", "0" )
            , ( "right", "0" )
            , ( "width", "50%" )
            ]
        ]
        []



-- MONOKAI COLORS


pink : Attribute msg
pink =
    style [ ( "color", "#ff6188" ) ]


green : Attribute msg
green =
    style [ ( "color", "#a9dc76" ) ]


yellow : Attribute msg
yellow =
    style [ ( "color", "#ffd866" ) ]


orange : Attribute msg
orange =
    style [ ( "color", "#fc9867o" ) ]


purple : Attribute msg
purple =
    style [ ( "color", "#ab9df2" ) ]


blue : Attribute msg
blue =
    style [ ( "color", "#78dce8" ) ]


white : Attribute msg
white =
    style [ ( "color", "#ffffff" ) ]


background : Attribute msg
background =
    style [ ( "background-color", "#2c292d" ) ]


backgroundLight : Attribute msg
backgroundLight =
    style [ ( "background-color", "#fafafa" ) ]
