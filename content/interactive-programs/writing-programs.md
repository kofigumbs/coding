---
title: Writing a program is just writing functions
code: |-
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

Elm programs have 3 central pieces.
Let's walk through each piece as it appears in the example.

##### 1. The model

The **model is the data** in your program.
In our code, `initialModel` is the data that we start with.
Since our data model is a `number`, we'll start it at 1.

##### 2. The update function

`update` defines how your model changes in the program.
It is a **function that takes two arguments**.
We'll cover this on the next page.

The second argument is the most recent version of your model.
`update` always returns a model, which is... an _updated_ version of your data.
In this simple example, we are always updating the data to be 2.

##### 3. The view function

`view` turns your data model into Html, in order to show something on the screen.
We'll come back to this one on the next page as well.

---

`main` is where it all comes together.
Here's how Elm uses your functions to run the program:

1. Store your initial model
2. Call `view` with your model to get something on the screen
3. Wait for an event to happen
4. Use the event's message to `update` your model
5. Go back to step 2

There's one piece we glossed over: **where do messages and events come from?**
Well, your answer is just one page away.

> ⭐️ **Try**
>
> 1. Predict what will display when you run the program
> 2. Run the program
>
> _This practice is known as "calling your shot".
> Thinking through what might happen helps you better understand the program.
> But always make sure you run it, in order to check your assumptions._
