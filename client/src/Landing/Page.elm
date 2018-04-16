module Landing.Page exposing (Model, init, view)

import Content exposing (Content)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Markdown
import Route
import Task exposing (Task)


type alias Model =
    { content : Content }


init : Task Never Model
init =
    Http.get "/api/landing" (D.field "content" Content.decoder)
        |> Http.toTask
        |> Task.map Model
        |> Task.onError ({- TODO -} toString >> Debug.crash)


view : Model -> Html msg
view { content } =
    div
        [ class "hero is-fullheight" ]
        [ div
            [ class "hero-body" ]
            [ div
                [ class "columns is-centered" ]
                [ div
                    [ class "column is-half" ]
                    [ Content.view content
                    , div [ class "buttons" ] [ startLink, learnLink ]
                    ]
                ]
            ]
        ]


startLink : Html msg
startLink =
    a
        [ class "button is-primary is-large"
        , Route.href <| Route.Lesson "text-numbers-functions"
        ]
        [ text "Start now" ]


learnLink : Html msg
learnLink =
    a
        [ class "button is-primary is-large is-inverted"
        , Route.href Route.Pricing
        ]
        [ text "Learn more" ]
