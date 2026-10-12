# An axis label draws a small copy of its image (img_html()); the copy is named
# by its source, so the path a label should hold names the image it should draw.
label_src <- function(url, size) {
  chartr("\\", "/", vapply(url, small_image, character(1), px = ceiling(4 * size), USE.NAMES = FALSE))
}
