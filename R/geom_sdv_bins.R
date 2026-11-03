# geom_sdv_bins(): sdv_bins()'s cells as a ggplot2 layer. The stat bins in data space and returns one row per
# cell (centre + extent, so the scales fit whole cells); the geom expands each row into its polygon and hands it
# to a polygon geom: GeomPolygon here, ggiraph's GeomInteractivePolygon for geom_sdv_bins_interactive().

StatSdvBins <- ggplot2::ggproto("StatSdvBins", ggplot2::Stat,
  required_aes = c("x", "y"),
  default_aes = ggplot2::aes(fill = ggplot2::after_stat(count)),
  # shape and size are the lattice bins_layer() resolved from the user's radius / side / equal_area
  compute_group = function(data, scales, shape = "hex", size = 1) {
    b <- bin_cells(bin_points(data$x, data$y, list(shape = shape, size = size)))
    # the cell's extent, so the position scales train on whole cells, not centres
    v <- cell_vertices(shape, size)
    data.frame(
      x = b$x, y = b$y,
      xmin = b$x + min(v$x), xmax = b$x + max(v$x),
      ymin = b$y + min(v$y), ymax = b$y + max(v$y),
      count = b$count, density = b$count / sum(b$count),
      cell_id = b$cell_id, cell_shape = shape, cell_size = size
    )
  }
)

# One polygon per cell row: the cell's vertices around its centre, group = the row.
cell_polygons <- function(data) {
  if (nrow(data) == 0) {
    return(data)
  }
  v <- cell_vertices(data$cell_shape[[1]], data$cell_size[[1]])
  k <- length(v$x)
  out <- data[rep(seq_len(nrow(data)), each = k), , drop = FALSE]
  out$x <- out$x + rep(v$x, nrow(data))
  out$y <- out$y + rep(v$y, nrow(data))
  out$group <- rep(seq_len(nrow(data)), each = k)
  out
}

GeomSdvBins <- ggplot2::ggproto("GeomSdvBins", ggplot2::Geom,
  required_aes = c("x", "y"),
  default_aes = ggplot2::aes(colour = NA, fill = "grey35", linewidth = 0.5, linetype = 1, alpha = NA),
  draw_key = ggplot2::draw_key_polygon,
  polygon_geom = ggplot2::GeomPolygon,
  draw_panel = function(self, data, panel_params, coord, lineend = "butt", linejoin = "mitre", linemitre = 10) {
    self$polygon_geom$draw_panel(cell_polygons(data), panel_params, coord,
      lineend = lineend, linejoin = linejoin, linemitre = linemitre
    )
  }
)

#' Hexagonal or square bins
#'
#' @description Bins x/y points into hexagons (`shape = "hex"`, the default)
#'   or squares (`shape = "square"`) and draws each cell filled by its count.
#'   The cells are [sdv_bins()]'s, so they match sdvplot (Python) and
#'   sdvplot-js. Sizes are in data units, so on a court from [sdv_surface()]
#'   with [sdv_court_coords()]'s `court_x` / `court_y` (feet), `radius = 1`
#'   is a 1-foot hexagon and `side = 1.5` a 1.5-foot square.
#' @details Unlike [ggplot2::geom_hex()], whose cells stretch with the axes,
#'   these are true hexagons and squares in data space, sized by `radius` or
#'   `side` rather than a bin count: under [ggplot2::coord_fixed()] (as
#'   [sdv_surface()] draws) they look regular. The lattice has a cell centred
#'   on the data origin (centre court on an [sdv_surface()] court); bin the
#'   NBA legacy frame with [sdv_bins()] for cells centred on the hoop.
#'
#'   Each group is binned on its own; facets bin each panel's data.
#' @section Computed variables:
#'   * `after_stat(count)`: points in the cell (the default `fill`).
#'   * `after_stat(density)`: the cell's share of its group's points.
#'   * `after_stat(cell_id)`: the cell's id, `"x,y"` ([sdv_bins()]).
#' @inheritParams sdv_bins
#' @param mapping,data,position,na.rm,show.legend,inherit.aes As in
#'   [ggplot2::geom_polygon()]. `x` and `y` are required.
#' @param ... Other arguments passed on to [ggplot2::layer()], such as
#'   `colour`, `linewidth` or `alpha` set to a value.
#' @return A ggplot2 layer.
#' @seealso [geom_sdv_bins_interactive()] to link each cell to its points.
#' @export
#' @examples
#' library(ggplot2)
#' set.seed(1)
#' d <- data.frame(x = rnorm(500), y = rnorm(500))
#' ggplot(d, aes(x, y)) +
#'   geom_sdv_bins(radius = 0.3) +
#'   coord_fixed()
#' ggplot(d, aes(x, y)) +
#'   geom_sdv_bins(aes(fill = after_stat(density)),
#'     shape = "square", radius = 0.3, equal_area = TRUE
#'   ) +
#'   coord_fixed()
geom_sdv_bins <- function(mapping = NULL, data = NULL, position = "identity", ..., shape = "hex", radius = NULL,
                          side = NULL, equal_area = FALSE, na.rm = FALSE, show.legend = NA, inherit.aes = TRUE) {
  bins_layer(GeomSdvBins, mapping, data, position, ...,
    shape = shape, radius = radius, side = side, equal_area = equal_area, na.rm = na.rm,
    show.legend = show.legend, inherit.aes = inherit.aes
  )
}

