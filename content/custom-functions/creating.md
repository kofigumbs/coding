---
title: Creating your own functions
code: |-
  import Html

  [focus|f(x) = x + 5|]

  result : number
  result = [focus|f(1)|]

  main =
    Html.div []
      [ Html.text (toString result)
      ]
---
The line `f(x) = x + 5` creates a brand new function, with the following properties:

* A **name** — this function is called `f`
* **Arguments** — this function has one argument, named `x`
* The **body** — anything that comes after the `=` sign

Notice how **we can use arguments inside the body** of the function. Let's decompose exactly how this works:

    f(1) = 1 + 5
    1 + 5 = 6
    therefore, f(1) = 6

In this example, 1 is substituted for `x` every time we use the function.
So `f` just adds 5 to whatever number you provide.

> ⭐️ **Try**
>
> 1. Change this function, `g(y)`, that doubles its argument
> 2. Make sure you test your function by using it to get something on the screen