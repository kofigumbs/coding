module Pricing.Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Html msg
view =
    div
        [ class "hero is-fullheight" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "container has-text-centered" ]
                [ h1 [ class "title" ] [ text "What's the plan" ]
                , div
                    [ class "columns" ]
                    [ div
                        [ class "column" ]
                        [ div [ class "notification" ] [ text "Good" ] ]
                    , div
                        [ class "column" ]
                        [ div [ class "notification is-primary" ] [ text "Great" ] ]
                    ]
                ]
            ]
        ]
