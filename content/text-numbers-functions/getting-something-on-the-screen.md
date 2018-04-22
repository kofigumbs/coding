---
title: Getting something on the screen
code: |-
  import [focus|Html|]

  main = [focus|Html.text|] "Hello, _YOU_!"
---
Start by glancing over at the code snippet. It won't make sense right away—don't worry! We explain all the pieces in each lesson. We've found that when you skim the code first, the lesson is actually easier to understand. It helps you follow along as we explain each part.

---

The first line here is an **import**, which tells Elm about a particular file. `import Html` is telling Elm to look for a file called Html. `Html` is going to show up in all of our examples because that's how **we tell Elm to "generate an Html file for us"**.

Inside of the Html file, there is a **function** called `text`. That's why the next line says `Html.text`, which just means **"use the function `text`, located within `Html`"**.

A function in Elm is just like a function in algebra or Excel. Functions take some input and produce some output. `Html.text` is a function that takes anything in quotes and turns it into Html. **In order to show something on the screen, it needs to be turned into Html.**

**Elm treats anything in quotes as normal text**. Just like typing into a cell in Excel. In Elm, we call this a **String**.

> **⭐ Try** using the _Edit_ button to replace `_YOU_` with your name!
