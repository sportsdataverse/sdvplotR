# plotly: team marks as layout images placed in data units, as sdvplot's
# plotly adapter does. Native plot_ly() charts only: ggplotly() drops layout images.

# Add images to the chart, keeping every image already on it: ones set by plotly::layout()
# (kept in layoutAttrs, one entry per call) and ones in layout$images. layout() entries sharing
# a key are not merged by element at build time, so gather them all, clear them, and set one
# combined list through layout().
append_images <- function(p, imgs) {
  attrs <- p$x$layoutAttrs
  old <- c(p$x$layout$images, unlist(lapply(attrs, function(a) a$images), recursive = FALSE))
  p$x$layout$images <- NULL
  p$x$layoutAttrs <- lapply(attrs, function(a) {
    a$images <- NULL
    a
  })
  plotly::layout(p, images = unname(c(old, imgs)))
}

check_not_date <- function(x, y, call = rlang::caller_env()) {
  if (inherits(x, c("Date", "POSIXt")) || inherits(y, c("Date", "POSIXt"))) {
    cli::cli_abort("Date axes are not supported yet: pass numbers or category names.", call = call)
  }
}

axis_span <- function(v) {
  if (!is.numeric(v)) {
    return(length(unique(v)))
  }
  r <- diff(range(v, na.rm = TRUE))
  if (!is.finite(r) || r == 0) 1 else r
}

# ponytail: numeric and categorical axes; date axes abort (add when asked).
add_layout_images <- function(p, x, y, urls, size, xref, yref) {
  check_not_date(x, y)
  n <- max(length(x), length(y), length(urls))
  x <- rep_len(if (is.factor(x)) as.character(x) else x, n)
  y <- rep_len(if (is.factor(y)) as.character(y) else y, n)
  urls <- rep_len(urls, n)
  # sizing "contain" fits each image by height; sizex only bounds the width
  sizey <- size * axis_span(y)
  sizex <- 2 * axis_span(x)
  ok <- which(!is.na(urls) & !is.na(x) & !is.na(y))
  imgs <- lapply(ok, function(i) {
    list(
      source = urls[[i]], xref = xref, yref = yref, x = x[[i]], y = y[[i]], sizex = sizex, sizey = sizey,
      xanchor = "center", yanchor = "middle", sizing = "contain", layer = "above"
    )
  })
  append_images(p, imgs)
}

#' Team logos, wordmarks and headshots on plotly charts
#'
#' @description Places team marks on a [plotly::plot_ly()] chart at data
#'   coordinates, as layout images. The R counterpart of sdvplot's plotly
#'   adapter. Works on native plotly charts; [plotly::ggplotly()] drops layout
#'   images, so draw a ggplot with [geom_sdv_logos()] or
#'   [geom_sdv_logos_interactive()] instead.
#' @details Images are placed in data units and fitted by height: each is sized to
#'   `size` times the y-axis span (the number of categories on a categorical axis),
#'   so a chart with a wide y range gets proportionally taller marks. Images already
#'   on the chart, including ones set with [plotly::layout()], are kept. Date axes
#'   are not supported yet.
#' @param p A plotly object.
#' @param x,y Positions: numbers, or category names on a categorical axis.
#' @param team Team identifiers, one per position.
#' @param player_id Player ids, one per position.
#' @inheritParams sdv_logo_url
#' @param size Each image is fitted by height to `size` times the y-axis span (the
#'   number of categories on a categorical axis), so `0.08` is 8% of the axis.
#'   The width follows the image's aspect ratio.
#' @param xref,yref The axes the positions refer to (`"x2"` for a subplot's).
#' @return The plotly object with the images added.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("plotly", quietly = TRUE)) {
#'   d <- data.frame(team = c("KC", "BUF", "BAL"), off = c(0.12, 0.15, 0.18), def = c(-0.05, 0.02, -0.08))
#'   plotly::plot_ly(d, x = ~off, y = ~def, type = "scatter", mode = "markers", text = ~team) |>
#'     add_sdv_logos(d$off, d$def, d$team, "nfl")
#' }
#' }
add_sdv_logos <- function(p, x, y, team, league, size = 0.08, season = NULL, variant = "default",
                          id_system = "auto", strict = FALSE, xref = "x", yref = "y") {
  rlang::check_installed("plotly", reason = "to draw logos on plotly charts.")
  urls <- logo_from_team(team, league, season = season, variant = variant, id_system = id_system, strict = strict)
  add_layout_images(p, x, y, urls, size, xref, yref)
}

