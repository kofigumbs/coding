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
Now, whenever that Html is clicked, Elm will use that value to call you **update**.
That's why we call it a "message" —
it's how your view **communicates** with your data model.

`update`'s job is to change the model according to the message it receives.
Elm will call `update` every time the `div` is clicked.
In this example, the message it receives will be `"Increment"`.

> ⭐️ **Try**
> 
> 0. Run the program _as-is_ and click on the number
> 0. Change the behavior inside of `update` —
>    every time you click, the number should increase by 1.
>
> _Hint:_ you can use the `currentModel` in order to calculate the new one!
