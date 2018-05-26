---
title: A trick to type less
code: |
  import Html

  main =
    Html.div []
      [ Html.text "Hello" ]

---

So far, we've only used **qualified imports**.
This means that every time we want to use something from Html,
we have to prefix it with `Html.` — for instance, `Html.text` and `Html.div`.
Since we end up using Html so frequently, it would be nice to avoid that prefix.

The `exposing` syntax allows to use certain functions from other files **without qualification** — `text` instead of `Html.text`.
This matrix highlights how the different forms of `exposing` enable different ways to use functions from Html:

|                                             | `text` | `div` |
| ------------------------------------------- | ------ | ----- |
| `import Html exposing (div)`                | ❌     | ✔     |
| `import Html exposing (text)`               | ✔      | ❌    |
| `import Html exposing (div, text)`          | ✔      | ✔     |
| `import Html exposing (..)` — _everything!_ | ✔      | ✔     |

Using `exposing` can make code tricker to understand
because it's harder to see where stuff is coming from.
Usually it's best to use it only once or twice per file.

> ⭐️ **Try** changing `import Html` so that you can use `div` without qualification
