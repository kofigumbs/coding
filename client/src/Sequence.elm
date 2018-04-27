module Sequence exposing (Location(..), Sequence, current, decoder, edit, mapToList, next, previous)

import Json.Decode


type Sequence a
    = Sequence { before : List a, this : a, after : List a }


decoder : Json.Decode.Decoder a -> Json.Decode.Decoder (Sequence a)
decoder =
    Json.Decode.list
        >> Json.Decode.andThen
            (\list ->
                case list of
                    [] ->
                        Json.Decode.fail "sequences cannot be empty"

                    first :: rest ->
                        Json.Decode.succeed <|
                            Sequence { before = [], this = first, after = rest }
            )


type Location
    = Start
    | End
    | Middle


current : Sequence a -> ( Location, a )
current (Sequence { before, this, after }) =
    if List.isEmpty before then
        ( Start, this )
    else if List.isEmpty after then
        ( End, this )
    else
        ( Middle, this )


edit : (a -> a) -> Sequence a -> Sequence a
edit f (Sequence input) =
    Sequence { input | this = f input.this }


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


mapToList : (Bool -> a -> b) -> Sequence a -> List b
mapToList f (Sequence { before, this, after }) =
    List.map (f False) (List.reverse before)
        ++ [ f True this ]
        ++ List.map (f False) after
