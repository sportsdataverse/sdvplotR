#' ggplot2 Layer for Visualizing Sports Team Logos
#'
#' @description This geom is used to plot sports team logos instead
#'   of points in a ggplot. It requires x, y aesthetics as well as a valid
#'   team identifier: anything [sdv_resolve()] accepts, or a conference or
#'   league key. A league's teams are listed by [sdv_teams()].
#'
#' @inheritParams ggplot2::geom_point
#' @inheritParams sdv_resolve
#'
#' @section Aesthetics:
#' `geom_sdv_logos()` understands the following aesthetics (required aesthetics are in bold):
#' \describe{
#'   \item{**x**}{ - The x-coordinate.}
#'   \item{**y**}{ - The y-coordinate.}
#'   \item{**team**}{ - The team: an abbreviation, name or id, resolved by [sdv_resolve()].}
#'   \item{`alpha = NULL`}{ - The alpha channel, i.e. transparency level, as a numerical value between 0 and 1.}
#'   \item{`colour = NULL`}{ - The image will be colorized with this colour. Use the special
#'   character `"b/w"` to set it to black and white.}
#'   \item{`angle = 0`}{ - The angle of the image as a numerical value between 0 and 360 degrees.}
#'   \item{`hjust = 0.5`}{ - The horizontal adjustment relative to the given x coordinate.}
#'   \item{`vjust = 0.5`}{ - The vertical adjustment relative to the given y coordinate.}
#'   \item{`width = 1.0`}{ - The desired width of the image in `npc` (Normalised Parent
#'   Coordinates). A typical size is `width = 0.075`.}
#'   \item{`height = 1.0`}{ - The desired height of the image in `npc`. A typical size is `height = 0.1`.}
#'   \item{`season = NA`}{ - The season whose logo to draw: the ending year for
#'   the NHL (`1990` for 1989-90), the year elsewhere. `NA` draws the
#'   team's logo today. See the Historical logos section.}
#' }
#'
#' @section Historical logos:
#' Given a `season`, a team is drawn with the mark it wore that season where
#' the SportsDataverse logo archive dates its marks, and with its current
#' mark otherwise. The season also picks the team a reused code meant then
#' (see [sdv_resolve()]). The images are copies kept in the archive, so they
#' don't change when a league reuses a file name. SVG marks are read with the
#' 'rsvg' package. `season` takes single years: the ending year for split
#' seasons (`2005` for 2004-05).
#'
#' @return A ggplot2 layer ([ggplot2::layer()]) that can be added to a plot
#'   created with [ggplot2::ggplot()].
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- sdv_teams("nfl")$abbr[1:16]
#'
#' df <- data.frame(
#'   a = rep(1:4, 4),
#'   b = sort(rep(1:4, 4), decreasing = TRUE),
#'   teams = team_abbr
#' )
#'
#' ggplot(df, aes(x = a, y = b)) +
#'   geom_sdv_logos(aes(team = teams), league = "nfl", width = 0.075) +
#'   geom_label(aes(label = teams), nudge_y = -0.35, alpha = 0.5) +
#'   theme_void()
#'
#' # the logo each team wore that season (NHL seasons are ending years;
#' # the NHL's marks are SVG files, read with the 'rsvg' package)
#' if (requireNamespace("rsvg", quietly = TRUE)) {
#'   old <- data.frame(
#'     x = 1:4, y = 1,
#'     team = c("QUE", "HFD", "ATL", "WPG"),
#'     season = c(1990, 1995, 2005, 2015)
#'   )
#'   ggplot(old, aes(x = x, y = y)) +
#'     geom_sdv_logos(aes(team = team, season = season), league = "nhl", width = 0.2) +
#'     theme_void()
#' }
#' }
geom_sdv_logos <- function(
    mapping = NULL,
    data = NULL,
    stat = "identity",
    position = "identity",
    ...,
    league,
    na.rm = FALSE,
    show.legend = FALSE,
    inherit.aes = TRUE
) {
  league <- check_league(league)

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomSDVlogo,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      league = league,
      ...
    )
  )
}

#' @rdname geom_sdv_logos
#' @export
GeomSDVlogo <- ggplot2::ggproto(
  "GeomSDVlogo", ggplot2::Geom,
  required_aes = c("x", "y", "team"),
  default_aes = ggplot2::aes(
    alpha = NULL, colour = NULL, angle = 0, hjust = 0.5,
    vjust = 0.5, width = 1.0, height = 1.0, season = NA
  ),
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, league = "nfl") {
    # Resolve team abbreviations (and seasons) to logo URLs
    data$path <- logo_from_team(data$team, league, season = data$season)

    # Delegate to ggpath for actual rendering
    ggpath::GeomFromPath$draw_panel(
      data = data,
      panel_params = panel_params,
      coord = coord,
      na.rm = na.rm
    )
  },
  draw_key = function(...) grid::nullGrob()
)
