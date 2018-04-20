---

title: Review — what did we learn?

---

### Elm generates Html for you

```
import Html

main = Html.text "Only Html goes on the screen!"
```

### Convert from numbers to Strings

```
main = Html.text (toString 42)
```

### Arithmetic in Elm

```
main = Html.text (toString (21 * 2))
```

### Variables can name ideas

```
drinkingAge = 21
meaningOfLife = drinkingAge * 2
main = Html.text (toString meaningOfLife)
```
