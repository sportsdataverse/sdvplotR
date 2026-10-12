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
  headshots: nfl, nba, wnba, mlb, nhl, cfb, mbb, wbb), `"gsis"`
  (nflverse's NFL gsis ids, such as `"00-0033873"`, read through a
  published map) or `"league"` (the league's own player id: NBA / WNBA
  Stats `PERSON_ID`, MLBAM, NHL API; for the NFL, the gsis id).

## Value

A character vector the length of `player_id`: the URL, or `NA` for a
missing or malformed id or (gsis) one not in the map.

## See also

[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md).

## Examples

``` r
sdv_headshot_url(3139477, "nfl")
#> [1] "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/3139477.png"
sdv_headshot_url("2544", "nba", id_system = "league")
#> [1] "https://cdn.nba.com/headshots/nba/latest/260x190/2544.png"
# \donttest{
# nflverse gsis ids read the published headshot map
sdv_headshot_url("00-0033873", "nfl", id_system = "gsis")
#> [1] "https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png"
# }
```
