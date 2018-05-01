module Dashboard.Page exposing (Model, Msg, init, update, view)

import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D
import Route
import Set exposing (Set)
import Task exposing (Task)


type alias Model =
    { roadmap : List Project
    , browsing : Project
    , learningPath : Project
    , progress : Set String
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
        |> Task.mapError ({- TODO -} toString >> Debug.crash)
        |> Task.andThen (withProgress context)


getRoadmap : Excelsior.Context -> Task Http.Error (List Project)
getRoadmap context =
    Http.get (context.contentApi ++ "/dashboard")
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
            (D.list D.string |> D.andThen (Set.fromList >> resolve roadmap))
            context.user
    of
        Ok model ->
            Task.succeed model

        Err reason ->
            Debug.crash {- TODO -} ""


resolve : List Project -> Set String -> D.Decoder Model
resolve roadmap progress =
    case ( roadmap, findNext roadmap progress ) of
        ( project :: _, Nothing ) ->
            D.succeed <|
                Model roadmap project project progress Excelsior.lessonOne

        ( _, Just ( project, lesson ) ) ->
            D.succeed <|
                Model roadmap project project progress lesson

        ( [], Nothing ) ->
            D.fail "bad project/lesson configuration"


findNext : List Project -> Set String -> Maybe ( Project, Lesson )
findNext projects progress =
    case projects of
        [] ->
            Nothing

        first :: rest ->
            case
                List.filter
                    (\{ slug } -> not <| Set.member slug progress)
                    first.lessons
                    |> List.head
            of
                Nothing ->
                    findNext rest progress

                Just lesson ->
                    Just ( first, lesson )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Browse project ->
            ( { model | browsing = project }, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ viewProgress model.learningPath model.progress
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


viewProgress : Project -> Set String -> Html Msg
viewProgress learningPath progress =
    div
        [ class "hero is-medium is-primary is-bold" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "container" ]
                [ h1
                    [ class "title is-1 has-text-weight-light" ]
                    [ text "You're "
                    , highlight <| viewPercentage learningPath progress
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
            [ p [ class "menu-label" ] [ text "Projects" ]
            , ul [ class "menu-list" ] <| List.indexedMap (viewProjectItem browsing) roadmap
            ]
        ]


viewProjectItem : Project -> Int -> Project -> Html Msg
viewProjectItem browsing index current =
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
            [ strong [] [ text <| toString (index + 1) ++ ". " ]
            , text current.title
            ]
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


viewPercentage : Project -> Set String -> String
viewPercentage learningPath progress =
    let
        finished =
            learningPath.lessons
                |> List.filter (\{ slug } -> Set.member slug progress)
                |> List.length

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
