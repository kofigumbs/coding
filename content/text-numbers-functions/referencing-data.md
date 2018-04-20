---
title: Referencing data
code: |-
  import Html

  [focus|meaningOfLife|] = 42

  [focus|main|] = Html.text (toString meaningOfLife)
---
Think briefly about **spreadsheet cells** in Excel: what are their properties? Here are some that we came up with:

* Cells **are static**
* Cells **have contents**
* Cells **can be referenced in other cells**

Well, in Elm, **variables** have the same properties. In this example, the variable `meaningOfLife` has the content `42`. This means anywhere you can use `42`, you can now use `meaningOfLife` instead! Variables help us **give names to ideas** in our program.

`**main**` **is a special variable** that Elm looks for in order to show a page. That's why it's been in every example so far. `main` always has to have Html contents.

> **⭐ Try**
>
> * Use arithmetic inside of a variable: change `42` to `21 \* 2`
> * Use variables inside variables: make a new variable called `drinkingAge`, so that you can say `meaningOfLife = drinkingAge \* 2`