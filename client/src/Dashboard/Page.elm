module Dashboard.Page exposing (Model, Msg, init, update, view)

import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Route
import Task exposing (Task)


type alias Model =
    { roadmap : List Project
    , project : Project
    , lesson : Lesson
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


type alias Progress =
    { project : String
    , lesson : String
    }


type alias Msg =
    ()


init : Excelsior.Context -> Task Never Model
init context =
    Task.map2 (,) (getProjects context) (getProgress context)
        |> Task.onError ({- TODO -} toString >> Debug.crash)
        |> Task.andThen fromProgress


getProjects : Excelsior.Context -> Task Http.Error (List Project)
getProjects context =
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


getProgress : Excelsior.Context -> Task Http.Error Progress
getProgress context =
    Task.succeed
        { project = "counter"
        , lesson = "error-messages"
        }


fromProgress : ( List Project, Progress ) -> Task Never Model
fromProgress ( projects, progress ) =
    case findBySlug progress.project projects of
        Nothing ->
            Debug.crash {- TODO -} ""

        Just project ->
            case findBySlug progress.lesson project.lessons of
                Nothing ->
                    Debug.crash {- TODO -} ""

                Just lesson ->
                    Task.succeed <| Model projects project lesson


findBySlug : String -> List { a | slug : String } -> Maybe { a | slug : String }
findBySlug slug list =
    case List.filter (.slug >> (==) slug) list of
        [ needle ] ->
            Just needle

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ viewProgress model.lesson model.project
        , div
            [ class "section" ]
            [ div
                [ class "container" ]
                [ div
                    [ class "columns" ]
                    [ viewLesson model.lesson
                    , viewProjects model.project.slug model.roadmap
                    ]
                ]
            ]
        ]


viewProgress : Lesson -> Project -> Html Msg
viewProgress lesson project =
    div
        [ class "hero is-medium is-primary is-bold" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "container" ]
                [ h1
                    [ class "title is-1 has-text-weight-light" ]
                    [ text "You are "
                    , strong
                        [ class "has-text-weight-bold"
                        , style [ ( "border-bottom", "1px solid white" ) ]
                        ]
                        [ viewPercentage lesson project ]
                    , text " done with this project"
                    ]
                , a
                    [ class "button is-primary is-inverted" ]
                    [ text "What are we building?" ]
                ]
            ]
        ]


viewProjects : String -> List Project -> Html Msg
viewProjects current roadmap =
    div
        [ class "column is-one-third" ]
        [ aside
            [ class "menu" ]
            [ p [ class "menu-label" ] [ text "Projects" ]
            , ul [ class "menu-list" ] <| List.map (viewProjectItem current) roadmap
            ]
        ]


viewProjectItem : String -> Project -> Html Msg
viewProjectItem current project =
    let
        ( active, children ) =
            if current == project.slug then
                ( "is-active", ul [] <| List.map viewLessonItem <| project.lessons )
            else
                ( "", text "" )
    in
    li [] [ a [ class active ] [ text project.title ], children ]


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
                [ h2 [ class "subtitle is-uppercase" ] [ text "Up next" ]
                , h3 [ class "title" ] [ text title ]
                ]
            , a
                [ class "button is-primary is-large"
                , Route.href <| Route.Lesson slug
                ]
                [ text "✔ Let's go" ]
            ]
        , div
            [ class "notification is-light" ]
            [ div
                []
                [ h2 [ class "subtitle is-uppercase" ] [ text "Review" ]
                , h3 [ class "title has-text-grey-light" ] [ text "Coming soon..." ]
                ]
            ]
        ]


viewPercentage : Lesson -> Project -> Html msg
viewPercentage lesson project =
    let
        finished =
            countCompleted 0 lesson.slug project.lessons

        total =
            List.length project.lessons

        hundredth =
            toString (100 * toFloat finished / toFloat total)
    in
    text <| String.left 2 hundredth ++ "%"


countCompleted : Int -> String -> List Lesson -> Int
countCompleted acc needle haystack =
    case haystack of
        [] ->
            0

        { slug } :: rest ->
            if slug == needle then
                acc
            else
                countCompleted (1 + acc) needle rest
