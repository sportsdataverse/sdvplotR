# Every archived mark for a team

The logo manifest's rows for one team (logos and wordmarks, every
variant, source and era), best first: the rows the logo helpers choose
from. The R counterpart of sdvplot's `marks()`.

## Usage

``` r
sdv_marks(team, league, season = NULL, id_system = "auto")
```

## Arguments

- team:

  One team identifier, or a conference or league key (`"SEC"`, `"AFC"`).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- season:

  `NULL`, or one season: which team `team` names where a code was reused
  across eras. The rows returned cover every season.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

## Value

A data frame of manifest rows with `team_id`, `variant`, `mark_type`,
`valid_from`, `valid_to` (the effective season range), `source`,
`source_rank` and `archive_url`.

## Examples

``` r
m <- sdv_marks("KC", "nfl")
table(m$variant)
#> 
#>                              dark                           default 
#>                                 1                                 2 
#>                         grayscale                primary_logo_black 
#>                                 1                                 1 
#>       primary_logo_on_black_color     primary_logo_on_primary_color 
#>                                 1                                 1 
#>   primary_logo_on_secondary_color       primary_logo_on_white_color 
#>                                 1                                 1 
#>                primary_logo_white                        scoreboard 
#>                                 1                                 1 
#>                   scoreboard_dark              secondary_logo_black 
#>                                 1                                 1 
#>     secondary_logo_on_black_color   secondary_logo_on_primary_color 
#>                                 1                                 1 
#> secondary_logo_on_secondary_color     secondary_logo_on_white_color 
#>                                 1                                 1 
#>              secondary_logo_white                           squared 
#>                                 1                                 1 
```
