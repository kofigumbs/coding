module Js.Editor exposing (new, resize, view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Js
import Json.Decode as D
import Json.Encode as E


id : String
id =
    "main-code-editor"


new : String -> Cmd msg
new value =
    Js.send "NEW_EDITOR"
        [ ( "value", E.string value )
        , ( "id", E.string id )
        ]


resize : Cmd msg
resize =
    Js.send "RESIZE_EDITOR" [ ( "id", E.string id ) ]


view : { onInput : String -> msg } -> Html msg
view options =
    Html.div
        [ Html.Attributes.id id
        , Html.Events.on "editor-change" <|
            D.map options.onInput (D.field "detail" D.string)
        ]
        []
