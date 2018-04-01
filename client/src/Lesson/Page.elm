module Lesson.Page exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Task exposing (Task)
import Ui


type alias Model =
    { code : String
    , items : List Item
    }


type Item
    = Text String


type Msg
    = JumpTo Int


init : String -> Task Never Model
init code =
    Task.succeed
        { code = code
        , items =
            [ Text "Hello, World"
            , Text "Oh, hi there?"
            , Text "Bye bye."
            ]
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


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
            [ style [ ( "flex", "1" ) ]
            ]
            []
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
          <|
            List.concat
                [ [ Ui.link (Ui.Foreground Ui.Primary) [] "Previous" ]
                , List.indexedMap viewProgress model.items
                , [ Ui.link (Ui.Background Ui.Primary) [] "Next" ]
                ]
        ]


viewProgress : Int -> Item -> Html Msg
viewProgress index item =
    if True {- CLICKABLE -} then
        Ui.link (Ui.Foreground Ui.Primary) [ onClick <| JumpTo index ] "○"
    else
        Ui.link (Ui.Foreground Ui.Light) [ disabled True ] "○"
