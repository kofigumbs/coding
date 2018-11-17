module Show exposing (row, table)

import Html exposing (..)
import Html.Attributes


type Row
    = Row String (Html Never)


row : String -> a -> Row
row name value =
    Row name <| textInput name (toString value)


table : List Row -> Html.Html Never
table rows =
    Html.table [] [ tbody [] <| List.map drawRow rows ]


drawRow : Row -> Html.Html Never
drawRow (Row name html) =
    tr [] [ td [] [ text name ], td [] [ html ] ]


textInput : String -> String -> Html a
textInput name raw =
    input
        [ Html.Attributes.value raw
        , Html.Attributes.attribute "oninput" <|
            "window.parent.postMessage("
                ++ "{ type: 'edit-text-row', name: '"
                ++ name
                ++ "', value: this.value }, '*')"
        ]
        []
