module Editor exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as D


view : { node : String, onInput : String -> msg, value : String } -> Html msg
view options =
    Html.node options.node
        [ Html.Attributes.attribute "data-value" options.value
        , Html.Events.on "editor-change" <|
            D.map options.onInput (D.field "detail" D.string)
        ]
        []
