# Standardize Team Abbreviations

Standardizes team abbreviations to the canonical abbreviations used by
sdvplotR. Matching is case-insensitive and understands full team names
(`"Kansas City Chiefs"`), common alternate abbreviations used by other
data sources (`"WSH"` / `"WAS"`, `"GNB"` / `"GB"`), and historical
abbreviations of relocated franchises (see
[`resolve_historical_abbr()`](https://sdvplotR.sportsdataverse.org/reference/resolve_historical_abbr.md)).
For the college sports it also takes the school names NCAA.com /
stats.ncaa.org, KenPom, Bart Torvik and Sports Reference use
(`"Iowa St."`, `"St. John's (NY)"`, `"Saint Mary's (CA)"`,
`"Southern California"`, `"Brigham Young"`). Conference names resolve to
the conference: ESPN's (`"SEC"`, `"Southeastern Conference"`) and the
NCAA's, KenPom's and Torvik's (`"B10"`, `"MWC"`). Where a team already
uses the name, the team wins, so the American Athletic Conference is
`"AAC"` (`"American"` is American University).

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
clean_team_abbrs(c("Iowa St.", "St. John's (NY)", "Miami (OH)"), sport = "mbb")
#> [1] "ISU"  "SJU"  "M-OH"
```
