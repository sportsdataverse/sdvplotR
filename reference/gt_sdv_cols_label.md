# Render Logos in 'gt' Table Column Labels

Translate team abbreviations into logos and render these images in
column labels of 'gt' tables.

## Usage

``` r
gt_sdv_cols_label(
  gt_object,
  columns = gt::everything(),
  league,
  height = 30,
  mark_type = c("logo", "wordmark", "headshot"),
  id_system = "auto",
  season = NULL,
  strict = FALSE
)
```

## Arguments

- gt_object:

  A table object created using
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- columns:

  The columns whose labels should be replaced with logos.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- height:

  The absolute height (px) of the image.

- mark_type:

  One of `"logo"`, `"wordmark"` or `"headshot"`: whether the column
  names are teams (logo / wordmark) or player IDs (headshot).

- id_system:

  How the column names are read. `"auto"` (the default) is
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)'s
  automatic reading for logo and wordmark labels, and means `"espn"`
  when `mark_type = "headshot"`; otherwise as in
  [`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md).

- season, strict:

  For logo and wordmark labels only (headshots take neither): the season
  whose mark to show, and whether an unresolved label is an error. With
  `strict = TRUE` every label that is not a team errors, including the
  non-team columns the default `columns = gt::everything()` takes.

## Value

An object of class `gt_tbl`.

## See also

[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
[`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md)

## Examples

``` r
# \donttest{
library(gt)
library(sdvplotR)

df <- data.frame(
  KC = 1:3,
  BUF = 4:6,
  SF = 7:9
)

df |>
  gt() |>
  gt_sdv_cols_label(columns = c("KC", "BUF", "SF"), league = "nfl")


  
```
