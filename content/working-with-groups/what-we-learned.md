---
title: What did we learn?

---

### Using a List to group values

```
total = List.sum [ 1, 2, 3 ]
```


### Using `div` to build up Html

```
main =
  Html.div []
    [ Html.text "Hello"
    , Html.text " friend!"
    ]
```


### Records can group different types

```
bad = [ 1, "THIS DOES NOT WORK!" ]

good : { oneThing : number, anotherThing : String }
good =
  { oneThing = 1, anotherThing = "👍" }
```
