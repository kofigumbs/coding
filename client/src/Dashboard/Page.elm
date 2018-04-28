module Dashboard.Page exposing (Model, Msg, init, update, view)

import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Route
import Task exposing (Task)


type alias Model =
    { roadmap : List Project
    , browsing : Project
    , learningPath : Project
    , upNext : Lesson
    }


type alias Project =
    { title : String
    , slug : String
    , lessons : List Lesson
    }


type alias Lesson =
    { title : String
    , slug : String
    }


type Msg
    = Browse Project


init : Excelsior.Context -> Task Excelsior.Error Model
init context =
    getRoadmap context
        |> Task.onError ({- TODO -} toString >> Debug.crash)
        |> Task.andThen (withProgress context)


getRoadmap : Excelsior.Context -> Task Http.Error (List Project)
getRoadmap context =
    Http.get (context.api.content ++ "/dashboard")
        (D.field "projects" <|
            D.list <|
                D.map3 Project
                    (D.field "title" D.string)
                    (D.field "slug" D.string)
                    (D.field "lessons" <|
                        D.list <|
                            D.map2 Lesson
                                (D.field "title" D.string)
                                (D.field "location" D.string)
                    )
        )
        |> Http.toTask


withProgress : Excelsior.Context -> List Project -> Task Excelsior.Error Model
withProgress context roadmap =
    case
        D.decodeValue
            (D.field "project" D.string
                |> D.andThen (lookup "project" .slug roadmap)
                |> D.andThen
                    (\project ->
                        D.field "lesson" D.string
                            |> D.andThen (lookup "lesson" .slug project.lessons)
                            |> D.map (Model roadmap project project)
                    )
            )
            context.user.metadata
    of
        Ok model ->
            Task.succeed model

        Err reason ->
            Task.fail Excelsior.RequiresAuth
                |> Debug.log reason


lookup : String -> (a -> b) -> List a -> b -> D.Decoder a
lookup tag f haystack needle =
    case List.filter (f >> (==) needle) haystack of
        [ target ] ->
            D.succeed target

        _ ->
            D.fail <| "no valid " ++ tag


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Browse project ->
            ( { model | browsing = project }, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ viewProgress model.upNext model.learningPath
        , div
            [ class "section" ]
            [ div
                [ class "container" ]
                [ div
                    [ class "columns" ]
                    [ viewLesson model.upNext
                    , viewRoadmap model.browsing model.roadmap
                    ]
                ]
            ]
        ]


viewProgress : Lesson -> Project -> Html Msg
viewProgress upNext learningPath =
    div
        [ class "hero is-medium is-primary is-bold" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "container" ]
                [ h1
                    [ class "title is-1 has-text-weight-light" ]
                    [ text "You're "
                    , highlight <| viewPercentage upNext learningPath
                    , text " through the "
                    , highlight learningPath.title
                    , text " project"
                    ]
                , a
                    [ class "button is-primary is-inverted" ]
                    [ text "What are we building?" ]
                ]
            ]
        ]


viewRoadmap : Project -> List Project -> Html Msg
viewRoadmap browsing roadmap =
    div
        [ class "column is-one-third" ]
        [ aside
            [ class "menu" ]
            [ p [ class "menu-label" ] [ text "Roadmap" ]
            , ul [ class "menu-list" ] <| List.map (viewProjectItem browsing) roadmap
            ]
        ]


viewProjectItem : Project -> Project -> Html Msg
viewProjectItem browsing current =
    let
        ( active, children ) =
            if browsing == current then
                ( "is-active", ul [] <| List.map viewLessonItem current.lessons )
            else
                ( "", text "" )
    in
    li []
        [ a
            [ class active
            , onClick <| Browse current
            ]
            [ text current.title ]
        , children
        ]


viewLessonItem : Lesson -> Html Msg
viewLessonItem { title, slug } =
    li [] [ a [ Route.href <| Route.Lesson slug ] [ text title ] ]


viewLesson : Lesson -> Html Msg
viewLesson { title, slug } =
    div
        [ class "column" ]
        [ div
            [ class "box" ]
            [ div
                [ class "block" ]
                [ h2 [ class "menu-label" ] [ text "Up next" ]
                , h3 [ class "title" ] [ text title ]
                ]
            , a
                [ class "button is-primary is-medium"
                , Route.href <| Route.Lesson slug
                ]
                [ text "✔ Let's go" ]
            ]
        , div
            [ class "notification is-light" ]
            [ div
                []
                [ h2 [ class "menu-label" ] [ text "Reviews" ]
                , h3 [ class "title has-text-grey-light" ] [ text "Coming soon …" ]
                ]
            ]
        ]


viewPercentage : Lesson -> Project -> String
viewPercentage upNext learningPath =
    let
        finished =
            List.indexedMap (,) learningPath.lessons
                |> List.filter (Tuple.second >> (==) upNext)
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault 0

        total =
            List.length learningPath.lessons

        hundredth =
            toString (100 * toFloat finished / toFloat total)
    in
    String.left 2 hundredth ++ "%"


highlight : String -> Html msg
highlight content =
    strong
        [ class "has-text-weight-bold"
        , style [ ( "border-bottom", "1px solid white" ) ]
        ]
        [ text content ]
