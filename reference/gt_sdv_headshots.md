# Render Player Headshots in 'gt' Tables

Translate player IDs to player headshots and render these images in html
tables with the 'gt' package. IDs are ESPN athlete IDs in every league,
or as `id_system` says. IDs that resolve to no headshot are left as
text.

## Usage

``` r
gt_sdv_headshots(
  gt_object,
  columns,
  league,
  height = 30,
  locations = NULL,
  id_system = "espn"
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

- id_system:

  `"espn"` (ESPN athlete ids; the default, for every league with ESPN
  headshots: nfl, nba, wnba, mlb, nhl, cfb, mbb, wbb), `"gsis"`
  (nflverse's NFL gsis ids, such as `"00-0033873"`, read through a
  published map) or `"league"` (the league's own player id: NBA / WNBA
  Stats `PERSON_ID`, MLBAM, NHL API; for the NFL, the gsis id).

## Value

An object of class `gt_tbl`.

## See also

[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
[`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
[`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)

## Examples

``` r
# \donttest{
library(gt)
library(sdvplotR)

df <- data.frame(
  player_id = c("00-0033873", "00-0026498", "00-0035228"),
  player_name = c("P.Mahomes", "M.Stafford", "K.Murray")
)

df |>
  gt() |>
  gt_sdv_headshots(columns = "player_id", league = "nfl", id_system = "gsis")


  

player_id
```
