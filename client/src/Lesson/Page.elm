module Lesson.Page exposing (Model, Msg, init, update, view)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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


type Msg
    = Previous
    | Next


init : String -> Task Never Model
init code =
    Task.succeed
        { code = code
        , items =
            Lesson.Sequence.fromStart
                (Text "Hello, World")
                [ Text "Oh, hi there?"
                , Text "Bye bye."
                ]
        }


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
        Text markdown ->
            Markdown.toHtml [] markdown


viewProgress : Sequence a -> Html msg
viewProgress items =
    div
        [ style [ ( "margin", "0 10px" ) ] ]
        [ sup [] [ text <| toString <| Lesson.Sequence.countSoFar items ]
        , text <| String.fromChar <| Char.fromCode 0x2044
        , sub [] [ text <| toString <| Lesson.Sequence.countTotal items ]
        ]
