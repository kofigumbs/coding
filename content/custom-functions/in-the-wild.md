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
    Html.div []
      [ Html.text (toString result)
      ]
---
On the last page, we used an Algebra-like syntax for our functions. However, it's more common to use the following style:

1. Give functions proper names, instead of `f` and `g`
2. Put the function body on the next line (more important as functions grow)
3. Omit the parenthesis

Note that **custom and built-in functions are equally important**. In other words, writing functions is an essential part of programming.

In order to **use** functions, you need two things — **the function name then the arguments**:

* Custom — `plusFive 1`
* Built-in — `toString 456` or `Html.text "Hello"`

> ⭐️ **Try** creating a new function that squares its argument.
