# Team Logo and Player Headshot URLs

The image URLs behind every sdvplotR geom, theme element and table
helper, for your own `<img>` tags, markdown, 'ggpath' layers or image
tooling. `sdv_logo_url()` resolves team keys the way
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
does (aliases, full names, historical abbreviations, conference names);
`sdv_headshot_url()` builds a headshot URL from a player id. These are
the R counterparts of sdvplot's `logo_url()` and `headshot_url()`.

## Usage

``` r
sdv_logo_url(
  team,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  variant = c("primary", "dark", "scoreboard"),
  season = NULL
)

sdv_headshot_url(
  player_id,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer"),
  id_type = NULL
)
```

## Arguments

- team:

  A character vector of team abbreviations or names.

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- variant:

  The logo variant: `"primary"` (the default mark), `"dark"` (the
  dark-background mark) or `"scoreboard"` (ESPN's scoreboard mark, which
  differs from the primary for a few pro teams: the Jets' `NY`), or a
  named mark the SportsDataverse logo archive carries for most of the
  sport's teams: ESPN's `"scoreboard_dark"`, `"grayscale"` (NFL),
  `"primary_logo_on_black_color"` and its siblings, nflverse's
  `"squared"` (NFL), MLB's `"cap_on_light"` / `"cap_on_dark"` /
  `"primary_on_light"` / `"primary_on_dark"` (SVG). A team without the
  requested variant gives its primary logo; a variant no mark of the
  sport has is an error that lists the sport's variants.

- season:

  A season year (the ending year for the NHL: 2005 for 2004-05) or a
  vector of them, recycled against `team`. Where sdvplotR has the mark
  the team wore that season (NHL, and the NFL's and WNBA's relocated
  identities), that mark is returned; otherwise today's. `NULL` (the
  default) gives today's logo.

- player_id:

  A vector of player ids: nflverse GSIS ids for the NFL
  (`"00-0033873"`), ESPN athlete ids elsewhere, unless `id_type` says
  otherwise.

- id_type:

  `NULL` (the default) takes each sport's default id; `"espn"` ESPN
  athlete ids for any sport; `"league"` the league's own ids (GSIS; NBA
  / WNBA Stats `PERSON_ID`; MLBAM; NHL API), which the league CDN serves
  without a lookup (a silhouette for an unknown id). College sports have
  no league ids.

## Value

A character vector the length of `team` / `player_id`: the image URL, or
`NA` for a team that does not resolve, a player id that is missing,
malformed or (NFL GSIS) not in the headshot map, or a league without
wordmarks (the NFL and MLB have them).

## Where the images come from

Logos and wordmarks are the SportsDataverse logo archive's copies of the
sources' files (ESPN's CDN, nflverse, MLB): immutable, content-addressed
URLs (`.../sha256/<ab>/<sha256>.png`, so a downloaded file can be
checked against its name) that stay up when a source drops or replaces a
file. A mark the archive has no copy of (none today) falls back to the
source's live URL.
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
keeps listing the sources' URLs. Headshots are not archived. sdvplot
(Python) reads the same archive manifest at run time; sdvplotR ships the
current marks in the package (`data-raw/generate_logo_marks.R`).

## See also

[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
for every team's URLs at once,
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
and
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
which draw them.

## Examples

``` r
sdv_logo_url(c("KC", "Buffalo Bills", "WAS"), sport = "nfl")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png"
#> [2] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png"
#> [3] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2f/2f67805ef9e385a4c67adb0a9320706bd481a52e3aa0e0faea995dad2b501112.png"
sdv_logo_url("NYJ", sport = "nfl", variant = "scoreboard")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ec/ecd80a4d905129313f6d400d1ae753aa0196beb2931e09d1fa8a80f6738f0636.png"
sdv_logo_url("KC", sport = "nfl", variant = "grayscale")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/7972affd32768d0fc112fb2f59b3db8d681085ce218e8c82a79545cef77a6c22.png"
sdv_logo_url("QUE", sport = "nhl", season = 1990)
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3c/3c28d243ddb84f6556dd6f5a6d9f02f658657f557a157df998fad9c6d7abc7c8.svg"
sdv_logo_url("SEC", sport = "cfb")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95fa7566bb2095986633050e61be22f524333ffdf757f35a1f80d1c1b05f4b76.png"

sdv_headshot_url(3917315, sport = "mbb")
#> [1] "https://a.espncdn.com/combiner/i?img=/i/headshots/mens-college-basketball/players/full/3917315.png"
sdv_headshot_url("2544", sport = "nba", id_type = "league")
#> [1] "https://cdn.nba.com/headshots/nba/latest/260x190/2544.png"
# \donttest{
# NFL GSIS ids read the published headshot map
sdv_headshot_url("00-0033873", sport = "nfl")
#> [1] "https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png"
# }
```
