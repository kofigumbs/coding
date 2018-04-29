module Lesson.Page exposing (Model, Msg, init, update, view)

import Content exposing (Content)
import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Json.Encode as E
import Lesson.Code exposing (Code)
import Lesson.Editor
import Navbar
import Pagination
import Route
import Sequence exposing (Sequence)
import Task exposing (Task)


type alias Model =
    { context : Excelsior.Context
    , slug : String
    , overlay : Maybe Overlay

    -- REMOTE
    , lesson : String
    , items : Sequence Item
    }


type Overlay
    = Summary
    | Loading
    | Runner Output


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
    = NoOp
    | EditorOpen
    | EditorClose
    | EditorInput String
    | Next
    | Previous
    | SetOverlay (Maybe Overlay)
    | Compile String
    | CompileResponse Output


type Output
    = Html String
    | Error String
    | Unknown


init : Excelsior.Context -> String -> Task Never Model
init context slug =
    Http.get (context.contentApi ++ "/lessons/" ++ slug)
        (D.map2 (Model context slug (Just Summary))
            (D.field "title" D.string)
            (D.field "items" <|
                Sequence.decoder <|
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
        NoOp ->
            pure model

        EditorOpen ->
            ( { model | items = Sequence.edit (setInteractive True) model.items }, Lesson.Editor.focus (\_ -> NoOp) )

        EditorClose ->
            pure { model | items = Sequence.edit (setInteractive False) model.items }

        EditorInput code ->
            pure { model | items = Sequence.edit (setRaw code) model.items }

        Next ->
            pure { model | items = Sequence.next model.items }

        Previous ->
            pure { model | items = Sequence.previous model.items }

        SetOverlay overlay ->
            pure { model | overlay = overlay }

        Compile code ->
            ( { model | overlay = Just Loading }, compile model.context code )

        CompileResponse output ->
            pure { model | overlay = Just <| Runner output }


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


setRaw : String -> Item -> Item
setRaw to item =
    let
        transform ({ code } as editor) =
            { editor | code = { code | raw = to } }
    in
    { item | editor = Maybe.map transform item.editor }


compile : Excelsior.Context -> String -> Cmd Msg
compile context code =
    Http.toTask
        (Http.post (context.runnerApi ++ "/compile")
            (Http.jsonBody <| E.object [ ( "elm", E.string code ) ])
            (D.oneOf
                [ D.map Html <| D.field "output" D.string
                , D.map Error <| D.field "error" D.string
                ]
            )
        )
        |> Task.onError (\_ -> Task.succeed Unknown)
        |> Task.perform CompileResponse


view : Model -> Html Msg
view model =
    div
        []
        [ Navbar.view
            [ viewContents model.lesson model.items ]
        , section
            [ class "section" ]
            [ div
                [ class "container" ]
                [ viewItem <| Sequence.current model.items ]
            ]
        , when model.overlay <|
            \overlay ->
                case overlay of
                    Summary ->
                        viewSummary model.lesson model.items

                    Loading ->
                        viewLoading

                    Runner (Html html) ->
                        viewRunnerHtml html

                    Runner (Error reason) ->
                        viewRunnerError reason

                    Runner Unknown ->
                        viewRunnerUnknown
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


viewItem : ( Sequence.Placement, Item ) -> Html Msg
viewItem ( placement, item ) =
    div
        []
        [ h1 [ class "title" ] [ text item.title ]
        , div
            [ class "columns" ]
            [ when item.editor <| viewEditor [ class "column is-sticky" ]
            , div [ class "column" ] [ Content.view item.content ]
            ]
        , Pagination.view
            { previous = onClick Previous
            , next = onClick Next
            , finish = Route.href Route.Dashboard
            }
            placement
        ]


viewEditor : List (Attribute Msg) -> Editor -> Html Msg
viewEditor layoutAttrs editor =
    if editor.interactive then
        div layoutAttrs
            [ Lesson.Editor.view EditorInput editor.code.raw
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
                [ ol [] <| Sequence.mapToList viewSummaryItem items ]
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


viewLoading : Html Msg
viewLoading =
    modalCard
        [ div
            [ class "modal-card-body has-text-centered" ]
            [ button [ class "button is-loading is-white" ] [] ]
        ]


viewRunnerHtml : String -> Html Msg
viewRunnerHtml html =
    modalCard
        [ div
            [ class "modal-card-body" ]
            [ iframe [ srcdoc html, sandbox "allow-scripts" ] [] ]
        ]


viewRunnerError : String -> Html Msg
viewRunnerError reason =
    modalCard
        [ div
            [ class "modal-card-body has-background-info" ]
            [ pre [ class "has-background-info has-text-white" ] [ text reason ] ]
        ]


viewRunnerUnknown : Html Msg
viewRunnerUnknown =
    modalCard
        [ div
            [ class "modal-card-body has-background-warning" ]
            [ strong [] [ text "Oops, we messed up somewhere along the line..." ] ]
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


when : Maybe a -> (a -> Html msg) -> Html msg
when maybe f =
    case maybe of
        Nothing ->
            text ""

        Just x ->
            f x
