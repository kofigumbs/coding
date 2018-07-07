module Essentials exposing (Row, row1, row2, row3, row4, secretNumber, table)

import Html
import Html.Attributes exposing (class)


secretNumber : Int
secretNumber =
    8


type Row
    = Row (List String)


table : List Row -> Html.Html Never
table rows =
    Html.table
        [ class "table is-bordered is-striped is-hoverable is-fullwidth" ]
        [ Html.tbody [] <| List.map toHtml rows ]


toHtml : Row -> Html.Html Never
toHtml (Row strings) =
    Html.tr [] <|
        List.map (Html.td [] << List.singleton << Html.text) strings


row1 : a -> Row
row1 a =
    Row [ toString a ]


row2 : a -> b -> Row
row2 a b =
    Row [ toString a, toString b ]


row3 : a -> b -> c -> Row
row3 a b c =
    Row [ toString a, toString b, toString c ]


row4 : a -> b -> c -> d -> Row
row4 a b c d =
    Row [ toString a, toString b, toString c, toString d ]
