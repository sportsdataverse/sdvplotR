# Render Team Logos, Wordmarks and Headshots in 'reactable' Tables

Cell renderers for
[`reactable::colDef()`](https://glin.github.io/reactable/reference/colDef.html)
that translate team abbreviations (or player IDs) into `<img>` tags.
Values that cannot be resolved are returned unchanged so the original
text is shown.

## Usage

``` r
reactable_sdv_logos(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  variant = c("primary", "dark", "light", "alt", "classic", "helmet"),
  height = 30,
  default_img = NULL
)

reactable_sdv_wordmarks(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  variant = c("primary", "dark", "light", "alt", "classic"),
  height = 30,
  default_img = NULL
)

reactable_sdv_headshots(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  height = 40,
  default_img = NULL
)
```

## Arguments

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- variant:

  Character. Logo variant: `"primary"`, `"dark"`, `"light"`, `"alt"`,
  `"classic"`, or `"helmet"` (NFL only). Falls back to the primary image
  when the requested variant is not available for a team.

- height:

  Numeric. Image height in pixels.

- default_img:

  Character. Fallback image URL used when the value cannot be resolved.
  If `NULL` (the default) the raw value is shown instead.

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

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","SF"],"wins":[13,12,11]},"columns":[{"id":"team","name":"team","type":"character","cell":["<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/kc.png\" style=\"height:30px;vertical-align:middle;\" alt=\"KC\" />","<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/buf.png\" style=\"height:30px;vertical-align:middle;\" alt=\"BUF\" />","<img src=\"https://a.espncdn.com/i/teamlogos/nfl/500/sf.png\" style=\"height:30px;vertical-align:middle;\" alt=\"SF\" />"],"html":true},{"id":"wins","name":"wins","type":"numeric"}],"dataKey":"316b90fa9ba7f260efd50e896f583a4b"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
