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
  league,
  which = c("primary", "secondary"),
  max_value = NULL,
  na_color = "grey70",
  season = NULL,
  id_system = "auto",
  strict = FALSE
)

reactable_sdv_team_color_bg(
  data,
  team_col,
  league,
  which = c("primary", "secondary"),
  alpha = 0.15,
  na_color = "grey70",
  season = NULL,
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- data:

  The data frame passed to
  [`reactable::reactable()`](https://glin.github.io/reactable/reference/reactable.html).
  Needed to look up the team of each row.

- team_col:

  Character. Name of the column in `data` holding team abbreviations.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- which:

  Character. `"primary"` or `"secondary"` team color.

- max_value:

  Numeric. Reference value that fills the whole cell. If `NULL` (the
  default), the maximum of the styled column is used.

- na_color:

  Color used when a team cannot be resolved.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

- strict:

  If `TRUE`, a value that does not resolve is an error; otherwise it
  becomes `NA` with one warning per call.

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
    team = colDef(style = reactable_sdv_team_color_bg(df, "team", league = "nfl")),
    wins = colDef(style = reactable_sdv_team_color_bar(df, "team", league = "nfl"))
  )
)

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","SF"],"wins":[13,12,11]},"columns":[{"id":"team","name":"team","type":"character","style":[{"background-color":"#E3183726"},{"background-color":"#00338D26"},{"background-color":"#AA000026"}]},{"id":"wins","name":"wins","type":"numeric","style":[{"background-image":"linear-gradient(90deg, #e31837 100%, transparent 100%)"},{"background-image":"linear-gradient(90deg, #00338d 92.3%, transparent 92.3%)"},{"background-image":"linear-gradient(90deg, #aa0000 84.6%, transparent 84.6%)"}]}],"dataKey":"4709b48efbba1dea748edda1bbc5ed2c"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
