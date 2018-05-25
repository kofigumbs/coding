module Global exposing (Context, Error(..), lessonOne)

import Json.Decode exposing (Value)


type Error
    = Fatal


type alias Context =
    { contentApi : String
    , runnerApi : String
    , user : Value
    }


lessonOne : { title : String, slug : String }
lessonOne =
    { title = "Text, numbers, and functions", slug = "text-numbers-functions" }
