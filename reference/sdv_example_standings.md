# Final regular-season standings for the examples

Real standings for one completed season in two leagues, one row per
team: the 2025 NFL season and the 2025-26 NBA season. The reference
examples run on it, so the table and plot helpers are shown on sports
data. Each `team` is the abbreviation
[`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md)
lists, so it works as the team input of every logo, color and headshot
helper as it is.

## Usage

``` r
sdv_example_standings
```

## Format

A tibble with 62 rows (32 NFL teams, then 30 NBA teams), ordered by
league, conference, division and division finish, and 16 columns:

- league:

  `"nfl"` or `"nba"`, the `sport` value the helpers take.

- season:

  `2025` for the NFL; `2026` for the NBA, whose 2025-26 season goes by
  its ending year as in 'hoopR'.

- team:

  Team abbreviation.

- espn_team_id:

  ESPN team id.

- team_name:

  Full team name.

- conference:

  `"AFC"` or `"NFC"`; `"Eastern"` or `"Western"`.

- division:

  Division, as `"AFC East"` or `"Atlantic"`.

- wins, losses, ties:

  The regular-season record. NBA games can't end tied, so `ties` is `0`
  there.

- win_pct:

  Winning percentage, a tie counting as half a win, rounded to three
  decimals.

- points_for, points_against:

  Regular-season points scored and allowed.

- conference_rank:

  Final place in the conference with the league's tiebreakers applied:
  the NFL's playoff seeds are 1 to 7, the NBA's playoff places 1 to 6
  and its play-in places 7 to 10.

- playoff_wins:

  Postseason wins, not counting the NBA's play-in; `NA` for a team that
  missed the playoffs.

- last_season_wins:

  Regular-season wins the season before: the NFL's 2024 and the NBA's
  2024-25.

## Source

Built by `data-raw/sdv_examples.R`. NFL: the nflverse schedules release,
`nflreadr::load_schedules(2025)`, with the standings and conference
ranks from
[`nflseedR::nfl_standings()`](https://nflseedr.com/reference/nfl_standings.html).
NBA: the sportsdataverse-data team box release,
`hoopR::load_nba_team_box(2026)`, counting standings games only (not the
NBA Cup final or the All-Star games), with divisions and conference
ranks from ESPN's standings (the endpoint
[`hoopR::espn_nba_standings()`](https://hoopR.sportsdataverse.org/reference/espn_mbb_standings.html)
reads), whose records the script checks against the box scores.
`last_season_wins` comes from the same loaders one season back. Team
names and ESPN ids come from
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md).

## Examples

``` r
# one division, in finishing order
subset(sdv_example_standings, division == "NFC West", c(team, wins:win_pct))
#> # A tibble: 4 × 5
#>   team   wins losses  ties win_pct
#>   <chr> <int>  <int> <int>   <dbl>
#> 1 SEA      14      3     0   0.824
#> 2 LA       12      5     0   0.706
#> 3 SF       12      5     0   0.706
#> 4 ARI       3     14     0   0.176

# the teams that reached the playoffs
playoffs <- subset(sdv_example_standings, !is.na(playoff_wins))
table(playoffs$league)
#> 
#> nba nfl 
#>  16  14 

# with logos, which are downloaded
# \donttest{
subset(sdv_example_standings, division == "Atlantic", c(team, wins, losses)) |>
  gt::gt() |>
  gt_sdv_logos(columns = "team", sport = "nba")


  

team
```
