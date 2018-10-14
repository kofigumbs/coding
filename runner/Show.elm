module Show exposing (row, table)

import Html exposing (..)
import Native.Show


type Row
    = Row String (Html Never)


row : String -> a -> Row
row name value =
    Row name <| Native.Show.anything value


table : List Row -> Html.Html Never
table rows =
    Html.table
        []
        [ thead []
            [ tr []
                [ th [] [ text "Name" ]
                , th [] [ text "Value" ]
                ]
            ]
        , tbody [] <| List.map drawRow rows
        ]


drawRow : Row -> Html.Html Never
drawRow (Row name html) =
    tr [] [ td [] [ text name ], td [] [ html ] ]
