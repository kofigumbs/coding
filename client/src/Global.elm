module Global exposing (Context, Error(..), lessonOne)

import Json.Decode exposing (Value)


type Error
    = Fatal


type alias Context =
    { runnerApi : String
    , user : Value
    }


lessonOne : { slug : String }
lessonOne =
    { slug = "001-welcome" }
