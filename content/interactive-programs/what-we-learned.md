---
title: What did we learn?

---

### How programs work

    ┌─────┐
    │     ↓
    │    MODEL  -- data in your program
    │     ↓
    │    VIEW   -- turn your data into Html
    │     ↓
    │    UPDATE -- do something when the user clicks
    └─────┘


### Wait for events in `view`

    import Html.Events

    view currentModel =
      Html.div
        [ Html.Events.onClick 1 ]
        [ Html.text (toString currentModel) ]


### Change your model in `update`

    update message currentModel =
      message + currentModel
