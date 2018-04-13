module Lesson.Sequence exposing (Sequence, current, decoder, select, toList)

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


select : a -> Sequence a -> Sequence a
select target ((Sequence { before, this, after }) as input) =
    selectHelp target [] (before ++ [ this ] ++ after)
        |> Maybe.withDefault input


selectHelp : a -> List a -> List a -> Maybe (Sequence a)
selectHelp target visited remaining =
    case remaining of
        [] ->
            Nothing

        next :: rest ->
            if next == target then
                Just <|
                    Sequence
                        { before = List.reverse visited
                        , this = next
                        , after = rest
                        }
            else
                selectHelp target (next :: visited) rest


toList : (Bool -> a -> b) -> Sequence a -> List b
toList f (Sequence { before, this, after }) =
    List.map (f False) before
        ++ [ f True this ]
        ++ List.map (f False) after
