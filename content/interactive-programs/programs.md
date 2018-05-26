---
title: How programs work

---

So far, we've been using `main` to describe the Html we want on the screen.
If you want to change the Html, you have to update your code.
In this lesson we'll upgrade our website handle **user interactions**.
Here's an overview of how Elm programs are structured:

```
┌─────┐
│     ↓
│    MODEL  -- data in your program
│     ↓
│    VIEW   -- turn your data into Html
│     ↓
│    UPDATE -- do something when the user clicks
└─────┘
```

Let's look at how these pieces combine to create interactive programs.
