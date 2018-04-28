---
title: What did we learn?

---

### Writing your own functions

```
square x =
  x * x
```


### Using functions to create programs

```
initialModel =
  1

update message currentModel =
  currentModel + 1

view currentModel =
  Html.text (toString currentModel)
```

### Html can generate messages

```
view currentModel =
  Html.div
    [ Html.Events.onClick "Increment" ]
    [ Html.text (toString currentModel) ]
```
