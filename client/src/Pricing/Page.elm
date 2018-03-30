module Pricing.Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Palette


view : Html msg
view =
    div
        [ style
            [ ( "display", "grid" )
            , ( "grid-template-areas", "info info\na b" )
            , ( "grid-template-rows", "1fr 1fr" )
            , ( "grid-template-columns", "1fr 1fr" )
            , ( "width", "100vw" )
            , ( "height", "100vh" )
            ]
        ]
        [ h1
            [ style [ ( "grid-area", "info" ) ] ]
            [ text "About Excelsior" ]
        , a
            [ class "button"
            , style
                [ ( "grid-area", "a" )
                , ( "background-color", Palette.primary )
                ]
            ]
            [ text "Option 1" ]
        , a
            [ class "button"
            , style
                [ ( "grid-area", "b" )
                ]
            ]
            [ text "Option 2" ]
        ]
