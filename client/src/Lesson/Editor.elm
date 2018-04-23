module Lesson.Editor exposing (focus, view)

import Dom
import Html exposing (Html, textarea)
import Html.Attributes as A
import Html.Events as E
import Task


id : String
id =
    "lesson-editor"


focus : (Result Dom.Error () -> msg) -> Cmd msg
focus toMsg =
    Dom.focus id |> Task.attempt toMsg


view : (String -> msg) -> String -> Html msg
view toMsg content =
    textarea
        [ A.id id
        , A.class "textarea block has-text-white"
        , A.style
            [ ( "font-family", "monospace" )
            , ( "font-weight", "600" )
            , ( "white-space", "pre" )
            , ( "overflow-wrap", "normal" )
            , ( "background-color", "#2c292d" )
            , ( "border-radius", "2px" )
            ]
        , A.rows <| List.length <| String.lines content
        , A.defaultValue content
        , E.onInput toMsg
        ]
        []
