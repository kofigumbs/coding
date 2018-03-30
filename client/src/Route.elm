module Route exposing (Route(..), fromLocation, href)

import Html
import Html.Attributes
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = Root
    | Pricing
    | Lesson String
    | Loading Route


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Root
    else
        parseHash entirePath location


entirePath : Parser (Route -> a) a
entirePath =
    map (|>) (mainSegments </> possiblgLoadingSegment)


mainSegments : Parser (Route -> a) a
mainSegments =
    oneOf
        [ map Root top
        , map Pricing <| s "pricing"
        , map Lesson <| s "lesson" </> string
        ]


possiblgLoadingSegment : Parser ((Route -> Route) -> a) a
possiblgLoadingSegment =
    oneOf
        [ map identity top
        , map Loading <| s "loading"
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

        Loading route ->
            hash route ++ "/loading"
