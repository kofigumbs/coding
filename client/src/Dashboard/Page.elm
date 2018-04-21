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
    }


type alias Lesson =
    { title : String
    , slug : String
    }


type Msg
    = NoOp


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
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html msg
view model =
    div
        [ class "section" ]
        [ div
            [ class "container" ]
            [ menu
                [ class "menu" ]
                [ p [ class "menu-label" ] [ text "Lessons" ]
                , ul [ class "menu-list" ] <| List.map viewLesson model.lessons
                ]
            ]
        ]


viewLesson : Lesson -> Html msg
viewLesson { title, slug } =
    li [] [ a [ Route.href <| Route.Lesson slug ] [ text title ] ]
