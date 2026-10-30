# **sdvplotR**

[**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) plots sports
team logos, wordmarks, player headshots and team colors across the **28
leagues** of the SportsDataverse team index
([`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md))
— NFL, NBA, WNBA, MLB, NHL, college football, men’s and women’s college
basketball, soccer and more — in
[**`ggplot2`**](https://ggplot2.tidyverse.org/) plots,
[**`gt`**](https://gt.rstudio.com/) tables and
[**`reactable`**](https://glin.github.io/reactable/) tables, and in
interactive [**`plotly`**](https://plotly-r.com/),
[**`ggiraph`**](https://davidgohel.github.io/ggiraph/) and
[**`leaflet`**](https://rstudio.github.io/leaflet/) charts and maps,
with playing surfaces (59 of them: every court, field, rink and sheet,
lacrosse, tennis, volleyball and curling included; the team leagues’
surfaces take a team’s colors) from
[**`sportyR`**](https://sportyR.sportsdataverse.org/). It is built on
[**`ggpath`**](https://mrcaseb.github.io/ggpath/) and unifies the
approach established by [nflplotR](https://nflplotr.nflverse.com/),
[cfbplotR](https://cfbplotR.sportsdataverse.org/),
[nbaplotR](https://mrcaseb.github.io/nbaplotR/) and
[mlbplotR](https://camdenk.github.io/mlbplotR/) behind one `league`
argument.

![Every NFL team's 2023 regular season drawn as its logo, placed by
points scored and allowed per
game.](https://raw.githubusercontent.com/sportsdataverse/sdvplotR/main/man/figures/README-home.png)

Part of the [SportsDataverse](https://sportsdataverse.org/) family of R
packages for sports analytics.

Data freshness and pipeline status for every SportsDataverse dataset:
[sportsdataverse.org/status](https://sportsdataverse.org/status).

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

### **Python**

The same team colors, logos, wordmarks and headshots are on PyPI as
[**`sdvplot`**](https://pypi.org/project/sdvplot/) (Python 3.10+), with
adapters for matplotlib and seaborn, plotnine, Plotly, Altair, Bokeh,
HoloViews, great_tables and folium. `sdvplot.great_tables` ports this
package’s table themes, cell styling, legends and image export. Docs:
[sdvplot.sportsdataverse.org](https://sdvplot.sportsdataverse.org/).
Source:
[sportsdataverse/sdvplot](https://github.com/sportsdataverse/sdvplot).

``` sh
pip install sdvplot
```

### **JavaScript / TypeScript**

They are also on npm as
[**`@sportsdataverse/sdvplot`**](https://www.npmjs.com/package/@sportsdataverse/sdvplot),
with Observable Plot, D3, React and chart-library integrations plus shot
charts.
[**`@sportsdataverse/sdvtables`**](https://www.npmjs.com/package/@sportsdataverse/sdvtables)
is the counterpart to the `gt` table helpers. Docs:
[plot.sportsdataverse.org](https://plot.sportsdataverse.org). Source:
[sportsdataverse/sdvplot-js](https://github.com/sportsdataverse/sdvplot-js).

``` sh
npm install @sportsdataverse/sdvplot @sportsdataverse/sdvtables @sportsdataverse/sporty
```

## **Usage**

Every team-aware function takes a `league` argument (`"nfl"`, `"nba"`,
`"wnba"`, `"mlb"`, `"nhl"`, `"cfb"`, `"mbb"`, `"wbb"`, `"soccer"` and
the rest of
[`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md)).
Team identifiers are resolved automatically: full names, abbreviations
from other data providers (ESPN, nflverse, MLB Stats, nba_api, NHL,
CFBD, NCAA and more) and the codes of relocated franchises all resolve
to the same team.
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
shows the id a value resolves to,
[`sdv_suggest()`](https://sdvplotR.sportsdataverse.org/reference/sdv_suggest.md)
proposes candidates for a typo, and `season` selects the era for codes
that were reused.

``` r

library(sdvplotR)
library(ggplot2)

# NFL team logos in a grid
df <- data.frame(
  a     = rep(1:8, 4),
  b     = sort(rep(1:4, 8), decreasing = TRUE),
  teams = sdv_teams("nfl")$abbr
)

ggplot(df, aes(x = a, y = b)) +
  geom_sdv_logos(aes(team = teams), league = "nfl", width = 0.075) +
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
  scale_fill_sdv(league = "nfl") +
  theme_minimal() +
  theme(axis.text.x = element_sdv_logo(league = "nfl", size = 1))
```

``` r

library(gt)

# Logos inside a gt table, in the SportsDataverse table theme
data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11)) |>
  gt() |>
  gt_sdv_logos(columns = "team", league = "nfl") |>
  gt_theme_sdv()

# ...or dressed in one team's colors
data.frame(player = c("Patrick Mahomes", "Travis Kelce"), yards = c(4183, 984)) |>
  gt() |>
  gt_theme_sdv_team(team = "KC", league = "nfl")
```

``` r

library(reactable)

# Logos inside a reactable table with team-coloured bars
df3 <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))

reactable(
  df3,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(league = "nfl"), html = TRUE),
    wins = colDef(style = reactable_sdv_team_color_bar(df3, "team", league = "nfl"))
  )
)
```

``` r

# Interactive: the logo grid again, each logo with a tooltip (ggiraph) ...
p <- ggplot(df, aes(x = a, y = b)) +
  geom_sdv_logos_interactive(aes(team = teams, tooltip = teams, data_id = teams),
    league = "nfl", width = 0.075
  ) +
  theme_void()
ggiraph::girafe(ggobj = p)

# ... or logos on a native plotly chart (addSdvLogoMarkers() does maps)
plotly::plot_ly(df, x = ~a, y = ~b, type = "scatter", mode = "markers", text = ~teams) |>
  add_sdv_logos(df$a, df$b, df$teams, league = "nfl")

# A playing surface painted in a team's colors, ready for shot or play data
sdv_surface("nba", team = "BOS")
# ... or any of 59 surfaces, lacrosse to curling: see the Surfaces cookbook
sdv_surface("nll")
```

The [Interactive Charts
cookbook](https://sdvplotR.sportsdataverse.org/articles/cookbook-interactive.html)
covers
[`geom_sdv_logos_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos_interactive.md)
and its wordmark and headshot siblings,
[`add_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
[`sdv_axis_logos()`](https://sdvplotR.sportsdataverse.org/reference/sdv_axis_logos.md)
and
[`sdv_colorway()`](https://sdvplotR.sportsdataverse.org/reference/sdv_colorway.md)
for plotly, and
[`addSdvLogoMarkers()`](https://sdvplotR.sportsdataverse.org/reference/addSdvLogoMarkers.md)
for leaflet.

[`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
(light or `style = "dark"`) and
[`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
are the SportsDataverse table themes. The `gt` side also carries the
[gtUtils](https://github.com/andreweatherman/gtUtils) toolkit by Andrew
Weatherman: 18 table themes
([`gt_theme_kenpom()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_kenpom.md),
[`gt_theme_savant()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_savant.md),
[`gt_theme_athletic()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_athletic.md),
…), color legends, cut lines, significance notation, outlier flags,
faceted grids and
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
/
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md)
for publishing.

Dark-mode logo variants are available through `variant = "dark"` in the
reactable helpers (`reactable_sdv_logos(variant = "dark")`) and
[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md),
and
[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)
exposes the full reference data (ESPN ids, colors, conference) for every
team.

## **Documentation**

The [**`sdvplotR`** documentation
website](https://sdvplotR.sportsdataverse.org/) has the full function
reference and every article; a selection:

🖼️ [**Browse the
gallery**](https://sdvplotR.sportsdataverse.org/articles/gallery.html):
every article by its picture, each linking to the article that draws it.

**Per-sport** (each with companion SportsDataverse package examples):
[NFL](https://sdvplotR.sportsdataverse.org/articles/nfl-viz.html) ·
[CFB](https://sdvplotR.sportsdataverse.org/articles/cfb-viz.html) ·
[NBA](https://sdvplotR.sportsdataverse.org/articles/nba-viz.html) ·
[WNBA](https://sdvplotR.sportsdataverse.org/articles/wnba-viz.html) ·
[MLB](https://sdvplotR.sportsdataverse.org/articles/mlb-viz.html) ·
[NHL](https://sdvplotR.sportsdataverse.org/articles/nhl-viz.html) ·
[MBB](https://sdvplotR.sportsdataverse.org/articles/mbb-viz.html) ·
[WBB](https://sdvplotR.sportsdataverse.org/articles/wbb-viz.html) ·
[Soccer](https://sdvplotR.sportsdataverse.org/articles/soccer-viz.html)

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
· [Logos in
ggplot2](https://sdvplotR.sportsdataverse.org/articles/cookbook-ggplot-logos.html)
· [Colors and
Themes](https://sdvplotR.sportsdataverse.org/articles/cookbook-colors-themes.html)
· [Interactive: plotly, ggiraph,
leaflet](https://sdvplotR.sportsdataverse.org/articles/cookbook-interactive.html)
· [Surfaces and Shot
Charts](https://sdvplotR.sportsdataverse.org/articles/cookbook-surfaces-shot-charts.html)

**Interactive** (ggiraph, plotly and leaflet; every per-sport and
leaderboard article also ends with an interactive version): [NFL EPA
Scatter](https://sdvplotR.sportsdataverse.org/articles/recipe-nfl-epa-interactive.html)
· [NBA Net
Rating](https://sdvplotR.sportsdataverse.org/articles/recipe-nba-net-rating-interactive.html)
· [NHL Shot
Map](https://sdvplotR.sportsdataverse.org/articles/recipe-nhl-shot-map-interactive.html)
· [MLB Run
Differential](https://sdvplotR.sportsdataverse.org/articles/recipe-mlb-run-differential-interactive.html)
· [CFB Stadium
Map](https://sdvplotR.sportsdataverse.org/articles/recipe-cfb-stadium-map.html)
· [Team Maps with
leaflet](https://sdvplotR.sportsdataverse.org/articles/cookbook-leaflet-maps.html)

**Tables cookbook:** [SportsDataverse Table
Themes](https://sdvplotR.sportsdataverse.org/articles/sdv-table-themes.html)
· [Table Theme
Registry](https://sdvplotR.sportsdataverse.org/articles/articles/table-themes.html)
· [Team Tables with the gt
Toolkit](https://sdvplotR.sportsdataverse.org/articles/gt-toolkit.html)
· [reactable and
reactablefmtr](https://sdvplotR.sportsdataverse.org/articles/cookbook-reactable.html)
· [Saving and Posting
Tables](https://sdvplotR.sportsdataverse.org/articles/saving_tables.html)
· [Tier
Lists](https://sdvplotR.sportsdataverse.org/articles/tier_list.html) and
six more gtUtils recipes

**Recipes:** [NFL EPA
Scatter](https://sdvplotR.sportsdataverse.org/articles/recipe-nfl-epa-scatter.html)
· [Head-to-Head
Card](https://sdvplotR.sportsdataverse.org/articles/recipe-head-to-head-card.html)
· [Rank Bump
Chart](https://sdvplotR.sportsdataverse.org/articles/recipe-rank-bump-chart.html)
· [Rolling
Form](https://sdvplotR.sportsdataverse.org/articles/rolling-form.html)
and eleven more

**Leaderboards:**
[NFL](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nfl-weekly.html)
·
[CFB](https://sdvplotR.sportsdataverse.org/articles/leaderboard-cfb-weekly.html)
·
[NBA](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nba.html)
·
[WNBA](https://sdvplotR.sportsdataverse.org/articles/leaderboard-wnba.html)
·
[MLB](https://sdvplotR.sportsdataverse.org/articles/leaderboard-mlb.html)
·
[NHL](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nhl.html)

**Automation:** [Social Graphics,
Automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.html)

The [articles
index](https://sdvplotR.sportsdataverse.org/articles/index.html) lists
all of them.

## **Cheat sheet**

A printable four-page reference for **sdvplotR**: team logos, colors and
scales in ggplot2, team identity, the plotly, ggiraph and leaflet
integrations, surfaces, and the gt and reactable toolkits, in four color
themes, light and dark.

📄 [**Download the sdvplotR cheat sheet
(PDF)**](https://sportsdataverse.org/cheatsheets/sdvplotR.pdf)

Browse the other SportsDataverse cheat sheets at
[**sportsdataverse.org/cheatsheets**](https://sportsdataverse.org/cheatsheets).

## **The SportsDataverse**

`sdvplotR` draws the pictures; the companion packages fetch the data.

| Package | Sport / Scope |
|----|----|
| [**cfbfastR**](https://cfbfastR.sportsdataverse.org/) | College football |
| [**hoopR**](https://hoopR.sportsdataverse.org/) | Men’s basketball (NBA and NCAA) |
| [**wehoop**](https://wehoop.sportsdataverse.org/) | Women’s basketball (WNBA and NCAA) |
| [**fastRhockey**](https://fastRhockey.sportsdataverse.org/) | Hockey (NHL and PWHL) |
| [**baseballr**](https://billpetti.github.io/baseballr/) | Baseball (MLB, MiLB, NCAA) |
| [**nflfastR**](https://github.com/nflverse/nflfastR) · [**nflreadr**](https://nflreadr.nflverse.com/) | NFL play-by-play and data loaders |
| [**oddsapiR**](https://oddsapiR.sportsdataverse.org/) | Sports betting odds |
| [**cfbseedR**](https://cfbseedR.sportsdataverse.org/) | CFB seeding and playoff simulation |
| [**sportyR**](https://sportyR.sportsdataverse.org/) | Playing-surface plots |
| [**sportsdataverse-R**](https://r.sportsdataverse.org/) | Umbrella R metapackage |
| [**sdvplot**](https://sdvplot.sportsdataverse.org/) | Python plots and tables |
| [**@sportsdataverse/sdvplot**](https://plot.sportsdataverse.org) · [**@sportsdataverse/sdvtables**](https://plot.sportsdataverse.org/guides/tables) | JavaScript / TypeScript plots and tables |
| [**sportsdataverse-py**](https://py.sportsdataverse.org/) · [**sportsdataverse.js**](https://js.sportsdataverse.org/) | Python and Node.js |

See the full ecosystem at
[sportsdataverse.org](https://sportsdataverse.org/).

## Follow the [SportsDataverse](https://x.com/SportsDataverse) on X and star this repo

[![X
Follow](https://img.shields.io/badge/%40SportsDataverse-blue?logo=x&style=for-the-badge)](https://x.com/SportsDataverse)

[![GitHub
stars](https://img.shields.io/github/stars/sportsdataverse/sdvplotR.svg?color=eee&logo=github&style=for-the-badge&label=Star%20sdvplotR&maxAge=2592000)](https://github.com/sportsdataverse/sdvplotR)

[![Star history of
sportsdataverse/sdvplotR](https://raw.githubusercontent.com/sportsdataverse/sdvplotR/star-history/star-history.png)](https://github.com/sportsdataverse/sdvplotR)

## **Our Authors**

- [Saiem Gilani](https://x.com/saiemgilani) [![ORCID
  logo](https://orcid.org/sites/default/files/images/orcid_16x16.png)](https://orcid.org/0000-0002-7194-9067)  
  [![@saiemgilani](https://img.shields.io/badge/%40saiemgilani-blue?logo=x&style=for-the-badge)](https://x.com/saiemgilani)
  [![@saiemgilani](https://img.shields.io/github/followers/saiemgilani?color=eee&logo=Github&style=for-the-badge)](https://github.com/saiemgilani)

- [Sebastian Carl](https://x.com/mrcaseb)  
  [![@mrcaseb](https://img.shields.io/badge/%40mrcaseb-blue?logo=x&style=for-the-badge)](https://x.com/mrcaseb)
  [![@mrcaseb](https://img.shields.io/github/followers/mrcaseb?color=eee&logo=Github&style=for-the-badge)](https://github.com/mrcaseb)

- [Jared Lee](https://github.com/Kazink36)  
  [![@Kazink36](https://img.shields.io/github/followers/Kazink36?color=eee&logo=Github&style=for-the-badge)](https://github.com/Kazink36)

- [Camden Kay](https://x.com/camdenkay)  
  [![@camdenkay](https://img.shields.io/badge/%40camdenkay-blue?logo=x&style=for-the-badge)](https://x.com/camdenkay)
  [![@camdenk](https://img.shields.io/github/followers/camdenk?color=eee&logo=Github&style=for-the-badge)](https://github.com/camdenk)

- [Andrew Weatherman](https://github.com/andreweatherman) (gtUtils)  
  [![@andreweatherman](https://img.shields.io/github/followers/andreweatherman?color=eee&logo=Github&style=for-the-badge)](https://github.com/andreweatherman)

## **Code of Conduct**

Please note that the sdvplotR project is released with a [Contributor
Code of
Conduct](https://sdvplotR.sportsdataverse.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

## **Citations**

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
