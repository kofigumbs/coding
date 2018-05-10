---
title: What did we learn?
---
### Writing your own functions

    f x =
      x + 2

### Using functions to create programs

    initialModel =
      1
    
    update message currentModel =
      currentModel + 1
    
    view currentModel =
      Html.text (toString currentModel)

### Html can trigger your update functions

    view currentModel =
      Html.div
        [ Html.Events.onClick "Increment" ]
        [ Html.text (toString currentModel) ]