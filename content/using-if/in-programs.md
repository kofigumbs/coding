---
title: Making decisions in programs
code: |-
  import Html
  import Html.Events

  initialModel : number
  initialModel =
    1

  update [focus|message|] currentModel =
    currentModel + 1

  view currentModel =
    Html.div []
      [ Html.div [ Html.Events.onClick [focus|"Increment"|] ] [ Html.text "+" ]
      , Html.text (toString currentModel)
      , Html.div [ Html.Events.onClick [focus|"Decrement"|] ] [ Html.text "-" ]
      ]

  main =
    Html.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }
---
Welcome back to the world of interactive programs!
Now that we know how to make decisions with `if`/`then`/`else`,
we can build more interesting programs.

The code in this example _should_ let you _increase and decrease_ the number on the screen. However, the code shown on the left is broken, because it is not operating as intended.

In this example, `Increment` and `Decrement` both need to get "plugged in" as a message inside of update. This model will be fixed when the message is being properly referenced.

> ⭐️ **Try**
>
> * Run the program _as-is_
> * Fix the program, so that clicking "-" makes the number decrease by 1