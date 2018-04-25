module Navbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Route


view : List (Html msg) -> Html msg
view items =
    nav
        [ class "navbar" ]
        [ div [ class "navbar-brand" ] <|
            span
                [ class "navbar-item" ]
                [ img
                    [ alt "Logo"
                    , src "http://acmelogos.com/images/logo-1.svg"
                    ]
                    []
                ]
                :: List.map viewItem items
        ]


viewItem : Html msg -> Html msg
viewItem =
    div [ class "navbar-item" ] << List.singleton
