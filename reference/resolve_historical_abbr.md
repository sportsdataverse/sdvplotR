# Resolve Historical Team Abbreviations

Maps defunct or relocated franchise abbreviations to the abbreviation of
the current franchise, so historical data (e.g. `"OAK"` for the Raiders,
`"SEA"` for the SuperSonics) resolves to the correct current team
(`"LV"`, `"OKC"`).
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
applies these mappings automatically; this function exposes them
directly.

## Usage

``` r
resolve_historical_abbr(
  abbr,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
)
```

## Arguments

- abbr:

  Character vector of team abbreviations (possibly historical).

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

## Value

A character vector the same length as `abbr` holding the current-team
abbreviation, or the input unchanged where no mapping exists.

## Details

The result is the package's canonical key, the one
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
returns: nflverse abbreviations for the NFL (the St. Louis Rams' `"STL"`
gives `"LA"`), ESPN's elsewhere (`"NOH"` gives `"NO"`, `"WSB"` gives
`"WSH"`). A relocation key follows the franchise, in both functions:
`"WIN"` is the original Winnipeg Jets (1979-96), so it gives the Utah
club they became, while today's Jets are `"WPG"`.

## Examples

``` r
resolve_historical_abbr(c("OAK", "SD", "KC"), sport = "nfl")
#> [1] "LV"  "LAC" "KC" 
resolve_historical_abbr("MON", sport = "mlb")
#> [1] "WSH"
resolve_historical_abbr("SEA", sport = "nba")
#> [1] "OKC"
```
