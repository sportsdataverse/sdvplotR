# Render Wordmarks in 'gt' Tables

Translate team abbreviations into wordmarks and render these images in
html tables with the 'gt' package.

## Usage

``` r
gt_sdv_wordmarks(
  gt_object,
  columns,
  league,
  height = 30,
  locations = NULL,
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

- season:

  `NULL` (the default) for today's marks, or one season whose marks
  every cell shows (the ending year for the NHL). See the Historical
  logos section.

- id_system, strict:

  How the team values are read and what an unresolved one does, as in
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md).

## Value

An object of class `gt_tbl`.

## See also

[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
[`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)

## Examples

``` r
# \donttest{
library(gt)
df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(14, 13, 12))
df |>
  gt() |>
  gt_sdv_wordmarks(columns = "team", league = "nfl")


  

team
```
