module Lesson.Page exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import SelectList exposing (SelectList)
import Task exposing (Task)
import Ui


type alias Model =
    { code : String
    , items : SelectList Item
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
            SelectList.fromLists
                []
                (Text "Hello, World")
                [ Text "Oh, hi there?"
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
            [{- TODO: content -}]
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
            [ Ui.link (Ui.Foreground Ui.Primary) [] "Previous"
            , viewProgress model.items
            , Ui.link (Ui.Background Ui.Primary) [] "Next"
            ]
        ]


viewProgress : SelectList a -> Html msg
viewProgress items =
    div
        [ style [ ( "margin", "0 10px" ) ] ]
        [ text <|
            toString (List.length (SelectList.before items) + 1)
                ++ " / "
                ++ toString (List.length (SelectList.toList items))
        ]
