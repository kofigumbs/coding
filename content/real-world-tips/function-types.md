---
title: Functions have types
code: |
  import Html

  [focus|plusOne : number -> String|]
  plusOne x =
    x + 1

  main =
    Html.div []
      [ Html.text (toString (plusOne 5))
      ]

---

In Elm, **functions are values**, and as we already know, all values have types.
We use `->` to write function types.
`plusOne : number -> String` means that "`plusOne` takes a number argument
and returns a String".

Generally, we write out the types of our functions to describe meaning and intent.
All type annotations are optional in Elm,
but if you make a mistake, the error messages are much nicer if you've used them.

> ⭐️ **Try** fixing the error in this example.
>
>  _Remember, you can always run the example first to see the error message!
>  There's no prize for refusing help._
