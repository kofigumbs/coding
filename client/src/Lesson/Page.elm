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
    , code : Maybe Code
    }


type Msg
    = Select Item
    | Edit


init : String -> Task Never Model
init code =
    Http.get ("/api/lessons/" ++ code)
        (Json.Decode.map (Model code)
            (Json.Decode.field "items" <|
                Lesson.Sequence.decoder <|
                    Json.Decode.map3 Item
                        (Json.Decode.field "title" Json.Decode.string)
                        (Json.Decode.field "content" Json.Decode.string)
                        (Json.Decode.maybe <| Json.Decode.field "code" Lesson.Code.decoder)
            )
        )
        |> Http.toTask
        |> Task.onError ({- TODO -} toString >> Debug.crash)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Select item ->
            ( { model | items = Lesson.Sequence.select item model.items }, Cmd.none )

        Edit ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ class "section" ]
        [ div
            [ class "container" ]
            [ div
                [ class "columns" ]
                [ div
                    [ class "column is-2" ]
                    [ div [ class "menu" ] [ viewMenu model.items ] ]
                , viewItem [ class "column" ] <| Lesson.Sequence.current model.items
                ]
            ]
        ]


viewMenu : Sequence Item -> Html Msg
viewMenu items =
    ul [ class "menu-list" ] <| Lesson.Sequence.toList viewMenuItem items


viewMenuItem : Bool -> Item -> Html Msg
viewMenuItem isCurrent item =
    li
        [ class "menu-item" ]
        [ a
            [ classList [ ( "is-active", isCurrent ) ]
            , onClick (Select item)
            ]
            [ text item.title ]
        ]


viewItem : List (Attribute Msg) -> Item -> Html Msg
viewItem layoutAttrs item =
    div layoutAttrs
        [ h1 [ class "title" ] [ text item.title ]
        , div
            [ class "columns" ]
            [ case item.code of
                Nothing ->
                    text ""

                Just { rendered } ->
                    div
                        [ class "column" ]
                        [ pre
                            [ class "block" ]
                            [ code [] <| List.map viewCode rendered ]
                        , level
                            [ button [ class "button", onClick Edit ] [ text "✏️  Edit" ] ]
                        ]
            , div
                [ class "column" ]
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


markdown : String -> Html msg
markdown =
    Markdown.toHtml []


level : List (Html msg) -> Html msg
level =
    div [ class "level" ] << List.map (\child -> div [ class "level-item" ] [ child ])
