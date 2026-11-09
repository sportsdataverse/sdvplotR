# Add ESPN athlete ids to a data frame of player names

Matches player names (and, where given, their team and season) to
published rosters and adds each player's ESPN athlete id, the id the
headshot helpers
([`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md),
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
...) read. The counterpart of cfbplotR's `add_athlete_id_col()`. The
rosters are cfbfastR-data's college football rosters, 2009 on, read over
the network when first needed and kept for the session. Like cfbplotR's,
the match is experimental: check the ids it gives.

## Usage

``` r
sdv_add_athlete_id(
  df,
  name_col,
  team_col = NULL,
  season_col = NULL,
  league = "cfb",
  headshot_urls = FALSE
)
```

## Arguments

- df:

  A data frame.

- name_col:

  The column of `df` with player names (a bare name or a string).

- team_col:

  The column with each player's team, or `NULL`: then a `team` or
  `school` column of `df`, if there is one.

- season_col:

  The column with each row's season, or `NULL`: then a `season` column
  of `df`, if there is one. Seasons outside the rosters' (2009 to the
  latest) match no one.

- league:

  A league with rosters: `"cfb"`.

- headshot_urls:

  If `TRUE`, also add each player's headshot URL.

## Value

`df` with an `athlete_id` column (character; `NA` where no single
athlete matched) and, with `headshot_urls = TRUE`, a `headshot_url`
column.

## Details

Names match ignoring case, accents and surrounding spaces. Teams match
through
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md),
so any name or id it accepts for the roster's team works; a team it
cannot resolve matches by name. A name that matches more than one
athlete is left `NA` (cfbplotR returns one row for each), so the result
has a row for each row of `df`: pass `team_col` and `season_col` to tell
players with one name apart.

Without `season_col` (and no `season` column) the latest season's
rosters are read, or the season before when the latest is not published
yet. Offline, or when a roster cannot be read, the call warns and the
ids it could not find are `NA`; it does not error.

## See also

[`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md)

## Examples

``` r
# \donttest{
x <- data.frame(player_name = c("Britain Covey", "JT Daniels"))
try(sdv_add_athlete_id(x, player_name))
#>     player_name athlete_id
#> 1 Britain Covey       <NA>
#> 2    JT Daniels       <NA>

x$season <- c(2021, 2021)
x$team <- c("Utah", "Georgia")
try(sdv_add_athlete_id(x, player_name, team, season, headshot_urls = TRUE))
#>     player_name season    team athlete_id
#> 1 Britain Covey   2021    Utah    3926231
#> 2    JT Daniels   2021 Georgia    4374303
#>                                                                  headshot_url
#> 1 https://a.espncdn.com/i/headshots/college-football/players/full/3926231.png
#> 2 https://a.espncdn.com/i/headshots/college-football/players/full/4374303.png
# }
```
