---
title: Using Bool to make decisions
code: |
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

```
=IF(A1=42, "You got it!", "Nope.")
```

**`if`** in Elm has the same 3 pieces:

 - A **condition** that goes between `if` and `then`
 - What happens if the condition is **True** — between `then` and `else`
 - What happens if the condition is **False** — after the `else`

In Elm, all 3 pieces are required, and the **condition must be a Bool**.
If you want to check if your number is non-zero, you would say `myNumber /= 0`.

> ⭐️ **Try** changing `guess` so that "You got it!" is displayed.
