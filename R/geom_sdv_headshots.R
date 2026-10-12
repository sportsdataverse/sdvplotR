#' ggplot2 Layer for Visualizing Player Headshots
#'
#' @description This geom is used to plot player headshots instead
#'   of points in a ggplot. It requires x, y aesthetics as well as a valid
#'   player identifier: an ESPN athlete ID by default, in every league. Set
#'   `id_system` to plot IDs from another source (nflverse's gsis IDs, or the
#'   league's own player IDs). A team's ESPN athlete IDs come
#'   with its roster: `hoopR::espn_mbb_team_roster()` and
#'   `espn_nba_team_roster()`, `wehoop::espn_wbb_team_roster()` and
#'   `espn_wnba_team_roster()`, and `cfbfastR::espn_cfb_team_roster()` each
#'   return an `athlete_id` column.
#'
#' @inheritParams ggplot2::geom_point
#' @inheritParams sdv_headshot_url
#' @details ESPN and league IDs are plain digits, so a mismatch draws the
#'   wrong player or no image rather than an error. League CDNs draw a
#'   silhouette for an unknown ID, and the NBA and WNBA CDNs refuse requests
#'   from datacenter IPs, so a plot drawn on CI or a server can come back
#'   without those headshots.
#'
#' @section Aesthetics:
#' `geom_sdv_headshots()` understands the following aesthetics (required aesthetics are in bold):
#' \describe{
#'   \item{**x**}{ - The x-coordinate.}
#'   \item{**y**}{ - The y-coordinate.}
#'   \item{**player_id**}{ - The player's ID: ESPN athlete ID, or as `id_system` says.}
#'   \item{`alpha = NULL`}{ - The alpha channel.}
#'   \item{`colour = NULL`}{ - The image will be colorized with this colour. Use `"b/w"` for black and white.}
#'   \item{`angle = 0`}{ - The angle of the image.}
#'   \item{`hjust = 0.5`}{ - The horizontal adjustment.}
#'   \item{`vjust = 0.5`}{ - The vertical adjustment.}
#'   \item{`width = 1.0`}{ - The desired width in `npc`.}
#'   \item{`height = 1.0`}{ - The desired height in `npc`.}
#' }
#'
#' @return A ggplot2 layer.
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' df <- data.frame(
#'   a = 1:3,
#'   b = 3:1,
#'   player_id = c("00-0033873", "00-0026498", "00-0035228"),
#'   player_name = c("P.Mahomes", "M.Stafford", "K.Murray")
#' )
#'
#' ggplot(df, aes(x = a, y = b)) +
#'   geom_sdv_headshots(aes(player_id = player_id), league = "nfl", id_system = "gsis", height = 0.2) +
#'   geom_label(aes(label = player_name), nudge_y = -0.35, alpha = 0.5) +
#'   coord_cartesian(xlim = c(0.5, 3.5), ylim = c(0.5, 3.5)) +
#'   theme_void()
#' }
geom_sdv_headshots <- function(
    mapping = NULL,
    data = NULL,
    stat = "identity",
    position = "identity",
    ...,
    league,
    id_system = "espn",
    na.rm = FALSE,
    show.legend = FALSE,
    inherit.aes = TRUE
) {
  league <- check_league(league)
  id_system <- check_id_system(id_system, league)

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomSDVheadshot,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      league = league,
      id_system = id_system,
      ...
    )
  )
}

#' @rdname geom_sdv_headshots
#' @export
GeomSDVheadshot <- ggplot2::ggproto(
  "GeomSDVheadshot", ggplot2::Geom,
  required_aes = c("x", "y", "player_id"),
  default_aes = ggplot2::aes(
    alpha = NULL, colour = NULL, angle = 0, hjust = 0.5,
    vjust = 0.5, width = 1.0, height = 1.0
  ),
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, league = "nfl", id_system = "espn") {
    # Resolve player IDs to headshot URLs
    data$path <- headshot_from_id(data$player_id, league, id_system)

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
