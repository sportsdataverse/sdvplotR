# Render Logos in 'gt' Tables

Translate team abbreviations into logos and render these images in html
tables with the 'gt' package.

## Usage

``` r
gt_sdv_logos(
  gt_object,
  columns,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  height = 30,
  locations = NULL
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

## Value

An object of class `gt_tbl`.

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
