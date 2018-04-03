module Ui exposing (Border(..), Color(..), Link(..), border, button)

import Html
import Html.Attributes


type Color
    = Primary
    | Light
    | Invert Color


type Link
    = Foreground Color
    | Background Color


type Border
    = Top
    | All


border : Border -> Color -> Html.Attribute msg
border config color =
    let
        name =
            case config of
                Top ->
                    "border-top"

                All ->
                    "border"
    in
    Html.Attributes.style [ ( name, "2px " ++ toCss color ++ " solid" ) ]


button : Link -> List (Html.Attribute msg) -> String -> Html.Html msg
button config userAttributes text =
    let
        allAttributes =
            case config of
                Foreground color ->
                    Html.Attributes.style
                        [ ( "color", toCss color ) ]
                        :: border All color
                        :: userAttributes

                Background color ->
                    Html.Attributes.style
                        [ ( "background-color", toCss color )
                        , ( "color", toCss (Invert color) )
                        ]
                        :: border All color
                        :: userAttributes
    in
    Html.a (Html.Attributes.class "button" :: allAttributes) [ Html.text text ]


{-| <https://color.adobe.com/explore/?q=hex%3A+21ce99>
-}
toCss : Color -> String
toCss color =
    case color of
        Primary ->
            "#21CE99"

        Light ->
            "#F0F0F0"

        Invert Primary ->
            "#FFFFFF"

        Invert Light ->
            "#333333"

        Invert (Invert c) ->
            toCss c
