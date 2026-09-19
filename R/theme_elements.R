# Theme elements for sdvplotR
# ============================================================================

#' Theme Elements for Image Grobs
#'
#' @description
#' In conjunction with the [ggplot2::theme] system, the following `element_`
#' functions enable images in non-data components of the plot, e.g. axis text.
#'
#'   - `element_sdv_logo()`: draws team logos instead of their abbreviations.
#'   - `element_sdv_wordmark()`: draws team wordmarks instead of their abbreviations.
#'   - `element_sdv_headshot()`: draws player headshots instead of their IDs.
#'   - `element_sdv_raster()`: draws a single image in a rectangular theme
#'     element such as `plot.background`. A thin wrapper around
#'     [ggpath::element_raster()].
#'
#' @details The elements translate team abbreviations or player IDs into
#'   logo images or player headshots for the specified sport. Rendering is
#'   delegated to [ggpath::element_path()].
#'
#' @param sport Character string identifying the sport. One of
#'   [supported_sports()].
#' @param alpha The alpha channel (transparency) between 0 and 1.
#' @param colour,color The image will be colorized with this color. Use `"b/w"`
#'   for black and white.
#' @param hjust Horizontal justification.
#' @param vjust Vertical justification.
#' @param size The output grob size in `cm`.
#' @param image_path A file path or url to an image.
#' @param x,y,width,height,just,interpolate Passed on to
#'   [ggpath::element_raster()].
#' @param ... Other arguments passed on to [ggpath::element_raster()].
#'
#' @return `element_sdv_logo()`, `element_sdv_wordmark()` and
#'   `element_sdv_headshot()` return an S3 object of class `element`;
#'   `element_sdv_raster()` returns a [ggpath::element_raster()].
#'
#' @rdname element_sdv
#' @seealso [ggpath::element_path()], [ggpath::element_raster()]
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- valid_team_names("nfl")[1:16]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' # use logos for x-axis
#' ggplot(df, aes(x = teams, y = random_value)) +
#'   geom_col(aes(color = teams, fill = teams), width = 0.5) +
#'   scale_color_sdv(sport = "nfl", type = "secondary") +
#'   scale_fill_sdv(sport = "nfl", alpha = 0.4) +
#'   theme_minimal() +
#'   theme(axis.text.x = element_sdv_logo(sport = "nfl"))
#' }
element_sdv_logo <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    alpha = NULL,
    colour = NA,
    color = NULL,
    hjust = NULL,
    vjust = NULL,
    size = 0.5
) {
  new_sdv_element("element_sdv_logo", sport, alpha, colour, color, hjust, vjust, size)
}

#' @rdname element_sdv
#' @export
element_sdv_wordmark <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    alpha = NULL,
    colour = NA,
    color = NULL,
    hjust = NULL,
    vjust = NULL,
    size = 0.5
) {
  new_sdv_element("element_sdv_wordmark", sport, alpha, colour, color, hjust, vjust, size)
}

#' @rdname element_sdv
#' @export
element_sdv_headshot <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    alpha = NULL,
    colour = NA,
    color = NULL,
    hjust = NULL,
    vjust = NULL,
    size = 0.5
) {
  new_sdv_element("element_sdv_headshot", sport, alpha, colour, color, hjust, vjust, size)
}

#' @rdname element_sdv
#' @export
element_sdv_raster <- function(
    image_path,
    x = grid::unit(0.5, "npc"),
    y = grid::unit(0.5, "npc"),
    width = grid::unit(1, "npc"),
    height = grid::unit(1, "npc"),
    just = "centre",
    hjust = 0.5,
    vjust = 0.5,
    interpolate = TRUE,
    ...
) {
  ggpath::element_raster(
    image_path = image_path,
    x = x,
    y = y,
    width = width,
    height = height,
    just = just,
    hjust = hjust,
    vjust = vjust,
    interpolate = interpolate,
    ...
  )
}

new_sdv_element <- function(class, sport, alpha, colour, color, hjust, vjust, size) {
  sport <- rlang::arg_match0(sport, supported_sports())
  if (!is.null(color)) colour <- color
  structure(
    list(
      sport = sport,
      alpha = alpha,
      colour = colour,
      hjust = hjust,
      vjust = vjust,
      size = size
    ),
    class = c(class, "element_text", "element")
  )
}

# ggpath::element_path() is an S7 object, so it has to be constructed through
# its constructor rather than by re-classing a plain list.
sdv_element_to_path_grob <- function(element, label, x, y, alpha, colour,
                                     hjust, vjust, size, ...) {
  ep <- ggpath::element_path(
    alpha = alpha %||% element$alpha %||% 1,
    colour = as.character(colour %||% element$colour %||% "transparent"),
    hjust = hjust %||% element$hjust %||% 0.5,
    vjust = vjust %||% element$vjust %||% 0.5,
    size = size %||% element$size %||% 0.5
  )
  ggplot2::element_grob(ep, label = label, x = x, y = y, ...)
}

#' @export
element_grob.element_sdv_logo <- function(element, label = "", x = NULL, y = NULL,
                                          alpha = NULL, colour = NULL,
                                          hjust = NULL, vjust = NULL,
                                          size = NULL, ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- logo_from_team(label, sport = element$sport)
  sdv_element_to_path_grob(element, label, x, y, alpha, colour, hjust, vjust, size, ...)
}

#' @export
element_grob.element_sdv_wordmark <- function(element, label = "", x = NULL, y = NULL,
                                              alpha = NULL, colour = NULL,
                                              hjust = NULL, vjust = NULL,
                                              size = NULL, ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- wordmark_from_team(label, sport = element$sport)
  sdv_element_to_path_grob(element, label, x, y, alpha, colour, hjust, vjust, size, ...)
}

#' @export
element_grob.element_sdv_headshot <- function(element, label = "", x = NULL, y = NULL,
                                              alpha = NULL, colour = NULL,
                                              hjust = NULL, vjust = NULL,
                                              size = NULL, ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- headshot_from_id(label, sport = element$sport)
  label[is.na(label)] <- headshot_placeholder
  sdv_element_to_path_grob(element, label, x, y, alpha, colour, hjust, vjust, size, ...)
}
