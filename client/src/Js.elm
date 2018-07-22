port module Js exposing (Flags, newUser, saveProgress)

import Json.Decode as D
import Json.Encode as E


type alias Flags =
    { runnerApi : String
    }


saveProgress : String -> Cmd msg
saveProgress lesson =
    outgoing <|
        E.object
            [ ( "tag", E.string "SAVE_PROGRESS" )
            , ( "lesson", E.string lesson )
            ]


newUser : (Maybe D.Value -> msg) -> Sub msg
newUser toMsg =
    incoming <| toMsg << getTagged "NEW_USER" (D.field "user" D.value)


getTagged : String -> D.Decoder a -> D.Value -> Maybe a
getTagged target decoder value =
    D.field "tag" D.string
        |> D.andThen
            (\tag ->
                if tag == target then
                    decoder
                else
                    D.fail ""
            )
        |> flip D.decodeValue value
        |> Result.toMaybe


port outgoing : E.Value -> Cmd msg


port incoming : (D.Value -> msg) -> Sub msg
