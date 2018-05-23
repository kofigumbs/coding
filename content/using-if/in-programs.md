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
Now that we know how to make decisions with `if`/`then`/`else`, we can build more interesting programs. In this example, **the code _should_ let you increase _and_ decrease the number on the screen**. However, the code shown on the left is broken.

In order to fix this, you must "plug in" `Increment` and `Decrement` as messages inside of update.

> ⭐️ **Try**
>
> * Run the program _as-is_
> * Fix the `update` by using `if`, so that clicking "-" makes the number decrease by 1