module Route exposing (Route(..), fromLocation, href)

import Html
import Html.Attributes
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Root
    | Pricing
    | Lesson String


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Root
    else
        parseHash parser location


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Root top
        , map Pricing <| s "pricing"
        , map Lesson <| s "lesson" </> string
        ]


href : Route -> Html.Attribute msg
href =
    Html.Attributes.href << hash


hash : Route -> String
hash route =
    case route of
        Root ->
            "#/"

        Pricing ->
            "#/pricing"

        Lesson code ->
            "#/lesson/" ++ code
