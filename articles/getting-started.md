# Getting Started with sdvplotR

On this page

## Introduction

`sdvplotR` provides a unified interface for visualizing sports data
across multiple leagues in the SportsDataverse ecosystem. This article
walks you through the core features of the package.

``` r

library(sdvplotR)
library(ggplot2)
```

## Valid Teams

Before plotting, you can list a league’s teams and the identifiers that
are valid for them:

``` r

# Get all NFL team abbreviations
nfl_teams <- sdv_teams("nfl")$abbr
head(nfl_teams)
#> [1] "ATL" "TEN" "IND" "KC"  "LV"  "LA"

# Get team names instead of abbreviations
nfl_team_names <- sdv_teams("nfl")$name
head(nfl_team_names)
#> [1] "Atlanta Falcons"    "Tennessee Titans"   "Indianapolis Colts"
#> [4] "Kansas City Chiefs" "Las Vegas Raiders"  "Los Angeles Rams"

# The 28 leagues of the team index
sdv_leagues()
#>  [1] "aaf"           "ahl"           "cfb"           "cricket"      
#>  [5] "echl"          "mbb"           "milb"          "mlb"          
#>  [9] "nba"           "nbagl"         "ncaa_baseball" "ncaa_mhockey" 
#> [13] "ncaa_softball" "ncaa_whockey"  "nfl"           "nhl"          
#> [17] "ohl"           "phf"           "pwhl"          "qmjhl"        
#> [21] "soccer"        "ufl"           "usfl"          "ushl"         
#> [25] "wbb"           "whl"           "wnba"          "xfl"
```

## Identifiers from any source

Team identifiers come in many spellings: an nflverse abbreviation, a
school name from CollegeFootballData.com, an ESPN team id.
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
turns any of them into the index’s canonical team id, and every helper
that takes a team does the same internally:

``` r

# an nflverse abbreviation, a full name and an ESPN team id: one team
sdv_resolve(c("KC", "Kansas City Chiefs", "12"), league = "nfl")
#> [1] "12" "12" "12"

# a CFBD school name
sdv_resolve("Ohio State", league = "cfb")
#> [1] "194"

# a typo does not resolve; sdv_suggest() proposes candidates
sdv_suggest("Kansas Cty", league = "nfl", n = 3)
#>   team_id               name
#> 1      12 Kansas City Chiefs
```

