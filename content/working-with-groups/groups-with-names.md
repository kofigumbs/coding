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
**Everything in a _list_ must have the same type.** This ultimately gives us helpful error messages. So long, `#N/A`!

**If there are different types, however, we can write a _record_.** Records specify types (e.g., String) for each value (e.g., "Eleven"). This allows us to use more than one type!

We use a colon to annotate a field's type, an equals sign to define the value in the field, and curly braces to communicate that we are using a **_record_** rather than a **_list._**

In order to **access a record field** we say `record.field`. This means the code retrieves a specific value (e.g., `prefix`) within a meta value (e.g., `good`). In this example, Html uses the record called `good` to show the name of a convenience store.

> ⭐️ **Try**
>
> 1. Run the code _as-is_
> 2. Change the code causing the error
> 3. Play with different values in the record