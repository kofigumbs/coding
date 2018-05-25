module Route exposing (Route(..), fromLocation, href, modifyUrl, newUrl)

import Html
import Html.Attributes
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Dashboard
    | Lesson String
    | Review String


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Nothing
    else
        parseHash parser location


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Dashboard <| s "dashboard"
        , map Lesson <| s "lesson" </> string
        , map Review <| s "review" </> string
        ]


modifyUrl : Route -> Cmd msg
modifyUrl =
    Navigation.modifyUrl << hash


newUrl : Route -> Cmd msg
newUrl =
    Navigation.newUrl << hash


href : Route -> Html.Attribute msg
href =
    Html.Attributes.href << hash


hash : Route -> String
hash route =
    case route of
        Dashboard ->
            "#/dashboard"

        Lesson code ->
            "#/lesson/" ++ code

        Review code ->
            "#/review/" ++ code
