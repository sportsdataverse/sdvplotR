# Convert stats.nba.com/stats.wnba.com Shot Locations to a sportyR Court Frame

stats.nba.com / stats.wnba.com shot-chart data reports shot locations in
the NBA's legacy frame: tenths of a foot, origin at the hoop, relative
to the shooter's basket. hoopR's/wehoop's `load_nba_stats_shots()` /
`load_wnba_stats_shots()` ship these columns as `x_legacy`/`y_legacy`
(snake_case); the `Shot_Chart_Detail` element of hoopR's
`nba_shotchartdetail()` uses the same frame, in the `LOC_X`/`LOC_Y`
columns stats.nba.com returns (upper snake case). This converts them
(feet, not tenths) into the frame `sportyR::geom_basketball("nba")`
draws: origin at center court, baseline at `x = -47`, basket on the
**left** at `x = -41.75`.

## Usage

``` r
sdv_court_coords(data, x_column = "x_legacy", y_column = "y_legacy")
```

## Arguments

- data:

  A data frame with shot-location columns, e.g. from
  [`hoopR::load_nba_stats_shots()`](https://hoopR.sportsdataverse.org/reference/load_nba_stats_coaches.html)
  /
  [`wehoop::load_wnba_stats_shots()`](https://wehoop.sportsdataverse.org/reference/load_wnba_stats_coaches.html)
  (`x_legacy`/`y_legacy`).
  [`hoopR::nba_shotchartdetail()`](https://hoopR.sportsdataverse.org/reference/nba_shotchartdetail.html)
  returns a named list: pass its `Shot_Chart_Detail` data frame and name
  the `LOC_X`/`LOC_Y` columns, e.g.
  `sdv_court_coords(res$Shot_Chart_Detail, "LOC_X", "LOC_Y")`.

- x_column:

  String naming the column holding the stats-API `LOC_X` / `x_legacy`
  value (tenths of a foot). Default `"x_legacy"`.

- y_column:

  String naming the column holding the stats-API `LOC_Y` / `y_legacy`
  value (tenths of a foot). Default `"y_legacy"`.

## Value

`data` with `court_x` and `court_y` added (existing columns of those
names are replaced); every other input column is kept as-is:

|  |  |  |
|----|----|----|
| col_name | type | description |
| court_x | numeric | Feet along the court's length: baseline at -47, basket at -41.75, half-court line at 0 |
| court_y | numeric | Feet across the court's width: -25 to 25; negative = shooter's left (TV-bottom sideline) |

## Details

The NBA legacy shot-location frame (`LOC_X`/`LOC_Y`, or
`x_legacy`/`y_legacy`; tenths of a foot, hoop at the origin, relative to
the shooter's basket) maps with negative x as the shooter's left corner:
`court_y` is `x_column / 10` with no sign flip, so a left-corner three
lands at negative `court_y` (the TV-bottom sideline), which is the
shooter's left when facing the TV-left basket. Verified on real 2022-23
`shotchartdetail` data (Left Corner 3 `LOC_X` -249..-221, Right Corner 3
+221..+248).

Shots land on sportyR's TV-left half, so draw half-court charts with
`sportyR::geom_basketball("nba", display_range = "defense")` or the full
court; `display_range = "offense"` shows the TV-right half and none of
the shots.

The converted points also fit sportyR's `"wnba"` and `"ncaa"` courts,
which share the `"nba"` court's 94-foot floor and 5.25-foot basket
offset. The input must still be in the NBA legacy frame (tenths of a
foot, hoop at the origin: `x_legacy`/`y_legacy` or `LOC_X`/`LOC_Y`).
Don't pass ESPN `coordinate_x`/`coordinate_y` from hoopR/wehoop
play-by-play: they are already in feet on a center-court frame.

Coordinate columns must be numeric, or character holding numbers, which
is coerced (`nba_shotchartdetail()` returns every column as character).
Factors, `TRUE`/`FALSE` and strings that aren't numbers (such as `""` or
`"NA"`) raise an error. Missing values stay `NA`, and an all-`NA` column
(even a logical one) gives `NA` coordinates.

## Examples

``` r
shots <- data.frame(x_legacy = c(-224, 240), y_legacy = c(39, 29))
sdv_court_coords(shots)
#>   x_legacy y_legacy court_x court_y
#> 1     -224       39  -37.85   -22.4
#> 2      240       29  -38.85    24.0
```
