---
title: Reacting to events
code: |
  import Html
  [focus|import Html.Events|]

  initialModel : number
  initialModel =
    1

  update [focus|message|] currentModel =
    2

  view currentModel =
    Html.div
      [focus|[ Html.Events.onClick "Increment" ]|]
      [ Html.text (toString currentModel) ]

  main =
    Html.beginnerProgram
      { model = initialModel
      , update = update
      , view = view
      }

---

There's one final step to make our program interactive.
We need to respond to events that happen on the page.
In this example, we are going to respond to **clicks**.

`Html.Events` is a file that has functions for web page events.
Once we import it, we can use the function `onClick` to make our Html interactive.
`onClick` takes one argument, which is a **message**.
Now, whenever `+` is clicked, Elm will use `"Increment"` as the first argument to `update`.
That's why we call it a "message" —
it's how your view **communicates** with your data model.
Whatever your `update` function returns is the new source of truth.

Let's look again at the steps Elm takes to run your program:

 0. Store your initial model
 0. Call `view` with your model to get something on the screen
 0. Wait for an event to happen
 0. Use the event's message to `update` your model
 0. Go back to step 2

> ⭐️ **Try**
> 
> 0. Run the program _as-is_ and click on the number
> 0. Change the behavior inside of `update` —
>    every time you click, the number should increase by 1.
>
> _Hint:_ you can use the `currentModel` in order to calculate the new one!
