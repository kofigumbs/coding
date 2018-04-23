---
title: Groups with names
code: |
  import Html

  [focus|bad|] = [ 7, "Eleven" ]

  [focus|good : { prefix : number, suffix : String }
  good =
    { prefix = 7, suffix = "Eleven" }|]

  main =
    Html.div []
      [ Html.text (toString good.prefix)
      , Html.text good.suffix
      ]

---

**Everything in a list must have the same type**.
This is probably different from what you're used to in Excel.
This difference is what makes scenarios like `#N/A __TODO__` impossible in Elm!

One way to group values of different types: is to use **records**.
We write records with curly braces and commas,
where each **field** has a name and a type.

 * In a **record type**, we use `:` to annotate the type of each field.
 * In a **record value**, we use `=` to define the value in each field.

In order to **get something out of a record** we say `record.field`.
So the Html in this example uses the record called `good` to show the name of a store.

> ⭐️ **Try**
>
> 0. Run the code _as-is_
> 0. Delete the code causing the error
> 0. Play with different values in the record
