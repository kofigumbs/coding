module Dashboard.Page exposing (Model, Msg, init, update, view)

import Excelsior
import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (Task)


type alias Model =
    {}


type Msg
    = NoOp


init : Excelsior.Context -> Task Never Model
init context =
    Task.succeed Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html msg
view model =
    div
        [ class "hero is-fullheight is-primary" ]
        [ text "Welcome to your Dashboard" ]
