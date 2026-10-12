# Team logo and wordmark URLs

The image URL behind every sdvplotR geom, theme element and table
helper: the SportsDataverse archive's copy of the team's mark
(content-addressed and immutable), chosen for the season. The R
counterpart of sdvplot's `logo_url()`.

## Usage

``` r
sdv_logo_url(
  team,
  league,
  season = NULL,
  variant = "default",
  mark_type = "logo",
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- team:

  A vector of team identifiers, or conference / league keys (`"SEC"`,
  `"Big 12"`, `"AFC"`), read after every team alias.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- variant:

  `"default"`, `"dark"`, or a named variant from
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  (`"scoreboard"`, `"grayscale"`, `"cap_on_light"`, ...). A team without
  it gets its closest mark of the same polarity; a name no mark in the
  archive has is an error listing the league's variants.

- mark_type:

  `"logo"` or `"wordmark"`.

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

A character vector the length of `team`: the URL, or `NA` (with a
warning) where the team does not resolve or has no such mark.

## See also

[`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md),
[`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md).

## Examples

``` r
sdv_logo_url(c("KC", "Buffalo Bills", "OAK"), "nfl")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png"
#> [2] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png"
#> [3] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png"
sdv_logo_url("NYJ", "nfl", variant = "scoreboard")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ec/ecd80a4d905129313f6d400d1ae753aa0196beb2931e09d1fa8a80f6738f0636.png"
sdv_logo_url("QUE", "nhl", season = 1990)
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3c/3c28d243ddb84f6556dd6f5a6d9f02f658657f557a157df998fad9c6d7abc7c8.svg"
sdv_logo_url("KC", "nfl", mark_type = "wordmark")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/16/16a2c7e0cd5dcf2e6bdc646c0b22bf03e575f505aa4b843a0ebfdaf19650257b.png"
sdv_logo_url("SEC", "cfb")
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95fa7566bb2095986633050e61be22f524333ffdf757f35a1f80d1c1b05f4b76.png"
```
