---
title: Creating your own functions
code: |-
  import Html

  [focus|square x =
    x * x|]

  four : number
  four =
    [focus|square 2|]

  nine : number
  nine =
    [focus|square 3|]

  main =
    Html.div []
      [ Html.text (toString four)
      , Html.text (toString nine)
      ]
---
Excel lets you define custom functions with VBA; however, this is meant for advanced users. Most of the time, people only need to work with the built-in functions.

Elm takes the opposite approach: defining your own functions is just as easy as defining your own variables. In this example you can see the similarities between the variables `four` and `nine`, the **function** `**square**`. In fact there is only one difference: **functions take arguments**. Arguments can be used inside a function to change its behavior.

Finally, notice that calling a custom function
is exactly the same as calling a built-in function.

> ⭐️ **Try**
> 0\. Create a new function called `plusOne` that adds 1 to its argument
> 0\. Make sure you test your function by using it to get something on the screen