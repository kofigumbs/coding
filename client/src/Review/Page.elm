module Review.Page exposing (Model, Msg, init, update, view)

import Content exposing (Content)
import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Pagination
import Sequence exposing (Sequence)
import Task exposing (Task)


json : String
json =
    """{
        "questions": [
            {
                "content": "Which of these is _NOT_ a String?",
                "options": [
                    {
                        "answer": "`\\"5\\"`",
                        "correct": false,
                        "explanation": "TODO: something about quotes"
                    },
                    {
                        "answer": "`5`",
                        "correct": true,
                        "explanation": "TODO: something about numbers"
                    },
                    {
                        "answer": "`(toString 5)`",
                        "correct": false,
                        "explanation": "TODO: something about functions"
                    }
                ]
            }
        ]
    }"""


type alias Model =
    { questions : Sequence Question }


type alias Question =
    { content : Content
    , options : List Option
    }


type alias Option =
    { answer : String
    , correct : Bool
    , explanation : Content
    }


type Msg
    = NoOp


init : Excelsior.Context -> String -> Task Never Model
init context slug =
    case D.decodeString (D.field "questions" <| Sequence.decoder question) json of
        Ok questions ->
            Task.succeed (Model questions)

        Err reason ->
            Debug.crash reason


question : D.Decoder Question
question =
    D.map2 Question
        (D.field "content" Content.decoder)
        (D.field "options" <|
            D.list <|
                D.map3 Option
                    (D.field "answer" D.string)
                    (D.field "correct" D.bool)
                    (D.field "explanation" Content.decoder)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        ( location, { content, options } ) =
            Sequence.current model.questions
    in
    div
        [ class "hero is-fullheight" ]
        [ div
            [ class "hero-body" ]
            [ Content.view content
            , Pagination.view
                { previous = onClick NoOp
                , next = onClick NoOp
                , finish = onClick NoOp
                }
                location
            ]
        ]
