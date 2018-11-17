module Show exposing (row, table)

import Html exposing (..)
import Html.Attributes
import Native.Show


type Row
    = Row String (Html Never)


row : String -> a -> Row
row name value =
    Row name <| Native.Show.anything value


table : List Row -> Html.Html Never
table rows =
    Html.table [] [ tbody [] <| List.map drawRow rows ]


drawRow : Row -> Html.Html Never
drawRow (Row name html) =
    tr [] [ td [] [ text name ], td [] [ html ] ]



-- HACKS, this is called from the Native module


textInput : String -> Html a
textInput s =
    input
        [ Html.Attributes.value s
        , Html.Attributes.attribute
            "oninput"
            "console.log('in iframe'); window.parent.postMessage('message', '*')"
        ]
        []
