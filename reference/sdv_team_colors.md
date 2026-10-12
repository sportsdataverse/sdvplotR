# Team colours

Primary and secondary colours (hex) for teams, resolved from any
identifier
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
accepts. The R counterpart of sdvplot's `team_colors()`.

## Usage

``` r
sdv_team_colors(
  league,
  team = NULL,
  which = c("primary", "secondary", "all"),
  season = NULL,
  id_system = "auto",
  strict = FALSE,
  include_conferences = FALSE
)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- team:

  Team identifiers, or `NULL` for every team in the league.

- which:

  `"primary"`, `"secondary"`, or `"all"` (both).

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

- include_conferences:

  With `team = NULL`, also list conference and league rows (see
  [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)).

## Value

With `team` given, a character vector named by `team` (`NA` where a team
does not resolve); for `which = "all"`, `"primary, secondary"` strings.
With `team = NULL`, a vector named by abbreviation (the `team_id` where
a team has none), or for `which = "all"` a data frame:

|           |           |                                               |
|-----------|-----------|-----------------------------------------------|
| col_name  | type      | description                                   |
| team_id   | character | Canonical team id                             |
| abbr      | character | Abbreviation (`NA` where the league has none) |
| name      | character | Full name                                     |
| primary   | character | Primary colour (hex)                          |
| secondary | character | Secondary colour (hex; `NA` where none)       |

## Examples

``` r
sdv_team_colors("nfl", "KC")
#>        KC 
#> "#e31837" 
sdv_team_colors("nfl", c("KC", "Buffalo Bills"), which = "all")
#>                 KC      Buffalo Bills 
#> "#e31837, #ffb612" "#00338d, #c60c30" 
sdv_team_colors("ahl", which = "primary")
#>       307       309       310       311       312       313       314       315 
#> "#202458" "#fcaa07" "#be2d39" "#53526d" "#022e63" "#f68129" "#e80215" "#45342d" 
#>       316       317       318       319       321       323       324       325 
#> "#feba21" "#00468c" "#d2454b" "#402a2e" "#002d62" "#011689" "#003e7f" "#036188" 
#>       326       327       328       329       330       331       334       335 
#> "#b86914" "#90b3cf" "#77613e" "#015836" "#000000" "#000000" "#013f68" "#003e7e" 
#>       336       337       344       370       371       372       373       375 
#> "#b2a07c" "#644b37" "#919497" "#02667f" "#db0425" "#2c2323" "#bc9856" "#bb0011" 
#>       379       380       383       384       387       389       390       395 
#> "#000000" "#0e8242" "#011436" "#dc0019" "#1d275d" "#00512f" "#d42233" "#1fbfc9" 
#>       396       397       398       399       400       402       403       404 
#> "#0a1f50" "#002f87" "#514356" "#a97e34" "#cb0111" "#fb4210" "#fcb426" "#f47937" 
#>       405       406       411       412       413       414       415       419 
#> "#00788a" "#cb0211" "#091f40" "#7a0023" "#ca2030" "#d31c2e" "#222a62" "#fad566" 
#>       437       440       444       445       457 
#> "#000000" "#002d56" "#cf152d" "#c8102e" "#00468c" 
```
