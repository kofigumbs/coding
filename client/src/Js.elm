port module Js exposing (Flags, saveLocal)

import Json.Decode as D
import Json.Encode as E


type alias Flags =
    { runnerApi : String
    , localStorage : D.Value
    }


saveLocal : String -> E.Value -> Cmd msg
saveLocal key value =
    outgoing <|
        E.object
            [ ( "tag", E.string "SAVE_LOCAL" )
            , ( "key", E.string key )
            , ( "value", value )
            ]


port outgoing : E.Value -> Cmd msg
