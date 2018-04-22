---
title: Errors and why they matter
---
First, let's define two more terms.

### Values

Great news: you've already seen and used values in this course!
Values are so common in Elm, that it's easier to define them by example:

* `42` is a **number value**
* `"Hello"` is a **String value**
* `toString` is a **function value**
* many, many more that we'll learn about later

### Types

Every value has a type.
Let's take another look at the example values listed above.
This time, we're going to use a simpler format:

* `42 : number`
* `"Hello" : String`
* `toString : anything -> String`

The `:` symbol means **has the type**, so the first example reads
"`42` has the type `number`.
The second example is the same: "`"Hello"` has the type `String`".

The `->` symbol is for _functions_.
The input type is on the left, and the output type is on the right.
You can read it as "`toString` takes `anything` for input and returns a `String`".

Ok, let's code!