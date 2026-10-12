# Render Team Logos, Wordmarks and Headshots in 'reactable' Tables

Cell renderers for
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html)
that translate team abbreviations (or player IDs) into `<img>` tags.
Values that cannot be resolved are returned unchanged so the original
text is shown. Logos and wordmarks get the team's full name as `alt`
text, headshots `"Player <id> headshot"`.

## Usage

``` r
reactable_sdv_logos(
  league,
  variant = "default",
  height = 30,
  default_img = NULL,
  season = NULL,
  id_system = "auto",
  strict = FALSE
)

reactable_sdv_wordmarks(
  league,
  variant = "default",
  height = 30,
  default_img = NULL,
  season = NULL,
  id_system = "auto",
  strict = FALSE
)

reactable_sdv_headshots(
  league,
  height = 40,
  default_img = NULL,
  id_system = "espn"
)
```

## Arguments

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

- default_img:

  Character. Fallback image URL used when the value cannot be resolved.
  If `NULL` (the default) the raw value is shown instead.

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

A function with signature `function(value, index)` suitable for the
`cell` argument of
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html).

## See also

[`reactable_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_cols_label.md),
[`reactable_sdv_team_color_bar()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md),
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)

## Examples

``` r
library(reactable)
library(sdvplotR)

df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))

reactable(
  df,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(league = "nfl"), html = TRUE)
  )
)

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","SF"],"wins":[13,12,11]},"columns":[{"id":"team","name":"team","type":"character","cell":["<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png\" style=\"height:30px;vertical-align:middle;\" alt=\"Kansas City Chiefs\" />","<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png\" style=\"height:30px;vertical-align:middle;\" alt=\"Buffalo Bills\" />","<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png\" style=\"height:30px;vertical-align:middle;\" alt=\"San Francisco 49ers\" />"],"html":true},{"id":"wins","name":"wins","type":"numeric"}],"dataKey":"5f05ae58d80e801de80b4a291128f42a"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
