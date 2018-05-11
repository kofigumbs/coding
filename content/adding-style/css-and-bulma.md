---
title: What is style?

---

Let's revisit some terms that we mentioned in the first lesson.


### HTML

HTML (HyperText Markup Language) describes the **content and structure** of the page.
For instance, the paragraph you're reading right now is defined in HTML.
Elm generates content and structure for us when we use functions from the `Html` file,
such as `div` and `text`.
There are several functions in that file that create different types of elements:
buttons, checkboxes, progress bars, etc.


### CSS

CSS (Cascading Style Sheets) describes the **look and feel** of the page.
HTML lets you put a button on the page, but CSS is what lets you make the button green.
This separation worked well for early websites,
but the line between "structure" and "look" continues to blur.
For instance, let's say I want a menu that always appears on the right for laptops
and on the bottom for phones.
Is that structure or look?


### Bulma

The `Html` file gives you very fine control over the HTML that Elm generates.
Moving forward, we are going to exchange that control for the benefit of nice default styles.
[Bulma](https://bulma.io) is pre-written CSS that lets us do that.
CSS styling is not a priority topic for this course,
but we want you to be proud of the sites you build.
Bulma lets us build on the work with others to make nice websites.
It also keeps us from having to think about the "structure versus look" question.
Let's look at some examples that illustrate the difference.
