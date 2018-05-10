---
title: What did we learn?
---
### Using a List to group values

    total = List.sum [ 1, 2, 3 ]

### Using `div` to show multiple things on the screen

    main =
      Html.div []
        [ Html.text "Hello"
        , Html.text " friend!"
        ]

### Records can group different types of values

    good : { oneThing : number, anotherThing : String }
    good =
      { oneThing = 7, anotherThing = "Eleven" }
