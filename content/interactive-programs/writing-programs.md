---
title: Writing a program is just writing functions
code: |
  import Html

  [focus|initialModel : number|]
  [focus|initialModel|] =
    1

  [focus|update|] message [focus|currentModel|] =
    2

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

Elm programs have 3 main pieces.
Let's walk through each piece as it appears in the example.

##### 1. The model

The **model is the data** in your program.
In our code, `initialModel` is the data that we start with.
Since our data model is a `number`, we'll start it at 1.


##### 2. The update function

`update` defines how your model changes in the program.
It is a **function that takes two arguments**.
We'll skip over the first one for a moment.

The second argument is the most recent version of your model.
`update` always returns a model, which is... an _updated_ version of your data.
In this simple example, we are always updating the data to be 2.


##### 3. The view function 

`view` tells Elm **how do you show your model on the screen**.
This function should look familiar to you, since it always returns Html.
`view` is a function because anytime we update our data model,
we probably want to show something different on the screen.

---

`main` is where it all comes together.
`Html.beginnerProgram` is a function that takes a record argument
and creates an interactive program.
Elm calls our `update` function anytime an event happens,
and then it calls `view` to put the new data on the screen

There's one piece we glossed over: **where do `message` events come from?**
Well, your answer is just one page away.

> ⭐️ **Try**
>
> 0. Predict what will display when you run the program
> 0. Run the program
>
> _This practice is known as "calling your shot".
> Thinking through what might happen helps you better understand the program.
> But always make sure you run it, in order to check your assumptions._
