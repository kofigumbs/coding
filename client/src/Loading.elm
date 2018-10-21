module Loading exposing (Loading(..), view)

import Html
import Html.Attributes


type Loading a
    = Loading
    | Done a


{-| <https://nzbin.github.io/three-dots/>
-}
view : Html.Html msg
view =
    Html.div
        [ Html.Attributes.style "display" "flex"
        , Html.Attributes.style "justify-content" "center"
        , Html.Attributes.style "align-items" "center"
        , Html.Attributes.style "height" "60px"
        ]
        [ Html.node "style" [] [ Html.text """
.dot-bricks {
  position: relative;
  top: 8px;
  left: -9999px;
  width: 10px;
  height: 10px;
  border-radius: 5px;
  background-color: #9880ff;
  color: #9880ff;
  box-shadow: 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff;
  animation: dotBricks 2s infinite ease;
}

@keyframes dotBricks {
  0% {
    box-shadow: 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff;
  }
  8.333% {
    box-shadow: 10007px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff;
  }
  16.667% {
    box-shadow: 10007px -16px 0 0 #9880ff, 9991px -16px 0 0 #9880ff, 10007px 0 0 0 #9880ff;
  }
  25% {
    box-shadow: 10007px -16px 0 0 #9880ff, 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff;
  }
  33.333% {
    box-shadow: 10007px 0 0 0 #9880ff, 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff;
  }
  41.667% {
    box-shadow: 10007px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff;
  }
  50% {
    box-shadow: 10007px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff, 9991px -16px 0 0 #9880ff;
  }
  58.333% {
    box-shadow: 9991px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff, 9991px -16px 0 0 #9880ff;
  }
  66.666% {
    box-shadow: 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff, 9991px -16px 0 0 #9880ff;
  }
  75% {
    box-shadow: 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff;
  }
  83.333% {
    box-shadow: 9991px -16px 0 0 #9880ff, 10007px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff;
  }
  91.667% {
    box-shadow: 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff, 10007px -16px 0 0 #9880ff;
  }
  100% {
    box-shadow: 9991px -16px 0 0 #9880ff, 9991px 0 0 0 #9880ff, 10007px 0 0 0 #9880ff;
  }
}
    """ ]
        , Html.div [ Html.Attributes.class "dot-bricks" ] []
        ]
