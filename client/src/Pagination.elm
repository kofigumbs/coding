module Pagination exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Sequence


view :
    { next : Attribute msg, previous : Attribute msg, finish : Attribute msg }
    -> Sequence.Location
    -> Html msg
view { previous, next, finish } location =
    div
        [ class "level" ]
        [ div
            [ class "level-item" ]
            [ div
                [ class "buttons" ]
                [ button
                    [ class "button is-primary is-medium is-inverted"
                    , title "Previous"
                    , disabled <| location == Sequence.Start
                    , previous
                    ]
                    [ strong [] [ text "←" ] ]
                , if location == Sequence.End then
                    a
                        [ class "button is-primary is-medium", finish ]
                        [ strong [] [ text "✔ Finish" ] ]
                  else
                    button
                        [ class "button is-primary is-medium", next ]
                        [ strong [] [ text "→ Next" ] ]
                ]
            ]
        ]
