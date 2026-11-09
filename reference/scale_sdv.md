# Scales for Sports Team Colors

These functions map team names to their team colors in color and fill
aesthetics.

## Usage

``` r
scale_color_sdv(
  league,
  which = c("primary", "secondary"),
  values = NULL,
  ...,
  alt_colors = NULL,
  aesthetics = "colour",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)

scale_colour_sdv(
  league,
  which = c("primary", "secondary"),
  values = NULL,
  ...,
  alt_colors = NULL,
  aesthetics = "colour",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)

scale_fill_sdv(
  league,
  which = c("primary", "secondary"),
  values = NULL,
  ...,
  alt_colors = NULL,
  aesthetics = "fill",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- which:

  One of `"primary"` or `"secondary"`: which team colour to use.

- values:

  If `NULL` (the default) use the internal team color vectors. Otherwise
  a set of aesthetic values to map data values to.

- ...:

  Other arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  or
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

- alt_colors:

  Teams (any identifier
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  accepts) drawn in their other colour: the secondary one, or the
  primary one with `which = "secondary"`. A team with no other colour
  keeps its own. Ignored when `values` is given. The counterpart of
  cfbplotR's `alt_colors`.

- aesthetics:

  The aesthetic to apply the scale to (`"colour"` or `"fill"`).

- breaks:

  Breaks for the scale.

- na.value:

  Color for NA values.

- guide:

  Guide function or name.

- alpha:

  Factor to modify color transparency via
  [`scales::alpha()`](https://scales.r-lib.org/reference/alpha.html). If
  `NA` (the default) no transparency will be applied.

## Value

A ggplot2 scale object.

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

ggplot(df, aes(x = teams, y = random_value)) +
  geom_col(aes(color = teams, fill = teams), width = 0.5) +
  scale_color_sdv(league = "nfl", which = "secondary") +
  scale_fill_sdv(league = "nfl", alpha = 0.4) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# college football, with Alabama and Utah in their secondary colours
cfb <- data.frame(y = 6:9, teams = c("Alabama", "Florida State", "Oregon", "Utah"))
ggplot(cfb, aes(x = teams, y = y)) +
  geom_col(aes(fill = teams)) +
  scale_fill_sdv(league = "cfb", alt_colors = c("Alabama", "Utah")) +
  theme_minimal()

# }
```
