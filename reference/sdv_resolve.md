# Resolve team identifiers to canonical team ids

Turns whatever team identifiers you have (abbreviations, full names,
ESPN, nflverse, MLB Stats, nba_api, HockeyTech, CFBD, Sports Reference
and other ids) into the index's canonical `team_id`, never guessing.
Every sdvplotR helper that takes a team resolves it this way. The R
counterpart of sdvplot's `resolve()`, and it gives the same answers.

## Usage

``` r
sdv_resolve(x, league, season = NULL, id_system = "auto", strict = FALSE)
```

## Arguments

- x:

  A vector of team identifiers (character, numeric or factor).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

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

A character vector of `team_id`s, the length of `x`.

## See also

[`sdv_suggest()`](https://sdvplotR.sportsdataverse.org/reference/sdv_suggest.md)
for a value that did not resolve,
[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md).

## Examples

``` r
sdv_resolve(c("KC", "Kansas City Chiefs", "OAK"), "nfl")
#> [1] "12" "12" "13"
sdv_resolve("QUE", "nhl", season = 1990)
#> [1] "17"
sdv_resolve(c("Iowa St.", "Miami (OH)"), "mbb")
#> [1] "66"  "193"
```
