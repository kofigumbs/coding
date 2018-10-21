port module Js exposing (send)

import Json.Encode as E


send : String -> List ( String, E.Value ) -> Cmd msg
send tag data =
    toJs <| E.object (( "tag", E.string tag ) :: data)


port toJs : E.Value -> Cmd msg
