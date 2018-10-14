module HiddenContent exposing (drawTable, secretNumber)

import Html exposing (table, tbody, td, text, th, tr)
import Html.Attributes exposing (class)


secretNumber : Int
secretNumber =
    8


drawTable : List (List String) -> Html.Html Never
drawTable rows =
    table
        [ class "table is-bordered is-striped is-hoverable is-fullwidth" ]
        [ tbody [] <| List.map drawRow rows ]


drawRow : List String -> Html.Html Never
drawRow =
    tr []
        << List.indexedMap
            (\index cell ->
                if index == 0 then
                    th [] [ text cell ]
                else
                    td [] [ text cell ]
            )
