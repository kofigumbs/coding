module Lesson.Sequence exposing (Sequence, current, decoder, next, previous, toList)

import Json.Decode


type Sequence a
    = Sequence { before : List a, this : a, after : List a }


decoder : Json.Decode.Decoder a -> Json.Decode.Decoder (Sequence a)
decoder item =
    Json.Decode.list item
        |> Json.Decode.andThen
            (\list ->
                case list of
                    [] ->
                        Json.Decode.fail "sequences cannot be empty"

                    first :: rest ->
                        Json.Decode.succeed <|
                            Sequence { before = [], this = first, after = rest }
            )


current : Sequence a -> a
current (Sequence { this }) =
    this


next : Sequence a -> Sequence a
next ((Sequence { before, this, after }) as input) =
    case after of
        [] ->
            input

        first :: rest ->
            Sequence { before = this :: before, this = first, after = rest }


previous : Sequence a -> Sequence a
previous ((Sequence { before, this, after }) as input) =
    case before of
        [] ->
            input

        first :: rest ->
            Sequence { before = rest, this = first, after = this :: after }


toList : (Bool -> a -> b) -> Sequence a -> List b
toList f (Sequence { before, this, after }) =
    List.map (f False) (List.reverse before)
        ++ [ f True this ]
        ++ List.map (f False) after
