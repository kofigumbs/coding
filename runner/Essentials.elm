module Essentials exposing (Row, row1, row2, row3, row4, secretNumber, table)

import Html
import Html.Attributes exposing (class)


secretNumber : Int
secretNumber =
    8


type Row
    = Row (List Cell)


type Cell
    = Cell String


table : List Row -> Html.Html Never
table rows =
    Html.table
        [ class "table is-bordered is-striped is-hoverable is-fullwidth" ]
        [ Html.tbody [] <| List.map toHtml rows ]


toHtml : Row -> Html.Html Never
toHtml (Row cells) =
    Html.tr [] <|
        List.map (\(Cell string) -> Html.td [] [ Html.text string ]) cells


row : List Cell -> Row
row =
    Row


row1 : a -> Row
row1 a =
    Row [ cell a ]


row2 : a -> b -> Row
row2 a b =
    Row [ cell a, cell b ]


row3 : a -> b -> c -> Row
row3 a b c =
    Row [ cell a, cell b, cell c ]


row4 : a -> b -> c -> d -> Row
row4 a b c d =
    Row [ cell a, cell b, cell c, cell d ]


cell : a -> Cell
cell a =
    let
        attempt =
            toString a
    in
    if String.startsWith "\"" attempt then
        String.dropLeft 1 attempt
            |> String.dropRight 1
            |> String.split "\\\""
            |> String.join "\""
            |> Cell
    else
        Cell attempt
