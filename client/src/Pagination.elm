module Pagination exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Sequence


view :
    { next : Attribute msg, previous : Attribute msg, finish : Attribute msg }
    -> Sequence.Context
    -> Html msg
view { previous, next, finish } context =
    buttons <|
        case context of
            Sequence.Alone ->
                [ leftButton (disabled True), right a "✔ Finish" finish ]

            Sequence.Start ->
                [ leftButton (disabled True), right button "→ Next" next ]

            Sequence.Surrounded ->
                [ leftButton previous, right button "→ Next" next ]

            Sequence.End ->
                [ leftButton previous, right a "✔ Finish" finish ]


leftButton : Attribute msg -> Html msg
leftButton attr =
    button
        [ class "button is-primary is-medium is-inverted"
        , title "Previous"
        , attr
        ]
        [ strong [] [ text "←" ] ]


right :
    (List (Attribute msg) -> List (Html msg) -> Html msg)
    -> String
    -> Attribute msg
    -> Html msg
right el name attr =
    el [ class "button is-primary is-medium", attr ] [ strong [] [ text name ] ]


buttons : List (Html msg) -> Html msg
buttons children =
    div
        [ class "level" ]
        [ div
            [ class "level-item" ]
            [ div
                [ class "buttons" ]
                children
            ]
        ]
