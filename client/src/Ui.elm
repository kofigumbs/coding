module Ui exposing (Border(..), Color(..), Link(..), border, link)

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


link : Link -> List (Html.Attribute msg) -> String -> Html.Html msg
link config userAttributes text =
    let
        allAttributes =
            case config of
                Foreground color ->
                    Html.Attributes.style
                        [ ( "color", toCss color ) ]
                        :: userAttributes

                Background color ->
                    Html.Attributes.style
                        [ ( "background-color", toCss color )
                        , ( "color", toCss (Invert color) )
                        ]
                        :: userAttributes
    in
    Html.a (Html.Attributes.class "link" :: allAttributes) [ Html.text text ]


toCss : Color -> String
toCss color =
    case color of
        Primary ->
            "#21ce99"

        Light ->
            "hsl(0, 0%, 96%)"

        Invert Primary ->
            "#fff"

        Invert Light ->
            "hsl(0, 0%, 21%)"

        Invert (Invert c) ->
            toCss c
