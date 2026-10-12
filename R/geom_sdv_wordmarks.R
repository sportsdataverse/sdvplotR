#' ggplot2 Layer for Visualizing Sports Team Wordmarks
#'
#' @description This geom is used to plot sports team wordmarks instead
#'   of points in a ggplot. It requires x, y aesthetics as well as a valid
#'   team identifier: anything [sdv_resolve()] accepts. A league's teams are
#'   listed by [sdv_teams()].
#'
#' @inheritParams ggplot2::geom_point
#' @inheritParams sdv_logo_url
#' @param league A league key from [sdv_leagues()]. A team the logo archive
#'   has no wordmark for is not drawn (its path is `NA`, with a warning).
#'
#' @section Aesthetics:
#' `geom_sdv_wordmarks()` understands the following aesthetics (required aesthetics are in bold):
#' \describe{
#'   \item{**x**}{ - The x-coordinate.}
#'   \item{**y**}{ - The y-coordinate.}
#'   \item{**team**}{ - The team: an abbreviation, name or id, resolved by [sdv_resolve()].}
#'   \item{`alpha = NULL`}{ - The alpha channel, i.e. transparency level, as a numerical value between 0 and 1.}
#'   \item{`colour = NULL`}{ - The image will be colorized with this colour. Use `"b/w"` for black and white.}
#'   \item{`angle = 0`}{ - The angle of the image as a numerical value between 0 and 360 degrees.}
#'   \item{`hjust = 0.5`}{ - The horizontal adjustment relative to the given x coordinate.}
#'   \item{`vjust = 0.5`}{ - The vertical adjustment relative to the given y coordinate.}
#'   \item{`width = 1.0`}{ - The desired width of the image in `npc`. A typical size is `width = 0.12`.}
#'   \item{`height = 1.0`}{ - The desired height of the image in `npc`. A typical size is `height = 0.1`.}
#'   \item{`season = NA`}{ - The season whose wordmark to draw, as for [geom_sdv_logos()].}
#' }
#'
#' @return A ggplot2 layer ([ggplot2::layer()]) that can be added to a plot
#'   created with [ggplot2::ggplot()].
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- sdv_teams("nfl")$abbr[1:8]
#'
#' df <- data.frame(
#'   a = rep(1:4, 2),
#'   b = sort(rep(1:2, 4), decreasing = TRUE),
#'   teams = team_abbr
#' )
#'
#' ggplot(df, aes(x = a, y = b)) +
#'   geom_sdv_wordmarks(aes(team = teams), league = "nfl", width = 0.12) +
#'   geom_label(aes(label = teams), nudge_y = -0.20, alpha = 0.5) +
#'   scale_x_continuous(expand = expansion(add = 0.5)) +
#'   theme_void()
#' }
geom_sdv_wordmarks <- function(
    mapping = NULL,
    data = NULL,
    stat = "identity",
    position = "identity",
    ...,
    league,
    id_system = "auto",
    strict = FALSE,
    na.rm = FALSE,
    show.legend = FALSE,
    inherit.aes = TRUE
) {
  league <- check_league(league)

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomSDVwordmark,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      league = league,
      id_system = id_system,
      strict = strict,
      ...
    )
  )
}

#' @rdname geom_sdv_wordmarks
#' @export
GeomSDVwordmark <- ggplot2::ggproto(
  "GeomSDVwordmark", ggplot2::Geom,
  required_aes = c("x", "y", "team"),
  default_aes = ggplot2::aes(
    alpha = NULL, colour = NULL, angle = 0, hjust = 0.5,
    vjust = 0.5, width = 1.0, height = 1.0, season = NA
  ),
  # resolved once for the whole layer, not per facet panel in draw_panel, so a
  # value that does not resolve warns once
  setup_data = function(data, params) {
    data$path <- wordmark_from_team(data$team, params$league %||% "nfl",
      season = rep_len(data$season %||% params$season %||% NA, nrow(data)),
      id_system = params$id_system %||% "auto", strict = isTRUE(params$strict)
    )
    data
  },
  # league, id_system and strict stay in the signature: ggplot2 reads a geom's parameters from it
  # max_px: set by the interactive geoms (draw_image_panel())
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, league = "nfl", id_system = "auto", strict = FALSE,
                        max_px = NULL) {
    draw_image_panel(data, panel_params, coord, na.rm, max_px)
  },
  draw_key = function(...) grid::nullGrob()
)
