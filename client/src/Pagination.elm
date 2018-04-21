module Pagination exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Sequence


view :
    { next : Attribute msg, previous : Attribute msg, finish : Attribute msg }
    -> Sequence.Location
    -> Html msg
view msgs location =
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
                    , msgs.previous
                    ]
                    [ strong [] [ text "←" ] ]
                , if location == Sequence.End then
                    a
                        [ class "button is-primary is-medium", msgs.finish ]
                        [ strong [] [ text "✔ Finish" ] ]
                  else
                    button
                        [ class "button is-primary is-medium", msgs.next ]
                        [ strong [] [ text "→ Next" ] ]
                ]
            ]
        ]
