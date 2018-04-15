module Landing.Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


view : Html msg
view =
    div
        [ class "hero is-fullheight" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "columns is-centered" ]
                [ div
                    [ class "column is-half" ]
                    [ title
                    , fakeParagraph
                    , div [ class "buttons" ] [ startLink, learnLink ]
                    ]
                ]
            ]
        ]


title : Html msg
title =
    h1 [ class "title" ] [ text "Know Excel? Learn coding 🎉" ]


startLink : Html msg
startLink =
    a
        [ class "button is-primary is-large"
        , Route.href <| Route.Lesson "text-numbers-functions"
        ]
        [ text "Start now" ]


learnLink : Html msg
learnLink =
    a
        [ class "button is-primary is-large is-inverted"
        , Route.href Route.Pricing
        ]
        [ text "Learn more" ]


fakeParagraph : Html msg
fakeParagraph =
    h4
        [ class "subtitle" ]
        [ text """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
        nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
        reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
        pariatur.
        """ ]
