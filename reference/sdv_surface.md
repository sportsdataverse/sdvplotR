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
sdv_surface(league, team = NULL, season = NULL, center_logo = FALSE, ...)
```

## Arguments

- league:

  One of the 59 SportsDataverse surface keys, the same table sdvplot-js
  uses. Each maps to a 'sportyR' surface:

  |  |  |
  |----|----|
  | league | surface |
  | `"nfl"`, `"aaf"`, `"ufl"`, `"usfl"`, `"xfl"` | `sportyR::geom_football("nfl")` |
  | `"cfb"` | `sportyR::geom_football("ncaa")` |
  | `"cfl"` | `sportyR::geom_football("cfl")` |
  | `"nfhs_football"` | `sportyR::geom_football("nfhs11")` |
  | `"nba"` | `sportyR::geom_basketball("nba")` |
  | `"nbagl"` | `sportyR::geom_basketball("nba g league")` |
  | `"wnba"` | `sportyR::geom_basketball("wnba")` |
  | `"mbb"`, `"wbb"` | `sportyR::geom_basketball("ncaa")` |
  | `"fiba"` | `sportyR::geom_basketball("fiba")` (28 x 15 m) |
  | `"nfhs_basketball"` | `sportyR::geom_basketball("nfhs")` |
  | `"mlb"`, `"milb"`, `"pony"` | [`sportyR::geom_baseball()`](https://sportyR.sportsdataverse.org/reference/geom_baseball.html) of the same league |
  | `"ncaa_baseball"` | `sportyR::geom_baseball("ncaa")` |
  | `"little_league"` | `sportyR::geom_baseball("little league")` |
  | `"nfhs_baseball"` | `sportyR::geom_baseball("nfhs")` |
  | `"ncaa_softball"` | `sportyR::geom_softball("ncaa")` |
  | `"nhl"`, `"whl"` | `sportyR::geom_hockey("nhl")` (no WHL rink in 'sportyR') |
  | `"pwhl"`, `"ahl"`, `"echl"`, `"ohl"`, `"qmjhl"`, `"ushl"`, `"phf"`, `"iihf"`, `"nwhl"` | [`sportyR::geom_hockey()`](https://sportyR.sportsdataverse.org/reference/geom_hockey.html) of the same league |
  | `"ncaa_mhockey"`, `"ncaa_whockey"` | `sportyR::geom_hockey("ncaa")` |
  | `"soccer"` | `sportyR::geom_soccer("fifa")`, 105 x 68 m (`pitch_updates` overrides) |
  | `"fifa"`, `"epl"`, `"mls"`, `"nwsl"` | [`sportyR::geom_soccer()`](https://sportyR.sportsdataverse.org/reference/geom_soccer.html) of the same league ('sportyR”s own pitch size) |
  | `"ncaa_soccer"` | `sportyR::geom_soccer("ncaa")` |
  | `"nll"`, `"pll"` | [`sportyR::geom_lacrosse()`](https://sportyR.sportsdataverse.org/reference/geom_lacrosse.html) of the same league |
  | `"world_lacrosse"` | `sportyR::geom_lacrosse("world lacrosse")` |
  | `"ncaa_mlacrosse"`, `"ncaa_wlacrosse"` | `sportyR::geom_lacrosse("ncaam")`, `("ncaaw")` |
  | `"usa_mlacrosse"`, `"usa_wlacrosse"` | `sportyR::geom_lacrosse("usam")`, `("usaw")` |
  | `"atp"`, `"wta"`, `"itf"`, `"ita"`, `"usta"` | [`sportyR::geom_tennis()`](https://sportyR.sportsdataverse.org/reference/geom_tennis.html) of the same league |
  | `"ncaa_tennis"` | `sportyR::geom_tennis("ncaa")` |
  | `"fivb"` | `sportyR::geom_volleyball("fivb")` |
  | `"usa_volleyball"` | `sportyR::geom_volleyball("usa volleyball")` |
  | `"ncaa_volleyball"` | `sportyR::geom_volleyball("ncaa")` |
  | `"wcf"` | `sportyR::geom_curling("wcf")` |
  | `"curling_canada"` | `sportyR::geom_curling("curling canada")` |

  The PWHL and the G League draw their own rink and court, as in
  sdvplot-js. Surfaces need 'sportyR' 2.4.5 or later, from CRAN
  (`install.packages("sportyR")`).

- team:

  `NULL` (the default) for the plain regulation surface, or one team
  identifier, resolved by
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md).
  Only keys that are also team leagues of
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md)
  take one; the others (`"fiba"`, `"atp"`, `"nll"`, `"epl"`, ...) error.

- season:

  A season for the team's colors and center logo (see
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md));
  `NULL` is the current identity.

- center_logo:

  If `TRUE`, draw the team's logo at center court, center ice or
  midfield. Needs a `team`. A baseball or softball field has no center,
  so the logo goes in shallow center field: at `x = 0`, midway between
  second base (`baseline_distance * sqrt(2)` from home plate) and the
  center-field fence (`center_field_distance`), and
  `0.15 * center_field_distance` across, from the league's 'sportyR'
  field parameters and any `field_updates`. On an MLB field that is 60
  feet across at 263.6 feet from home plate.

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

- Baseball and softball: nothing. No part of a regulation infield is
  team-colored (the green background is the outfield grass), so the team
  is checked and the surface stays 'sportyR”s.

Lacrosse, tennis, volleyball and curling surfaces have no team
identities yet and take no `team`.

Soccer and FIBA surfaces are drawn in meters. "soccer" defaults to a
regulation 105 x 68 m pitch, the frame
[`sdv_pitch_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_pitch_coords.md)
converts to; 'sportyR”s own "fifa" default is FIFA's 120 x 90 m maximum.
Soccer takes a `team` for its center logo (18.3 m, the center circle);
the pitch keeps its regulation colors. FIBA takes no `team` yet.

Surfaces use 'sportyR”s coordinates: the origin at the center, in feet
(yards for football, meters for soccer and FIBA). The center logo is
sized in those units (12 feet on a court, 10 yards on a field, 24 feet
on a rink, 18.3 m on a pitch, 0.15 x the center-field distance on a
baseball or softball field, whose origin is home plate) and follows
`x_trans`, `y_trans`, `rotation` and the unit arguments.

## Examples

``` r
# \donttest{
if (requireNamespace("sportyR", quietly = TRUE)) {
  library(ggplot2)

  # in a team's colors, with its logo at center court, and shots on top
  shots <- data.frame(x = c(-40, -35, 30), y = c(5, -12, 0))
  sdv_surface("nba", "BOS", center_logo = TRUE) +
    geom_point(aes(x, y), data = shots, color = "red", size = 3)
}

# }
```
