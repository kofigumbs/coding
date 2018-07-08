# Welcome

> One of the all-time most popular programming models is the spreadsheet.
> A spreadsheet is the dual of a conventional programming language —
> a language shows all the code, but hides the data.
> A spreadsheet shows all the data, but hides the code.
> Some people believe that spreadsheets are popular
> because of their two-dimensional grid, but that's a minor factor.
> Spreadsheets rule because they show the data.
>
> _Bret Victor_

In this course, we'll do our best to present both the functionality _and_ the data.
For example, in the snippet below, you can change the **code on the left**,
and see the **change reflected immediately on the right**.
Go ahead and try typing your name into the program!

```elm
import Essentials exposing (table, row2)

main =
  table
    [ row2 "Hello" "__YOUR NAME HERE__"
    ]
```

# A quick warmup

Now that you know how to make changes, let's get right to our first challenge.
This course is structured around short challenges that give you a taste of how programming works.
The challenges are short, but they still require effort.
Most of them are based off real world problems.

This first one is easy — just to get you in the habit of typing into the editor.
There is a `secretNumber` that we need you to guess.
Here's a hint: it's between 1 and 10.

```elm
import Essentials exposing (table, row2, secretNumber)

guess =
  0

main =
  table
    [ row2 "Your guess" guess
    , row2 "Correct?" (secretNumber == guess)
    ]
```
