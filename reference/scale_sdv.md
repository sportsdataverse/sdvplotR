# Scales for Sports Team Colors

These functions map team names to their team colors in color and fill
aesthetics.

## Usage

``` r
scale_color_sdv(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("primary", "secondary"),
  values = NULL,
  ...,
  aesthetics = "colour",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)

scale_colour_sdv(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("primary", "secondary"),
  values = NULL,
  ...,
  aesthetics = "colour",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)

scale_fill_sdv(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("primary", "secondary"),
  values = NULL,
  ...,
  aesthetics = "fill",
  breaks = ggplot2::waiver(),
  na.value = "grey50",
  guide = NULL,
  alpha = NA
)
```

## Arguments

- sport:

  Character string identifying the sport.

- type:

  One of `"primary"` or `"secondary"` to decide which color type to use.

- values:

  If `NULL` (the default) use the internal team color vectors. Otherwise
  a set of aesthetic values to map data values to.

- ...:

  Other arguments passed to
  [`ggplot2::scale_color_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
  or
  [`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

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

team_abbr <- valid_team_names("nfl")[1:16]

df <- data.frame(
  random_value = runif(length(team_abbr), 0, 1),
  teams = team_abbr
)

ggplot(df, aes(x = teams, y = random_value)) +
  geom_col(aes(color = teams, fill = teams), width = 0.5) +
  scale_color_sdv(sport = "nfl", type = "secondary") +
  scale_fill_sdv(sport = "nfl", alpha = 0.4) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# }
```
