module Lesson.Page exposing (Model, Msg, init, update, view)

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
    { slug : String
    , lesson : String
    , items : Sequence Item
    }


type alias Item =
    { title : String
    , content : String
    , code : Maybe Code
    }


type Msg
    = Edit
    | Next
    | Previous


init : String -> Task Never Model
init slug =
    Http.get ("/api/lessons/" ++ slug)
        (Json.Decode.map2 (Model slug)
            (Json.Decode.field "title" Json.Decode.string)
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
        Edit ->
            ( model, Cmd.none )

        Next ->
            ( { model | items = Lesson.Sequence.next model.items }, Cmd.none )

        Previous ->
            ( { model | items = Lesson.Sequence.previous model.items }, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ nav
            [ class "navbar" ]
            [ div
                [ class "navbar-brand" ]
                [ div
                    [ class "navbar-item" ]
                    [ h1 [ class "subtitle" ] [ text "Excelsior" ] ]
                ]
            , div
                [ class "navbar-menu is-active" ]
                [ div
                    [ class "navbar-end" ]
                    [ viewContents model.lesson model.items ]
                ]
            ]
        , section
            [ class "section" ]
            [ div
                [ class "container" ]
                [ viewItem <| Lesson.Sequence.current model.items ]
            ]
        ]


viewContents : String -> Sequence Item -> Html Msg
viewContents lesson items =
    div
        [ class "navbar-item has-dropdown is-hoverable" ]
        [ a [ class "navbar-link" ] []
        , div [ class "navbar-dropdown is-right" ] <|
            div [ class "navbar-item" ] [ strong [] [ text lesson ] ]
                :: div [ class "navbar-divider" ] []
                :: Lesson.Sequence.toList viewContentLesson items
        ]


viewContentLesson : Bool -> Item -> Html Msg
viewContentLesson isCurrent { title } =
    div
        [ classList
            [ ( "navbar-item", True )
            , ( "has-text-info", isCurrent )
            ]
        ]
        [ text title ]


viewItem : Item -> Html Msg
viewItem item =
    div
        []
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
                            [ button
                                [ class "button", onClick Edit ]
                                [ text "✏️  Edit" ]
                            ]
                        ]
            , div
                [ class "column" ]
                [ div [ class "content" ] [ markdown item.content ] ]
            ]
        , level
            [ div
                [ class "buttons" ]
                [ button
                    [ class "button is-primary is-medium is-inverted"
                    , title "Previous"
                    , onClick Previous
                    ]
                    [ strong [] [ text "←" ] ]
                , button
                    [ class "button is-primary is-medium", onClick Next ]
                    [ strong [] [ text "→ Next" ] ]
                ]
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
