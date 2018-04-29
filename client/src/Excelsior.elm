module Excelsior exposing (Context, Error(..))

import Json.Decode exposing (Value)


type Error
    = RequiresAuth


type alias Context =
    { contentApi : String
    , runnerApi : String
    , user : Value
    }
