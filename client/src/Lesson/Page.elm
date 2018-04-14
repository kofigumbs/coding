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
    , overlay : Maybe Overlay

    -- REMOTE
    , lesson : String
    , items : Sequence Item
    }


type Overlay
    = Summary


type alias Item =
    { title : String
    , content : String
    , code : Maybe Code
    }


type Msg
    = Edit
    | Next
    | Previous
    | SetOverlay (Maybe Overlay)


init : String -> Task Never Model
init slug =
    Http.get ("/api/lessons/" ++ slug)
        (Json.Decode.map2 (Model slug (Just Summary))
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

        SetOverlay overlay ->
            ( { model | overlay = overlay }, Cmd.none )


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
                    [ viewContents model.lesson model.items ]
                ]
            ]
        , section
            [ class "section" ]
            [ div
                [ class "container" ]
                [ viewItem <| Lesson.Sequence.current model.items ]
            ]
        , whenJust model.overlay <|
            \_ -> viewSummary model.lesson model.items
        ]


viewContents : String -> Sequence Item -> Html Msg
viewContents lesson items =
    a
        [ class "navbar-link"
        , onClick <| SetOverlay (Just Summary)
        ]
        [ text "Table of contents" ]


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
            [ whenJust item.code <|
                \{ rendered } ->
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


viewSummary : String -> Sequence Item -> Html Msg
viewSummary lesson items =
    div
        [ class "modal is-active" ]
        [ div [ class "modal-background" ] []
        , div
            [ class "modal-card" ]
            [ div
                [ class "modal-card-head" ]
                [ p [] [ strong [] [ text lesson ] ] ]
            , div
                [ class "modal-card-body" ]
                [ div
                    [ class "content" ]
                    [ ol [] <|
                        Lesson.Sequence.mapToList
                            (\_ { title } -> li [] [ text title ])
                            items
                    ]
                ]
            , div
                [ class "modal-card-foot" ]
                [ button
                    [ class "button is-primary"
                    , onClick <| SetOverlay Nothing
                    ]
                    [ text "✔ Let's go" ]
                ]
            ]
        ]


markdown : String -> Html msg
markdown =
    Markdown.toHtml []


level : List (Html msg) -> Html msg
level =
    div [ class "level" ]
        << List.map (\child -> div [ class "level-item" ] [ child ])


whenJust : Maybe a -> (a -> Html msg) -> Html msg
whenJust maybe f =
    case maybe of
        Nothing ->
            text ""

        Just x ->
            f x
