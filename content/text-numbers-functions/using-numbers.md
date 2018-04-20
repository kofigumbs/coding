---
title: Using numbers
code: |-
  import Html

  main = Html.text [focus|(toString (1 - 2 + 3))|]
---
Don't forget to glance at the code first! This is the last time you'll see a reminder here, but it's a great habit for learning.

---

Numbers work as you might expect them to: you can add, subtract, multiply, and divide, just the same as you would in Excel.

Note how **parenthesis let us order functions**. In this example, we are using two functions:

1. `toString` which turns the number into a String
2. `Html.text` which turns a String into Html (to show on the screen)