The team index and logo archive are read from the SportsDataverse CDN
and cached for a day.
[`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md)
reports which data version is in use, and
`options(sdvplotR.offline = TRUE)` keeps everything on the copy bundled
with the package.

## Plotting Team Logos

The
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
function plots team logos at specified coordinates:

``` r

# Create sample data
df <- data.frame(
  x = rep(1:4, 4),
  y = sort(rep(1:4, 4), decreasing = TRUE),
  team = sdv_teams("nfl")$abbr[1:16]
)

# Plot logos
ggplot(df, aes(x = x, y = y)) +
  geom_sdv_logos(aes(team = team), league = "nfl", width = 0.075) +
  theme_void()
```

## Using Team Colors

Map team names to their official colors using the color scales:

``` r

df <- data.frame(
  team = sdv_teams("nfl")$abbr[1:8],
  value = runif(8, 0, 1)
)

ggplot(df, aes(x = team, y = value)) +
  geom_col(aes(color = team, fill = team), width = 0.5) +
  scale_color_sdv(league = "nfl", which = "secondary") +
  scale_fill_sdv(league = "nfl", alpha = 0.4) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

![Bar chart of example values for NFL teams, each bar filled and
outlined in the team's primary and secondary
colors.](getting-started_files/figure-html/colors-1.png)

## Theme Elements

Replace axis labels with logos using theme elements. Add them after a
complete theme such as
[`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html);
set on `axis.text.x` (or `axis.text.y`), they also replace the
`axis.text.x.bottom` (`axis.text.y.left`) element that theme sets:

``` r

df <- data.frame(
  team = sdv_teams("nfl")$abbr[1:8],
  value = runif(8, 0, 1)
)

ggplot(df, aes(x = team, y = value)) +
  geom_col(aes(fill = team), width = 0.5) +
  scale_fill_sdv(league = "nfl", alpha = 0.4) +
  theme_minimal() +
  theme(axis.text.x = element_sdv_logo(league = "nfl"))
```

## Player Headshots

Plot player headshots using their ESPN athlete IDs:

``` r

# NFL player GSIS IDs
df_players <- data.frame(
  x = 1:3,
  y = 3:1,
  player_id = c("00-0033873", "00-0026498", "00-0035228"),
  player_name = c("P. Mahomes", "M. Stafford", "K. Murray")
)

ggplot(df_players, aes(x = x, y = y)) +
  geom_sdv_headshots(aes(player_id = player_id), league = "nfl", id_system = "gsis", height = 0.2) +
  geom_label(aes(label = player_name), nudge_y = -0.35) +
  theme_void()
```

## gt Tables

Add logos to gt tables:

``` r

library(gt)

df_table <- data.frame(
  team = sdv_teams("nfl")$abbr[1:8],
  logo = sdv_teams("nfl")$abbr[1:8],
  wins = sample(1:16, 8)
)

df_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", league = "nfl")
```

## Team Tier Plots

Create tier plots for any league:

``` r

team_abbrs <- sample(sdv_teams("nfl")$abbr)
df_tiers <- data.frame(
  tier_no = sample(1:5, length(team_abbrs), replace = TRUE),
  team = team_abbrs
)

sdv_team_tiers(df_tiers, league = "nfl")
```

## Working with Multiple Sports

The same functions work across all supported leagues:

``` r

# NBA logos
nba_df <- data.frame(
  x = 1:5,
  y = 5:1,
  team = sdv_teams("nba")$abbr[1:5]
)

ggplot(nba_df, aes(x = x, y = y)) +
  geom_sdv_logos(aes(team = team), league = "nba", width = 0.075) +
  theme_void()

# CFB logos
cfb_df <- data.frame(
  x = 1:5,
  y = 5:1,
  team = sdv_teams("cfb")$abbr[1:5]
)

ggplot(cfb_df, aes(x = x, y = y)) +
  geom_sdv_logos(aes(team = team), league = "cfb", width = 0.075) +
  theme_void()
```

## Every league

[`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md)
lists all 28 leagues of the team index, from the NFL and the Premier
League to the junior hockey leagues, NCAA softball and cricket. The loop
below draws ten teams of each that have a logo, one row per league. This
article reads teams from the snapshot bundled with the package
(`options(sdvplotR.offline = TRUE)`, set before its first lookup), so it
does not wait on a live fetch of the index.

``` r

teams <- do.call(rbind, lapply(sdv_leagues(), function(lg) {
  t <- sdv_teams(lg)
  # sdv_logo_url() warns for teams with no archived logo; keep ten that have one
  t <- tail(t[!is.na(suppressWarnings(sdv_logo_url(t$team_id, lg))), ], 10)
  data.frame(league = lg, team = t$team_id, x = seq_len(nrow(t)))
}))
# geom_sdv_logos() takes one league per layer: one layer per league
layers <- lapply(split(teams, teams$league), function(d) {
  geom_sdv_logos(aes(x = x, y = 0, team = team), data = d, league = d$league[1], width = 0.08)
})
ggplot() +
  layers +
  facet_wrap(~league, ncol = 2) +
  scale_x_continuous(limits = c(0.5, 10.5)) +
  theme_void() +
  theme(
    strip.text = element_text(face = "bold", hjust = 0),
    plot.background = element_rect(fill = "white", colour = NA)
  )
```

![Ten team logos for each of the 28 leagues of the SportsDataverse team
index, one labelled row per league, from the AAF and AHL to the
XFL.](getting-started_files/figure-html/every-league-1.png)

## Next Steps

- Explore the function documentation with
  [`?geom_sdv_logos`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
- Check out the [README](https://github.com/sportsdataverse/sdvplotR)
  for more examples
- Report issues on
  [GitHub](https://github.com/sportsdataverse/sdvplotR/issues)

## Companion Articles

Each league has its own dedicated article showing integration with the
relevant SportsDataverse data package:

| Sport | Article | Companion Package(s) |
|----|----|----|
| **NFL** | [NFL Visualizations](https://sdvplotR.sportsdataverse.org/articles/nfl-viz.html) | `nflfastR`, `nflreadr` |
| **CFB** | [CFB Visualizations](https://sdvplotR.sportsdataverse.org/articles/cfb-viz.html) | `cfbfastR`, `cfbseedR` |
| **NBA** | [NBA Visualizations](https://sdvplotR.sportsdataverse.org/articles/nba-viz.html) | `hoopR` |
| **WNBA** | [WNBA Visualizations](https://sdvplotR.sportsdataverse.org/articles/wnba-viz.html) | `wehoop` |
| **MLB** | [MLB Visualizations](https://sdvplotR.sportsdataverse.org/articles/mlb-viz.html) | `baseballr` |
| **NHL** | [NHL Visualizations](https://sdvplotR.sportsdataverse.org/articles/nhl-viz.html) | `fastRhockey` |
| **MBB** | [MBB Visualizations](https://sdvplotR.sportsdataverse.org/articles/mbb-viz.html) | `hoopR` |
| **WBB** | [WBB Visualizations](https://sdvplotR.sportsdataverse.org/articles/wbb-viz.html) | `wehoop` |

Cross-league cookbook articles:

| Topic | Article |
|----|----|
| Social media posting patterns | [Social Posting](https://sdvplotR.sportsdataverse.org/articles/social-posting.html) |
| Leaderboard dashboards | [Leaderboard Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.html) |
| End-to-end workflows | [Workflows](https://sdvplotR.sportsdataverse.org/articles/workflows.html) |

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
