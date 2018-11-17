port module Js exposing (onMessage, send)

import Json.Encode as E


send : String -> List ( String, E.Value ) -> Cmd msg
send tag data =
    toJs <| E.object (( "tag", E.string tag ) :: data)


port toJs : E.Value -> Cmd msg


port onMessage : (E.Value -> msg) -> Sub msg
