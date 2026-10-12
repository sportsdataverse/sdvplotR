# Theme Elements for Image Grobs

In conjunction with the
[ggplot2::theme](https://ggplot2.tidyverse.org/reference/theme.html)
system, the following `element_` functions enable images in non-data
components of the plot, e.g. axis text.

- `element_sdv_logo()`: draws team logos instead of their abbreviations.

- `element_sdv_wordmark()`: draws team wordmarks instead of their
  abbreviations.

- `element_sdv_headshot()`: draws player headshots instead of their IDs.

- `element_sdv_raster()`: draws a single image in a rectangular theme
  element such as `plot.background`. A thin wrapper around
  [`ggpath::element_raster()`](https://mrcaseb.github.io/ggpath/reference/element_path.html).

## Usage

``` r
element_sdv_logo(
  league,
  alpha = NULL,
  colour = NA,
  color = NULL,
  hjust = NULL,
  vjust = NULL,
  size = 0.5,
  season = NULL,
  id_system = "auto"
)

element_sdv_wordmark(
  league,
  alpha = NULL,
  colour = NA,
  color = NULL,
  hjust = NULL,
  vjust = NULL,
  size = 0.5,
  season = NULL,
  id_system = "auto"
)

element_sdv_headshot(
  league,
  alpha = NULL,
  colour = NA,
  color = NULL,
  hjust = NULL,
  vjust = NULL,
  size = 0.5,
  id_system = "espn"
)

element_sdv_raster(
  image_path,
  x = grid::unit(0.5, "npc"),
  y = grid::unit(0.5, "npc"),
  width = grid::unit(1, "npc"),
  height = grid::unit(1, "npc"),
  just = "centre",
  hjust = 0.5,
  vjust = 0.5,
  interpolate = TRUE,
  ...
)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- alpha:

  The alpha channel (transparency) between 0 and 1.

- colour, color:

  The image will be colorized with this color. Use `"b/w"` for black and
  white.

- hjust:

  Horizontal justification.

- vjust:

  Vertical justification.

- size:

  The output grob size in `cm`.

- season:

  `NULL` for today's marks, or one season: the marks the teams wore that
  season. One element draws every label, so one season.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

- image_path:

  A file path or url to an image.

- x, y, width, height, just, interpolate:

  Passed on to
  [`ggpath::element_raster()`](https://mrcaseb.github.io/ggpath/reference/element_path.html).

- ...:

  Other arguments passed on to
  [`ggpath::element_raster()`](https://mrcaseb.github.io/ggpath/reference/element_path.html).

## Value

`element_sdv_logo()`, `element_sdv_wordmark()` and
`element_sdv_headshot()` return a theme element extending
[`ggpath::element_path()`](https://mrcaseb.github.io/ggpath/reference/element_path.html);
`element_sdv_raster()` returns a
[`ggpath::element_raster()`](https://mrcaseb.github.io/ggpath/reference/element_path.html).

## Details

The elements translate team abbreviations or player IDs into logo images
or player headshots for the specified league. Rendering is delegated to
[`ggpath::element_path()`](https://mrcaseb.github.io/ggpath/reference/element_path.html),
which they extend. Set on a parent element such as `axis.text.x`, they
also replace the position children (`axis.text.x.bottom`,
`axis.text.y.left`, ...) that complete themes like
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
set, keeping the child's spacing.

## See also

[`ggpath::element_path()`](https://mrcaseb.github.io/ggpath/reference/element_path.html),
[`ggpath::element_raster()`](https://mrcaseb.github.io/ggpath/reference/element_path.html)

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

team_abbr <- sdv_teams("nfl")$abbr[1:16]

df <- data.frame(
  random_value = runif(length(team_abbr), 0, 1),
  teams = team_abbr
)

# use logos for x-axis
ggplot(df, aes(x = teams, y = random_value)) +
  geom_col(aes(color = teams, fill = teams), width = 0.5) +
  scale_color_sdv(league = "nfl", which = "secondary") +
  scale_fill_sdv(league = "nfl", alpha = 0.4) +
  theme_minimal() +
  theme(axis.text.x = element_sdv_logo(league = "nfl"))

# }
```
