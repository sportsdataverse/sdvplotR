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
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  variant = c("primary", "dark", "scoreboard"),
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

  Character. Logo variant: `"primary"`, `"dark"`, `"scoreboard"` or a
  named mark of the sport (see
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md));
  wordmarks come in `"primary"` for the NFL and MLB, plus `"on_light"` /
  `"on_dark"` for MLB. Falls back to the primary image when the
  requested variant is not available for a team, and, in the browser,
  when the variant's file fails to load.

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

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"KC":[1,2,3],"BUF":[4,5,6],"SF":[7,8,9]},"columns":[{"id":"KC","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png\" style=\"height:30px;\" alt=\"Kansas City Chiefs\" />","html":true},{"id":"BUF","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png\" style=\"height:30px;\" alt=\"Buffalo Bills\" />","html":true},{"id":"SF","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png\" style=\"height:30px;\" alt=\"San Francisco 49ers\" />","html":true}],"dataKey":"23ae1938f096496d5ea51b990bee02dd"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
