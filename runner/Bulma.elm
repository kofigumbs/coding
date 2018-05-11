module Bulma exposing (..)

import Html exposing (Attribute, Html)
import Html.Attributes exposing (class, style)


beginnerProgram :
    { model : model, update : msg -> model -> model, view : model -> Html msg }
    -> Program Never model msg
beginnerProgram program =
    Html.beginnerProgram { program | view = program.view }



-- ELEMENTS


text : String -> Html msg
text =
    Html.text


button : List (Attribute msg) -> List (Html msg) -> Html msg
button attributes =
    Html.button (class "button" :: attributes)


level : List (Html msg) -> Html msg
level =
    Html.div [ class "level" ]
        << List.map (\child -> Html.div [ class "level-item" ] [ child ])
