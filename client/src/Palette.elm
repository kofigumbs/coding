module Palette exposing (danger, dark, info, invert, light, primary, success, warning)

-- Originally copied from https://bulma.io/documentation/overview/colors/


primary : String
primary =
    -- "hsl(171, 100%, 41%)"
    "#21ce99"


info : String
info =
    "hsl(204, 86%, 53%)"


success : String
success =
    "hsl(141, 71%, 48%)"


warning : String
warning =
    "hsl(48, 100%, 67%)"


danger : String
danger =
    "hsl(348, 100%, 61%)"


light : String
light =
    "hsl(0, 0%, 96%)"


dark : String
dark =
    "hsl(0, 0%, 21%)"


invert : String -> String
invert original =
    if original == warning then
        "rgba(0, 0, 0, 0.7)"
    else if original == dark then
        "hsl(0, 0%, 96%)"
    else
        "#fff"
