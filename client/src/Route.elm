module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html
import Html.Attributes
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Root
    | Dashboard
    | Pricing
    | Lesson String
    | Review String


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
        , map Dashboard <| s "dashboard"
        , map Pricing <| s "pricing"
        , map Lesson <| s "lesson" </> string
        , map Review <| s "review" </> string
        ]


modifyUrl : Route -> Cmd msg
modifyUrl =
    Navigation.modifyUrl << hash


href : Route -> Html.Attribute msg
href =
    Html.Attributes.href << hash


hash : Route -> String
hash route =
    case route of
        Root ->
            "#/"

        Dashboard ->
            "#/dashboard"

        Pricing ->
            "#/pricing"

        Lesson code ->
            "#/lesson/" ++ code

        Review code ->
            "#/review/" ++ code
