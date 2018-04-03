module Lesson.SampleCode
    exposing
        ( Annotated(..)
        , Declaration(..)
        , Import(..)
        , SampleCode
        , decoder
        )

import Json.Decode exposing (..)


type alias SampleCode =
    { imports : List (Annotated Import)
    , declarations : List (Annotated Declaration)
    }


type Import
    = Import String (List (Annotated String))


type Declaration
    = Function String


type Annotated a
    = A { hint : Maybe String } a


decoder : Decoder SampleCode
decoder =
    map2 SampleCode
        (field "imports" <| list <| withHint import_)
        (field "declarations" <| list <| withHint declaration)


import_ : Decoder Import
import_ =
    map2 Import
        (field "module" string)
        (field "exposing" <| list <| withHint <| field "name" string)


declaration : Decoder Declaration
declaration =
    field "type" string
        |> andThen
            (\type_ ->
                case type_ of
                    "FUNCTION" ->
                        map Function <| field "value" string

                    invalid ->
                        fail <| "`" ++ invalid ++ "` is not a valid type"
            )


withHint : Decoder a -> Decoder (Annotated a)
withHint =
    map2 (\hint -> A { hint = hint }) (maybe (field "hint" string))
