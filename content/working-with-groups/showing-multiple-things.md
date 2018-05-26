---
title: Showing multiple things on the screen
code: |-
  import Html

  main =
    Html.div [] [focus|
      [ Html.text "Hello"
      , Html.text " friend!"
      ]
    |]
---
We can also use Lists to put multiple things on the screen.
There is a function in `Html` called `div` (meaning section or "division"),
which let's you group multiple Html values.
`div` is the first function we've seen that takes **two inputs**.
Both inputs are Lists.

We're going to leave the first List empty for now, and focus on the second list. The second list contains two Html values that you want to show on the screen, inside the div.

Finally, notice how we can spread out our list across multiple lines.
This is just to make things easier to read:
it has no effect how Elm understands the code.

> ⭐️ **Try** adding another entry to the List, so that the program says "Hello my friend!".
