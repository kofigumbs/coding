module Explorer.Ast exposing (Expr(..), Import(..), Module, toElm)


type alias Module =
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



-- GENERATE ELM CODE


toElm : Module -> String
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
