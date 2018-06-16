---
title: Making decisions in programs
code: |+
  import Html
  import Html.Events

  main =
    Html.beginnerProgram
      { model = 1
      , update = update
      , view = view
      }

  view currentModel =
    Html.div []
      [ Html.div [ Html.Events.onClick [focus|"Increment"|] ] [ Html.text "+" ]
      , Html.text (toString currentModel)
      , Html.div [ Html.Events.onClick [focus|"Decrement"|] ] [ Html.text "-" ]
      ]

  update [focus|message|] currentModel =
    currentModel + 1

---
Now that we know how to make decisions with `if`/`then`/`else`, we can build more interesting programs. In this example, the code _should_ let you increase _and_ decrease the number on the screen. However, the code shown on the left is broken. **Messages like `"Increment"` and `"Decrement"` **should connect your view to your `update`**, but the code currently does not.

> ⭐️ **Try**
>
> * Run the program _as-is_
> * Fix the `update` by using `if`, so that clicking "-" makes the number decrease by 1

_HINT:_ Your solution should continue to use the existing functionality: `currentModel + 1`... but only _if_ a certain message is sent!
