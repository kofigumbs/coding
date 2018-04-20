---
title: Using numbers
code: |-
  import Html

  main = Html.text [focus|(toString (1 - 2 + 3))|]
---

Numbers work as you might expect them to: you can add, subtract, multiply, and divide, just the same as you would in Excel.

Note how **parenthesis let us order functions**. In this example, we are using two functions:

0. `toString` which turns the number into a String
0. `text` which turns a String into Html (to go on the screen)
