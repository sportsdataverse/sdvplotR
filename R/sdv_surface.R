# nolint start: line_length_linter. table rows and Rd figure macros cannot wrap
#' Team-Styled Playing Surfaces
#'
#' @description Draws a regulation court, field or rink with 'sportyR' and,
#'   given a team, paints a few of its features in that team's colors from
#'   [sdv_team_colors()]. The result is a ggplot, so data layers go on top.
#'
#'   These are **stylized** surfaces built from team colors, not the team's
#'   real court, field or rink design: no dataset of real team surface designs
#'   (paint colors, center logos, end zone art, special-event floors) exists
#'   yet.
#'
#' @param league One of the 59 SportsDataverse surface keys, the same table
#'   sdvplot-js uses. Each maps to a 'sportyR' surface:
#'
#'   | league | surface |
#'   |---|---|
#'   | `"nfl"`, `"aaf"`, `"ufl"`, `"usfl"`, `"xfl"` | `sportyR::geom_football("nfl")` |
#'   | `"cfb"` | `sportyR::geom_football("ncaa")` |
#'   | `"cfl"` | `sportyR::geom_football("cfl")` |
#'   | `"nfhs_football"` | `sportyR::geom_football("nfhs11")` |
#'   | `"nba"` | `sportyR::geom_basketball("nba")` |
#'   | `"nbagl"` | `sportyR::geom_basketball("nba g league")` |
#'   | `"wnba"` | `sportyR::geom_basketball("wnba")` |
#'   | `"mbb"`, `"wbb"` | `sportyR::geom_basketball("ncaa")` |
#'   | `"fiba"` | `sportyR::geom_basketball("fiba")` (28 x 15 m) |
#'   | `"nfhs_basketball"` | `sportyR::geom_basketball("nfhs")` |
#'   | `"mlb"`, `"milb"`, `"pony"` | `sportyR::geom_baseball()` of the same league |
#'   | `"ncaa_baseball"` | `sportyR::geom_baseball("ncaa")` |
#'   | `"little_league"` | `sportyR::geom_baseball("little league")` |
#'   | `"nfhs_baseball"` | `sportyR::geom_baseball("nfhs")` |
#'   | `"ncaa_softball"` | `sportyR::geom_softball("ncaa")` |
#'   | `"nhl"`, `"whl"` | `sportyR::geom_hockey("nhl")` (no WHL rink in 'sportyR') |
#'   | `"pwhl"`, `"ahl"`, `"echl"`, `"ohl"`, `"qmjhl"`, `"ushl"`, `"phf"`, `"iihf"`, `"nwhl"` | `sportyR::geom_hockey()` of the same league |
#'   | `"ncaa_mhockey"`, `"ncaa_whockey"` | `sportyR::geom_hockey("ncaa")` |
#'   | `"soccer"` | `sportyR::geom_soccer("fifa")`, 105 x 68 m (`pitch_updates` overrides) |
#'   | `"fifa"`, `"epl"`, `"mls"`, `"nwsl"` | `sportyR::geom_soccer()` of the same league ('sportyR''s own pitch size) |
#'   | `"ncaa_soccer"` | `sportyR::geom_soccer("ncaa")` |
#'   | `"nll"`, `"pll"` | `sportyR::geom_lacrosse()` of the same league |
#'   | `"world_lacrosse"` | `sportyR::geom_lacrosse("world lacrosse")` |
#'   | `"ncaa_mlacrosse"`, `"ncaa_wlacrosse"` | `sportyR::geom_lacrosse("ncaam")`, `("ncaaw")` |
#'   | `"usa_mlacrosse"`, `"usa_wlacrosse"` | `sportyR::geom_lacrosse("usam")`, `("usaw")` |
#'   | `"atp"`, `"wta"`, `"itf"`, `"ita"`, `"usta"` | `sportyR::geom_tennis()` of the same league |
#'   | `"ncaa_tennis"` | `sportyR::geom_tennis("ncaa")` |
#'   | `"fivb"` | `sportyR::geom_volleyball("fivb")` |
#'   | `"usa_volleyball"` | `sportyR::geom_volleyball("usa volleyball")` |
#'   | `"ncaa_volleyball"` | `sportyR::geom_volleyball("ncaa")` |
#'   | `"wcf"` | `sportyR::geom_curling("wcf")` |
#'   | `"curling_canada"` | `sportyR::geom_curling("curling canada")` |
#'
#'   The PWHL and the G League draw their own rink and court, as in
#'   sdvplot-js. Surfaces need 'sportyR' 2.4.5 or later, from CRAN
#'   (`install.packages("sportyR")`).
#' @param team `NULL` (the default) for the plain regulation surface, or one
#'   team identifier, resolved by [sdv_resolve()]. Only keys that are also
#'   team leagues of [sdv_leagues()] take one; the others (`"fiba"`, `"atp"`,
#'   `"nll"`, `"epl"`, ...) error.
#' @param season A season for the team's colors and center logo (see
#'   [sdv_team_colors()]); `NULL` is the current identity.
#' @param center_logo If `TRUE`, draw the team's logo at center court, center
#'   ice or midfield. Needs a `team`. A baseball or softball field has no
#'   center, so the logo goes in shallow center field: at `x = 0`, midway
#'   between second base (`baseline_distance * sqrt(2)` from home plate) and
#'   the center-field fence (`center_field_distance`), and `0.15 *
#'   center_field_distance` across, from the league's 'sportyR' field
#'   parameters and any `field_updates`. On an MLB field that is 60 feet across
#'   at 263.6 feet from home plate.
#' @param ... Passed to the 'sportyR' geom: `display_range`, `rotation`,
#'   `x_trans`, `y_trans`, `xlims`, `ylims`, the unit arguments, and
#'   `color_updates`, which overrides the team colors feature by feature (see
#'   `sportyR::cani_color_league_features()` for the names).
#'
#' @details With a `team`, these features change; everything else keeps
#'   'sportyR''s regulation colors, so the court stays wood, the field green
#'   and the ice white:
#'
#'   * Basketball: the painted area and the court apron take the primary color.
#'     The lines drawn inside the paint (restricted arc, free-throw circle
#'     dashes, lower defensive boxes) turn black or white, whichever contrasts
#'     more with it.
#'   * Football: both end zones take the primary color.
#'   * Hockey: the center line, center faceoff circle and center faceoff spot
#'     take the primary color, or the secondary where the primary is too pale
#'     to read on white ice (under 3:1 contrast); the boards take the primary.
#'   * Baseball and softball: nothing. No part of a regulation infield is
#'     team-colored (the green background is the outfield grass), so the team
#'     is checked and the surface stays 'sportyR''s.
#'
#'   Lacrosse, tennis, volleyball and curling surfaces have no team identities
#'   yet and take no `team`.
#'
#'   Soccer and FIBA surfaces are drawn in meters. "soccer" defaults to a
#'   regulation 105 x 68 m pitch, the frame [sdv_pitch_coords()] converts to;
#'   'sportyR''s own "fifa" default is FIFA's 120 x 90 m maximum. Soccer takes a
#'   `team` for its center logo (18.3 m, the center circle); the pitch keeps its
#'   regulation colors. FIBA takes no `team` yet.
#'
#'   Surfaces use 'sportyR''s coordinates: the origin at the center, in feet
#'   (yards for football, meters for soccer and FIBA). The center logo is sized
#'   in those units (12 feet on a court, 10 yards on a field, 24 feet on a
#'   rink, 18.3 m on a pitch, 0.15 x the center-field distance on a baseball or
#'   softball field, whose origin is home plate) and follows
#'   `x_trans`, `y_trans`, `rotation` and the unit arguments.
#'
#' @return A ggplot object ([ggplot2::ggplot()]) with `coord_fixed()`; add
#'   layers with `+`.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("sportyR", quietly = TRUE)) {
#'   library(ggplot2)
#'
#'   # in a team's colors, with its logo at center court, and shots on top
#'   shots <- data.frame(x = c(-40, -35, 30), y = c(5, -12, 0))
#'   sdv_surface("nba", "BOS", center_logo = TRUE) +
#'     geom_point(aes(x, y), data = shots, color = "red", size = 3)
#' }
#' }
# nolint end
sdv_surface <- function(
  league,
  team = NULL,
  season = NULL,
  center_logo = FALSE,
  ...
) {
  if (!rlang::is_string(league) || !league %in% names(surface_map)) {
    cli::cli_abort(c(
      "No playing surface for {.val {league}}.",
      i = "Surfaces exist for {.val {names(surface_map)}}."
    ))
  }
  rlang::check_installed("sportyR", version = "2.4.5", reason = "to draw playing surfaces.")

  geom <- surface_map[[league]][[1]]
  sporty_league <- surface_map[[league]][[2]]
  args <- list(...)
  if (league == "soccer") {
    # sportyR's "fifa" pitch is FIFA's 120 x 90 m maximum; real pitches (and sdv_pitch_coords()) are 105 x 68
    args$pitch_updates <- utils::modifyList(list(pitch_length = 105, pitch_width = 68), as.list(args$pitch_updates))
  }
  if (!is.null(team) && !league %in% sdv_leagues()) {
    cli::cli_abort("No team identities for {.val {league}} yet: draw the plain surface with {.code team = NULL}.")
  }

  if (!is.null(team)) {
    if (!is.character(team) || length(team) != 1L || is.na(team)) {
      cli::cli_abort("{.arg team} must be one team name or abbreviation.")
    }
    primary <- unname(quiet_miss(sdv_team_colors(league, team, which = "primary", season = season)))
    if (is.na(primary)) {
      cli::cli_abort(c(
        "{.val {team}} is not a {.val {league}} team.",
        i = "See {.code sdv_teams(\"{league}\")}."
      ))
    }
    secondary <- unname(sdv_team_colors(league, team, which = "secondary", season = season))
    args$color_updates <- utils::modifyList(
      surface_color_updates(geom, primary, secondary),
      as.list(args$color_updates)
    )
  }

  p <- do.call(getExportedValue("sportyR", geom), c(list(sporty_league), args))

  if (isTRUE(center_logo)) {
    if (is.null(team)) cli::cli_abort("{.arg center_logo} needs a {.arg team}.")
    p <- p + surface_logo_layer(geom, sporty_league, team, league, season, args)
  }
  p
}

