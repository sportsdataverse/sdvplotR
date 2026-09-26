#' ggplot2 Layer for Visualizing Player Headshots
#'
#' @description This geom is used to plot player headshots instead
#'   of points in a ggplot. It requires x, y aesthetics as well as a valid
#'   player identifier: a GSIS ID for the NFL (`"00-0033873"`, resolved through
#'   the headshot map sdvplotR publishes from nflverse rosters to the player's
#'   NFL.com headshot) and an ESPN athlete ID for every other sport. Set
#'   `id_type` to plot IDs from another source.
#'
#' @inheritParams ggplot2::geom_point
#' @param sport Character string identifying the sport.
#' @param id_type Which ID system `player_id` holds. `NULL` (the default) takes
#'   GSIS IDs for the NFL and ESPN athlete IDs for every other sport. `"espn"`
#'   takes ESPN athlete IDs for any sport, the IDs in ESPN-sourced data such as
#'   hoopR's and wehoop's `espn_*()` functions. `"league"` takes the league's
#'   own ID: the GSIS ID for the NFL, the NBA Stats or WNBA Stats `PERSON_ID`
#'   (hoopR's `nba_*()`, wehoop's `wnba_*()`), the MLBAM ID (baseballr's
#'   `mlb_*()`, Baseball Savant) for MLB, or the NHL API player ID
#'   (fastRhockey's `nhl_*()` and `load_nhl_*()`) for the NHL, drawn from
#'   that league's image CDN; college sports have no league option. Both are
#'   plain digits, so a mismatch draws the wrong player or no image rather
#'   than an error. League CDNs draw
#'   a silhouette for an unknown ID, and the NBA and WNBA CDNs refuse requests
#'   from datacenter IPs, so a plot drawn on CI or a server can come back
#'   without those headshots.
#'
#' @section Aesthetics:
#' `geom_sdv_headshots()` understands the following aesthetics (required aesthetics are in bold):
#' \describe{
#'   \item{**x**}{ - The x-coordinate.}
#'   \item{**y**}{ - The y-coordinate.}
#'   \item{**player_id**}{ - The player's ID: GSIS ID for the NFL, ESPN athlete ID otherwise, or as `id_type` says.}
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
#'   geom_sdv_headshots(aes(player_id = player_id), sport = "nfl", height = 0.2) +
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
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    id_type = NULL,
    na.rm = FALSE,
    show.legend = FALSE,
    inherit.aes = TRUE
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  id_type <- check_id_type(id_type, sport)

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
      sport = sport,
      id_type = id_type,
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
  draw_panel = function(data, panel_params, coord, na.rm = FALSE, sport = "nfl", id_type = NULL) {
    # Resolve player IDs to headshot URLs
    data$path <- headshot_from_id(data$player_id, sport = sport, id_type = id_type)

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
