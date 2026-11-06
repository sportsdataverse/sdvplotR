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
#'   is set to `width / asp`.
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
  file <- tempfile(fileext = if (is.character(device)) paste0(".", device) else ".png")
  if (is.numeric(asp)) height <- width / asp
  ggplot2::ggsave(
    file,
    plot = plot, device = device, scale = scale, width = width, height = height,
    units = units, dpi = dpi, limitsize = limitsize, bg = bg, ...
  )
  if (interactive()) open_preview(file)
  invisible(file)
}

open_preview <- function(file) {
  if (identical(Sys.getenv("RSTUDIO"), "1")) {
    rlang::check_installed("rstudioapi", reason = "to show the preview in RStudio's Viewer pane.")
    rstudioapi::viewer(file)
  } else {
    utils::browseURL(file)
  }
}
