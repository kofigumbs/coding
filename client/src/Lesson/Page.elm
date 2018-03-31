module Lesson.Page exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Palette
import Task exposing (Task)


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
                , ( "border-top", "2px " ++ Palette.light ++ " solid" )
                ]
            ]
          <|
            List.concat
                [ [ a
                        [ class "link"
                        , style [ ( "color", Palette.primary ) ]
                        ]
                        [ text "Previous" ]
                  ]
                , List.indexedMap viewProgress model.items
                , [ a
                        [ class "link"
                        , style
                            [ ( "background-color", Palette.primary )
                            , ( "color", Palette.invert Palette.primary )
                            ]
                        ]
                        [ text "Next" ]
                  ]
                ]
        ]


viewProgress : Int -> Item -> Html Msg
viewProgress index item =
    let
        clickable =
            if False then
                [ style
                    [ ( "color", Palette.primary )
                    ]
                , onClick <| JumpTo index
                ]
            else
                [ style [ ( "color", Palette.light ) ]
                , disabled True
                ]
    in
    a
        (List.concat
            [ clickable
            , [ class "link"
              , style [ ( "margin", "0 15px" ) ]
              ]
            ]
        )
        [ text "○" ]
