module Navbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


view : List (Html msg) -> Html msg
view items =
    nav
        [ class "navbar" ]
        [ div [ class "navbar-brand" ] <|
            a
                [ class "navbar-item"
                , Route.href Route.Dashboard
                ]
                [ img
                    [ src "http://via.placeholder.com/32x32"
                    , alt "Logo"
                    , class "image is-32x32"
                    ]
                    []
                ]
                :: List.map viewItem items
        ]


viewItem : Html msg -> Html msg
viewItem =
    div [ class "navbar-item" ] << List.singleton
