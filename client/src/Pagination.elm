module Pagination exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Sequence


view :
    { next : Attribute msg, previous : Attribute msg, finish : Attribute msg }
    -> Sequence.Placement
    -> Html msg
view { previous, next, finish } placement =
    buttons <|
        case placement of
            Sequence.Alone ->
                [ leftButton (disabled True), rightButton "✔ Finish" finish ]

            Sequence.Start ->
                [ leftButton (disabled True), rightButton "→ Next" next ]

            Sequence.Surrounded ->
                [ leftButton previous, rightButton "→ Next" next ]

            Sequence.End ->
                [ leftButton previous, rightButton "✔ Finish" finish ]


leftButton : Attribute msg -> Html msg
leftButton attr =
    button
        [ class "button is-primary is-medium is-inverted"
        , title "Previous"
        , attr
        ]
        [ strong [] [ text "←" ] ]


rightButton : String -> Attribute msg -> Html msg
rightButton name attr =
    button [ class "button is-primary is-medium", attr ] [ strong [] [ text name ] ]


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
