# Axis Scales for Sports Team Logos

These scale functions replace axis labels with team logos or player
headshots. They work by modifying the axis text theme element to render
images.

## Usage

``` r
scale_x_sdv(
  ...,
  league,
  expand = ggplot2::waiver(),
  guide = ggplot2::waiver(),
  position = "bottom",
  size = 12,
  season = NULL,
  id_system = "auto"
)

scale_y_sdv(
  ...,
  league,
  expand = ggplot2::waiver(),
  guide = ggplot2::waiver(),
  position = "left",
  size = 12,
  season = NULL,
  id_system = "auto"
)

scale_x_sdv_headshots(
  ...,
  league,
  expand = ggplot2::waiver(),
  guide = ggplot2::waiver(),
  position = "bottom",
  size = 20,
  id_system = "espn"
)

scale_y_sdv_headshots(
  ...,
  league,
  expand = ggplot2::waiver(),
  guide = ggplot2::waiver(),
  position = "left",
  size = 30,
  id_system = "espn"
)
```

## Arguments

- ...:

  Other arguments passed to
  [`ggplot2::scale_x_discrete()`](https://ggplot2.tidyverse.org/reference/scale_discrete.html)
  or
  [`ggplot2::scale_y_discrete()`](https://ggplot2.tidyverse.org/reference/scale_discrete.html).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- expand:

  Expansion limits for the axis.

- guide:

  Guide for the axis.

- position:

  Position of the axis.

- size:

  The logo size in pixels. It is applied as height for an x-scale and as
  width for a y-scale.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

## Value

A ggplot2 scale object.

## Details

The scale translates team names into raw image HTML and places the HTML
as axis labels. Because of the way ggplots are constructed, it is
necessary to adjust the theme after calling this scale. This can be done
by calling
[`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
or
[`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
after any complete theme such as
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
which replaces every theme element. To set the theme by hand, change the
relevant `axis.text` and its position children (`axis.text.x.bottom`,
...) to
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html):
complete themes in 'ggplot2' 4 set those children themselves.

## See also

[`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md),
[`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

team_abbr <- sdv_teams("nfl")$abbr[1:8]

df <- data.frame(
  random_value = runif(length(team_abbr), 0, 1),
  teams = team_abbr
)

if (requireNamespace("ggtext", quietly = TRUE)) {
  ggplot(df, aes(x = teams, y = random_value)) +
    geom_col(aes(fill = teams), width = 0.5) +
    scale_fill_sdv(league = "nfl", alpha = 0.4) +
    scale_x_sdv(league = "nfl") +
    theme_minimal() +
    theme_x_sdv()
}

# }
```
