# Player headshot URLs

The headshot image URL for player ids, as every sdvplotR headshot helper
draws it. The R counterpart of sdvplot's `headshot_url()`.

## Usage

``` r
sdv_headshot_url(player_id, league, id_system = "espn")
```

## Arguments

- player_id:

  A vector of player ids.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- id_system:

  `"espn"` (ESPN athlete ids; the default, for every league with ESPN
  headshots), `"gsis"` (nflverse's NFL gsis ids, such as `"00-0033873"`,
  read through a published map) or `"league"` (the league's own player
  id). The details of `sdv_headshot_url()` list which leagues take
  which.

## Value

A character vector the length of `player_id`: the URL, or `NA` for a
missing or malformed id or (gsis) one not in the map. The URL is built
from the id alone, so an id the CDN has no photo for still gets one:
ESPN and HockeyTech answer it with a 404, which the ggplot geoms skip
with a warning and the gt, reactable and ggtext helpers show as a broken
image; the NBA, WNBA, MLB and NHL CDNs serve a silhouette.

## Details

Headshots by league and `id_system`:

|  |  |  |
|----|----|----|
| League | `"espn"` | `"league"` |
| nfl | ESPN athlete id | gsis id (as `"gsis"`) |
| nba, wnba | ESPN athlete id | NBA / WNBA Stats `PERSON_ID` |
| mlb | ESPN athlete id | MLBAM id |
| nhl | ESPN athlete id | NHL API player id |
| nbagl | ESPN athlete id (the NBA's id space) | none |
| soccer | ESPN athlete id | none |
| cfb, mbb, wbb | ESPN athlete id | none |
| pwhl, ahl, echl, ohl, whl, qmjhl, ushl | none | HockeyTech `player_id` |

ESPN files G League photos with the NBA's, so a G League player's ESPN
id is the one ESPN uses for him in the NBA. ESPN has photos for only
part of the G League and soccer rosters. The HockeyTech leagues' images
come from the leagues' stats provider's CDN (`assets.leaguestat.com`),
keyed by the `player_id` in their HockeyTech feeds. Other leagues have
no headshots.

## See also

[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md).

## Examples

``` r
sdv_headshot_url(3139477, "nfl")
#> [1] "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/3139477.png"
sdv_headshot_url("2544", "nba", id_system = "league")
#> [1] "https://cdn.nba.com/headshots/nba/latest/260x190/2544.png"
sdv_headshot_url(52, "pwhl", id_system = "league")
#> [1] "https://assets.leaguestat.com/pwhl/240x240/52.jpg"
# \donttest{
# nflverse gsis ids read the published headshot map
sdv_headshot_url("00-0033873", "nfl", id_system = "gsis")
#> [1] "https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png"
# }
```
