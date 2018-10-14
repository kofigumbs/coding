module Editor exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as D


view : { id : String, value : String, onInput : String -> msg } -> Html msg
view options =
    Html.div
        [ Html.Attributes.id options.id
        , Html.Attributes.attribute "data-value" options.value
        , Html.Events.on "editor-change" <|
            D.map options.onInput (D.field "detail" D.string)
        ]
        []