# sportyR 2.4.5's regulation playing-area colors, which team colors are
# checked against: court wood, field grass, ice.
surface_base <- c(
  geom_basketball = "#d2ab6f",
  geom_football = "#196f0c",
  geom_hockey = "#ffffff",
  geom_soccer = "#195f0c",
  geom_baseball = "#395d33",
  geom_softball = "#395d33"
)

# A diamond's logo goes in shallow center field, this fraction of the
# center-field distance across (sdvplot, the Python package, is adopting the
# same placement).
field_logo_fraction <- 0.15

# color_updates for a team. Fills keep the primary, the team's identity;
# lines are what has to stay legible, so they are chosen by contrast.
surface_color_updates <- function(geom, primary, secondary) {
  switch(geom,
    geom_basketball = {
      ink <- .theme_on_color(primary)
      list(
        painted_area = primary,
        court_apron = primary,
        restricted_arc = ink,
        free_throw_circle_dash = ink,
        lane_lower_defensive_box = ink,
        baseline_lower_defensive_box = ink
      )
    },
    geom_football = list(offensive_endzone = primary, defensive_endzone = primary),
    geom_hockey = {
      ice <- surface_base[["geom_hockey"]]
      readable <- !is.na(secondary) &&
        .theme_contrast(primary, ice) < 3 &&
        .theme_contrast(secondary, ice) >= 3
      accent <- if (readable) secondary else primary
      list(
        center_line = accent,
        center_faceoff_circle = accent,
        center_faceoff_spot = accent,
        boards = primary
      )
    },
    # sportyR's baseball background is the outfield grass; the infield's dirt,
    # grass, bases and chalk have no team color to take
    geom_baseball = list(),
    geom_softball = list(),
    # the pitch keeps its regulation colors; the club is the center logo
    geom_soccer = list()
  )
}

