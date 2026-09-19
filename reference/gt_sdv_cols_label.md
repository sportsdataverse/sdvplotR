# Render Logos in 'gt' Table Column Labels

Translate team abbreviations into logos and render these images in
column labels of 'gt' tables.

## Usage

``` r
gt_sdv_cols_label(
  gt_object,
  columns = gt::everything(),
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  height = 30,
  type = c("logo", "wordmark", "headshot")
)
```

## Arguments

- gt_object:

  A table object created using
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- columns:

  The columns whose labels should be replaced with logos.

- sport:

  Character string identifying the sport.

- height:

  The absolute height (px) of the image.

- type:

  One of `"logo"`, `"wordmark"` or `"headshot"`: whether the column
  names are team abbreviations (logo / wordmark) or player IDs
  (headshot).

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
  gt_sdv_cols_label(columns = c("KC", "BUF", "SF"), sport = "nfl")


  
```
