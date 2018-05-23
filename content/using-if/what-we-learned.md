---
title: What did we learn?
---
### Bool's are either True or False

    boolA : Bool
    boolA = "Left" == "Right"

### 3 parts to an `if`/`then`/`else`

    notification : String
    notification =
      if isWeakPassword then "That's too weak!" else "Nice!"

### Use `if` inside of `update` to make decisions

    update message currentModel =
      if message == "Increment" then
        currentModel + 1
      else
        currentModel - 1