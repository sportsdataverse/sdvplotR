# Dunks & Threes table style for `gt` tables

A shortcut for `gt_theme_source(gt_object, "dunks-and-threes")`: the
Dunks & Threes table style from the surveyed registry (category
`sports`). `mode = "dark"` uses the theme's dark palette.

## Usage

``` r
gt_theme_dunks_and_threes(gt_object, mode = "light", density = "comfortable")
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- mode:

  `"light"` (default) or `"dark"`.

- density:

  Character. The type and padding scale. One of `"comfortable"`,
  `"compact"` or `"social"`.

## Value

A modified `gt` table with the theme applied.

## See also

[`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md),
[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md)

## Examples

``` r
library(gt)
central <- subset(
  sdv_example_standings, division == "Central",
  c(team_name, wins, losses, win_pct)
)
gt(central) |> gt_theme_dunks_and_threes()


  

team_name
```
