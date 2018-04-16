module Content exposing (Content, decoder, view)

import Html
import Html.Attributes exposing (class)
import Json.Decode as D
import Markdown


type Content
    = Content String


decoder : D.Decoder Content
decoder =
    D.map Content D.string


view : Content -> Html.Html msg
view (Content c) =
    Html.div [ class "content" ] [ Markdown.toHtml [] c ]
