# Hexagonal and square binning, ported from sdvplot-js `@sportsdataverse/sdvplot/bins`
# (packages/sdvplot/src/bins/{hexbin,squarebin}.ts). The hexagon lattice is d3-hexbin 0.2.2's
# (src/hexbin.js:23-72, Copyright 2012-2016 Mike Bostock, BSD-3-Clause), so bins, their order and their
# centres equal d3-hexbin's, sdvplot-js's and sdvplot's. tests/testthat/test-bins.R checks them against
# sdvplot-js run in node on 2000 real shots (data-raw/sdvplot_bins_oracle.mts).

# A hexagon of circumradius r has area (3 * sqrt(3) / 2) * r^2: the square of equal area has side r * this
# (sdvplot-js squarebin.ts EQUAL_AREA).
equal_area_factor <- sqrt(1.5 * sqrt(3))

# The lattice from the user's options: list(shape, size), size = the hexagon's circumradius or the square's side.
bin_lattice <- function(shape, radius, side, equal_area, call = rlang::caller_env()) {
  shape <- rlang::arg_match0(shape, c("hex", "square"), error_call = call)
  if (!isTRUE(equal_area) && !isFALSE(equal_area)) {
    cli::cli_abort("{.arg equal_area} must be {.code TRUE} or {.code FALSE}.", call = call)
  }
  if (shape == "hex" && equal_area) {
    cli::cli_abort("{.arg equal_area} is for squares; hexagons are sized by {.arg radius}.", call = call)
  }
  # the one size argument the lattice takes: hexagons and equal-area squares a radius, other squares a side
  given <- list(radius = radius, side = side)
  want <- if (shape == "hex" || equal_area) "radius" else "side"
  other <- setdiff(names(given), want)
  if (is.null(given[[want]]) || !is.null(given[[other]])) {
    cli::cli_abort(c(
      "{.code shape = \"{shape}\"}{if (equal_area) ' with equal_area = TRUE'} takes {.arg {want}}, not {.arg {other}}.",
      i = if (want == "side") "Or size squares by a hexagon's {.arg radius} with {.code equal_area = TRUE}."
    ), call = call)
  }
  v <- given[[want]]
  if (!(is.numeric(v) && length(v) == 1 && is.finite(v) && v > 0)) {
    cli::cli_abort("{.arg {want}} must be a finite number > 0, not {.obj_type_friendly {v}}.", call = call)
  }
  size <- if (equal_area) v * equal_area_factor else v
  if (!is.finite(size * 2)) { # the hexagon lattice's row spacing is 2 * size: past the double range it is Inf
    cli::cli_abort("{.arg {want}} = {v} is too large: the cell spacing overflows.", call = call)
  }
  list(shape = shape, size = size)
}

# JavaScript's Math.round: halves go toward +Inf (R's round() goes to even).
js_round <- function(v) {
  f <- floor(v)
  f + (v - f >= 0.5)
}

# Each finite point's cell centre: list(x, y, keep), x and y for the kept points only.
bin_centres <- function(x, y, lattice) {
  keep <- is.finite(x) & is.finite(y)
  x <- x[keep]
  y <- y[keep]
  r <- lattice$size
  if (lattice$shape == "square") {
    cx <- js_round(x / r) * r
    cy <- js_round(y / r) * r
    if (!all(is.finite(cx) & is.finite(cy))) { # a side so small that x / side overflows
      cli::cli_abort("{.arg side} = {r} is too small for these coordinates: a cell centre overflows.")
    }
  } else {
    # d3-hexbin hexbin.js:28-47, operation for operation (the same doubles as sdvplot-js)
    dx <- r * 2 * sin(pi / 3)
    dy <- r * 1.5
    py <- y / dy
    pj <- js_round(py)
    odd <- pj %% 2 != 0
    px <- x / dx - odd / 2
    pi_ <- js_round(px)
    py1 <- py - pj
    px1 <- px - pi_
    pi2 <- pi_ + ifelse(px < pi_, -1, 1) / 2
    pj2 <- pj + ifelse(py < pj, -1, 1)
    px2 <- px - pi2
    py2 <- py - pj2
    # the second candidate only past a third of a row, and only when strictly nearer in lattice units: the
    # documented d3-hexbin quirk that leaves 1-2% of points just outside their drawn hexagon. Do not "fix" it.
    swap <- abs(py1) * 3 > 1 & px1 * px1 + py1 * py1 > px2 * px2 + py2 * py2
    pi_[swap] <- pi2[swap] + ifelse(odd[swap], 1, -1) / 2
    pj[swap] <- pj2[swap]
    cx <- (pi_ + (pj %% 2 != 0) / 2) * dx
    cy <- pj * dy
  }
  # -0 folds to 0 (sdvplot-js `|| 0`), so the cell at the origin has one id
  list(x = cx + 0, y = cy + 0, keep = keep)
}

