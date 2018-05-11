---
title: Transforming Lists
code: |
  import Html exposing (..)

  friends : List String
  friends =
    [ "Amy"
    , "Fido"
    , "Nick"
    ]

  [focus|viewFriend : String -> Html String|]
  viewFriend name =
    div []
      [ text name
      , text " is my friend."
      ]

  main =
    div [] ([focus|List.map viewFriend friends|])

---

`List.map` is a function that lets us transform the individual values in a List.
Let's look at it's type annotation (from the official Elm documentation):

```
map : (a -> b) -> List a -> List b
```

Now, in English.
`List.map` takes 2 arguments, the first of which is another function!
Yes, **functions can take other functions as arguments**.
The first argument to `List.map` describes "how should we transform each individual value".
This second argument is the List of values to transform.
It returns a new List, which contains the transformed values.

Note that **lowercase `a` and `b` are placeholders**.
In our example `a` is a `String`, and `b` is a `Html String`.
The important piece is that the **placeholders must match up**.
If I provide a function that knows how to transform Strings,
then I _must_ also provide a `List String`.

It's OK if the type annotation is a bit confusing!
We are going to be using them to introduce new functions to build your comfort level.
In time, you won't need the English translation at all.

> ⭐️ **Try** using `if` inside of `viewFriend` so that the program says
> > Amy is my friend.
>
> > Fido is my dog.
>
> > Nick is my friend.
