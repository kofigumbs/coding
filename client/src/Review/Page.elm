module Review.Page exposing (Model, Msg, init, update, view)

import Content exposing (Content)
import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Pagination
import Route
import Sequence exposing (Sequence)
import Task exposing (Task)


json : String
json =
    """{
        "questions": [
            {
                "content": "# Which of these is _NOT_ a String?",
                "options": [
                    {
                        "answer": "`\\"5\\"`",
                        "correct": false,
                        "explanation": "Anything in quotes is a String. Yes, 5 is a number, but once we put it in quotes, Elm treats it like any other quoted text."
                    },
                    {
                        "answer": "`5`",
                        "correct": true,
                        "explanation": "`5` is a number, not a String.\\n\\n---\\n\\n> ⭐️ **Try** clicking the other options to see more explanations."
                    },
                    {
                        "answer": "`toString 5`",
                        "correct": false,
                        "explanation": "`toString` is a function that **turns its input into a String**. So when we write `toString 5`, we now have a String to use elsewhere."
                    }
                ]
            },
            {
                "content": "# Elm needs `main` to be a \\\\_\\\\_\\\\_\\\\_\\\\_\\\\_ in order to show something on the screen.",
                "options": [
                    {
                        "answer": "Html",
                        "correct": true,
                        "explanation": "At the end of the day, Html is the language of the web. Elm generates Html for us."
                    },
                    {
                        "answer": "String",
                        "correct": false,
                        "explanation": "_Hint:_ we used `Html.text` to turn a String into a \\\\_\\\\_\\\\_\\\\_\\\\_\\\\_."
                    },
                    {
                        "answer": "number",
                        "correct": false,
                        "explanation": "_Hint:_ we used `Html.text` to turn a String into a \\\\_\\\\_\\\\_\\\\_\\\\_\\\\_."
                    }
                ]
            },
            {
                "content": "# What text will appear on the screen when this code runs?\\n\\n```\\nimport Html\\n\\nhello = \\"Hello\\"\\naGreeting = hello\\nmain = Html.text aGreeting\\n```",
                "options": [
                    {
                        "answer": "a Greeting",
                        "correct": false,
                        "explanation": "`aGreeting` is **a variable**. Variables have contents and can be referenced. Elm doesn't show a variable name, but rather the **contents of the variable**."
                    },
                    {
                        "answer": "Hello",
                        "correct": true,
                        "explanation": ""
                    },
                    {
                        "answer": "hello",
                        "correct": false,
                        "explanation": "`hello` is **a variable**. Variables have contents and can be referenced. Elm doesn't show a variable name, but rather the **contents of the variable**."
                    }
                ]
            }
        ]
    }"""


type alias Model =
    { selected : Maybe Option
    , questions : Sequence Question
    }


type alias Question =
    { content : Content
    , options : List Option
    }


type alias Option =
    { answer : Content
    , explanation : Content
    , correct : Bool
    }


type Msg
    = Next
    | Previous
    | Select Option


init : Excelsior.Context -> String -> Task Never Model
init context slug =
    case D.decodeString (D.field "questions" <| Sequence.decoder question) json of
        Ok questions ->
            Task.succeed (Model Nothing questions)

        Err reason ->
            Debug.crash reason


question : D.Decoder Question
question =
    D.map2 Question
        (D.field "content" Content.decoder)
        (D.field "options" <|
            D.list <|
                D.map3 Option
                    (D.field "answer" Content.decoder)
                    (D.field "explanation" Content.decoder)
                    (D.field "correct" D.bool)
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Next ->
            ( { model
                | questions = Sequence.next model.questions
                , selected = Nothing
              }
            , Cmd.none
            )

        Previous ->
            ( { model
                | questions = Sequence.previous model.questions
                , selected = Nothing
              }
            , Cmd.none
            )

        Select option ->
            ( { model | selected = Just option }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        ( location, { content, options } ) =
            Sequence.current model.questions
    in
    div
        [ class "section" ]
        [ div
            [ class "container" ]
            [ Content.view content
            , div
                [ class "columns" ]
                [ div [ class "column" ] <|
                    List.map (viewOption model.selected) options
                , div [ class "column" ] [ viewSelected model.selected ]
                ]
            , Pagination.view
                { previous = onClick Previous
                , finish = whenCorrect model <| Route.href Route.Dashboard
                , next = whenCorrect model <| onClick Next
                }
                location
            ]
        ]


viewOption : Maybe Option -> Option -> Html Msg
viewOption selected current =
    div
        [ class "notification"
        , style [ ( "cursor", "pointer" ) ]
        , selectedColor selected current
        , onClick <| Select current
        ]
        [ Content.view current.answer ]


viewSelected : Maybe Option -> Html Msg
viewSelected maybeOption =
    case maybeOption of
        Nothing ->
            text ""

        Just { explanation, correct } ->
            div
                []
                [ h2
                    [ class "subtitle is-2" ]
                    [ if correct then
                        text "🎉 Nice!"
                      else
                        text "\x1F914 Not quite..."
                    ]
                , Content.view explanation
                ]


selectedColor : Maybe Option -> Option -> Attribute msg
selectedColor maybeSelected current =
    case maybeSelected of
        Nothing ->
            class ""

        Just selected ->
            if selected == current && current.correct then
                class "is-info"
            else if selected == current then
                class "is-warning"
            else
                class ""


whenCorrect : Model -> Attribute msg -> Attribute msg
whenCorrect model attr =
    if Maybe.map .correct model.selected == Just True then
        attr
    else
        attribute "disabled" ""
