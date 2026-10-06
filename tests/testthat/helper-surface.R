# sportyR draws every feature as polygons with a constant fill and outline
# (aes_params); those constants are the colors the built plot carries.
surface_colors <- function(p) {
  vapply(p$layers, function(l) {
    paste(l$aes_params$fill %||% "-", l$aes_params$colour %||% "-")
  }, character(1))
}
surface_data <- function(p) lapply(p$layers, function(l) l$data)
