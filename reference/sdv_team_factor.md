# Order Team Names as a Factor

Creates a factor of cleaned, valid team names. Levels are restricted to
teams present in
[`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md)
so that downstream ggplot2 scales drop invalid entries gracefully.

## Usage

``` r
sdv_team_factor(
  teams,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
)
```

## Arguments

- teams:

  Character vector of team names.

- sport:

  Character string identifying the sport.

## Value

An ordered `factor` of the cleaned, valid team names.

## Examples

``` r
sdv_team_factor(c("KC", "BUF", "invalid"), sport = "nfl")
#> [1] KC   BUF  <NA>
#> Levels: BUF KC
```
