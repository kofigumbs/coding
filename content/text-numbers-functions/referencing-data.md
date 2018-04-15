---

title: Referencing data
code: |
  import Html exposing (text)

  [focus|meaningOfLife|] = 21 * 2

  [focus|main|] = text (toString meaningOfLife)

---

Variables hold information, just **like a spreadsheet cell**. In Excel, you'd say something like `A2`. Well, in Elm, you can name variables whatever you want (almost)!

We say that "**values**, like Strings or numbers, **are assigned to variables**." In this example "the number `42` is assigned to the variable `meaningOfLife`".

**`main` is a special variable** that Elm looks for in order to show a page. That's why it's been in every example so far. Since `meaningOfLife` is a number behind-the-scenes, we still need to use `toString`.

> **⭐ Try**
> - Create a new variable called `two`
> - Assign it the number `2`
> - Use it inside of `meaningOfLife`
