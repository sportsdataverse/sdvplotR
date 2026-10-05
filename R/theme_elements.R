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
#'   delegated to [ggpath::element_path()], which they extend. Set on a parent
#'   element such as `axis.text.x`, they also replace the position children
#'   (`axis.text.x.bottom`, `axis.text.y.left`, ...) that complete themes like
#'   [ggplot2::theme_minimal()] set, keeping the child's spacing.
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
#'   `element_sdv_headshot()` return a theme element extending
#'   [ggpath::element_path()]; `element_sdv_raster()` returns a
#'   [ggpath::element_raster()].
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
  new_sdv_element(sdv_logo_element, sport, alpha, colour, color, hjust, vjust, size)
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
  new_sdv_element(sdv_wordmark_element, sport, alpha, colour, color, hjust, vjust, size)
}

#' @param id_type Which ID system the player IDs hold: `NULL` (the default;
#'   GSIS IDs for the NFL, ESPN athlete IDs otherwise), `"espn"` or `"league"`
#'   (NBA / WNBA Stats `PERSON_ID`, MLBAM, NHL API, GSIS). See [geom_sdv_headshots()].
#' @rdname element_sdv
#' @export
element_sdv_headshot <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    alpha = NULL,
    colour = NA,
    color = NULL,
    hjust = NULL,
    vjust = NULL,
    size = 0.5,
    id_type = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  new_sdv_element(
    sdv_headshot_element, sport, alpha, colour, color, hjust, vjust, size,
    id_type = check_id_type(id_type, sport)
  )
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

# The elements are S7 subclasses of ggpath::element_path, carrying ggplot2's
# own S3 classes ("element_text", "element") as ggplot2's elements do. In
# ggplot2 4 a child element (theme_minimal()'s axis.text.x.bottom) only lets
# its parent (axis.text.x) win when the parent is such a subclass of it;
# otherwise the child stays a plain element_text, inherits colour = NA and
# size = 0.5, and the axis draws nothing. ggpath::element_path and S3 lists
# both fail that test.
sdv_logo_element <- S7::new_class(
  "element_sdv_logo",
  parent = ggpath::element_path,
  properties = list(sport = S7::class_character),
  package = NULL
)
sdv_wordmark_element <- S7::new_class(
  "element_sdv_wordmark",
  parent = ggpath::element_path,
  properties = list(sport = S7::class_character),
  package = NULL
)
sdv_headshot_element <- S7::new_class(
  "element_sdv_headshot",
  parent = ggpath::element_path,
  properties = list(
    sport = S7::class_character,
    id_type = S7::new_union(NULL, S7::class_character)
  ),
  package = NULL
)

new_sdv_element <- function(cls, sport, alpha, colour, color, hjust, vjust, size, ...) {
  sport <- rlang::arg_match0(sport, supported_sports())
  element <- cls(
    sport = sport,
    alpha = alpha %||% 1,
    colour = as.character(color %||% colour),
    hjust = hjust %||% 0.5,
    vjust = vjust %||% 0.5,
    size = size,
    ...
  )
  class(element) <- union(class(element), c("element_text", "element"))
  element
}

#' @export
element_grob.element_sdv_logo <- function(element, label = "", ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- logo_from_team(label, sport = element@sport)
  NextMethod()
}

#' @export
element_grob.element_sdv_wordmark <- function(element, label = "", ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- wordmark_from_team(label, sport = element@sport)
  NextMethod()
}

#' @export
element_grob.element_sdv_headshot <- function(element, label = "", ...) {
  if (is.null(label)) return(ggplot2::zeroGrob())
  label <- headshot_from_id(label, sport = element@sport, id_type = element@id_type)
  label[is.na(label)] <- headshot_placeholder
  NextMethod()
}
