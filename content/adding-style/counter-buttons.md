---
title: Styling the Counter
code: |
  [focus|import Bulma exposing (text, level, button)|]
  import Html.Events

  initialModel : number
  initialModel =
    1

  update message currentModel =
    if message == "Increment" then
      currentModel + 1
    else
      currentModel - 1

  view currentModel =
    [focus|level|]
      [ [focus|button|] [ Html.Events.onClick "Increment" ] [ text "+" ]
      , text (toString currentModel)
      , [focus|button|] [ Html.Events.onClick "Decrement" ] [ text "-" ]
      ]

  main =
    Bulma.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }

---
