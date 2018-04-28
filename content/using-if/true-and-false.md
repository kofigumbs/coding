---
title: True and False
code: |
  import Html

  bool1 : [focus|Bool|]
  bool1 = [focus|True|]

  bool2 : [focus|Bool|]
  bool2 = [focus|False|]

  bool3 : [focus|Bool|]
  bool3 = "Left" [focus|==|] "Right"

  main =
    Html.div []
      [ Html.text (toString bool1)
      , Html.text ", "
      , Html.text (toString bool2)
      , Html.text ", "
      , Html.text (toString bool3)
      ]

---

Often in programming, we need to ask "yes or no" questions.
For instance, we might want to know "are these two values equal?"
This idea is built into Elm – we call it the `Bool` type (short for "boolean").
A Bool can be either `True` or `False`.

There are several ways to create a Bool,
some of which are demonstrated in this example.

 - You can use the **literal values** `True` and `False`
 - You can compare two values using `==`, which **checks for equality**

Note that in Elm `=` (or "single equals") means _assignment_,
but `==` ("double equals") checks for _equality_.

> ⭐️ **Try**
>
>  * Predict what will display when you run the program _as-is_
>  * Try switching `==` to `/=`, which means **not equal to**
