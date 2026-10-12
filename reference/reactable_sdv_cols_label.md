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
  league,
  variant = "default",
  height = 30,
  season = NULL,
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- .data:

  A data frame whose column names are team abbreviations.

- ...:

  Additional arguments passed to every
  [`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- variant:

  Character. `"default"`, `"dark"`, or a named variant from
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  (`"scoreboard"`, `"grayscale"`, ...); see
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md).
  A team without it gets its closest mark, and in the browser the image
  falls back to the default mark when the variant's file fails to load.

- height:

  Numeric. Image height in pixels.

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

## Value

A named list of `colDef` objects for the `columns` argument of
[`reactable::reactable()`](https://glin.github.io/reactable/reference/reactable.html).

## Examples

``` r
library(reactable)
library(sdvplotR)

df <- data.frame(KC = 1:3, BUF = 4:6, SF = 7:9)
reactable(df, columns = reactable_sdv_cols_label(df, league = "nfl"))

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"KC":[1,2,3],"BUF":[4,5,6],"SF":[7,8,9]},"columns":[{"id":"KC","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png\" style=\"height:30px;\" alt=\"Kansas City Chiefs\" />","html":true},{"id":"BUF","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png\" style=\"height:30px;\" alt=\"Buffalo Bills\" />","html":true},{"id":"SF","name":"","type":"numeric","header":"<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png\" style=\"height:30px;\" alt=\"San Francisco 49ers\" />","html":true}],"dataKey":"23ae1938f096496d5ea51b990bee02dd"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
