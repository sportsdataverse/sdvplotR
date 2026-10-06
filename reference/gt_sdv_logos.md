# Render Logos in 'gt' Tables

Translate team abbreviations into logos and render these images in html
tables with the 'gt' package.

## Usage

``` r
gt_sdv_logos(
  gt_object,
  columns,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  height = 30,
  locations = NULL,
  include_name = FALSE,
  season = NULL
)
```

## Arguments

- gt_object:

  A table object created using
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- columns:

  The columns for which the image translation should be applied.
  Argument has no effect if `locations` is not `NULL`.

- sport:

  Character string identifying the sport.

- height:

  The absolute height (px) of the image in the table cell.

- locations:

  If `NULL` (the default), the function will render logos in argument
  `columns`. Otherwise, the cell or set of cells to be associated with
  the team name transformation. Only
  [`gt::cells_body()`](https://gt.rstudio.com/reference/cells_body.html),
  [`gt::cells_stub()`](https://gt.rstudio.com/reference/cells_stub.html),
  [`gt::cells_column_labels()`](https://gt.rstudio.com/reference/cells_column_labels.html),
  and
  [`gt::cells_row_groups()`](https://gt.rstudio.com/reference/cells_row_groups.html)
  helper functions can be used here.

- include_name:

  If `TRUE`, keep the cell's text after the logo, so a cell shows logo
  and name (what cbbplotR's `gt_cbb_teams()` did), and the image gets an
  empty `alt` so the name is not read twice. Defaults to `FALSE`, the
  logo alone, whose `alt` is the team's full name.

- season:

  `NULL` (the default) for today's logos, or one season whose marks
  every cell shows (the ending year for the NHL). See the Historical
  logos section.

## Value

An object of class `gt_tbl`.

## Historical logos

Given a `season`, a team is drawn with the mark it wore that season
where sdvplotR has one, and with today's logo otherwise. Coverage:

- NHL: every club identity since 1917-18, primary and dark marks from
  the NHL's own logo catalog; a club's current era draws today's logo.
  Teams are keyed by the NHL triCode of that identity (`"QUE"`, `"HFD"`,
  `"ATL"`, `"MNS"`, `"TBL"`); current clubs also answer to sdvplotR's
  abbreviation and full name (`"TB"`, `"Tampa Bay Lightning"`).

- NFL and WNBA: relocated and defunct identities only, one mark each:
  NFL `"STL"` (1995-2015) and `"SD"` (1961-2016); WNBA `"HOU"`, `"SAC"`,
  `"CHA"`, `"DET"`, `"TUL"`, `"SAS"` and `"SA"`.

- No other league has per-season logos yet.

A key only finds its own identity's marks: `"COL"` in 1990 draws today's
Avalanche logo (the Nordiques are `"QUE"`), and `"STL"` in 2020 today's
Rams. The images are copies kept in the SportsDataverse asset archive,
so they don't change when a league reuses a file name. The NHL marks are
SVG files, which 'ggpath' reads with the 'rsvg' package. `season` takes
single years: the ending year for the NHL (`2005` for 2004-05).

## See also

[`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
[`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)

## Examples

``` r
# \donttest{
library(gt)
library(sdvplotR)

teams <- valid_team_names("nfl")[1:8]
df <- data.frame(
  team = teams,
  logo = teams,
  wins = sample(1:16, 8)
)

df |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl")


  

team
```
