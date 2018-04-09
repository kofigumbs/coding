module Landing.Page exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


view : Html msg
view =
    div
        [ style
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            , ( "max-width", "1080px" )
            , ( "margin", "0 auto" )
            , ( "display", "flex" )
            , ( "flex-direction", "row" )
            , ( "align-items", "center" )
            ]
        ]
        [ div
            [ style
                [ ( "flex", "1" )
                , ( "padding", "25px" )
                ]
            ]
            [ h1 [ class "title", noMargin ] [ text "A coding course" ]
            , h1 [ class "title", noMargin ] [ text "Designed for Excel users" ]
            , fakeParagraph
            , div
                []
                [ startLink
                , learnLink
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


startLink : Html msg
startLink =
    a
        [ class "button is-primary"
        , Route.href <| Route.Lesson "0000"
        ]
        [ text "Start lesson 1" ]


learnLink : Html msg
learnLink =
    a
        [ class "button"
        , Route.href Route.Pricing
        ]
        [ text "Learn more" ]


fakeParagraph : Html msg
fakeParagraph =
    p
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


noMargin : Attribute msg
noMargin =
    style [ ( "margin", "0" ) ]
