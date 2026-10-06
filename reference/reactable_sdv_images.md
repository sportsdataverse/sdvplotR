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
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  variant = c("primary", "dark", "scoreboard"),
  height = 30,
  default_img = NULL
)

reactable_sdv_wordmarks(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  variant = "primary",
  height = 30,
  default_img = NULL
)

reactable_sdv_headshots(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  height = 40,
  default_img = NULL,
  id_type = NULL
)
```

## Arguments

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

- default_img:

  Character. Fallback image URL used when the value cannot be resolved.
  If `NULL` (the default) the raw value is shown instead.

- id_type:

  Which ID system the player IDs hold: `NULL` (the default; GSIS IDs for
  the NFL, ESPN athlete IDs otherwise), `"espn"` or `"league"` (NBA /
  WNBA Stats `PERSON_ID`, MLBAM, NHL API, GSIS). See
  [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md).

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
    team = colDef(cell = reactable_sdv_logos(sport = "nfl"), html = TRUE)
  )
)

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","SF"],"wins":[13,12,11]},"columns":[{"id":"team","name":"team","type":"character","cell":["<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png\" style=\"height:30px;vertical-align:middle;\" alt=\"Kansas City Chiefs\" />","<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png\" style=\"height:30px;vertical-align:middle;\" alt=\"Buffalo Bills\" />","<img src=\"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png\" style=\"height:30px;vertical-align:middle;\" alt=\"San Francisco 49ers\" />"],"html":true},{"id":"wins","name":"wins","type":"numeric"}],"dataKey":"5f05ae58d80e801de80b4a291128f42a"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
