module Excelsior exposing (Context)


type alias Context =
    { api :
        { content : String
        , runner : String
        , user : String
        }
    }
