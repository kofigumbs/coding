module Excelsior exposing (Context, Error(..))

import Json.Decode exposing (Value)


type Error
    = RequiresAuth


type alias Context =
    { api : { content : String, runner : String }
    , user : { metadata : Value }
    }
