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
y : Html number
y =
  div [ onClick 0 ] [ text "Reset" ]

x : List number
x =
  [ 1, 2, 3 ]
```


### If you don't know, ask Elm

```
-- TYPE MISMATCH - 

The definition of `x` does not match its type annotation.

3| x : String
4|>x = [ 1, 2, 3 ]

The type annotation for `x` says it is a:

    String

But the definition (shown above) is a:

    List number
```
