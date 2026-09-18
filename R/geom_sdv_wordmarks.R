#' ggplot2 Layer for Visualizing Sports Team Wordmarks
#'
#' @description This geom is used to plot sports team wordmarks instead
#'   of points in a ggplot. It requires x, y aesthetics as well as a valid
#'   team abbreviation. The latter can be checked with [`valid_team_names()`].
#'
#' @inheritParams ggplot2::geom_point
#' @param sport Character string identifying the sport. One of:
#'   `"nfl"`, `"nba"`, `"wnba"`, `"mlb"`, `"nhl"`, `"cfb"`, `"mbb"`, `"wbb"`.
#'
#' @section Aesthetics:
#' `geom_sdv_wordmarks()` understands the following aesthetics (required aesthetics are in bold):
#' \describe{
#'   \item{**x**}{ - The x-coordinate.}
#'   \item{**y**}{ - The y-coordinate.}
#'   \item{**team**}{ - The team abbreviation. Should be one of [valid_team_names()].}
#'   \item{`alpha = NULL`}{ - The alpha channel, i.e. transparency level, as a numerical value between 0 and 1.}
#'   \item{`colour = NULL`}{ - The image will be colorized with this colour. Use `"b/w"` for black and white.}
#'   \item{`angle = 0`}{ - The angle of the image as a numerical value between 0° and 360°.}
#'   \item{`hjust = 0.5`}{ - The horizontal adjustment relative to the given x coordinate.}
#'   \item{`vjust = 0.5`}{ - The vertical adjustment relative to the given y coordinate.}
#'   \item{`width = 1.0`}{ - The desired width of the image in `npc`. A typical size is `width = 0.12`.}
#'   \item{`height = 1.0`}{ - The desired height of the image in `npc`. A typical size is `height = 0.1`.}
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
#' team_abbr <- valid_team_names("nfl")[1:8]
#'
#' df <- data.frame(
#'   a = rep(1:4, 2),
#'   b = sort(rep(1:2, 4), decreasing = TRUE),
#'   teams = team_abbr
#' )
#'
#' ggplot(df, aes(x = a, y = b)) +
#'   geom_sdv_wordmarks(aes(team = teams), sport = "nfl", width = 0.12) +
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
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    na.rm = FALSE,
    show.legend = FALSE,
    inherit.aes = TRUE
) {
  sport <- rlang::arg_match0(sport, supported_sports())

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
      sport = sport,
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
    vjust = 0.5, width = 1.0, height = 1.0
  ),
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, sport = "nfl") {
    # Resolve team abbreviations to wordmark URLs
    data$path <- wordmark_from_team(data$team, sport = sport)

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
