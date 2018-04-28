module Excelsior exposing (Context)

import Json.Decode exposing (Value)


type alias Context =
    { api : { content : String, runner : String }
    , user : { metadata : Value }
    }
