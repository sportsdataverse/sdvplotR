# Clean team names to one display name

Standardizes team names, abbreviations and ids to one display name per
team, for joins and labels. The counterpart of cfbplotR's
`clean_school_names()` and its alias (and of nflplotR's abbreviation
cleaner with `column = "abbr"`), built on
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md):
every alias and id system it reads cleans to the same name, and a value
it cannot resolve without guessing (an unknown name, or one that names
two teams) is not cleaned.

## Usage

``` r
sdv_clean_names(
  x,
  league,
  keep_non_matches = TRUE,
  column = c("location", "short_name", "name", "abbr", "team_id"),
  season = NULL,
  id_system = "auto"
)
```

## Arguments

- x:

  A vector of team identifiers (character, numeric or factor).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- keep_non_matches:

  If `TRUE` (the default) a value that does not resolve is kept as it
  is, quietly. Otherwise it becomes `NA`, with one warning per call.

- column:

  The
  [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)
  column to return: `"location"` (the default; the school in college
  sports, the city in the pros, and closest to cfbplotR's names),
  `"short_name"`, `"name"`, `"abbr"` or `"team_id"`.

- season:

  `NULL`, one season year, or one per value: picks the team that used a
  reused code that season. Without one, a reused code means its current
  holder. Split seasons take their ending year (2021 for 2020-21).

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"yahoo"`, `"kenpom"`, `"torvik"`, `"sdvplotr"`, `"name"`, or one
  `"auto"` never tries because its numbers overlap ESPN's: `"nhl_id"`
  (NHL stats API ids), `"fox"`, `"cbs"`, `"sports247"` (247Sports team
  and institution ids) or `"on3"`.

## Value

A character vector the length of `x`.

## See also

[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
for team ids,
[`sdv_aliases()`](https://sdvplotR.sportsdataverse.org/reference/sdv_aliases.md)
for every name the index knows.

## Examples

``` r
x <- c("utah", "San Jose State", "Hawaii", "UTSA", "SLC", "USC")
# keep the values that do not resolve
sdv_clean_names(x, "cfb")
#> [1] "Utah"           "San José State" "Hawai'i"        "UTSA"          
#> [5] "SLC"            "USC"           
# or replace them with NA
sdv_clean_names(x, "cfb", keep_non_matches = FALSE)
#> Warning: 1 value did not resolve to a "cfb" team: 'SLC' (unknown).
#> ℹ Use `sdv_suggest()` for candidates, or `strict = TRUE` to error.
#> [1] "Utah"           "San José State" "Hawai'i"        "UTSA"          
#> [5] NA               "USC"           
sdv_clean_names(c("Kansas City Chiefs", "OAK"), "nfl", column = "abbr")
#> [1] "KC" "LV"
```
