---
title: Writing programs is just writing functions
code: |
  import Html

  [focus|initialModel : number|]
  [focus|initialModel|] =
    1

  [focus|update|] msg [focus|currentModel|] =
    currentModel

  [focus|view currentModel|] =
    Html.text (toString currentModel)

  [focus|main|] =
    Html.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }

---

Welcome to your first Elm program!
So far, we've just been generating Html in `main`,
but now that we know about functions, we can do much more.
Functions let us define the behavior for our programs.

Elm programs have 3 main pieces:

 0. The **model** — the data in your program
 0. The **update** function — how does your model change in the program
 0. The **view** function — how do you show your model on the screen

Let's walk through how each piece appears in the example.
First, the `initialModel` is the data that you start with.
In this example, our data is a `number` that we start at 0.

Next `update` is a **function that takes two arguments**.
We'll skip over the first one for a moment.
The second argument is the most recent version of your model.
`update` always returns a model, which is... an _updated_ version of your data.
In this example, we aren't doing any updates.
Instead we are always returning the `currentModel`.
This means our program is very boring, since it doesn't _do_ anything yet.

`view` should look very familiar to you, since it always returns Html.
`view` is a function because anytime we update our data model,
we probably want to show something different on the screen.

`main` is where it all comes together.
`Html.beginnerProgram` is a function that takes a record argument.
Elm uses these 3 fields, `model`, `update`, and `view`, to create and run our program.

---

There's one piece I glossed over: **where do `msg` events come from?**.
Well, your answer is just one page away.

> ⭐️ **Try** running this program.
> We told you that it won't do anything,
> but it's a good habit to check for yourself.
