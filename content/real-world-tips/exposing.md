---
title: A trick to type less
code: |
  import Html [focus|exposing (..)|]

  main =
    [focus|text|] (toString (List.sum [1, 2, 3, 4]))

---

So far, we've only used **qualified imports**.
This means that every time we want to use a value in the Html file,
we have to prefix it with `Html.`.
But since we end up using Html so frequently,
so it would be nice if we could avoid the repetition.
Well that's what **exposing** lets us do.

This keyword has two forms:

 - `import Html exposing (..)` lets us use **everything** inside Html without qualification
 - `import Html exposing (div)` only lets us use `div` without qualification, so we'd still need to write `Html.text`

Using `exposing` can make code tricker to understand
because it's harder to see where the values are coming from.
For that reason, we'll try to use it sparingly.

> ⭐️ **Try**
>  * Change `import Html` to **only import text**, not everything
>  * Add a new import that lets us write `sum` instead of `List.sum`
