# A surveyed table style as a `gt` theme

Styles a table like one of the 122 surveyed sources listed by
[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md)
(`"datagolf"`, `"wikipedia"`, `"economist"`, ...). Fonts, ground, text
and rule colors, row rules, column rules, striping, label case and
tracking, and padding come from the theme's spec
([`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md)).

## Usage

``` r
gt_theme_source(gt_object, name, mode = "light", density = "comfortable")
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- name:

  A registry theme id, for example `"datagolf"` or `"wikipedia"`.

- mode:

  `"light"` (default) or `"dark"`. `"dark"` on a light-only theme is an
  error that names three dark-capable themes in the same category.

- density:

  Character. The type and padding scale. One of `"comfortable"` (the
  spec's own sizes), `"compact"` or `"social"`.

## Value

A modified `gt` table with the theme applied.

## Details

The spec's sizes are the `"comfortable"` baseline; `density` rescales
type and padding by the house density ratios, as the other
`gt_theme_*()` functions do. Each face is a Google font written with its
generic family (`'Lora', serif`), so a face that fails to load degrades
to the right kind of font. The borders, stripes and tracking `gt` has no
option for are written as css scoped to this table's id.

## See also

[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md),
[`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md),
[`reactable_sdv_theme()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_theme.md)

## Examples

``` r
library(gt)
central <- subset(
  sdv_example_standings, division == "Central",
  c(team_name, wins, losses, win_pct)
)
gt(central) |> gt_theme_source("datagolf")


  

team_name
```
