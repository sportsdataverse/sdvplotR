# SportsDataverse Table Themes

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

The final 2023 AFC West standings, typed in so this article builds
offline. The logos come from
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
which resolves the abbreviations through
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md).

``` r

standings <- data.frame(
  team = c("KC", "LV", "DEN", "LAC"),
  name = c("Kansas City Chiefs", "Las Vegas Raiders", "Denver Broncos", "Los Angeles Chargers"),
  w = c(11, 8, 8, 5),
  l = c(6, 9, 9, 12)
)
standings$pct <- standings$w / (standings$w + standings$l)

standings_table <- gt(standings) |>
  gt_sdv_logos(columns = "team", sport = "nfl", height = 26) |>
  cols_label(team = "", name = "Team", w = "W", l = "L", pct = "Win pct") |>
  # win percentage without the leading zero, as box scores print it (.647)
  fmt(columns = "pct", fns = function(x) sub("^0", "", sprintf("%.3f", x))) |>
  tab_header("AFC West standings", "2023 regular season") |>
  tab_source_note("Data: nflverse")
```

## The house theme

``` r

standings_table |> gt_theme_sdv()
```

| AFC West standings |  |  |  |  |
|----|----|----|----|----|
| 2023 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | Kansas City Chiefs | 11 | 6 | .647 |
| ![The LV logo](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | Las Vegas Raiders | 8 | 9 | .471 |
| ![The DEN logo](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | Denver Broncos | 8 | 9 | .471 |
| ![The LAC logo](https://a.espncdn.com/i/teamlogos/nfl/500/lac.png) | Los Angeles Chargers | 5 | 12 | .294 |
| Data: nflverse |  |  |  |  |

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
| 2023 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | Kansas City Chiefs | 11 | 6 | .647 |
| ![The LV logo](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | Las Vegas Raiders | 8 | 9 | .471 |
| ![The DEN logo](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | Denver Broncos | 8 | 9 | .471 |
| ![The LAC logo](https://a.espncdn.com/i/teamlogos/nfl/500/lac.png) | Los Angeles Chargers | 5 | 12 | .294 |
| Data: nflverse |  |  |  |  |

## A team’s colors

[`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
takes a team and a sport. It uses the colors
[`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
returns: the title block is filled with the primary color, the line
under the labels uses the secondary color, and the labels are set in the
primary color. Any abbreviation, alias or full name
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
accepts works as `team`.

``` r

data.frame(
  player = c("Patrick Mahomes", "Travis Kelce", "Isiah Pacheco"),
  stat = c("Passing", "Receiving", "Rushing"),
  yards = c(4183, 984, 935)
) |>
  gt() |>
  cols_label(player = "Player", stat = "", yards = "Yards") |>
  fmt_number(columns = "yards", decimals = 0) |>
  tab_header("Chiefs yardage leaders", "2023 regular season") |>
  gt_theme_sdv_team(team = "KC", sport = "nfl")
```

| Chiefs yardage leaders |           |       |
|------------------------|-----------|-------|
| 2023 regular season    |           |       |
| Player                 |           | Yards |
| Patrick Mahomes        | Passing   | 4,183 |
| Travis Kelce           | Receiving | 984   |
| Isiah Pacheco          | Rushing   | 935   |

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

color_record <- function(sport, team) {
  data.frame(
    team = team,
    primary = unname(sdv_team_colors(sport, team, "primary")),
    secondary = unname(sdv_team_colors(sport, team, "secondary"))
  )
}

color_record("mbb", "DUKE") |>
  gt() |>
  tab_header("Duke Blue Devils", "A white secondary: the line takes the primary") |>
  gt_theme_sdv_team(team = "DUKE", sport = "mbb")
```

| Duke Blue Devils                              |          |           |
|-----------------------------------------------|----------|-----------|
| A white secondary: the line takes the primary |          |           |
| team                                          | primary  | secondary |
| DUKE                                          | \#00539B | \#FFFFFF  |

``` r


color_record("nfl", "NO") |>
  gt() |>
  tab_header("New Orleans Saints", "A gold primary: the labels go navy") |>
  gt_theme_sdv_team(team = "NO", sport = "nfl")
```

| New Orleans Saints                 |          |           |
|------------------------------------|----------|-----------|
| A gold primary: the labels go navy |          |           |
| team                               | primary  | secondary |
| NO                                 | \#D3BC8D | \#000000  |

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
| 2023 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | Kansas City Chiefs | 11 | 6 | .647 |
| ![The LV logo](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | Las Vegas Raiders | 8 | 9 | .471 |
| ![The DEN logo](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | Denver Broncos | 8 | 9 | .471 |
| ![The LAC logo](https://a.espncdn.com/i/teamlogos/nfl/500/lac.png) | Los Angeles Chargers | 5 | 12 | .294 |
| Data: nflverse |  |  |  |  |

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
| 2023 regular season |  |  |  |  |
|  | Team | W | L | Win pct |
| ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | Kansas City Chiefs | 11 | 6 | .647 |
| ![The LV logo](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | Las Vegas Raiders | 8 | 9 | .471 |
| ![The DEN logo](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | Denver Broncos | 8 | 9 | .471 |
| ![The LAC logo](https://a.espncdn.com/i/teamlogos/nfl/500/lac.png) | Los Angeles Chargers | 5 | 12 | .294 |
| Data: nflverse |  |  |  |  |

## Saving an image

`theme_bg` records the background each theme paints. Pass it to
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
so the padding around the saved image matches the table instead of
framing it in white.

``` r

bg <- theme_bg$bg[theme_bg$theme == "gt_theme_sdv" & theme_bg$has_style == "dark"]

standings_table |>
  gt_theme_sdv(style = "dark", density = "social") |>
  gt_save_crop("afc-west.png", bg = bg)
```

To see these next to the 18 other themes in the package on your own
data, run `gt_theme_preview(standings)`.
