module Lesson.Page exposing (Model, Msg, init, update, view)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Lesson.Code exposing (Code)
import Lesson.Sequence exposing (Sequence)
import Markdown
import Task exposing (Task)


type alias Model =
    { code : String
    , items : Sequence Item
    }


type alias Item =
    { title : String
    , content : String
    , code : Code
    }


type Msg
    = Previous
    | Next


init : String -> Task Never Model
init code =
    Http.get ("/api/lessons/" ++ code)
        (Json.Decode.map (Model code)
            (Json.Decode.field "items" <|
                Lesson.Sequence.decoder <|
                    Json.Decode.map3 Item
                        (Json.Decode.field "title" Json.Decode.string)
                        (Json.Decode.field "content" Json.Decode.string)
                        (Json.Decode.field "code" Lesson.Code.decoder)
            )
        )
        |> Http.toTask
        |> Task.onError ({- TODO -} toString >> Debug.crash)


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

            -- , Ui.border Ui.Top Ui.Light
            ]
            [ button [ class "button", onClick Previous ] [ text "Previous" ]
            , viewProgress model.items
            , button [ class "button is-primary", onClick Next ] [ text "Next" ]
            ]
        ]


viewItem : Item -> Html Msg
viewItem item =
    div
        []
        [ h1 [ class "title" ] [ text item.title ]
        , div
            [ class "columns" ]
            [ div
                [ class "column is-half" ]
                [ pre [] [ code [] <| List.map viewCode item.code.rendered ] ]
            , div
                [ class "column is-half" ]
                [ div [ class "content" ] [ markdown item.content ] ]
            ]
        ]


viewCode : Lesson.Code.Render -> Html msg
viewCode rendered =
    case rendered of
        Lesson.Code.Raw content ->
            text content

        Lesson.Code.Focus content ->
            strong [ class "has-text-info" ] [ text content ]


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