bins_layer <- function(geom, mapping, data, position, ..., shape, radius, side, equal_area, na.rm, show.legend,
                       inherit.aes, stat = StatSdvBins, call = rlang::caller_env()) {
  lattice <- bin_lattice(shape, radius, side, equal_area, call = call) # fail at the call, not at print
  ggplot2::layer(
    data = data, mapping = mapping, stat = stat, geom = geom, position = position,
    show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(shape = lattice$shape, size = lattice$size, na.rm = na.rm, ...)
  )
}

# The interactive stat: each cell carries its cell id as data_id unless a data_id is mapped, in the layer or in
# ggplot() (a stat's default aesthetics apply only to what the combined mapping leaves unset).
StatSdvBinsInteractive <- ggplot2::ggproto("StatSdvBinsInteractive", StatSdvBins,
  default_aes = ggplot2::aes(fill = ggplot2::after_stat(count), data_id = ggplot2::after_stat(cell_id))
)

# A mapping as a plain named list (ggplot2 4's S7 mapping has no as.list()), NULL entries kept.
aes_list <- function(m) stats::setNames(lapply(names(m), function(n) m[[n]]), names(m))

#' Interactive hexagonal or square bins (ggiraph)
#'
#' @description [geom_sdv_bins()] with ggiraph's interactivity: each cell's
#'   `data_id` is its cell id (`after_stat(cell_id)`) unless you map one, so a
#'   cell links to every other element with the same id. Give the points the
#'   same id with [sdv_bin_ids()] (same `shape` and size) and draw them with
#'   any ggiraph geom: hovering or selecting a cell then highlights its
#'   points, and a point lights its cell and its cell-mates, in one
#'   [ggiraph::girafe()] (one plot, or several combined with 'patchwork').
#' @details **The linking contract** is sdvplot-js's: ids are strings, and a
#'   cell's id is `"x,y"`, its centre as JavaScript writes the numbers
#'   ([sdv_bins()]). A point links to a cell when its `data_id` equals the
#'   cell's, so bin both with the same lattice (`shape`, `radius` / `side`,
#'   `equal_area`) in the same coordinates. Selection works the same way: with
#'   `ggiraph::opts_selection(type = "multiple")`, the selected ids (in Shiny,
#'   `input$<outputId>_selected`) are cell ids, and `sdv_bins()`'s `rows`
#'   column maps each back to its points, for a linked table or any other
#'   view.
#'
#'   Map `tooltip` to label the cells, e.g.
#'   `aes(tooltip = after_stat(paste(count, "shots")))`.
#' @inheritParams geom_sdv_bins
#' @return A ggplot2 layer.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("ggiraph", quietly = TRUE)) {
#'   library(ggplot2)
#'   set.seed(1)
#'   d <- data.frame(x = rnorm(300), y = rnorm(300))
#'   # the points carry their cell's id, so a cell and its points link
#'   d$cell_id <- sdv_bin_ids(d$x, d$y, shape = "square", side = 0.5)
#'   p <- ggplot(d, aes(x, y)) +
#'     geom_sdv_bins_interactive(aes(tooltip = after_stat(count)),
#'       shape = "square", side = 0.5, alpha = 0.6
#'     ) +
#'     ggiraph::geom_point_interactive(aes(data_id = cell_id), size = 0.8) +
#'     coord_fixed()
#'   ggiraph::girafe(
#'     ggobj = p,
#'     options = list(
#'       ggiraph::opts_hover(css = "fill:orange;stroke:black;"),
#'       ggiraph::opts_selection(type = "multiple")
#'     )
#'   )
#' }
#' }
geom_sdv_bins_interactive <- function(mapping = NULL, data = NULL, position = "identity", ..., shape = "hex",
                                      radius = NULL, side = NULL, equal_area = FALSE, na.rm = FALSE,
                                      show.legend = NA, inherit.aes = TRUE) {
  rlang::check_installed("ggiraph", reason = "for interactive bins.")
  geom <- ggplot2::ggproto("GeomInteractiveSdvBins", GeomSdvBins,
    default_aes = do.call(ggplot2::aes, c(
      aes_list(GeomSdvBins$default_aes),
      aes_list(ggiraph::GeomInteractivePolygon$default_aes)[interactive_aes]
    )),
    polygon_geom = ggiraph::GeomInteractivePolygon
  )
  bins_layer(geom, mapping, data, position, ...,
    shape = shape, radius = radius, side = side, equal_area = equal_area, na.rm = na.rm,
    show.legend = show.legend, inherit.aes = inherit.aes, stat = StatSdvBinsInteractive
  )
}

# ggplotly(): the cells as plotly polygons (plotly's own GeomHex method does the same).
#' @exportS3Method plotly::to_basic
to_basic.GeomSdvBins <- function(data, prestats_data, layout, params, p, ...) {
  structure(cell_polygons(data), class = unique(c("GeomPolygon", "GeomSdvBins", class(data))))
}
