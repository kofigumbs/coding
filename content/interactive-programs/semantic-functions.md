---
title: Functions in the wild
code: |-
  import Html

  [focus|plusFive x =
    x + 5|]

  result : number
  result =
    [focus|plusFive 1|]

  main =
    Html.text (toString result)

---

It is common to write and use custom functions in programming.
On the last page, we used an Algebra-like syntax for our functions.
However, it's more common to use the following style:

  0. Give functions proper names, instead of `f` and `g`
  0. Put the function body on the next line (more important as functions grow)
  0. Omit the parenthesis, unless required for order of operations

After those tweaks, notice that **using a custom function is no different than using a built-in one**.
It's always the function name, a space, then the argument.

 - Custom — `plusFive 1`
 - Built-in — `toString 456` or `Html.text "Hello"`

> ⭐️ **Try** creating a new function that squares its argument.
