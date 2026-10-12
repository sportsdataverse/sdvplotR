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
