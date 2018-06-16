---
title: Viewing your data model
code: |-
  import Html

  main =
    Html.beginnerProgram
      { [focus|model = 42|]
      , [focus|view = view|]
      , update = update
      }

  [focus|view currentModel|] =
    Html.div []
      [ Html.text (toString currentModel)
      ]

  update message currentModel =
    0
---
In Elm, we use the term "model" to refer to **the data in your program**.
In this example, our data is the number 42.

Having data is nice, but showing that data on the screen is even nicer!
`view` is a custom function that describes **how to turn your model into Html**.
Our `view` function has one argument, `currentModel`,
which is always the **most recent version of your model**.

> ⭐️ **Try**
>
> * Run the program as-is
> * Change `model` so that the program shows _100_
> * Change `view` so that the program shows _$100_

_HINT:_ You can put multiple texts within a div.
