---
title: What did we learn?

---

### Imports can expose values

```
import Html exposing (..)
import Html.Events exposing (onClick)
```


### Functions have types

```
update : String -> number -> number
update message currentModel =
  currentModel + 1
```


### Html and List are generic types

```
x : Html number
x =
  div [ onClick 0 ] [ text "Reset" ]

y : List number
y =
  [ 1, 2, 3 ]
```


### If you don't know, ask Elm

```
-- TYPE MISMATCH - 

The definition of `z` does not match its type annotation.

3| z : String
4| z =
5|>  [ 1, 2, 3 ]

The type annotation for `z` says it is a:

    String

But the definition (shown above) is a:

    List number
```
