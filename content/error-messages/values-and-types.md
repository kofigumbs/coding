---
title: Values and types

---

Before we define types,
let's give a name to a concept we've used many times already: **values**.
Values are so common in Elm, that it's easier to define them by example:

 * `42` is a **number value**
 * `"Hello"` is a **String value**
 * `name = "Alex"` defines a new variable called `name`, which is a **String value**.

There are many more possible values that we'll learn about as we go.
For now, just know that **every value has a type**, something like `number` or `String`.
Here's how we'd phrase the bullet points above in terms of types:

 * the value `42` has the type `number`
 * the value `"Hello"` has the type `String`
 * the value `name` has the type `String`

Not that capitalization matters: `number` starts with a lowercase letter, but `String` is uppercase.
Let's look at an example to see how types can help us out.