# The team logo at the surface's center, `size` surface units across, or on a
# diamond (origin at home plate) in shallow center field. ESPN's
# dark-background variant goes on dark grass.
surface_logo_layer <- function(geom, sporty_league, team, league, season, args) {
  offset <- 0
  from <- c(
    geom_basketball = "ft", geom_football = "yd", geom_hockey = "ft", geom_soccer = "m",
    geom_baseball = "ft", geom_softball = "ft"
  )[[geom]]
  if (geom %in% c("geom_baseball", "geom_softball")) {
    dims <- utils::modifyList(
      sportyR::get_surface_dimensions(sub("geom_", "", geom), sporty_league),
      as.list(args$field_updates)
    )
    offset <- (dims$baseline_distance * sqrt(2) + dims$center_field_distance) / 2
    size <- field_logo_fraction * dims$center_field_distance
    # the field's own unit, which field_updates may change
    from <- dims$field_units %||% "ft"
  } else {
    size <- c(geom_basketball = 12, geom_football = 10, geom_hockey = 24, geom_soccer = 18.3)[[geom]]
  }
  unit_arg <- c(
    geom_basketball = "court_units", geom_football = "field_units", geom_hockey = "rink_units",
    geom_soccer = "pitch_units", geom_baseball = "field_units", geom_softball = "field_units"
  )[[geom]]
  if (!is.null(args[[unit_arg]])) {
    size <- sportyR::convert_units(size, from, args[[unit_arg]])
    offset <- sportyR::convert_units(offset, from, args[[unit_arg]])
  }

  # sportyR translates, then rotates about the origin
  center <- sportyR::rotate_coords(
    data.frame(x = args$x_trans %||% 0, y = offset + (args$y_trans %||% 0)),
    angle = args$rotation %||% 0
  )
  variant <- if (.theme_on_color(surface_base[[geom]]) == "#FFFFFF") "dark" else "default"
  center$path <- logo_from_team(team, league, season = season, variant = variant)

  ggplot2::layer(
    data = center,
    mapping = ggplot2::aes(x = .data$x, y = .data$y, path = .data$path),
    stat = "identity",
    geom = GeomSDVsurfaceLogo,
    position = "identity",
    show.legend = FALSE,
    inherit.aes = FALSE,
    params = list(logo_size = size)
  )
}

