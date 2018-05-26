---
title: Updating your model
code: |
  import Html
  [focus|import Html.Events|]

  main =
    Html.beginnerProgram
      { model = 42
      , view = view
      , [focus|update = update|]
      }

  view currentModel =
    Html.div
      [ [focus|Html.Events.onClick 1|] ]
      [ Html.text (toString currentModel)
      ]

  [focus|update message currentModel|] =
    message + currentModel

---

There's one final step to make our program interactive.
We need to **change our data model based on events** that happen on our website.

### Waiting for events

Websites have many types of events, like clicking and scrolling.
When we import `Html.Events`, we get access to functions that let us wait for those events.
This example uses `onClick` which waits for the user to click something.

`Html.Events.onClick` takes one argument.
We refer to that argument as a "message".
**Messages connect the `view` function with the `update` function**.


### Changing the model

Changes to the model happen in a custom function called `update`.
The `update` function takes **two arguments**:

 0. The message generated in the `view`
 0. The most recent version of the data model

Whatever your `update` function returns is the new model.
Then that new model is passed onto `view` to show something new on the screen...
And the cycle repeats forever!

> ⭐️ **Try**
> 
> 0. Run the program _as-is_ and click on the number
> 0. Change `view` so that the model increases by _2_ on each click
> 0. Change `update` so that the model is _multiplied by 2_ on each click
