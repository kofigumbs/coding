module Editor exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as D


view : { id : String, onInput : String -> msg } -> Html msg
view options =
    Html.div
        [ Html.Attributes.id options.id
        , Html.Events.on "editor-change" <|
            D.map options.onInput (D.field "detail" D.string)
        ]
        []
