---
title: Html has a type
code: |-
  import Html exposing ([focus|Html|], text, div)
  import Html.Events exposing (onClick)

  plusButton : [focus|Html String|]
  plusButton =
    div [ [focus|onClick "Increment"|] ] [ text "+" ]

  resetButton : [focus|Html number|]
  resetButton =
    div [ [focus|onClick 0|] ] [ text "Reset to 0" ]

  main =
    div [] [ plusButton, resetButton ]
---
We've talked at length about Html, but we've yet to write its type.
Recall that `onClick` allows Html to produce a message.
Elm requires that we explicitly note the type of the values that the Html can produce.
Here's how that plays out in our example:

* Since `Html` is a type inside the Html file, we'll use `exposing` to import it.
  That way, we don't have to write `Html.Html`.
* `plusButton` is a `\*\*Html\*\*` **that can produce** `\*\*String\*\*` **messages**
* `resetButton` is a `\*\*Html\*\*` **that can produce** `\*\*number\*\*` **messages**

`Html String` is the first type we've used that is multiple words long.
Types like this are called **generic types**.
It's incomplete to _just_ call something a Html —
it's always a Html _that can produce_ values of another type, like String.
In practice, people shorten that description to "an Html _of_ String".

> ⭐️ **Try**
>
> * Predict what will appear when you run the code
> * Run the code _as-is_
> * Fix any errors

///HINT: change 0 to “0” and number to “String”    