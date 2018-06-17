module Explorer.Page exposing (Model, Msg, init, update, view)

import Char
import Global
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)


type alias Model =
    { context : Global.Context
    , code : Ast
    , results : String
    }


type alias Ast =
    { imports : List Import
    , definitions : List ( String, Expr )
    }


type Import
    = Qualified String


type Expr
    = LiteralInt Int
    | LiteralString String
    | If Expr Expr Expr
    | Binop String Expr Expr
    | VarGlobal String String
    | VarLocal String
    | Call Expr (List Expr)


init : Global.Context -> Task x Model
init context =
    Task.map (Model context demoCode)
        (compile context (toElm demoCode))


demoCode : Ast
demoCode =
    { imports = [ Qualified "Html", Qualified "Secrets" ]
    , definitions =
        [ ( "guess", LiteralInt 7 )
        , ( "main"
          , If (Binop "==" (VarLocal "guess") (VarGlobal "Secrets" "magicNumber"))
                (Call (VarGlobal "Html" "text") [ LiteralString "YOU GOT IT!" ])
                (Call (VarGlobal "Html" "text") [ LiteralString "NOT QUITE, try again..." ])
          )
        ]
    }


type Msg
    = NoOp
    | CompileResponse String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CompileResponse html ->
            ( { model | results = html }, Cmd.none )


toElm : Ast -> String
toElm code =
    String.join newline <|
        List.map fromImport code.imports
            ++ List.map fromDef code.definitions


fromImport : Import -> String
fromImport import_ =
    case import_ of
        Qualified name ->
            "import " ++ name


fromDef : ( String, Expr ) -> String
fromDef ( name, body ) =
    name ++ " =" ++ newline ++ indent ++ fromExpr body


fromExpr : Expr -> String
fromExpr expr =
    case expr of
        LiteralInt i ->
            toString i

        LiteralString s ->
            "\"" ++ s ++ "\""

        If condition true false ->
            "if " ++ fromExpr condition ++ " then " ++ fromExpr true ++ " else " ++ fromExpr false

        Binop symbol left right ->
            fromExpr left ++ " " ++ symbol ++ fromExpr right

        VarGlobal home name ->
            home ++ "." ++ name

        VarLocal name ->
            name

        Call function args ->
            fromExpr function ++ " " ++ String.join " " (List.map fromExpr args)


newline : String
newline =
    "\n"


indent : String
indent =
    " "


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
        , iframe
            [ srcdoc model.results
            , sandbox <|
                "allow-scripts"
                    ++ " allow-popups"
                    ++ " allow-popups-to-escape-sandbox"
            , style
                [ ( "width", "50%" )
                , ( "padding", "60px" )
                , ( "float", "right" )
                ]
            ]
            []
        ]


viewEditor : Ast -> Html Msg
viewEditor code =
    div
        [ background
        , style
            [ ( "font-family", "monospace" )
            , ( "overflow-wrap", "normal" )
            , ( "padding", "60px" )

            -- FILL SCREEN
            , ( "float", "left" )
            , ( "width", "50vw" )
            , ( "height", "100vh" )
            ]
        ]
    <|
        List.map viewImport code.imports
            ++ List.map viewDefinition code.definitions


viewImport : Import -> Html Msg
viewImport import_ =
    case import_ of
        Qualified name ->
            div []
                [ span [ pink ] [ text "import", space ]
                , span [ blue ] [ text name ]
                ]


viewDefinition : ( String, Expr ) -> Html Msg
viewDefinition ( name, body ) =
    div [ style [ ( "margin-top", "40px" ) ] ]
        [ div [] [ span [ white ] [ text name, space, text "=" ] ]
        , div [ indented ] [ viewExpr body ]
        ]


viewExpr : Expr -> Html Msg
viewExpr expr =
    case expr of
        LiteralInt i ->
            span [ blue ] [ text <| toString i ]

        LiteralString s ->
            span [ yellow ] [ quote, text s, quote ]

        If condition true false ->
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

        Binop symbol left right ->
            span []
                [ viewExpr left
                , span [ pink ] [ space, text symbol, space ]
                , viewExpr right
                ]

        VarGlobal home name ->
            span []
                [ span [ blue ] [ text home ]
                , span [ white ] [ text ".", text name ]
                ]

        VarLocal name ->
            span [ white ] [ text name ]

        Call function args ->
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
