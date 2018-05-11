---
title: Using Bool to make decisions
code: |-
  import Html

  guess : number
  guess = 51

  result : String
  result =
    [focus|if|] guess == 42 [focus|then|] "You got it!" [focus|else|] "Nope."

  main =
    Html.text result
---
In Excel, you can use the `IF()` function to make decisions.
Here's an example Excel formula that corresponds to `result` in our example:

    =IF(51=42, "You got it!", "Nope.")

On the left, the text between `if` and `then` is referred to as a “condition". This condition must be a Bool (i.e., it returns either `True` or `False` — those are the only two options).”

> ⭐️ **Try** changing `guess` so that "You got it!" is displayed.