# ggpath sizes an image in npc of the panel; convert from surface units at
# draw time, so zooms, display ranges and rotations keep the logo's size.
GeomSDVsurfaceLogo <- ggplot2::ggproto(
  "GeomSDVsurfaceLogo", ggpath::GeomFromPath,
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, logo_size = 1) {
    data$width <- logo_size / diff(panel_params$x.range)
    data$height <- logo_size / diff(panel_params$y.range)
    ggpath::GeomFromPath$draw_panel(data, panel_params, coord, na.rm = na.rm)
  }
)

# league -> sportyR geom and its league: the SDV surface-key table, the same as
# sdvplot-js's src/surfaces.ts (sdvplot's SURFACES, Python, is being brought in
# line with it)
surface_map <- list(
  nfl = c("geom_football", "nfl"), aaf = c("geom_football", "nfl"), ufl = c("geom_football", "nfl"),
  usfl = c("geom_football", "nfl"), xfl = c("geom_football", "nfl"), cfb = c("geom_football", "ncaa"),
  cfl = c("geom_football", "cfl"), nfhs_football = c("geom_football", "nfhs11"),
  nba = c("geom_basketball", "nba"), nbagl = c("geom_basketball", "nba g league"),
  wnba = c("geom_basketball", "wnba"),
  mbb = c("geom_basketball", "ncaa"), wbb = c("geom_basketball", "ncaa"), fiba = c("geom_basketball", "fiba"),
  nfhs_basketball = c("geom_basketball", "nfhs"),
  mlb = c("geom_baseball", "mlb"), milb = c("geom_baseball", "milb"), ncaa_baseball = c("geom_baseball", "ncaa"),
  little_league = c("geom_baseball", "little league"), pony = c("geom_baseball", "pony"),
  nfhs_baseball = c("geom_baseball", "nfhs"),
  ncaa_softball = c("geom_softball", "ncaa"),
  nhl = c("geom_hockey", "nhl"), whl = c("geom_hockey", "nhl"), pwhl = c("geom_hockey", "pwhl"),
  ahl = c("geom_hockey", "ahl"), echl = c("geom_hockey", "echl"), ohl = c("geom_hockey", "ohl"),
  qmjhl = c("geom_hockey", "qmjhl"), ushl = c("geom_hockey", "ushl"), phf = c("geom_hockey", "phf"),
  iihf = c("geom_hockey", "iihf"), nwhl = c("geom_hockey", "nwhl"),
  ncaa_mhockey = c("geom_hockey", "ncaa"), ncaa_whockey = c("geom_hockey", "ncaa"),
  soccer = c("geom_soccer", "fifa"), fifa = c("geom_soccer", "fifa"), epl = c("geom_soccer", "epl"),
  mls = c("geom_soccer", "mls"), nwsl = c("geom_soccer", "nwsl"), ncaa_soccer = c("geom_soccer", "ncaa"),
  nll = c("geom_lacrosse", "nll"), pll = c("geom_lacrosse", "pll"),
  world_lacrosse = c("geom_lacrosse", "world lacrosse"), ncaa_mlacrosse = c("geom_lacrosse", "ncaam"),
  ncaa_wlacrosse = c("geom_lacrosse", "ncaaw"), usa_mlacrosse = c("geom_lacrosse", "usam"),
  usa_wlacrosse = c("geom_lacrosse", "usaw"),
  atp = c("geom_tennis", "atp"), wta = c("geom_tennis", "wta"), itf = c("geom_tennis", "itf"),
  ita = c("geom_tennis", "ita"), usta = c("geom_tennis", "usta"), ncaa_tennis = c("geom_tennis", "ncaa"),
  fivb = c("geom_volleyball", "fivb"), usa_volleyball = c("geom_volleyball", "usa volleyball"),
  ncaa_volleyball = c("geom_volleyball", "ncaa"),
  wcf = c("geom_curling", "wcf"), curling_canada = c("geom_curling", "curling canada")
)
