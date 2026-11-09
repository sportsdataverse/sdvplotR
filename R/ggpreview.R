#' Preview a ggplot at the size it will be saved
#'
#' @description Saves the plot to a temporary file with [ggplot2::ggsave()]
#'   and opens it, so you see it at the size, aspect ratio and resolution of
#'   the saved image (and faster than RStudio's plot pane draws plots full of
#'   images). In RStudio the file opens in the Viewer pane (this needs
#'   'rstudioapi'), elsewhere in your browser. It opens only in an
#'   interactive session. The counterpart of nflplotR's and cfbplotR's
#'   `ggpreview()`.
#' @inheritParams ggplot2::ggsave
#' @param asp The aspect ratio, `width / height`. When a number, the `height`
#'   is set to `width / asp`; with no `width`, the `width` is `height * asp`,
#'   or 7 inches when neither is given.
#' @return The path of the image, invisibly.
#' @export
#' @examples
#' \donttest{
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point()
#' # opens only in an interactive session
#' path <- sdv_ggpreview(p, width = 5, asp = 16 / 9, dpi = 72)
#' file.exists(path)
#' }
sdv_ggpreview <- function(
    plot = ggplot2::last_plot(),
    width = NA,
    height = NA,
    asp = NULL,
    dpi = 300,
    device = "png",
    units = c("in", "cm", "mm", "px"),
    scale = 1,
    limitsize = TRUE,
    bg = NULL,
    ...
) {
  units <- rlang::arg_match0(units[1], c("in", "cm", "mm", "px"))
  file <- tempfile(fileext = paste0(".", preview_ext(device)))
  if (is.numeric(asp)) {
    if (is.na(width) && !is.na(height)) {
      width <- height * asp
    } else {
      # ggsave's default size: a 7-inch side
      if (is.na(width)) width <- 7 * c("in" = 1, cm = 2.54, mm = 25.4, px = dpi)[[units]]
      height <- width / asp
    }
  }
  ggplot2::ggsave(
    file,
    plot = plot, device = device, scale = scale, width = width, height = height,
    units = units, dpi = dpi, limitsize = limitsize, bg = bg, ...
  )
  if (interactive()) open_preview(file)
  invisible(file)
}

# The preview file's extension: a device name as given, a base graphics device
# by its format; any other function (ragg::agg_png, ...) is taken as PNG
preview_ext <- function(device) {
  if (is.character(device)) {
    return(device)
  }
  devs <- list(
    pdf = grDevices::pdf, pdf = grDevices::cairo_pdf, ps = grDevices::postscript, ps = grDevices::cairo_ps,
    svg = grDevices::svg, jpeg = grDevices::jpeg, tiff = grDevices::tiff, bmp = grDevices::bmp,
    png = grDevices::png
  )
  hit <- names(devs)[vapply(devs, identical, logical(1), device)]
  if (length(hit)) hit[1] else "png"
}

open_preview <- function(file) {
  # RStudio's Viewer when the API is there (not, e.g., R started from RStudio's terminal), else the browser
  if (identical(Sys.getenv("RSTUDIO"), "1") && requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()) {
    rstudioapi::viewer(file)
  } else {
    utils::browseURL(file)
  }
}
