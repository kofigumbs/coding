module Lesson.Code exposing (Code, Render(..), decoder)

import Json.Decode exposing (..)


type alias Code =
    { raw : String, rendered : List Render }


type Render
    = Raw String
    | Focus String


decoder : Decoder Code
decoder =
    map (toCode ( "", [] )) string


toCode : ( String, List Render ) -> String -> Code
toCode ( raw, rendered ) input =
    case findBracketed { left = "[focus|", right = "|]" } input of
        Nothing ->
            Code (raw ++ input) <| List.reverse (Raw input :: rendered)

        Just found ->
            toCode
                ( raw ++ found.before ++ found.inside
                , Focus found.inside :: Raw found.before :: rendered
                )
                found.after


findBracketed :
    { left : String, right : String }
    -> String
    -> Maybe { before : String, inside : String, after : String }
findBracketed { left, right } input =
    case ( String.indexes left input, String.indexes right input ) of
        ( start :: _, end :: _ ) ->
            let
                leftStart =
                    start + String.length left

                rightEnd =
                    String.length input - String.length right - end
            in
            Just
                { before = String.left start input
                , inside = String.slice leftStart end input
                , after = String.right rightEnd input
                }

        _ ->
            Nothing
