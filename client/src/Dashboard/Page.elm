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
    { lessons : List Lesson
    }


type alias Lesson =
    { title : String
    , slug : String
    }


type Msg
    = Review String


init : Excelsior.Context -> Task Never Model
init context =
    Http.get (context.api.content ++ "/dashboard")
        (D.field "lessons" <|
            D.list <|
                D.map2 Lesson
                    (D.field "title" D.string)
                    (D.field "location" D.string)
        )
        |> Http.toTask
        |> Task.map Model
        |> Task.onError ({- TODO -} toString >> Debug.crash)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Review slug ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ class "hero is-primary" ]
            [ div
                [ class "hero-body" ]
                [ div
                    [ class "container" ]
                    [ h1 [ class "title" ] [ text "🏠 Welcome home!" ] ]
                ]
            ]
        , div
            [ class "section" ]
            [ div [ class "container" ] <|
                h2 [ class "subtitle" ] [ text "Lessons" ]
                    :: List.intersperse (hr [] [])
                        (List.map viewLesson model.lessons)
            ]
        ]


viewLesson : Lesson -> Html Msg
viewLesson { title, slug } =
    div
        []
        [ a
            [ class "button is-inverted is-info"
            , Route.href <| Route.Lesson slug
            ]
            [ text title ]
        , a
            [ class "button is-inverted is-primary"
            , Route.href <| Route.Review slug
            ]
            [ strong [] [ text "Review" ] ]
        ]
