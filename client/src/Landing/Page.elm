module Landing.Page exposing (view)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Palette
import Route


view : Html msg
view =
    div
        [ style
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            , ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "align-items", "center" )
            ]
        ]
        [ div
            [ style
                [ ( "flex", "1" )
                , ( "padding", "80px" )
                ]
            ]
            [ h1 [ style [ ( "margin", "0" ) ] ] [ text "A coding course" ]
            , h1 [ style [ ( "margin", "0" ) ] ] [ text "Designed for Excel users" ]
            , p
                []
                [ text """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
        nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
        reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
        pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa
        qui officia deserunt mollit anim id est laborum.
        """ ]
            , p
                []
                [ text """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
        nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
        reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
        pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa
        qui officia deserunt mollit anim id est laborum.
        """ ]
            , div
                [ style [ ( "padding", "10px" ) ] ]
                [ a
                    [ Route.href <| Route.Loading <| Route.Lesson "0000"
                    , class "link"
                    , style
                        [ ( "color", Palette.invert Palette.primary )
                        , ( "background-color", Palette.primary )
                        ]
                    ]
                    [ text "Start lesson 1" ]
                , a
                    [ Route.href <| Route.Loading Route.Pricing
                    , class "link"
                    , style
                        [ ( "color", Palette.primary )
                        , ( "border-color", Palette.primary )
                        ]
                    ]
                    [ text "Learn more" ]
                ]
            ]
        , object
            [ style
                [ ( "flex", "1" )
                , ( "width", "100%" )
                , ( "height", "100%" )
                , ( "max-height", "350px" )
                ]
            , attribute "data" "/hero-image.svg"
            ]
            []
        ]
