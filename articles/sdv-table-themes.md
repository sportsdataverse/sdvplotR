# SportsDataverse Table Themes

On this page

sdvplotR puts team logos, headshots and colors inside `gt` tables. The
table around them still needs a look, and two themes are built for that:

- [`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
  is the SportsDataverse house table, in light or dark.
- [`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
  dresses the same table in one team’s colors.

Both follow the same rules. Titles and column labels are set in Chivo,
and the body in Lato with tabular figures, so digits line up down a
column. Column labels keep the case you give them. The one accent is a
line under the column labels, so logos and team colors stay the loudest
thing in the table.

``` r

library(sdvplotR)
library(gt)
```

## The data

The final 2025 AFC West standings.
[`nflseedR::nfl_standings()`](https://nflseedr.com/reference/nfl_standings.html)
computes them from nflverse’s schedule, read with `nflreadr`, NFL
tiebreakers included, and
[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)
adds each team’s full name. The logos come from
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
which resolves the abbreviations through
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md).

``` r

nfl_teams <- sdv_teams("nfl")

standings <- nflseedR::nfl_standings(nflreadr::load_schedules(2025), verbosity = "NONE") |>
  subset(division == "AFC West")
standings <- standings[order(standings$div_rank), ]
standings <- data.frame(
  team = standings$team,
  name = nfl_teams$name[match(standings$team, nfl_teams$abbr)],
  w = standings$true_wins,
  l = standings$losses,
  pct = standings$win_pct
)

standings_table <- gt(standings) |>
  gt_sdv_logos(columns = "team", league = "nfl", height = 26) |>
  cols_label(team = "", name = "Team", w = "W", l = "L", pct = "Win pct") |>
  # win percentage without the leading zero, as box scores print it (.647)
  fmt(columns = "pct", fns = function(x) sub("^0", "", sprintf("%.3f", x))) |>
  tab_header("AFC West standings", "2025 regular season") |>
  tab_source_note("Data: nflverse via nflreadr and nflseedR")
```

## The house theme

``` r

standings_table |> gt_theme_sdv()
```

| AFC West standings |  |  |  |  |
|----|----|----|----|----|
| 2025 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![Denver Broncos](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c98bec2be32e27b19f79f5da86ac6ef133c78d75ab78aadb28ef36696c3213e8.png) | Denver Broncos | 14 | 3 | .824 |
| ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | Los Angeles Chargers | 11 | 6 | .647 |
| ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | Kansas City Chiefs | 6 | 11 | .353 |
| ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | Las Vegas Raiders | 3 | 14 | .176 |
| Data: nflverse via nflreadr and nflseedR |  |  |  |  |

The line under the column labels is the SportsDataverse gradient, the
same one in the package logo. It is the only decoration, drawn once
across the whole table rather than per cell.

## Dark

`style = "dark"` sets the same table on the SportsDataverse navy. It
matches the dark mode of this site, and suits posts that sit on a dark
background.

``` r

standings_table |> gt_theme_sdv(style = "dark")
```

| AFC West standings |  |  |  |  |
|----|----|----|----|----|
| 2025 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![Denver Broncos](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c98bec2be32e27b19f79f5da86ac6ef133c78d75ab78aadb28ef36696c3213e8.png) | Denver Broncos | 14 | 3 | .824 |
| ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | Los Angeles Chargers | 11 | 6 | .647 |
| ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | Kansas City Chiefs | 6 | 11 | .353 |
| ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | Las Vegas Raiders | 3 | 14 | .176 |
| Data: nflverse via nflreadr and nflseedR |  |  |  |  |

## A team’s colors

[`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
takes a team and a sport. It uses the colors
[`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
returns: the title block is filled with the primary color, the line
under the labels uses the secondary color, and the labels are set in the
primary color. Any abbreviation, alias or full name
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
accepts works as `team`. Here the division winner’s yardage leaders,
from nflverse’s season player stats, wear the winner’s colors.

``` r

winner <- standings$team[1]
players <- nflreadr::load_player_stats(2025, summary_level = "reg")
players <- players[players$recent_team == winner, ]

leader <- function(stat, label) {
  top <- players[which.max(players[[stat]]), ]
  data.frame(player = top$player_display_name, stat = label, yards = top[[stat]])
}

rbind(
  leader("passing_yards", "Passing"),
  leader("receiving_yards", "Receiving"),
  leader("rushing_yards", "Rushing")
) |>
  gt() |>
  cols_label(player = "Player", stat = "", yards = "Yards") |>
  fmt_number(columns = "yards", decimals = 0) |>
  tab_header(
    paste(nfl_teams$short_name[nfl_teams$abbr == winner], "yardage leaders"),
    "2025 regular season"
  ) |>
  gt_theme_sdv_team(team = winner, league = "nfl")
```

| Broncos yardage leaders |           |       |
|-------------------------|-----------|-------|
| 2025 regular season     |           |       |
| Player                  |           | Yards |
| Bo Nix                  | Passing   | 3,931 |
| Courtland Sutton        | Receiving | 1,017 |
| J.K. Dobbins            | Rushing   | 772   |

### Colors that would not read

Team colors are chosen for jerseys, not for text on a white table, so
the theme checks contrast rather than using the colors as they come:

- Title text on the filled block is black or white, whichever contrasts
  more with the primary color.
- A secondary color too pale to see on white (Duke’s is white) gives way
  to the primary color for the line.
- A primary color too light to read as text (the Saints’ gold) gives way
  to the SportsDataverse navy for the column labels.

Each table below shows the team’s own colors as
[`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
returns them, dressed in those colors.

``` r

color_record <- function(league, team) {
  data.frame(
    team = team,
    primary = unname(sdv_team_colors(league, team, "primary")),
    secondary = unname(sdv_team_colors(league, team, "secondary"))
  )
}

color_record("mbb", "DUKE") |>
  gt() |>
  tab_header("Duke Blue Devils", "A white secondary: the line takes the primary") |>
  gt_theme_sdv_team(team = "DUKE", league = "mbb")
```

| Duke Blue Devils                              |          |           |
|-----------------------------------------------|----------|-----------|
| A white secondary: the line takes the primary |          |           |
| team                                          | primary  | secondary |
| DUKE                                          | \#00539b | \#ffffff  |

``` r


color_record("nfl", "NO") |>
  gt() |>
  tab_header("New Orleans Saints", "A gold primary: the labels go navy") |>
  gt_theme_sdv_team(team = "NO", league = "nfl")
```

| New Orleans Saints                 |          |           |
|------------------------------------|----------|-----------|
| A gold primary: the labels go navy |          |           |
| team                               | primary  | secondary |
| NO                                 | \#d3bc8d | \#000000  |

With `team = NULL` the table wears the SportsDataverse navy and cyan.

## Sizing for where it goes

Every theme takes `density`. `"comfortable"` is the default, `"compact"`
tightens type and row padding for long tables, and `"social"` scales
both up to the size
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
and
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md)
export at.

``` r

standings_table |> gt_theme_sdv(density = "compact")
```

| AFC West standings |  |  |  |  |
|----|----|----|----|----|
| 2025 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![Denver Broncos](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c98bec2be32e27b19f79f5da86ac6ef133c78d75ab78aadb28ef36696c3213e8.png) | Denver Broncos | 14 | 3 | .824 |
| ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | Los Angeles Chargers | 11 | 6 | .647 |
| ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | Kansas City Chiefs | 6 | 11 | .353 |
| ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | Las Vegas Raiders | 3 | 14 | .176 |
| Data: nflverse via nflreadr and nflseedR |  |  |  |  |

## Changing one thing

Anything in `...` goes to
[`gt::tab_options()`](https://gt.rstudio.com/reference/tab_options.html)
after the theme’s own options, so it overrides them. Center the heading
and keep everything else:

``` r

standings_table |> gt_theme_sdv(heading.align = "center")
```

| AFC West standings |  |  |  |  |
|----|----|----|----|----|
| 2025 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![Denver Broncos](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c98bec2be32e27b19f79f5da86ac6ef133c78d75ab78aadb28ef36696c3213e8.png) | Denver Broncos | 14 | 3 | .824 |
| ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | Los Angeles Chargers | 11 | 6 | .647 |
| ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | Kansas City Chiefs | 6 | 11 | .353 |
| ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | Las Vegas Raiders | 3 | 14 | .176 |
| Data: nflverse via nflreadr and nflseedR |  |  |  |  |

## Saving an image

`theme_bg` records the background each theme paints. Pass it to
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
so the padding around the saved image matches the table instead of
framing it in white. Saving drives a headless Chrome through `webshot2`,
so this chunk is not run here.

``` r

bg <- theme_bg$bg[theme_bg$theme == "gt_theme_sdv" & theme_bg$has_style == "dark"]

standings_table |>
  gt_theme_sdv(style = "dark", density = "social") |>
  gt_save_crop("afc-west.png", bg = bg)
```

To see these next to every other theme that needs only the table, on
your own data, run `gt_theme_preview(standings)`.

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
