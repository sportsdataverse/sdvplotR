# Team-Styled Playing Surfaces

Draws a regulation court, field or rink with 'sportyR' and, given a
team, paints a few of its features in that team's colors from
[`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md).
The result is a ggplot, so data layers go on top.

These are **stylized** surfaces built from team colors, not the team's
real court, field or rink design: no dataset of real team surface
designs (paint colors, center logos, end zone art, special-event floors)
exists yet.

## Usage

``` r
sdv_surface(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer", "fiba"),
  team = NULL,
  center_logo = FALSE,
  ...
)
```

## Arguments

- sport:

  One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md),
  or `"soccer"` or `"fiba"`. Each maps to a 'sportyR' surface:

  |  |  |
  |----|----|
  | sport | surface |
  | `"nfl"` | `sportyR::geom_football("nfl")` |
  | `"cfb"` | `sportyR::geom_football("ncaa")` |
  | `"nba"`, `"wnba"` | `sportyR::geom_basketball("nba")` / `("wnba")` |
  | `"mbb"`, `"wbb"` | `sportyR::geom_basketball("ncaa")` |
  | `"nhl"` | `sportyR::geom_hockey("nhl")` |
  | `"mlb"` | `sportyR::geom_baseball("mlb")` |
  | `"soccer"` | `sportyR::geom_soccer("fifa")`, 105 x 68 m (`pitch_updates` overrides) |
  | `"fiba"` | `sportyR::geom_basketball("fiba")` (28 x 15 m) |

- team:

  `NULL` (the default) for the plain regulation surface, or one team
  name or abbreviation, cleaned by
  [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md).

- center_logo:

  If `TRUE`, draw the team's logo at center court, center ice or
  midfield. Needs a `team`; ignored with a warning for `"mlb"`, whose
  surface is an infield with no center.

- ...:

  Passed to the 'sportyR' geom: `display_range`, `rotation`, `x_trans`,
  `y_trans`, `xlims`, `ylims`, the unit arguments, and `color_updates`,
  which overrides the team colors feature by feature (see
  [`sportyR::cani_color_league_features()`](https://sportyR.sportsdataverse.org/reference/cani_color_league_features.html)
  for the names).

## Value

A ggplot object
([`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html))
with
[`coord_fixed()`](https://ggplot2.tidyverse.org/reference/coord_fixed.html);
add layers with `+`.

## Details

With a `team`, these features change; everything else keeps 'sportyR”s
regulation colors, so the court stays wood, the field green and the ice
white:

- Basketball: the painted area and the court apron take the primary
  color. The lines drawn inside the paint (restricted arc, free-throw
  circle dashes, lower defensive boxes) turn black or white, whichever
  contrasts more with it.

- Football: both end zones take the primary color.

- Hockey: the center line, center faceoff circle and center faceoff spot
  take the primary color, or the secondary where the primary is too pale
  to read on white ice (under 3:1 contrast); the boards take the
  primary.

- Baseball: nothing. No part of a regulation infield is team-colored
  (the green background is the outfield grass), so the team is checked
  and the surface stays 'sportyR”s.

Soccer and FIBA surfaces are drawn in meters. "soccer" defaults to a
regulation 105 x 68 m pitch, the frame
[`sdv_pitch_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_pitch_coords.md)
converts to; 'sportyR”s own "fifa" default is FIFA's 120 x 90 m maximum.
Neither takes a `team` yet.

Surfaces use 'sportyR”s coordinates: the origin at the center, in feet
(yards for football). The center logo is sized in those units (12 feet
on a court, 10 yards on a field, 24 feet on a rink) and follows
`x_trans`, `y_trans`, `rotation` and the unit arguments.

## Examples

``` r
# \donttest{
if (requireNamespace("sportyR", quietly = TRUE)) {
  library(ggplot2)

  # the regulation surface
  sdv_surface("nhl")

  # in a team's colors, with its logo at center court, and shots on top
  shots <- data.frame(x = c(-40, -35, 30), y = c(5, -12, 0))
  sdv_surface("nba", "BOS", center_logo = TRUE) +
    geom_point(aes(x, y), data = shots, color = "red", size = 3)

  # sportyR arguments pass through
  sdv_surface("cfb", "TEX", rotation = 90)
}

# }
```
