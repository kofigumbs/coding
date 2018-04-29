module Landing.Page exposing (Model, init, view)

import Content exposing (Content)
import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Route
import Task exposing (Task)


type alias Model =
    { context : Excelsior.Context
    , content : Content
    }


init : Excelsior.Context -> Task Never Model
init context =
    Http.get (context.contentApi ++ "/landing") (D.field "content" Content.decoder)
        |> Http.toTask
        |> Task.map (Model context)
        |> Task.onError ({- TODO -} toString >> Debug.crash)


view : Model -> Html msg
view { content } =
    div
        [ class "section" ]
        [ div
            [ class "columns is-centered" ]
            [ div
                [ class "column is-half" ]
                [ Content.view content
                , div [ class "buttons" ] [ startLink, learnLink ]
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
