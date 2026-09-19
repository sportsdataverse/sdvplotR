# **sdvplotR**

[**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) plots sports
team logos, wordmarks, player headshots and team colors across **eight
leagues** — NFL, NBA, WNBA, MLB, NHL, college football, and men’s and
women’s college basketball — in
[**`ggplot2`**](https://ggplot2.tidyverse.org/) plots,
[**`gt`**](https://gt.rstudio.com/) tables and
[**`reactable`**](https://glin.github.io/reactable/) tables. It is built
on [**`ggpath`**](https://mrcaseb.github.io/ggpath/) and unifies the
approach established by [nflplotR](https://nflplotr.nflverse.com/),
[cfbplotR](https://cfbplotR.sportsdataverse.org/),
[nbaplotR](https://mrcaseb.github.io/nbaplotR/) and
[mlbplotR](https://camdenk.github.io/mlbplotR/) behind one `sport`
argument.

Part of the [SportsDataverse](https://sportsdataverse.org/) family of R
packages for sports analytics.

## **Installation**

Once on CRAN, install the released version with:

``` r

install.packages("sdvplotR")
```

Install the development version of
[**`sdvplotR`**](https://github.com/sportsdataverse/sdvplotR) from
GitHub with:

``` r

# using the pak package (recommended):
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}
pak::pak("sportsdataverse/sdvplotR")
```

``` r

# or from R-universe (binary builds):
install.packages("sdvplotR", repos = c("https://sportsdataverse.r-universe.dev", "https://cloud.r-project.org"))
```

## **Usage**

Every function takes a `sport` argument (`"nfl"`, `"nba"`, `"wnba"`,
`"mlb"`, `"nhl"`, `"cfb"`, `"mbb"`, `"wbb"`). Team keys are cleaned
automatically: full names, alternate abbreviations used by other data
providers and historical abbreviations of relocated franchises (`"OAK"`
→ `"LV"`, `"SEA"` → `"OKC"`) all resolve to the same team.

``` r

library(sdvplotR)
library(ggplot2)

# NFL team logos in a grid
df <- data.frame(
  a     = rep(1:8, 4),
  b     = sort(rep(1:4, 8), decreasing = TRUE),
  teams = valid_team_names("nfl")
)

ggplot(df, aes(x = a, y = b)) +
  geom_sdv_logos(aes(team = teams), sport = "nfl", width = 0.075) +
  theme_void()
```

``` r

# Logos as axis labels + team colours as fill
df2 <- data.frame(
  team  = c("KC", "BUF", "SF", "DAL"),
  score = c(42, 38, 35, 30)
)

ggplot(df2, aes(x = team, y = score)) +
  geom_col(aes(fill = team), show.legend = FALSE) +
  scale_fill_sdv(sport = "nfl") +
  theme_minimal() +
  theme(axis.text.x = element_sdv_logo(sport = "nfl", size = 1))
```

``` r

library(gt)

# Logos inside a gt table
data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11)) |>
  gt() |>
  gt_sdv_logos(columns = "team", sport = "nfl")
```

``` r

library(reactable)

# Logos inside a reactable table with team-coloured bars
df3 <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))

reactable(
  df3,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "nfl"), html = TRUE),
    wins = colDef(style = reactable_sdv_team_color_bar(df3, "team", sport = "nfl"))
  )
)
```

Dark-mode logo variants are available through `variant = "dark"` in the
table helpers, and
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
exposes the full reference data (ESPN ids, colors, conference /
division) for every team.

## **Documentation**

The [**`sdvplotR`** documentation
website](https://sdvplotR.sportsdataverse.org/) has the full function
reference and these articles:

**Per-sport** (each with companion SportsDataverse package examples):
[NFL](https://sdvplotR.sportsdataverse.org/articles/nfl-viz.html) ·
[CFB](https://sdvplotR.sportsdataverse.org/articles/cfb-viz.html) ·
[NBA](https://sdvplotR.sportsdataverse.org/articles/nba-viz.html) ·
[WNBA](https://sdvplotR.sportsdataverse.org/articles/wnba-viz.html) ·
[MLB](https://sdvplotR.sportsdataverse.org/articles/mlb-viz.html) ·
[NHL](https://sdvplotR.sportsdataverse.org/articles/nhl-viz.html) ·
[MBB](https://sdvplotR.sportsdataverse.org/articles/mbb-viz.html) ·
[WBB](https://sdvplotR.sportsdataverse.org/articles/wbb-viz.html)

**Cookbooks:** [Getting
Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.html)
· [Social
Posting](https://sdvplotR.sportsdataverse.org/articles/social-posting.html)
· [Leaderboard
Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.html)
· [reactable
Integration](https://sdvplotR.sportsdataverse.org/articles/reactable-integration.html)
·
[Workflows](https://sdvplotR.sportsdataverse.org/articles/workflows.html)

A printable `sdvplotR` cheat sheet will join [the set covering every
SportsDataverse package](https://sportsdataverse.org/cheatsheets).

## **The SportsDataverse**

`sdvplotR` draws the pictures; the companion packages fetch the data.

| Package | Sport / Scope |
|----|----|
| [**cfbfastR**](https://cfbfastR.sportsdataverse.org/) | College football |
| [**hoopR**](https://hoopR.sportsdataverse.org/) | Men’s basketball (NBA and NCAA) |
| [**wehoop**](https://wehoop.sportsdataverse.org/) | Women’s basketball (WNBA and NCAA) |
| [**fastRhockey**](https://fastRhockey.sportsdataverse.org/) | Hockey (NHL and PWHL) |
| [**baseballr**](https://billpetti.github.io/baseballr/) | Baseball (MLB, MiLB, NCAA) |
| [**nflfastR**](https://nflfastr.com/) · [**nflreadr**](https://nflreadr.nflverse.com/) | NFL play-by-play and data loaders |
| [**oddsapiR**](https://oddsapiR.sportsdataverse.org/) | Sports betting odds |
| [**cfbseedR**](https://cfbseedR.sportsdataverse.org/) | CFB seeding and playoff simulation |
| [**sportyR**](https://sportyR.sportsdataverse.org/) | Playing-surface plots |
| [**sportsdataverse-R**](https://r.sportsdataverse.org/) | Umbrella R metapackage |
| [**sportsdataverse-py**](https://py.sportsdataverse.org/) · [**sportsdataverse.js**](https://js.sportsdataverse.org/) | Python and Node.js |

See the full ecosystem at
[sportsdataverse.org](https://sportsdataverse.org/).

## Follow the [SportsDataverse](https://x.com/SportsDataverse) on X and star this repo

[![X
Follow](https://img.shields.io/twitter/follow/SportsDataverse?color=blue&label=%40SportsDataverse&logo=x&style=for-the-badge)](https://x.com/SportsDataverse)

[![GitHub
stars](https://img.shields.io/github/stars/sportsdataverse/sdvplotR.svg?color=eee&logo=github&style=for-the-badge&label=Star%20sdvplotR&maxAge=2592000)](https://github.com/sportsdataverse/sdvplotR)

## **Our Authors**

- [Saiem Gilani](https://x.com/saiemgilani) [![ORCID
  logo](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0000-0002-7194-9067)
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

## **Code of Conduct**

Please note that the sdvplotR project is released with a [Contributor
Code of
Conduct](https://sdvplotR.sportsdataverse.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## **Citations**

To cite the [**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) R
package in publications, use:

BibTex Citation

``` bibtex
@misc{gilani_carl_lee_kay_sdvplotR,
  author = {Gilani, Saiem and Carl, Sebastian and Lee, Jared and Kay, Camden},
  title = {sdvplotR: The SportsDataverse's R Package for Multi-League Sports Plotting.},
  url = {https://sdvplotR.sportsdataverse.org},
  year = {2026}
}
```
