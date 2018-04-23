---
title: Type errors
code: |
  import Html

  [focus|meaningOfLife : String|]
  meaningOfLife = 42

  main = Html.text (toString meaningOfLife)

---

Elm knows all all of the types in our program,
so it checks that everything matches up before it puts anything on the screen.
Also, Elm's error messages are state-of-the-art,
so you'll never see `#N/A __TODO__`.

In order to get the most helpful error messages,
we can **annotate** our variables with types.
In our example I've annotated `meaningOfLife` with `String`.
These annotations are **optional**,
but they let Elm know what you are trying to do.

In this example `String` is not actually the correct type!
But don't worry, Elm will guide you through the fix.

> ⭐️ **Try**
> 
> 0. Run the program _as-is_
> 0. Don't panic
> 0. Fix the error
