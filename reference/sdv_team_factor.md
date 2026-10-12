# Order Team Names as a Factor

A factor of `teams` as given, levels ordered by each team's
abbreviation; values that do not resolve are `NA` (with the resolver's
warning), so downstream ggplot2 scales drop them.

## Usage

``` r
sdv_team_factor(teams, league, season = NULL, id_system = "auto")
```

## Arguments

- teams:

  Character vector of team names.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- season, id_system:

  Passed to
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md).

## Value

A `factor` of `teams`.

## Examples

``` r
suppressWarnings(sdv_team_factor(c("KC", "BUF", "invalid"), league = "nfl"))
#> [1] KC   BUF  <NA>
#> Levels: BUF KC
```
