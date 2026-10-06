# Convert Shot Locations to a sportyR Court Frame

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

`provider = "euroleague"` converts the Euroleague shot frame of hoopR's
`euroleague_game_points()` (`coord_x`/`coord_y`) instead, onto the FIBA
court `sdv_surface("fiba")` draws, in meters.

## Usage

``` r
sdv_court_coords(
  data,
  x_column = "x_legacy",
  y_column = "y_legacy",
  provider = "nba"
)
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
  value (tenths of a foot), or Euroleague `coord_x` (centimeters).
  Default `"x_legacy"`.

- y_column:

  String naming the column holding the stats-API `LOC_Y` / `y_legacy`
  value (tenths of a foot), or Euroleague `coord_y` (centimeters).
  Default `"y_legacy"`.

- provider:

  The frame of `data`, which sets the output's units: `"nba"` (the
  default; stats.nba.com / stats.wnba.com, tenths of a foot in, **feet**
  out on the NBA/WNBA/NCAA court) or `"euroleague"` (hoopR's
  `euroleague_game_points()` `coord_x`/`coord_y`, centimeters in,
  **meters** out on the FIBA court). Case is ignored.

## Value

`data` with `court_x` and `court_y` added (existing columns of those
names are replaced); every other input column is kept as-is:

|  |  |  |
|----|----|----|
| col_name | type | description |
| court_x | numeric | Along the court: the basket at -41.75 ft (nba) or -12.425 m (euroleague), half court at 0 |
| court_y | numeric | Across the court: -25 to 25 ft (nba; negative = shooter's left) or -7.5 to 7.5 m (euroleague) |

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

The Euroleague frame (`provider = "euroleague"`; measured on real games,
2026-10-06) is integer centimeters with the hoop at the origin, both
teams mapped onto one basket, `coord_y` growing away from the baseline
toward the court, and free throws encoded as `coord_x = coord_y = -1` (a
sentinel, not a location), which become `NA`. The FIBA court is 28 x 15
m with its basket 1.575 m from the baseline, so
`court_x = -12.425 + coord_y / 100` and `court_y = coord_x / 100`. Which
sideline is positive `coord_x` is unverified, so a chart may be
left-right mirrored; the court is symmetric, so distances and zones are
unaffected.

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

# Euroleague shots (hoopR::euroleague_game_points() columns) onto the FIBA court
euro <- data.frame(coord_x = c(0, 12, 650, -1), coord_y = c(0, 422, 50, -1))
sdv_court_coords(euro, "coord_x", "coord_y", provider = "euroleague")
#>   coord_x coord_y court_x court_y
#> 1       0       0 -12.425    0.00
#> 2      12     422  -8.205    0.12
#> 3     650      50 -11.925    6.50
#> 4      -1      -1      NA      NA
# \donttest{
if (requireNamespace("sportyR", quietly = TRUE)) {
  library(ggplot2)
  euro <- sdv_court_coords(euro, "coord_x", "coord_y", provider = "euroleague")
  sdv_surface("fiba", display_range = "defense") +
    geom_point(aes(court_x, court_y), data = euro, colour = "red", size = 3, na.rm = TRUE)
}

# }
```
