port module Js exposing (login)

import Json.Encode as E


login : Cmd msg
login =
    outgoing <| E.object [ ( "tag", E.string "LOGIN" ) ]


port outgoing : E.Value -> Cmd msg
