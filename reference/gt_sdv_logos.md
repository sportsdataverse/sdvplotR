# Render Logos in 'gt' Tables

Translate team abbreviations into logos and render these images in html
tables with the 'gt' package.

## Usage

``` r
gt_sdv_logos(
  gt_object,
  columns,
  league,
  height = 30,
  locations = NULL,
  include_name = FALSE,
  season = NULL,
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- gt_object:

  A table object created using
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- columns:

  The columns for which the image translation should be applied.
  Argument has no effect if `locations` is not `NULL`.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

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

  `NULL` (the default) for today's marks, or one season whose marks
  every cell shows (the ending year for the NHL). See the Historical
  logos section.

- id_system, strict:

  How the team values are read and what an unresolved one does, as in
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md).

## Value

An object of class `gt_tbl`.

## Historical logos

Given a `season`, a team is drawn with the mark it wore that season
where the SportsDataverse logo archive dates its marks, and with its
current mark otherwise. The season also picks the team a reused code
meant then (see
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)).
The images are copies kept in the archive, so they don't change when a
league reuses a file name. SVG marks are read with the 'rsvg' package.
`season` takes single years: the ending year for split seasons (`2005`
for 2004-05).

## See also

[`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
[`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)

## Examples

``` r
# \donttest{
library(gt)
library(sdvplotR)

teams <- sdv_teams("nfl")$abbr[1:8]
df <- data.frame(
  team = teams,
  logo = teams,
  wins = sample(1:16, 8)
)

df |>
  gt() |>
  gt_sdv_logos(columns = "logo", league = "nfl")


  

team
```
