---

title: Getting something on the screen
code: |
  import [focus|Html|] exposing ([focus|text|])

  main = [focus|text|] "Hello, _YOU_!"

---

First things first—let's get something on the screen! To do that we're going to need to use **HTML**. I know, I said we won't be writing actual HTML... and we're not! We're actually just telling Elm to "create some HTML" for us.

The first line here is an **import**, which tells the Elm where to find a certain **function**. You can read this as "let me use the function called `text` from the `Html` file."

In the next line, we use `text` to put something on the screen. **Elm treats anything in quotes as normal text**. Just like typing into a cell in Excel. In Elm, we call this a **String**.

> **⭐ Try** using the _Edit_ button to replace `_YOU_` with your name!
