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

**If there are different types, however, we can write a _record_.** Records specify types (e.g., String) for each value (e.g., "Eleven"). With this added layer of specificity, records allow the use of more than one type!

We use: `:` to annotate a field's type, `=` to define the value in the field and curly braces to communicate that we are using a **_record_** rather than a **_list._** 

In order to **enable functionality for a record** we say `record.field`. In this example, Html uses the record called `good` to show the name of a convenience store.

> ⭐️ **Try**
>
> 1. Run the code _as-is_
> 2. Delete the code causing the error
> 3. Play with different values in the record