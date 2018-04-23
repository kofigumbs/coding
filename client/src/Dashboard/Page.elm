module Dashboard.Page exposing (Model, Msg, init, update, view)

import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Route
import Task exposing (Task)


type alias Model =
    { lessons : List Lesson
    , progress : Progress
    }


type alias Lesson =
    { title : String
    , slug : String
    }


type alias Progress =
    { finished : List String
    , current : String
    , reviewing : Bool
    }


type alias Msg =
    ()


init : Excelsior.Context -> Task Never Model
init context =
    Task.map2 Model (getLessons context) (getProgress context)
        |> Task.onError ({- TODO -} toString >> Debug.crash)


getLessons : Excelsior.Context -> Task Http.Error (List Lesson)
getLessons context =
    Http.get (context.api.content ++ "/dashboard")
        (D.field "lessons" <|
            D.list <|
                D.map2 Lesson
                    (D.field "title" D.string)
                    (D.field "location" D.string)
        )
        |> Http.toTask


getProgress : Excelsior.Context -> Task Http.Error Progress
getProgress context =
    Http.get (context.api.user ++ "/progress")
        (D.map3 Progress
            (D.field "finished" <| D.list D.string)
            (D.field "current" D.string)
            (D.field "reviewing" D.bool)
        )
        |> Http.toTask


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ class "hero" ]
            [ div
                [ class "hero-body" ]
                [ div
                    [ class "container" ]
                    [ h1 [ class "title" ] [ text "🏠 Welcome home!" ] ]
                ]
            ]
        , div
            [ class "section" ]
            [ div
                [ class "container" ]
                [ div [ class "columns is-centered" ]
                    [ div [ class "column is-three-quarters" ] <|
                        List.indexedMap (viewLesson model.progress) model.lessons
                    ]
                ]
            ]
        ]


viewLesson : Progress -> Int -> Lesson -> Html Msg
viewLesson progress index { title, slug } =
    div
        [ classList
            [ ( "notification", True )
            , ( "is-primary", slug == progress.current )
            ]
        ]
        [ viewLessonTitle index title
        , div [ class "buttons is-right" ] <|
            if List.member slug progress.finished then
                [ activeLink (Route.Lesson slug) "is-light has-text-primary" "✔ Lesson"
                , activeLink (Route.Review slug) "is-light has-text-primary" "✔ Review"
                ]
            else if slug == progress.current && progress.reviewing then
                [ activeLink (Route.Lesson slug) "is-primary" "✔ Lesson"
                , activeLink (Route.Review slug) "is-primary is-inverted" "Review"
                ]
            else if slug == progress.current then
                [ activeLink (Route.Lesson slug) "is-primary is-inverted" "Lesson"
                , disabledLink "is-primary" "Review"
                ]
            else
                [ activeLink (Route.Lesson slug) "is-light has-text-primary" "Lesson"
                , disabledLink "is-light" "Review"
                ]
        ]


viewLessonTitle : Int -> String -> Html msg
viewLessonTitle index title =
    h3
        [ class "subtitle is-4" ]
        [ span
            [ style [ ( "opacity", "0.4" ) ] ]
            [ text <| toString (index + 1) ++ ". " ]
        , text title
        ]


activeLink : Route.Route -> String -> String -> Html msg
activeLink route extraClass name =
    a [ class <| "button " ++ extraClass, Route.href route ] [ strong [] [ text name ] ]


disabledLink : String -> String -> Html msg
disabledLink extraClass name =
    a [ class <| "button " ++ extraClass, attribute "disabled" "" ] [ strong [] [ text name ] ]
