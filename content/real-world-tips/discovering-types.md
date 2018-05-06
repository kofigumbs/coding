---
title: Discovering new types
code: |
  import Html

  [focus|x : String|]
  x = [ 1, 2, 3 ]

  main = Html.text "Nice!"

---

Type annotations are always optional, but we include them to communicate our intent.
Well, what if we don't know how to write a particular type?
For example, we've spent time using Lists, but we've never actually written an annotation.

Elm makes this really easy:
we can **intentionally make mistakes to get the real answer**.
In this example, we've _incorrectly_ called `[ 1, 2, 3 ]` a String.
The error message will teach you how to annotate Lists.

> ⭐️ **Try** fixing the annotation of `x`.
>
> _The fixed annotation should look like another type we discussed.
> What do we call types that look that?_
