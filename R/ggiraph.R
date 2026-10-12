# ggiraph: the image layer draws, an invisible interactive point on top takes
# the hover, click and selection.
# ponytail: an overlay, not an interactive image grob; ggiraph's grob internals
# change between versions. Upgrade if hover needs the image's exact outline.

interactive_aes <- c("tooltip", "data_id", "onclick", "hover_css", "selected_css")

# `mapping` without `drop`, rebuilt with aes() (works on ggplot2 4's S7 mapping)
strip_aes <- function(mapping, drop) {
  if (is.null(mapping)) {
    return(NULL)
  }
  keep <- setdiff(names(mapping), drop)
  do.call(ggplot2::aes, stats::setNames(lapply(keep, function(n) mapping[[n]]), keep))
}

interactive_layers <- function(image_layer, image_aes, mapping, data, hover_size, inherit.aes) {
  rlang::check_installed("ggiraph", reason = "for interactive team marks.")
  list(
    image_layer(strip_aes(mapping, interactive_aes)),
    ggiraph::geom_point_interactive(
      mapping = strip_aes(mapping, c(image_aes, "season")), data = data,
      alpha = 0, size = hover_size, inherit.aes = inherit.aes
    )
  )
}

#' Interactive team logos, wordmarks and headshots (ggiraph)
#'
#' @description [geom_sdv_logos()] and its siblings with ggiraph's
#'   interactivity: map `tooltip`, `data_id` or `onclick`, then render with
#'   [ggiraph::girafe()]. Each returns two layers: the images, and an
#'   invisible interactive point over each that takes the hover.
#' @inheritParams geom_sdv_logos
#' @param hover_size The size of the invisible hover target, in ggplot2 point size.
#' @param max_px The longest side, in pixels, of each image embedded in the
#'   page. ggiraph writes every image into the widget, and a source logo
#'   (500 px) or headshot is 20-300 KB, so 30 of them make a page of megabytes;
#'   160 px stays sharp at the size these geoms draw. `NULL` embeds the source.
#' @param ... Passed to the image layer (`width`, `height`, `alpha`, ...).
#' @return A list of two ggplot2 layers, to add with `+`.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("ggiraph", quietly = TRUE)) {
#'   library(ggplot2)
#'   d <- data.frame(x = 1:3, y = c(2, 3, 1), team = c("KC", "BUF", "BAL"))
#'   p <- ggplot(d, aes(x, y)) +
#'     geom_sdv_logos_interactive(
#'       aes(team = team, tooltip = team, data_id = team), league = "nfl", width = 0.1
#'     )
#'   ggiraph::girafe(ggobj = p)
#' }
#' }
geom_sdv_logos_interactive <- function(mapping = NULL, data = NULL, ..., league, hover_size = 8, max_px = 160,
                                       id_system = "auto", strict = FALSE, inherit.aes = TRUE) {
  interactive_layers(function(m) {
    geom_sdv_logos(m, data, ...,
      league = league, id_system = id_system, strict = strict, max_px = max_px,
      inherit.aes = inherit.aes
    )
  }, "team", mapping, data, hover_size, inherit.aes)
}

#' @rdname geom_sdv_logos_interactive
#' @export
geom_sdv_wordmarks_interactive <- function(mapping = NULL, data = NULL, ..., league, hover_size = 8, max_px = 160,
                                           id_system = "auto", strict = FALSE, inherit.aes = TRUE) {
  interactive_layers(function(m) {
    geom_sdv_wordmarks(m, data, ...,
      league = league, id_system = id_system, strict = strict, max_px = max_px,
      inherit.aes = inherit.aes
    )
  }, "team", mapping, data, hover_size, inherit.aes)
}

#' @rdname geom_sdv_logos_interactive
#' @param id_system For headshots, as in [sdv_headshot_url()].
#' @export
geom_sdv_headshots_interactive <- function(mapping = NULL, data = NULL, ..., league, hover_size = 8, max_px = 160,
                                           id_system = "espn", inherit.aes = TRUE) {
  interactive_layers(function(m) {
    geom_sdv_headshots(m, data, ..., league = league, id_system = id_system, max_px = max_px, inherit.aes = inherit.aes)
  }, "player_id", mapping, data, hover_size, inherit.aes)
}
