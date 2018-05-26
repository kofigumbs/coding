---
title: Creating your own functions
code: |-
  import Html

  [focus|f(x) = x + 5|]

  result : number
  result = [focus|f(1)|]

  main =
    Html.text (toString result)

---

The line `f(x) = x + 5` creates a brand new function, with the following properties:

 - A **name** — this function is called `f`
 - **Arguments** — this function has one argument, named `x`
 - The **body** — anything that comes after the `=` sign

Notice how **we can use arguments inside the body** of the function.
When we use our function, like `f(1)`, the number 1 is then substituted for `x` in the function body.
This means that each of these lines have the same result:

    f(1)
    1 + 5
    6

So `f` just adds 5 to whatever number you provide.

> ⭐️ **Try**
>  1. Create a new function — `g(y)` — that doubles argument
>  2. Make sure you test your function by using it to get something on the screen
