# Troubleshooting

On this page

``` r

library(sdvplotR)
```

## A team does not resolve

A value sdvplotR cannot match becomes `NA`, with one warning per call
that names each value and why it failed:

``` r

sdv_resolve(c("KC", "Kansas Cty"), league = "nfl")
#> Warning in sdv_resolve(c("KC", "Kansas Cty"), league = "nfl"): 1 value did not resolve to a "nfl" team: 'Kansas Cty' (unknown).
#> ℹ Use `sdv_suggest()` for candidates, or `strict = TRUE` to error.
#> [1] "12" NA
```

Things to try, in order:

1.  **Check the league.** One abbreviation means different teams in
    different leagues, so `league` is required, and it must be one of
    [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
    ESPN’s NBL is `"nbl"` (ESPN ids), while the DataCore-keyed NBL is
    `"nbl_au"`.

2.  **Ask for candidates.**
    [`sdv_suggest()`](https://sdvplotR.sportsdataverse.org/reference/sdv_suggest.md)
    ranks the closest names:

    ``` r

    sdv_suggest("Kansas Cty", league = "nfl", n = 3)
    #>   team_id               name
    #> 1      12 Kansas City Chiefs
    ```

3.  **Name the id system.** The default `id_system = "auto"` tries the
    index’s own `team_id` first, then the provider ids in a fixed order
    (an ESPN id wins over an equal NCAA id). It never tries `"nhl_id"`,
    `"fox"`, `"cbs"`, `"sports247"` or `"on3"`, whose numbers overlap
    ESPN’s. Pass the provider your values come from:

    ``` r

    sdv_resolve("54", league = "mbb", id_system = "fox")
    #> [1] "41"
    ```

4.  **Pass a season.** A code reused across eras resolves to its current
    holder. The warning says `ambiguous` when a code fits several teams.
    `season` picks the team of that year:

    ``` r

    # the Quebec Nordiques: the franchise's team_id, today the Colorado Avalanche
    sdv_resolve("QUE", league = "nhl", season = 1990)
    #> [1] "17"
    ```

5.  **Look the team up.** `sdv_teams(league)` lists every team and its
    `team_id`, and `sdv_aliases(league)` every spelling each id system
    holds. The [Leagues and
    Identifiers](https://sdvplotR.sportsdataverse.org/articles/leagues-and-identifiers.md)
    article explains what the ids are in each league.

In a pipeline where a miss should stop the run, use `strict = TRUE`. It
raises an error of class `sdvplotR_unresolved` instead of warning:

``` r

res <- tryCatch(
  sdv_resolve("Kansas Cty", league = "nfl", strict = TRUE),
  sdvplotR_unresolved = function(e) conditionMessage(e)
)
res
#> [1] "\033[1m\033[22m1 value did not resolve to a \033[34m\"nfl\"\033[39m team: 'Kansas Cty' (unknown)."
```

## A logo or wordmark is missing

[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)
returns `NA` with a warning where a team does not resolve or has no mark
of that kind. The geoms leave that point blank. Check the URL directly,
and list the marks the archive holds with
[`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md):

``` r

sdv_logo_url(c("KC", "Kansas Cty"), "nfl")
#> Warning in sdv_logo_url(c("KC", "Kansas Cty"), "nfl"): 1 value did not resolve to a "nfl" team: 'Kansas Cty' (unknown).
#> ℹ Use `sdv_suggest()` for candidates, or `strict = TRUE` to error.
#> [1] "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png"
#> [2] NA
head(sdv_marks("KC", "nfl")[, c("team_id", "variant", "mark_type")])
#>   team_id              variant mark_type
#> 1      12   primary_logo_white      logo
#> 2      12 secondary_logo_white      logo
#> 3      12                 dark      logo
#> 4      12              default      logo
#> 5      12           scoreboard      logo
#> 6      12      scoreboard_dark      logo
```

- A `variant` the team lacks falls back to its closest mark of the same
  polarity. A variant no team in the league has is an error that lists
  the league’s variants.
- Not every league has wordmarks (`mark_type = "wordmark"`), and older
  seasons have logos only where the archive dates its marks.
- Team logos and headshots are downloaded when the plot draws, and
  cached for the session by ‘ggpath’. With no network, the plot draws
  without them.

## A headshot is missing

Headshots are keyed by player id, and `id_system` says whose. The
default is `id_system = "espn"` (the ESPN athlete id). Other options:

- `"league"`: the league’s own id, such as the MLBAM id, the NHL API id,
  or HockeyTech’s `player_id` for the HockeyTech leagues, which have no
  ESPN photos.
- `"gsis"`: NFL GSIS ids.
- A provider’s player id (`"fox"`, `"yahoo"`, `"cbs"`, `"kenpom"`,
  `"ncaa"` and others, by league), which maps to the player’s ESPN id.

[`?sdv_headshot_url`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md)
has the full table of leagues and id systems. Things to know:

- ESPN and league ids are plain digits, so an id from the wrong system
  draws the wrong player or no image rather than an error.
- An id the provider maps do not hold is `NA`.
- For an id with no photo, the NBA, WNBA, MLB and NHL CDNs serve a
  silhouette. ESPN and HockeyTech answer 404: the ggplot geoms skip that
  player with a warning, and the gt, reactable and ggtext helpers show a
  broken image.
- The NBA and WNBA CDNs refuse requests from datacenter IPs, so a plot
  drawn on CI or a server can come back without those headshots.
- Leagues outside that table have no headshots: the international
  basketball and European hockey leagues, cricket and F1 among them.

## The data looks out of date

sdvplotR reads the team index and the logo manifest from the
SportsDataverse CDN and keeps them on disk for a day (in
`tools::R_user_dir("sdvplotR", "cache")`).
[`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md)
reports what the session has loaded and where it came from:

``` r

sdv_versions()
#> $package
#> [1] "0.3.0"
#> 
#> $index_version
#> [1] "abd1a34c1550"
#> 
#> $index_source
#> [1] "snapshot"
#> 
#> $manifest_rows
#> [1] 48650
#> 
#> $manifest_source
#> [1] "snapshot"
```

`index_source` is `"live"` (the CDN, or the disk copy within a day of
it), `"cache"` (an older disk copy, after a failed refresh) or
`"snapshot"` (the copy bundled with the package). To read the CDN again
now, turn offline mode off if you set it (the snapshot is always used
while it is on), then clear the caches:

``` r

options(sdvplotR.offline = FALSE)
sdv_clear_cache()
sdv_versions()
```

`options(sdvplotR.offline = TRUE)`, set before the first lookup, keeps
the session on the bundled snapshot. Use it for reproducible builds and
machines with no network. On CRAN, and in an `R CMD check` with
`NOT_CRAN` unset, the package uses the snapshot on its own
(`devtools::check()` sets `NOT_CRAN=true`, so it reads the CDN).

## Saving an image fails

Saving a `gt` table, or a grid or stack of them, to PNG goes through the
‘webshot2’ package and a headless Chrome. Install ‘webshot2’, and check
that
[`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
returns a path that exists. ggplot2 plots save with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
as usual.

## A playing surface fails

[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
draws its courts, fields and rinks through ‘sportyR’ (\>= 2.4.5), which
is a suggested package. If it is missing or older,
[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
offers to install it. An older ‘sportyR’ that is already loaded stays
loaded until R restarts, and
[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
says so: restart R after updating it.

## Still stuck?

Open an issue on
[GitHub](https://github.com/sportsdataverse/sdvplotR/issues) with the
call, the warning and the output of
[`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md).
A wrong logo or color for a team is a data issue, fixed upstream in the
team index: the issue form has a template for it.

## **Our Authors**

- [Saiem Gilani](https://x.com/saiemgilani)  
  [![@saiemgilani](https://img.shields.io/twitter/follow/saiemgilani?color=blue&label=%40saiemgilani&logo=x&style=for-the-badge)](https://x.com/saiemgilani)
  [![@saiemgilani](https://img.shields.io/github/followers/saiemgilani?color=eee&logo=Github&style=for-the-badge)](https://github.com/saiemgilani)
- [Sebastian Carl](https://x.com/mrcaseb)  
  [![@mrcaseb](https://img.shields.io/twitter/follow/mrcaseb?color=blue&label=%40mrcaseb&logo=x&style=for-the-badge)](https://x.com/mrcaseb)
  [![@mrcaseb](https://img.shields.io/github/followers/mrcaseb?color=eee&logo=Github&style=for-the-badge)](https://github.com/mrcaseb)
- [Jared Lee](https://github.com/Kazink36)  
  [![@Kazink36](https://img.shields.io/github/followers/Kazink36?color=eee&logo=Github&style=for-the-badge)](https://github.com/Kazink36)
- [Camden Kay](https://x.com/camdenkay)  
  [![@camdenkay](https://img.shields.io/twitter/follow/camdenkay?color=blue&label=%40camdenkay&logo=x&style=for-the-badge)](https://x.com/camdenkay)
  [![@camdenk](https://img.shields.io/github/followers/camdenk?color=eee&logo=Github&style=for-the-badge)](https://github.com/camdenk)
- [Andrew Weatherman](https://github.com/andreweatherman) (gtUtils)  
  [![@andreweatherman](https://img.shields.io/github/followers/andreweatherman?color=eee&logo=Github&style=for-the-badge)](https://github.com/andreweatherman)

## **Citation**

To cite the [**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) R
package in publications, use:

BibTeX Citation

``` bibtex
@misc{gilani_carl_lee_kay_weatherman_sdvplotR,
  author = {Gilani, Saiem and Carl, Sebastian and Lee, Jared and Kay, Camden and Weatherman, Andrew},
  title = {sdvplotR: The SportsDataverse's R Package for Multi-League Sports Plotting.},
  url = {https://sdvplotR.sportsdataverse.org},
  year = {2026}
}
```

## **Related SportsDataverse packages**

- [**sdvplot**](https://sdvplot.sportsdataverse.org/) - the Python
  plotting package
- [**sdvplot-js**](https://plot.sportsdataverse.org/) - the JavaScript /
  TypeScript plotting packages
- [**cfbfastR**](https://cfbfastR.sportsdataverse.org/) - college
  football
- [**hoopR**](https://hoopR.sportsdataverse.org/) - men’s basketball
- [**wehoop**](https://wehoop.sportsdataverse.org/) - women’s basketball
- [**baseballr**](https://baseballr.sportsdataverse.org/) - baseball
- [**fastRhockey**](https://fastRhockey.sportsdataverse.org/) - hockey
- [**oddsapiR**](https://oddsapiR.sportsdataverse.org/) - betting odds
- [**sportyR**](https://sportyR.sportsdataverse.org/) - playing surfaces
- [**sportsdataverse-py**](https://py.sportsdataverse.org/) - the Python
  package
- [**sportsdataverse-R**](https://r.sportsdataverse.org/) - the R
  meta-package
