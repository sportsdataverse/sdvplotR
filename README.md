
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **sdvplotR** <a href='https://sdvplotR.sportsdataverse.org/'><img src='https://raw.githubusercontent.com/sportsdataverse/sdvplotR/main/man/figures/logo.png' align="right" width="25%" min-width="120px" /></a>

<!-- badges: start -->

<!-- [![CRAN version](https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=success&label=CRAN%20version&prefix=v&query=%24.Version&url=https%3A%2F%2Fcrandb.r-pkg.org%2FsdvplotR)](https://CRAN.R-project.org/package=sdvplotR) -->

<!-- [![CRAN downloads](https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=success&label=Downloads&query=%24%5B0%5D.downloads&url=https%3A%2F%2Fcranlogs.r-pkg.org%2Fdownloads%2Ftotal%2F2026-01-01%3Alast-day%2FsdvplotR)](https://CRAN.R-project.org/package=sdvplotR) -->

[![Version-Number](https://img.shields.io/github/r-package/v/sportsdataverse/sdvplotR?label=sdvplotR&logo=R&style=for-the-badge)](https://github.com/sportsdataverse/sdvplotR/)
[![R-CMD-check](https://img.shields.io/github/actions/workflow/status/sportsdataverse/sdvplotR/R-CMD-check.yaml?branch=main&label=R-CMD-Check&logo=R&logoColor=white&style=for-the-badge)](https://github.com/sportsdataverse/sdvplotR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://img.shields.io/github/actions/workflow/status/sportsdataverse/sdvplotR/pkgdown.yaml?branch=main&label=pkgdown&logo=github&style=for-the-badge)](https://github.com/sportsdataverse/sdvplotR/actions/workflows/pkgdown.yaml)
[![Codecov](https://img.shields.io/codecov/c/github/sportsdataverse/sdvplotR?logo=codecov&style=for-the-badge)](https://app.codecov.io/gh/sportsdataverse/sdvplotR)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg?style=for-the-badge&logo=github)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-universe](https://img.shields.io/badge/dynamic/json?style=for-the-badge&color=success&label=r-universe&prefix=v&query=%24.Version&url=https%3A%2F%2Fsportsdataverse.r-universe.dev%2Fapi%2Fpackages%2FsdvplotR)](https://sportsdataverse.r-universe.dev/sdvplotR)
[![Contributors](https://img.shields.io/github/contributors/sportsdataverse/sdvplotR?style=for-the-badge)](https://github.com/sportsdataverse/sdvplotR/graphs/contributors)
[![X
Follow](https://img.shields.io/twitter/follow/SportsDataverse?color=blue&label=%40SportsDataverse&logo=x&style=for-the-badge)](https://x.com/SportsDataverse)
<!-- badges: end -->

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
table helpers, and `team_reference()` exposes the full reference data
(ESPN ids, colors, conference / division) for every team.

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

There is also a printable [**`sdvplotR` cheat sheet
(PDF)**](https://sportsdataverse.org/cheatsheets/sdvplotR.pdf), one of
[a set covering every SportsDataverse
package](https://sportsdataverse.org/cheatsheets).

## **The SportsDataverse**

`sdvplotR` draws the pictures; the companion packages fetch the data.

| Package                                                                                                               | Sport / Scope                      |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| [**cfbfastR**](https://cfbfastR.sportsdataverse.org/)                                                                 | College football                   |
| [**hoopR**](https://hoopR.sportsdataverse.org/)                                                                       | Men’s basketball (NBA and NCAA)    |
| [**wehoop**](https://wehoop.sportsdataverse.org/)                                                                     | Women’s basketball (WNBA and NCAA) |
| [**fastRhockey**](https://fastRhockey.sportsdataverse.org/)                                                           | Hockey (NHL and PWHL)              |
| [**baseballr**](https://billpetti.github.io/baseballr/)                                                               | Baseball (MLB, MiLB, NCAA)         |
| [**nflfastR**](https://nflfastr.com/) · [**nflreadr**](https://nflreadr.nflverse.com/)                                | NFL play-by-play and data loaders  |
| [**oddsapiR**](https://oddsapiR.sportsdataverse.org/)                                                                 | Sports betting odds                |
| [**cfbseedR**](https://cfbseedR.sportsdataverse.org/)                                                                 | CFB seeding and playoff simulation |
| [**sportyR**](https://sportyR.sportsdataverse.org/)                                                                   | Playing-surface plots              |
| [**sportsdataverse-R**](https://r.sportsdataverse.org/)                                                               | Umbrella R metapackage             |
| [**sportsdataverse-py**](https://py.sportsdataverse.org/) · [**sportsdataverse.js**](https://js.sportsdataverse.org/) | Python and Node.js                 |

See the full ecosystem at
[sportsdataverse.org](https://sportsdataverse.org/).

## Follow the [SportsDataverse](https://x.com/SportsDataverse) on X and star this repo

[![X
Follow](https://img.shields.io/twitter/follow/SportsDataverse?color=blue&label=%40SportsDataverse&logo=x&style=for-the-badge)](https://x.com/SportsDataverse)

[![GitHub
stars](https://img.shields.io/github/stars/sportsdataverse/sdvplotR.svg?color=eee&logo=github&style=for-the-badge&label=Star%20sdvplotR&maxAge=2592000)](https://github.com/sportsdataverse/sdvplotR/stargazers/)

## **Our Authors**

  - [Saiem Gilani](https://x.com/saiemgilani)
    <a href="https://orcid.org/0000-0002-7194-9067" target="orcid.widget" aria-label="ORCID"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID logo"></a></br>
    <a href="https://x.com/saiemgilani" target="blank"><img src="https://img.shields.io/twitter/follow/saiemgilani?color=blue&label=%40saiemgilani&logo=x&style=for-the-badge" alt="@saiemgilani" /></a>
    <a href="https://github.com/saiemgilani" target="blank"><img src="https://img.shields.io/github/followers/saiemgilani?color=eee&logo=Github&style=for-the-badge" alt="@saiemgilani" /></a>

  - [Sebastian Carl](https://x.com/mrcaseb) </br>
    <a href="https://x.com/mrcaseb" target="blank"><img src="https://img.shields.io/twitter/follow/mrcaseb?color=blue&label=%40mrcaseb&logo=x&style=for-the-badge" alt="@mrcaseb" /></a>
    <a href="https://github.com/mrcaseb" target="blank"><img src="https://img.shields.io/github/followers/mrcaseb?color=eee&logo=Github&style=for-the-badge" alt="@mrcaseb" /></a>

  - [Jared Lee](https://github.com/Kazink36) </br>
    <a href="https://x.com/JaredDLee" target="blank"><img src="https://img.shields.io/twitter/follow/JaredDLee?color=blue&label=%40JaredDLee&logo=x&style=for-the-badge" alt="@JaredDLee" /></a>
    <a href="https://github.com/Kazink36" target="blank"><img src="https://img.shields.io/github/followers/Kazink36?color=eee&logo=Github&style=for-the-badge" alt="@Kazink36" /></a>

  - [Camden Kay](https://x.com/camdenkay) </br>
    <a href="https://x.com/camdenkay" target="blank"><img src="https://img.shields.io/twitter/follow/camdenkay?color=blue&label=%40camdenkay&logo=x&style=for-the-badge" alt="@camdenkay" /></a>
    <a href="https://github.com/camdenk" target="blank"><img src="https://img.shields.io/github/followers/camdenk?color=eee&logo=Github&style=for-the-badge" alt="@camdenk" /></a>

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
