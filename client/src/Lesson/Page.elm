module Lesson.Page exposing (Model, Msg, init, update, view)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Lesson.SampleCode exposing (SampleCode)
import Lesson.Sequence exposing (Sequence)
import Markdown
import Task exposing (Task)
import Ui


type alias Model =
    { code : String
    , items : Sequence Item
    }


type Item
    = Text String
    | SampleCode { description : String, hint : Maybe String } SampleCode


type Msg
    = Previous
    | Next


init : String -> Task Never Model
init code =
    Http.get ("/api/lessons/" ++ code)
        (Json.Decode.map (Model code)
            (Json.Decode.field "items" <|
                Lesson.Sequence.decoder <|
                    Json.Decode.andThen parseItem
                        (Json.Decode.field "type" Json.Decode.string)
            )
        )
        |> Http.toTask
        |> Task.onError ({- TODO -} toString >> Debug.crash)


parseItem : String -> Json.Decode.Decoder Item
parseItem type_ =
    case type_ of
        "TEXT" ->
            Json.Decode.map Text
                (Json.Decode.field "content" Json.Decode.string)

        "SAMPLE_CODE" ->
            Json.Decode.map2 SampleCode
                (Json.Decode.map
                    (\description ->
                        { description = description, hint = Nothing }
                    )
                    (Json.Decode.field "description" Json.Decode.string)
                )
                Lesson.SampleCode.decoder

        invalid ->
            Json.Decode.fail <| "`" ++ invalid ++ "`" ++ "is not an item type"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Previous ->
            ( { model | items = Lesson.Sequence.previous model.items }, Cmd.none )

        Next ->
            ( { model | items = Lesson.Sequence.next model.items }, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "height", "100vh" )
            , ( "width", "100vw" )
            ]
        ]
        [ div
            [ style
                [ ( "flex", "1" )
                , ( "width", "100vw" )
                , ( "max-width", "1080px" )
                , ( "padding", "25px" )
                , ( "margin", "0 auto" )
                ]
            ]
            [ viewItem <| Lesson.Sequence.current model.items ]
        , nav
            [ style
                [ ( "display", "flex" )
                , ( "flex-direction", "row" )
                , ( "align-items", "center" )
                , ( "justify-content", "center" )
                , ( "width", "100vw" )
                , ( "height", "65px" )
                ]
            , Ui.border Ui.Top Ui.Light
            ]
            [ Ui.button (Ui.Foreground Ui.Primary) [ onClick Previous ] "Previous"
            , viewProgress model.items
            , Ui.button (Ui.Background Ui.Primary) [ onClick Next ] "Next"
            ]
        ]


viewItem : Item -> Html Msg
viewItem item =
    case item of
        Text content ->
            markdown content

        SampleCode { description, hint } code ->
            div []
                [ markdown description
                , div
                    [ style [ ( "display", "flex" ) ]
                    ]
                    [ div
                        [ style [ ( "flex", "2" ) ] ]
                        [ viewSampleCode code ]
                    , div
                        [ style [ ( "flex", "1" ), ( "padding", "0 15px" ) ] ]
                        [ viewHint hint ]
                    ]
                ]


viewSampleCode : SampleCode -> Html Msg
viewSampleCode { imports, declarations } =
    Ui.code
        [ text <| toString declarations ]


viewHint : Maybe String -> Html Msg
viewHint =
    Maybe.withDefault "_Click some code to learn more!_" >> markdown


viewProgress : Sequence a -> Html msg
viewProgress items =
    div
        [ style
            [ ( "margin", "0 10px" )
            , ( "font-family", "monospace" )
            ]
        ]
        [ sup [] [ text <| toString <| Lesson.Sequence.countSoFar items ]
        , text <| String.fromChar <| Char.fromCode 0x2044
        , sub [] [ text <| toString <| Lesson.Sequence.countTotal items ]
        ]


markdown : String -> Html msg
markdown =
    Markdown.toHtml []
