---
title: Groups with names
code: |-
  import Html

  [focus|good : { prefix : String, suffix : String }
  good =
    { prefix = 7, suffix = "Eleven" }|]

  main =
    Html.div []
      [ Html.text (toString good.prefix)
      , Html.text good.suffix
      ]
---
**Everything in a _list_ must have the same type.** This is probably different from what you're used to in Excel. This difference ultimately gives us helpful error messages. So long, `#N/A`! 

**If there are different types, however, we can write a _record_.** Records specify types (e.g., String, number) for each value (e.g., 7, "Eleven"). With this added layer of specificity, records allow the use of more than one type! 

We write records with curly braces, where each **_field _**has a name (e.g., prefix) and a type (e.g., number).    

* In a **record type**, we use `:` to annotate the type of each field.
* In a **record value**, we use `=` to define the value in each field.

In order to **get something out of a record** we say `record.field`.
So the Html in this example uses the record called `good` to show the name of a store.

> ⭐️ **Try**
>
> 1. Run the code _as-is_
> 2. Delete the code causing the error
> 3. Play with different values in the record