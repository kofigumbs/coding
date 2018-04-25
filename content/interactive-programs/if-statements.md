---
title: Using IF
code: |
  import Html
  import Html.Events

  initialModel : number
  initialModel =
    1

  update : String -> number -> number
  update [focus|msg|] currentModel =
    [focus|if msg == "Increment" then|]
      currentModel + 1
    [focus|else|]
      currentModel - 1

  view currentModel =
    Html.div
      [ Html.Events.onClick "" ]
      [ Html.text (toString currentModel) ]

  main =
    Html.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }

---
