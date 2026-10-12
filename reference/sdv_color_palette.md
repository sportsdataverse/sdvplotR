# Team colour palette

A named colour vector for
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
and friends. The R counterpart of sdvplot's
[`palette()`](https://rdrr.io/r/grDevices/palette.html).

## Usage

``` r
sdv_color_palette(
  league,
  teams = NULL,
  which = c("primary", "secondary"),
  season = NULL,
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- teams:

  Team identifiers, or `NULL` for every team.

- which:

  `"primary"` or `"secondary"`.

- season:

  `NULL`, one season year, or one per value: picks the team that used a
  reused code that season. Without one, a reused code means its current
  holder. Split seasons take their ending year (2021 for 2020-21).

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

- strict:

  If `TRUE`, a value that does not resolve is an error; otherwise it
  becomes `NA` with one warning per call.

## Value

A named character vector of hex colours, unresolved teams dropped.

## Examples

``` r
sdv_color_palette("nfl", c("KC", "BUF", "SF"))
#>        KC       BUF        SF 
#> "#e31837" "#00338d" "#aa0000" 
```
