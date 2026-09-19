# Replace 'reactable' Column Headers with Team Logos

Builds a named list of
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html)
objects whose headers are team logos, for data frames whose column names
are team abbreviations. Columns that cannot be resolved are left out of
the list so `reactable` falls back to the plain column name.

## Usage

``` r
reactable_sdv_cols_label(
  .data,
  ...,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  variant = c("primary", "dark", "light", "alt", "classic", "helmet"),
  height = 30
)
```

## Arguments

- .data:

  A data frame whose column names are team abbreviations.

- ...:

  Additional arguments passed to every
  [`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html).

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- variant:

  Character. Logo variant: `"primary"`, `"dark"`, `"light"`, `"alt"`,
  `"classic"`, or `"helmet"` (NFL only). Falls back to the primary image
  when the requested variant is not available for a team.

- height:

  Numeric. Image height in pixels.

## Value

A named list of `colDef` objects for the `columns` argument of
[`reactable::reactable()`](https://glin.github.io/reactable/reference/reactable.html).

## Examples

``` r
library(reactable)
library(sdvplotR)

df <- data.frame(KC = 1:3, BUF = 4:6, SF = 7:9)
reactable(df, columns = reactable_sdv_cols_label(df, sport = "nfl"))

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"KC":[1,2,3],"BUF":[4,5,6],"SF":[7,8,9]},"columns":[{"id":"KC","name":"","type":"numeric","header":"<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/kc.png\" style=\"height:30px;\" alt=\"KC\" />","html":true},{"id":"BUF","name":"","type":"numeric","header":"<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/buf.png\" style=\"height:30px;\" alt=\"BUF\" />","html":true},{"id":"SF","name":"","type":"numeric","header":"<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/sf.png\" style=\"height:30px;\" alt=\"SF\" />","html":true}],"dataKey":"4b0e34ca34362132865398d629729103"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
