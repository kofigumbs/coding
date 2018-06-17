---
title: Guess the secret number
code: |
  [focus|import Secrets|]
  import Html

  guess = 7

  main =
    if guess == [focus|Secrets.magicNumber|] then
      Html.text "YOU GOT IT!"
    else
      Html.text "NOT QUITE, try again..."

---

Use your knowledge of **if** and **numbers** to guess the magic number with code!

| Operator | Meaning |
| ---- | --- |
| `==` | is equal to |
| `/=` | is _not_ equal to |
| `>` | is greater than |
| `<` | is less than |
| `>=` | is greater than _or_ equal to |
| `<=` | is less than _or_ equal to |
