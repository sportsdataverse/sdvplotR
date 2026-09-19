# Team-Colored Cell Styles for 'reactable' Tables

Style functions for
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html)
that color cells with a team's primary or secondary color: a horizontal
bar whose length is proportional to the cell value, or a translucent
background fill.

## Usage

``` r
reactable_sdv_team_color_bar(
  data,
  team_col,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("primary", "secondary"),
  max_value = NULL,
  na_color = "grey70"
)

reactable_sdv_team_color_bg(
  data,
  team_col,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("primary", "secondary"),
  alpha = 0.15,
  na_color = "grey70"
)
```

## Arguments

- data:

  The data frame passed to
  [`reactable::reactable()`](https://glin.github.io/reactable/reference/reactable.html).
  Needed to look up the team of each row.

- team_col:

  Character. Name of the column in `data` holding team abbreviations.

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- type:

  Character. `"primary"` or `"secondary"` team color.

- max_value:

  Numeric. Reference value that fills the whole cell. If `NULL` (the
  default), the maximum of the styled column is used.

- na_color:

  Color used when a team cannot be resolved.

- alpha:

  Numeric. Opacity of the background fill in `[0, 1]`.

## Value

A function with signature `function(value, index, name)` suitable for
the `style` argument of
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html).

## Examples

``` r
library(reactable)
library(sdvplotR)

df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))

reactable(
  df,
  columns = list(
    team = colDef(style = reactable_sdv_team_color_bg(df, "team", sport = "nfl")),
    wins = colDef(style = reactable_sdv_team_color_bar(df, "team", sport = "nfl"))
  )
)

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","SF"],"wins":[13,12,11]},"columns":[{"id":"team","name":"team","type":"character","style":[{"background-color":"#E3183726"},{"background-color":"#00338D26"},{"background-color":"#AA000026"}]},{"id":"wins","name":"wins","type":"numeric","style":[{"background-image":"linear-gradient(90deg, #E31837 100%, transparent 100%)"},{"background-image":"linear-gradient(90deg, #00338D 92.3%, transparent 92.3%)"},{"background-image":"linear-gradient(90deg, #AA0000 84.6%, transparent 84.6%)"}]}],"dataKey":"54b46a97531ff2ca3f1398b8ed18a03c"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