# JavaScript's Number#toString for ordinary magnitudes: the shortest decimal that reads back as the same double.
# ponytail: no exponent form, so ids differ from JS below 1e-6 or from 1e21 in magnitude (never court data).
js_number <- function(v) {
  out <- trimws(formatC(v, digits = 15, format = "fg"))
  for (d in 16:17) {
    bad <- read_numbers(out) != v
    if (!any(bad)) break
    out[bad] <- trimws(formatC(v[bad], digits = d, format = "fg"))
  }
  out
}

# Read decimal strings back with C's strtod (through jsonlite's parser): it rounds correctly everywhere, while
# as.numeric() is R's own parser, one ulp off on macOS arm64 (no 80-bit long double), which turned
# "96.71129386411877" into a 17-digit id there.
read_numbers <- function(s) jsonlite::parse_json(paste0("[", paste(s, collapse = ","), "]"), simplifyVector = TRUE)

cell_ids <- function(cx, cy) paste0(js_number(cx), rep_len(",", length(cx)), js_number(cy))

#' Bin points into hexagons or squares
#'
#' @description `sdv_bins()` bins x/y points into pointy-top hexagons
#'   (`shape = "hex"`, the default) or axis-aligned squares (`shape =
#'   "square"`) and returns one row per cell: its id, centre, count and the
#'   rows it holds. `sdv_bin_ids()` returns each point's cell id instead, the
#'   key that links a point to its cell in an interactive chart
#'   ([geom_sdv_bins_interactive()]). The lattice is the one sdvplot (Python)
#'   and sdvplot-js (`binner()`) use, with the same argument names, so all three
#'   put the same points in the same cells with the same ids.
#' @details Sizes are in the points' own units (data space, not pixels): a
#'   hexagon has circumradius `radius`, a square side `side`, and with
#'   `equal_area = TRUE` a square has the area of a hexagon of circumradius
#'   `radius` (side `radius * sqrt(3 * sqrt(3) / 2)`, about `1.6119 * radius`).
#'   Both lattices have a cell centred on the origin.
#'
#'   * Hexagons are d3-hexbin's lattice: rows `1.5 * radius` apart, columns
#'     `sqrt(3) * radius` apart, odd rows shifted half a column. Each point
#'     goes to the centre d3-hexbin picks, which is close to but not exactly
#'     the nearest one, so about 1-2% of points sit just outside the hexagon
#'     drawn for their cell (22 of 2000 real shots at radius 10). That is
#'     faithful to d3-hexbin, sdvplot-js and sdvplot.
#'   * Squares are centred on `(i * side, j * side)` and half-open: a point
#'     exactly on an edge goes to the higher cell (JavaScript's `Math.round()`,
#'     which d3-hexbin uses). Every point lies inside its square.
#'
#'   Cells come in first-seen order: the cell of the first point first.
#'   Points with a missing or non-finite coordinate are skipped (sdvplot-js
#'   skips `NaN`; it would put an infinite one in a cell of its own).
#'
#'   **Ids are strings**, as in sdvplot-js's linked interactivity: a cell's id
#'   is `"x,y"`, its centre written as JavaScript writes a number (the
#'   shortest decimal that reads back exactly, `-0` as `0`), the
#'   `data-sdv-id` sdvplot-js stamps on the cell. The rim cell of a shot chart
#'   in the NBA legacy frame is `"0,0"` for either shape.
#' @param x,y Numeric vectors of point coordinates, the same length.
#' @param shape `"hex"` (the default) or `"square"`.
#' @param radius The hexagons' circumradius; for squares, with
#'   `equal_area = TRUE`, the circumradius of the hexagon whose area each
#'   square has.
#' @param side The squares' side.
#' @param equal_area For squares: size them by `radius` to the area of a
#'   hexagon of that circumradius, so a hex chart and a square chart of the
#'   same data have cells of the same area.
#' @return `sdv_bins()`: a data frame with one row per cell, in first-seen order:
#'   | col_name | type | description |
#'   |---|---|---|
#'   | cell_id | character | The cell's id, `"x,y"` (see Details) |
#'   | x | numeric | The cell centre's x, in the points' units |
#'   | y | numeric | The cell centre's y, in the points' units |
#'   | count | integer | Points in the cell |
#'   | rows | list | Integer positions (1-based) of the cell's points in `x` / `y`, in input order |
#'
#'   `sdv_bin_ids()`: a character vector as long as `x`, each point's cell id
#'   (`NA` for a skipped point).
#' @seealso [geom_sdv_bins()] to draw the cells, [geom_sdv_bins_interactive()]
#'   to link them to their points.
#' @export
#' @examples
#' # three Brooklyn shots of 2025-26, NBA legacy frame (tenths of a foot,
#' # hoop at the origin): the two at the rim share a 1 ft hexagon
#' x <- c(0, -1, -44)
#' y <- c(0, 7, 252)
#' sdv_bins(x, y, radius = 10)
#' sdv_bins(x, y, shape = "square", side = 10)
#' sdv_bins(x, y, shape = "square", radius = 10, equal_area = TRUE)
#' sdv_bin_ids(x, y, radius = 10)
sdv_bins <- function(x, y, shape = "hex", radius = NULL, side = NULL, equal_area = FALSE) {
  b <- bin_points(x, y, bin_lattice(shape, radius, side, equal_area))
  members <- unname(split(which(b$keep), b$cell))
  cells <- bin_cells(b)
  cells$rows <- I(members)
  cells
}

