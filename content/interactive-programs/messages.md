---
title: Reacting to events
code: |
  import Html
  import Html.Events

  initialModel : number
  initialModel =
    1

  update : [focus|String|] -> number -> number
  update [focus|msg|] currentModel =
    currentModel [focus|+ 1|]

  view currentModel =
    Html.div
      [focus|[ Html.Events.onClick "" ]|]
      [ Html.text (toString currentModel) ]

  main =
    Html.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }

---
