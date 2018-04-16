module Lesson.Page exposing (Model, Msg, init, update, view)

import Content exposing (Content)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Lesson.Code exposing (Code)
import Lesson.Sequence exposing (Sequence)
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
    | RunnerLoading
    | RunnerOutput String
    | RunnerError String


type alias Item =
    { title : String
    , content : Content
    , editor : Maybe Editor
    }


type alias Editor =
    { interactive : Bool
    , code : Code
    }


type Msg
    = EditorOpen
    | EditorClose
    | EditorInput String
    | Next
    | Previous
    | SetOverlay (Maybe Overlay)
    | Compile String
    | CompileResponse (Result Http.Error String)


init : String -> Task Never Model
init slug =
    Http.get ("/api/lessons/" ++ slug)
        (D.map2 (Model slug (Just Summary))
            (D.field "title" D.string)
            (D.field "items" <|
                Lesson.Sequence.decoder <|
                    D.map3 Item
                        (D.field "title" D.string)
                        (D.field "content" Content.decoder)
                        (D.field "code" Lesson.Code.decoder
                            |> D.map (Editor False)
                            |> D.maybe
                        )
            )
        )
        |> Http.toTask
        |> Task.onError ({- TODO -} toString >> Debug.crash)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorOpen ->
            pure { model | items = Lesson.Sequence.edit (setInteractive True) model.items }

        EditorClose ->
            pure { model | items = Lesson.Sequence.edit (setInteractive False) model.items }

        EditorInput code ->
            pure { model | items = Lesson.Sequence.edit (setElm code) model.items }

        Next ->
            pure { model | items = Lesson.Sequence.next model.items }

        Previous ->
            pure { model | items = Lesson.Sequence.previous model.items }

        SetOverlay overlay ->
            pure { model | overlay = overlay }

        Compile code ->
            ( { model | overlay = Just RunnerLoading }, compile code )

        CompileResponse (Ok html) ->
            pure { model | overlay = Just <| RunnerOutput html }

        CompileResponse (Err e) ->
            pure { model | overlay = Just <| RunnerError (toString e) }


pure : Model -> ( Model, Cmd Msg )
pure model =
    ( model, Cmd.none )


setInteractive : Bool -> Item -> Item
setInteractive to item =
    let
        transform editor =
            { editor | interactive = to }
    in
    { item | editor = Maybe.map transform item.editor }


setElm : String -> Item -> Item
setElm to item =
    let
        transform ({ code } as editor) =
            { editor | code = { code | raw = to } }
    in
    { item | editor = Maybe.map transform item.editor }


compile : String -> Cmd Msg
compile code =
    Http.send CompileResponse <|
        Http.post "http://localhost:3001/compile"
            (Http.jsonBody <| E.object [ ( "elm", E.string code ) ])
            (D.field "output" D.string)


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
                [ viewItem
                    (Lesson.Sequence.atStart model.items)
                    (Lesson.Sequence.current model.items)
                ]
            ]
        , whenJust model.overlay <|
            \overlay ->
                case overlay of
                    Summary ->
                        viewSummary model.lesson model.items

                    RunnerLoading ->
                        viewRunnerLoading

                    RunnerOutput html ->
                        viewRunnerOutput html

                    RunnerError reason ->
                        viewRunnerError reason
        ]


viewContents : String -> Sequence Item -> Html Msg
viewContents lesson items =
    a
        [ class "navbar-link"
        , onClick <| SetOverlay (Just Summary)
        ]
        [ text "Overview" ]


viewContentLesson : Bool -> Item -> Html Msg
viewContentLesson isCurrent { title } =
    div
        [ classList
            [ ( "navbar-item", True )
            , ( "has-text-info", isCurrent )
            ]
        ]
        [ text title ]


viewItem : Bool -> Item -> Html Msg
viewItem atStart item =
    div
        []
        [ h1 [ class "title" ] [ text item.title ]
        , div
            [ class "columns" ]
            [ whenJust item.editor <| viewEditor [ class "column" ]
            , div [ class "column" ] [ Content.view item.content ]
            ]
        , level
            [ div
                [ class "buttons" ]
                [ button
                    [ class "button is-primary is-medium is-inverted"
                    , title "Previous"
                    , onClick Previous
                    , disabled atStart
                    ]
                    [ strong [] [ text "←" ] ]
                , button
                    [ class "button is-primary is-medium", onClick Next ]
                    [ strong [] [ text "→ Next" ] ]
                ]
            ]
        ]


viewEditor : List (Attribute Msg) -> Editor -> Html Msg
viewEditor layoutAttrs editor =
    if editor.interactive then
        div layoutAttrs
            [ textarea
                [ class "textarea block"
                , style
                    [ ( "font-family", "monospace" )
                    , ( "white-space", "pre" )
                    , ( "overflow-wrap", "normal" )
                    , ( "overflow-x", "scroll" )
                    ]
                , onInput EditorInput
                ]
                [ text editor.code.raw ]
            , level
                [ button
                    [ class "button is-danger is-inverted", onClick EditorClose ]
                    [ text "❌ Close" ]
                , button
                    [ class "button", onClick <| Compile editor.code.raw ]
                    [ text "🏃 Run" ]
                ]
            ]
    else
        div layoutAttrs
            [ pre
                [ class "block" ]
                [ code [] <| List.map viewCode editor.code.rendered ]
            , level
                [ button
                    [ class "button", onClick EditorOpen ]
                    [ text "✏️  Edit" ]
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
    modalCard
        [ div
            [ class "modal-card-head" ]
            [ p [] [ strong [] [ text lesson ] ] ]
        , div
            [ class "modal-card-body" ]
            [ div
                [ class "content" ]
                [ ol [] <| Lesson.Sequence.mapToList viewSummaryItem items ]
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


viewSummaryItem : Bool -> Item -> Html Msg
viewSummaryItem isCurrent { title } =
    li [ classList [ ( "has-text-info", isCurrent ) ] ] [ text title ]


viewRunnerLoading : Html Msg
viewRunnerLoading =
    modalCard
        [ div
            [ class "modal-card-body has-text-centered" ]
            [ button [ class "button is-loading is-white" ] [] ]
        ]


viewRunnerOutput : String -> Html Msg
viewRunnerOutput html =
    modalCard
        [ div
            [ class "modal-card-body" ]
            [ iframe [ srcdoc html, sandbox "allow-scripts" ] [] ]
        ]


viewRunnerError : String -> Html Msg
viewRunnerError reason =
    modalCard
        [ div
            [ class "modal-card-body has-background-warning" ]
            [ strong [] [ text "Oops, we messed up somewhere along the line..." ]
            , input [ type_ "hidden", value reason ] []
            ]
        ]


level : List (Html msg) -> Html msg
level =
    div [ class "level" ]
        << List.map (\child -> div [ class "level-item" ] [ child ])


modalCard : List (Html Msg) -> Html Msg
modalCard children =
    div
        [ class "modal is-active" ]
        [ div [ class "modal-background", onClick <| SetOverlay Nothing ] []
        , div [ class "modal-card" ] children
        ]


whenJust : Maybe a -> (a -> Html msg) -> Html msg
whenJust maybe f =
    case maybe of
        Nothing ->
            text ""

        Just x ->
            f x
