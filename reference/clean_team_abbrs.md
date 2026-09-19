# Standardize Team Abbreviations

Standardizes team abbreviations to the canonical abbreviations used by
sdvplotR. Matching is case-insensitive and understands full team names
(`"Kansas City Chiefs"`), common alternate abbreviations used by other
data sources (`"WSH"` / `"WAS"`, `"GNB"` / `"GB"`), and historical
abbreviations of relocated franchises (see
[`resolve_historical_abbr()`](https://sdvplotR.sportsdataverse.org/reference/resolve_historical_abbr.md)).

## Usage

``` r
clean_team_abbrs(
  abbr,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  keep_non_matches = TRUE
)
```

## Arguments

- abbr:

  A character vector of abbreviations or team names.

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- keep_non_matches:

  If `TRUE` (the default) an element of `abbr` that can't be matched
  will be kept as is. Otherwise it will be replaced with `NA`.

## Value

A character vector with cleaned team abbreviations.

## Examples

``` r
clean_team_abbrs(c("KC", "kansas city chiefs", "OAK", "WSH"), sport = "nfl")
#> [1] "KC"  "KC"  "LV"  "WAS"
clean_team_abbrs(c("BOS", "GS", "INVALID"), sport = "nba", keep_non_matches = FALSE)
#> [1] "BOS" "GS"  NA   
```
