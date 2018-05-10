---
title: Grouping values
code: |-
  import Html

  total = [focus|List.sum [ 1, 2, 3 ]|]

  main = Html.text (toString total)
---
So far, we've only worked with individual values, but Excel wouldn't be such a great tool if you could only work with one cell at a time. In a spreadsheet, we group cells in a **table**. In Elm, the simplest way to group values is with a **List**.

We write Lists using square brackets and commas, like `\\\\\\\[ 1, 2, 3 \\\\\\\]`.
There are a lot of functions for working with Lists in the `List` file.
`List.sum` is one of those functions.
It works just like `SUM()` in Excel:
it takes a List of numbers as input and returns one number as output.

Did you notice that we don't have to write `import List` at the top of the file?
That's because Lists are so common in Elm, that `\\\*\\\*List\\\*\\\*` **is automatically imported**.
Technically, you can write it if you want, but there's no reason to do so.

> ⭐️ **Try** adding more numbers to the List.

---

> ⭐️ **Try** switching out `List.sum` for these other functions:
>
> | Elm | Excel |
> | --- | --- |
> | List.product | PRODUCT() |
> | List.length | COUNT() |
