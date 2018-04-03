module Lesson.Sequence exposing (Sequence, countSoFar, countTotal, current, fromStart, next, previous)


type Sequence a
    = Sequence (List a) a (List a)


fromStart : a -> List a -> Sequence a
fromStart =
    Sequence []


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
            Sequence before first (this :: rest)


current : Sequence a -> a
current (Sequence _ this _) =
    this


countTotal : Sequence a -> Int
countTotal (Sequence before _ after) =
    List.length before + 1 + List.length after


countSoFar : Sequence a -> Int
countSoFar (Sequence before _ after) =
    List.length before + 1