#' @rdname sdv_bins
#' @export
sdv_bin_ids <- function(x, y, shape = "hex", radius = NULL, side = NULL, equal_area = FALSE) {
  b <- bin_points(x, y, bin_lattice(shape, radius, side, equal_area))
  out <- rep(NA_character_, length(b$keep))
  out[b$keep] <- b$id
  out
}

# Each kept point's centre, id and cell number (first-seen order), plus the keep mask.
bin_points <- function(x, y, lattice, call = rlang::caller_env()) {
  if (!is.numeric(x) || !is.numeric(y) || length(x) != length(y)) {
    cli::cli_abort("{.arg x} and {.arg y} must be numeric vectors of the same length.", call = call)
  }
  b <- bin_centres(as.double(x), as.double(y), lattice)
  b$id <- cell_ids(b$x, b$y)
  b$cell <- match(b$id, unique(b$id))
  b
}

# One row per cell: id, centre, count.
bin_cells <- function(b) {
  first <- !duplicated(b$cell)
  data.frame(cell_id = b$id[first], x = b$x[first], y = b$y[first], count = tabulate(b$cell, nbins = sum(first)))
}

# A cell's vertices around (0, 0): a pointy-top hexagon of circumradius `size` (d3-hexbin's vertex order,
# sdvplot-js hexagonPoints) or a square of side `size` (squarePoints).
cell_vertices <- function(shape, size) {
  if (shape == "square") {
    h <- size / 2
    return(list(x = c(-h, h, h, -h), y = c(-h, -h, h, h)))
  }
  a <- seq(0, 5) * pi / 3
  list(x = sin(a) * size, y = -cos(a) * size)
}
