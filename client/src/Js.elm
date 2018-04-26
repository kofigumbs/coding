port module Js exposing (scrollTop)

import Json.Encode as E


scrollTop : Cmd msg
scrollTop =
    outgoing <| E.object [ ( "tag", E.string "SCROLL_TOP" ) ]


port outgoing : E.Value -> Cmd msg
