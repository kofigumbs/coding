---
title: True and False
code: |-
  import Html

  bool : [focus|Bool|]
  bool = "Left" [focus|==|] "Right"

  main =
    Html.div []
      [ Html.text (toString bool)
      ]
---
**Often in programming, we need to ask "yes or no" questions.**
For instance, we might want to know "are these two values equal?"
This idea is built into Elm – we call it the `Bool` type (short for "boolean"). A Bool can return one of two results, and those results are either `True` or `False`.

Note that in Elm `=` (or "single equals") means _assignment_,
but `==` ("double equals") checks for _equality_.

> ⭐️ **Try**
>
> * Predict what will display when you run the program _as-is_
> * Try switching `==` to `/=`, which means **not equal to**