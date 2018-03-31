module Pricing.Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


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
        [ text "Hello, World!"
        ]