#' @rdname add_sdv_logos
#' @export
add_sdv_wordmarks <- function(p, x, y, team, league, size = 0.08, season = NULL, variant = "default",
                              id_system = "auto", strict = FALSE, xref = "x", yref = "y") {
  rlang::check_installed("plotly", reason = "to draw wordmarks on plotly charts.")
  urls <- wordmark_from_team(team, league, season = season, variant = variant, id_system = id_system, strict = strict)
  add_layout_images(p, x, y, urls, size, xref, yref)
}

#' @rdname add_sdv_logos
#' @param id_system For headshots, as in [sdv_headshot_url()].
#' @export
add_sdv_headshots <- function(p, x, y, player_id, league, size = 0.08, id_system = "espn", xref = "x", yref = "y") {
  rlang::check_installed("plotly", reason = "to draw headshots on plotly charts.")
  check_league(league)
  urls <- headshot_from_id(player_id, league, check_id_system(id_system, league))
  add_layout_images(p, x, y, urls, size, xref, yref)
}

#' Team logos as plotly axis labels
#'
#' @description Replaces a categorical axis's tick labels with team logos.
#' @inheritParams add_sdv_logos
#' @param teams The axis categories, in the chart's order (the team values the
#'   chart plots on that axis).
#' @param axis `"x"` or `"y"`.
#' @param size Image size as a fraction of the plot area on the other axis.
#' @return The plotly object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("plotly", quietly = TRUE)) {
#'   teams <- c("KC", "BUF", "BAL")
#'   plotly::plot_ly(x = teams, y = c(11, 13, 12), type = "bar") |>
#'     sdv_axis_logos(teams, "nfl")
#' }
#' }
sdv_axis_logos <- function(p, teams, league, axis = c("x", "y"), size = 0.08, season = NULL,
                           variant = "default", id_system = "auto", strict = FALSE) {
  rlang::check_installed("plotly", reason = "to draw logos on plotly axes.")
  axis <- rlang::arg_match(axis)
  if (is.factor(teams)) teams <- as.character(teams)
  urls <- logo_from_team(teams, league, season = season, variant = variant, id_system = id_system, strict = strict)
  ok <- which(!is.na(urls))
  imgs <- lapply(ok, function(i) {
    if (axis == "x") {
      list(
        source = urls[[i]], xref = "x", yref = "paper", x = teams[[i]], y = 0, sizex = 1, sizey = size,
        xanchor = "center", yanchor = "top", sizing = "contain", layer = "above"
      )
    } else {
      list(
        source = urls[[i]], xref = "paper", yref = "y", x = 0, y = teams[[i]], sizex = size, sizey = 1,
        xanchor = "right", yanchor = "middle", sizing = "contain", layer = "above"
      )
    }
  })
  ax <- list(showticklabels = FALSE)
  p <- if (axis == "x") plotly::layout(p, xaxis = ax) else plotly::layout(p, yaxis = ax)
  append_images(p, imgs)
}

#' Team colours as a plotly colorway
#'
#' @description Sets the chart's trace colours to the teams' colours, in order.
#' @inheritParams add_sdv_logos
#' @inheritParams sdv_color_palette
#' @return The plotly object.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("plotly", quietly = TRUE)) {
#'   plotly::plot_ly(type = "bar") |> sdv_colorway("nfl", c("KC", "BUF"))
#' }
#' }
sdv_colorway <- function(p, league, teams = NULL, which = c("primary", "secondary"), season = NULL,
                         id_system = "auto") {
  rlang::check_installed("plotly", reason = "to colour plotly charts.")
  which <- rlang::arg_match(which)
  plotly::layout(
    p,
    colorway = unname(sdv_color_palette(league, teams, which = which, season = season, id_system = id_system))
  )
}
