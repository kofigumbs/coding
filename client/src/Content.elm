module Content exposing (Content, decoder, view)

import Html
import Html.Attributes exposing (class)
import Json.Decode as D
import Markdown exposing (defaultOptions)


type Content
    = Content String


decoder : D.Decoder Content
decoder =
    D.map Content D.string


options : Markdown.Options
options =
    { defaultOptions | githubFlavored = Just { tables = True, breaks = False } }


view : Content -> Html.Html msg
view (Content c) =
    Html.div [ class "content" ] [ Markdown.toHtmlWith options [] c ]
