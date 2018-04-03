module Lesson.Sequence exposing (Sequence, countSoFar, countTotal, current, decoder, next, previous)

import Json.Decode


type Sequence a
    = Sequence (List a) a (List a)


decoder : Json.Decode.Decoder a -> Json.Decode.Decoder (Sequence a)
decoder item =
    Json.Decode.list item
        |> Json.Decode.andThen
            (\list ->
                case list of
                    [] ->
                        Json.Decode.fail "sequences cannot be empty"

                    first :: rest ->
                        Json.Decode.succeed <| Sequence [] first rest
            )


next : Sequence a -> Sequence a
next ((Sequence before this after) as initial) =
    case after of
        [] ->
            initial

        first :: rest ->
            Sequence (this :: before) first rest


previous : Sequence a -> Sequence a
previous ((Sequence before this after) as initial) =
    case before of
        [] ->
            initial

        first :: rest ->
            Sequence rest first (this :: after)


current : Sequence a -> a
current (Sequence _ this _) =
    this


countTotal : Sequence a -> Int
countTotal (Sequence before _ after) =
    List.length before + 1 + List.length after


countSoFar : Sequence a -> Int
countSoFar (Sequence before _ after) =
    List.length before + 1
