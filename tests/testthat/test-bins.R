skip_on_cran()

# 2000 real Brooklyn shots of 2025-26 (NBA legacy frame, tenths of a foot) with each shot's cell id under six
# lattices, as sdvplot-js's binner() writes them: data-raw/sdvplot_bins_oracle.mts, run in node on sdvplot-js
# main @ fffc941 (fixtures/shots/nba-2026-bkn-2000-columns.json there).
oracle <- utils::read.csv(test_path("fixtures", "bins_bkn_2000.csv.gz"),
  colClasses = c("numeric", "numeric", "integer", rep("character", 6))
)
lattices <- list(
  hex10 = list(radius = 10), hex15 = list(radius = 15),
  sq10 = list(shape = "square", side = 10), sq15 = list(shape = "square", side = 15),
  eq10 = list(shape = "square", radius = 10, equal_area = TRUE),
  eq15 = list(shape = "square", radius = 15, equal_area = TRUE)
)
bins_of <- function(f, k) do.call(f, c(list(oracle$x_legacy, oracle$y_legacy), lattices[[k]]))

test_that("every shot gets sdvplot-js's cell id, byte for byte, under all six lattices", {
  cells <- c(hex10 = 374, hex15 = 211, sq10 = 641, sq15 = 395, eq10 = 378, eq15 = 214)
  for (k in names(lattices)) {
    ids <- bins_of(sdv_bin_ids, k)
    expect_identical(ids, oracle[[k]], label = k)
    b <- bins_of(sdv_bins, k)
    expect_identical(nrow(b), as.integer(cells[[k]]), label = k)
    # first-seen order, as sdvplot-js returns its bins
    expect_identical(b$cell_id, unique(oracle[[k]]), label = k)
    expect_identical(sum(b$count), 2000L)
  }
})

test_that("rows hold each cell's points, in input order", {
  b <- sdv_bins(oracle$x_legacy, oracle$y_legacy, radius = 15)
  expect_identical(lengths(b$rows), b$count)
  expect_identical(sort(unlist(b$rows)), 1:2000)
  ids <- sdv_bin_ids(oracle$x_legacy, oracle$y_legacy, radius = 15)
  for (i in c(1, 7, nrow(b))) {
    expect_identical(b$rows[[i]], which(ids == b$cell_id[[i]]))
  }
  expect_identical(b$cell_id, paste0(js_number(b$x), ",", js_number(b$y)))
})

test_that("squares hold every point, half-open, edges going to the higher cell", {
  b <- sdv_bins(oracle$x_legacy, oracle$y_legacy, shape = "square", side = 10)
  x <- oracle$x_legacy[unlist(b$rows)]
  y <- oracle$y_legacy[unlist(b$rows)]
  cx <- rep(b$x, b$count)
  cy <- rep(b$y, b$count)
  expect_true(all(x >= cx - 5 & x < cx + 5 & y >= cy - 5 & y < cy + 5))
  # sdvplot-js squarebin's example: x = 5 is on an edge and goes up; -5 goes up to 0 (not -0)
  expect_identical(
    sdv_bin_ids(c(0, -1, 5, -5), c(0, 7, 91, -5), shape = "square", side = 10),
    c("0,0", "0,10", "10,90", "0,0")
  )
})

test_that("hexagons keep d3-hexbin's nearest-centre quirk (22 / 37 of the 2000 shots outside their hexagon)", {
  outside <- function(r) {
    b <- sdv_bins(oracle$x_legacy, oracle$y_legacy, radius = r)
    dx <- abs(oracle$x_legacy[unlist(b$rows)] - rep(b$x, b$count))
    dy <- abs(oracle$y_legacy[unlist(b$rows)] - rep(b$y, b$count))
    # outside a pointy-top hexagon of circumradius r (a hair of slack for points on an edge)
    sum(dx > sqrt(3) / 2 * r + 1e-9 | dy + dx / sqrt(3) > r + 1e-9)
  }
  expect_identical(outside(10), 22L)
  expect_identical(outside(15), 37L)
})

test_that("an equal-area square has a hexagon's area", {
  hex <- cell_vertices("hex", 15)
  shoelace <- abs(sum(hex$x * c(hex$y[-1], hex$y[1]) - c(hex$x[-1], hex$x[1]) * hex$y)) / 2
  side <- bin_lattice("square", 15, NULL, TRUE)$size
  expect_equal(side^2, shoelace)
  expect_equal(side, 24.177823466029693)
})

test_that("missing and non-finite points are skipped; -0 folds to 0", {
  ids <- sdv_bin_ids(c(1, NA, NaN, Inf, -1), c(1, 1, 1, 1, -1), radius = 10)
  expect_identical(ids, c("0,0", NA, NA, NA, "0,0"))
  b <- sdv_bins(c(NA, -1, 1), c(0, -1, 1), radius = 10)
  expect_identical(b$rows[[1]], 2:3)
  expect_identical(nrow(sdv_bins(numeric(), numeric(), radius = 1)), 0L)
})

test_that("lattice arguments are checked as sdvplot-js's binner() checks them", {
  expect_error(sdv_bins(1, 1), "radius")
  expect_error(sdv_bins(1, 1, radius = 0), "radius")
  expect_error(sdv_bins(1, 1, radius = 1, side = 1), "side")
  expect_error(sdv_bins(1, 1, shape = "square"), "side")
  expect_error(sdv_bins(1, 1, shape = "square", radius = 1), "equal_area")
  expect_error(sdv_bins(1, 1, shape = "square", side = Inf), "side")
  expect_error(sdv_bins(1, 1, shape = "circle", radius = 1), "shape")
  expect_error(sdv_bins(1:2, 1, radius = 1), "same length")
})

shots <- data.frame(x = oracle$x_legacy, y = oracle$y_legacy)

test_that("geom_sdv_bins draws sdv_bins()'s cells, filled by count", {
  p <- ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins(shape = "square", radius = 10, equal_area = TRUE)
  d <- ggplot2::layer_data(p)
  b <- sdv_bins(shots$x, shots$y, shape = "square", radius = 10, equal_area = TRUE)
  expect_identical(d$cell_id, b$cell_id)
  expect_identical(d$count, b$count)
  expect_equal(d$density, b$count / 2000)
  expect_false(anyNA(d$fill))
  # the scales fit whole cells
  expect_equal(d$xmax - d$xmin, rep(10 * sqrt(1.5 * sqrt(3)), nrow(d)))
  grob <- ggplot2::layer_grob(p)[[1]]
  expect_s3_class(grob, "polygon")
  expect_length(grob$x, 4 * nrow(b))
  expect_error(geom_sdv_bins(shape = "square", radius = 1), "equal_area")
})

test_that("hexagons draw six vertices per cell and each group bins on its own", {
  shots$half <- shots$x < 0
  p <- ggplot2::ggplot(shots, ggplot2::aes(x, y, group = half)) +
    geom_sdv_bins(radius = 15)
  d <- ggplot2::layer_data(p)
  expect_identical(sum(d$count), 2000L)
  expect_length(ggplot2::layer_grob(p)[[1]]$x, 6 * nrow(d))
})

test_that("interactive bins carry their cell id, which links them to points binned alike", {
  skip_if_not_installed("ggiraph")
  shots$cell_id <- sdv_bin_ids(shots$x, shots$y, shape = "square", side = 15)
  p <- ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins_interactive(ggplot2::aes(tooltip = ggplot2::after_stat(count)), shape = "square", side = 15) +
    ggiraph::geom_point_interactive(ggplot2::aes(data_id = cell_id), size = 0.5)
  d <- ggplot2::layer_data(p)
  expect_identical(d$data_id, d$cell_id)
  expect_setequal(unique(shots$cell_id), d$data_id)
  html <- ggiraph::girafe(ggobj = p)$x$html
  ids <- regmatches(html, gregexpr("data-id='[^']+'", html))[[1]]
  # one cell plus its points share each id
  expect_identical(length(ids), nrow(d) + 2000L)
  expect_setequal(unique(ids), paste0("data-id='", d$cell_id, "'"))
  # a mapped data_id wins
  p2 <- ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins_interactive(ggplot2::aes(data_id = "all"), radius = 15)
  expect_identical(unique(ggplot2::layer_data(p2)$data_id), "all")
})

test_that("ggplotly draws the cells as polygons", {
  skip_if_not_installed("plotly")
  p <- ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins(radius = 15)
  built <- plotly::plotly_build(plotly::ggplotly(p))$x$data
  fills <- Filter(function(t) identical(t$fill, "toself"), built)
  expect_gt(length(fills), 0)
  expect_identical(sum(vapply(fills, function(t) sum(is.finite(t$x)), numeric(1))), 7 * 211) # closed rings
})

test_that("lattices whose spacing or centres overflow are refused", {
  expect_error(sdv_bins(0, 0, radius = 1e308), "overflows")
  expect_error(sdv_bins(1e300, 0, shape = "square", side = 1e-10), "overflows")
})

test_that("a data_id mapped in ggplot() wins over the cell id", {
  skip_if_not_installed("ggiraph")
  d <- data.frame(x = c(0, 1, 30), y = c(0, 1, 30), g = c("a", "b", "c"))
  layer_id <- ggplot2::layer_data(ggplot2::ggplot(d, ggplot2::aes(x, y)) + geom_sdv_bins_interactive(radius = 5))
  expect_true(all(grepl(",", layer_id$data_id))) # the cell ids by default
  own <- ggplot2::layer_data(
    ggplot2::ggplot(d, ggplot2::aes(x, y, data_id = ggplot2::after_stat(paste0("bin-", count)))) +
      geom_sdv_bins_interactive(radius = 5)
  )
  expect_true(all(startsWith(own$data_id, "bin-")))
})

test_that("origin shifts the lattice so a cell is centred on it; ids stay absolute", {
  # integer shots and an integer origin, so x + 3 - 3 is x exactly: the same cells, moved
  b <- sdv_bins(oracle$x_legacy, oracle$y_legacy, radius = 15)
  moved <- sdv_bins(oracle$x_legacy + 3, oracle$y_legacy - 40, radius = 15, origin = c(3, -40))
  expect_identical(moved$count, b$count)
  expect_identical(moved$x, b$x + 3)
  expect_identical(moved$y, b$y - 40)
  expect_identical(moved$cell_id, paste0(js_number(b$x + 3), ",", js_number(b$y - 40)))
  # a hoop-centred lattice: the hoop's cell is centred on the hoop, for either shape
  for (args in list(list(radius = 1), list(shape = "square", side = 1))) {
    ids <- do.call(sdv_bin_ids, c(list(c(0, 0.2, 5), c(5.25, 5.4, 5.25)), args, list(origin = c(0, 5.25))))
    expect_identical(ids[1:2], c("0,5.25", "0,5.25"))
  }
  expect_identical(sdv_bin_ids(0, 5.25, shape = "square", side = 1), "0,5")
  expect_identical(
    sdv_bin_ids(oracle$x_legacy, oracle$y_legacy, radius = 10, origin = c(0, 0)), oracle$hex10
  )
  expect_error(sdv_bins(1, 1, radius = 1, origin = 0), "origin")
  expect_error(sdv_bin_ids(1, 1, radius = 1, origin = c(0, NA)), "origin")
  expect_error(geom_sdv_bins(radius = 1, origin = "hoop"), "origin")
})

test_that("weights sum per cell; missing or non-finite ones count 0 but the point stays binned", {
  b <- sdv_bins(oracle$x_legacy, oracle$y_legacy, radius = 15)
  expect_identical(b$weight, as.double(b$count))
  w <- oracle$x_legacy %% 3 + 1
  bw <- sdv_bins(oracle$x_legacy, oracle$y_legacy, radius = 15, weights = w)
  expect_identical(bw$count, b$count)
  expect_equal(bw$weight, vapply(bw$rows, function(r) sum(w[r]), numeric(1)))
  bad <- sdv_bins(c(0, 1, 2, 3, NA), c(0, 1, 2, 3, 0), radius = 10, weights = c(2, NA, Inf, NaN, 5))
  expect_identical(bad$count, 4L)
  expect_identical(bad$weight, 2)
  expect_error(sdv_bins(1:2, 1:2, radius = 1, weights = 1), "weights")
  expect_error(sdv_bins(1:2, 1:2, radius = 1, weights = c("a", "b")), "weights")
})

test_that("geom_sdv_bins takes origin and a weight aesthetic", {
  shots$pts <- ifelse(abs(shots$x) > 220 | shots$y > 237, 3, 2)
  shots$pts[1:2] <- c(NA, Inf)
  p <- ggplot2::ggplot(shots, ggplot2::aes(x, y, weight = pts)) +
    geom_sdv_bins(shape = "square", side = 15, origin = c(0, 52.5))
  expect_no_warning(d <- ggplot2::layer_data(p))
  b <- sdv_bins(shots$x, shots$y, shape = "square", side = 15, origin = c(0, 52.5), weights = shots$pts)
  expect_identical(d$cell_id, b$cell_id)
  expect_identical(d$count, b$count)
  expect_identical(d$weight, b$weight)
  expect_equal(d$density, b$weight / sum(b$weight))
  expect_identical(sum(d$count), 2000L)
  # fill stays the count; after_stat(weight) fills by the weight
  expect_identical(d$fill, ggplot2::layer_data(ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins(shape = "square", side = 15, origin = c(0, 52.5)))$fill)
  pw <- ggplot2::ggplot(shots, ggplot2::aes(x, y, weight = pts)) +
    geom_sdv_bins(ggplot2::aes(fill = ggplot2::after_stat(weight)), radius = 15)
  expect_identical(ggplot2::layer_data(pw)$weight, sdv_bins(shots$x, shots$y, radius = 15, weights = shots$pts)$weight)
  skip_if_not_installed("ggiraph")
  pi <- ggplot2::ggplot(shots, ggplot2::aes(x, y, weight = pts)) + geom_sdv_bins_interactive(radius = 15, origin = c(1, 1))
  expect_no_warning(di <- ggplot2::layer_data(pi))
  expect_identical(di$data_id, sdv_bins(shots$x, shots$y, radius = 15, origin = c(1, 1))$cell_id)
})

test_that("ggplotly links cells and points through a highlight_key on the cell id", {
  skip_if_not_installed("plotly")
  shots$cell_id <- sdv_bin_ids(shots$x, shots$y, radius = 15, origin = c(0, 5))
  p <- ggplot2::ggplot(plotly::highlight_key(shots, ~cell_id), ggplot2::aes(x, y)) +
    geom_sdv_bins(radius = 15, origin = c(0, 5)) +
    ggplot2::geom_point()
  built <- plotly::plotly_build(plotly::highlight(plotly::ggplotly(p), on = "plotly_click", off = "plotly_doubleclick"))$x$data
  cells <- Filter(function(t) identical(t$fill, "toself"), built)
  points <- Filter(function(t) identical(t$mode, "markers") && !is.null(t$key), built)[[1]]
  # one trace per cell, hovered on its fill, keyed by its own cell id, in the points' crosstalk set
  expect_length(cells, length(unique(shots$cell_id)))
  expect_true(all(vapply(cells, function(t) isTRUE(t[["_isSimpleKey"]]) && t$hoveron == "fills", logical(1))))
  expect_setequal(vapply(cells, function(t) t$key[[1]], ""), shots$cell_id)
  expect_identical(unique(vapply(cells, function(t) t$set, "")), points$set)
  expect_setequal(as.character(points$key), shots$cell_id)
  # without crosstalk data the cells carry no key
  plain <- plotly::plotly_build(plotly::ggplotly(ggplot2::ggplot(shots, ggplot2::aes(x, y)) + geom_sdv_bins(radius = 15)))
  expect_true(all(vapply(plain$x$data, function(t) is.null(t$key), logical(1))))
})

test_that("cell_fill shrinks the drawn squares (0.88 by default), never the lattice; hexagons tile at 1", {
  drawn_width <- function(...) {
    d <- ggplot2::layer_data(ggplot2::ggplot(shots, ggplot2::aes(x, y)) + geom_sdv_bins(...))
    poly <- cell_polygons(d)
    list(d = d, w = as.vector(tapply(poly$x, poly$group, function(v) max(v) - min(v))))
  }
  sq <- drawn_width(shape = "square", side = 15)
  # the drawn squares never reach the cell side, so neighbours never touch
  expect_true(all(sq$w < 15 - 1e-9))
  expect_equal(sq$w, rep(0.88 * 15, nrow(sq$d)))
  # the cells and the scales stay the lattice's
  expect_equal(sq$d$xmax - sq$d$xmin, rep(15, nrow(sq$d)))
  expect_identical(sq$d$count, sdv_bins(shots$x, shots$y, shape = "square", side = 15)$count)
  expect_equal(drawn_width(shape = "square", side = 15, cell_fill = 1)$w, rep(15, nrow(sq$d)))
  hex <- drawn_width(radius = 15)
  expect_equal(hex$w, rep(sqrt(3) * 15, nrow(hex$d))) # full-radius hexagons
  expect_equal(drawn_width(radius = 15, cell_fill = 0.5)$w, rep(sqrt(3) * 7.5, nrow(hex$d)))
  expect_error(geom_sdv_bins(radius = 1, cell_fill = 0), "cell_fill")
  expect_error(geom_sdv_bins(radius = 1, cell_fill = 1.5), "cell_fill")
  expect_error(geom_sdv_bins(radius = 1, min_count = NA), "min_count")
})

test_that("min_count leaves cells with fewer points out of the layer only", {
  all_cells <- sdv_bins(shots$x, shots$y, shape = "square", side = 15)
  expect_true(any(all_cells$count == 1))
  d <- ggplot2::layer_data(ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins(shape = "square", side = 15, min_count = 2))
  expect_identical(d$cell_id, all_cells$cell_id[all_cells$count >= 2])
  expect_true(all(d$count >= 2))
  # density stays each cell's share of all the points
  expect_equal(d$density, all_cells$count[all_cells$count >= 2] / 2000)
  expect_identical(nrow(ggplot2::layer_data(ggplot2::ggplot(shots, ggplot2::aes(x, y)) +
    geom_sdv_bins(shape = "square", side = 15))), nrow(all_cells))
})

test_that("an origin that pushes finite points past the double range is refused", {
  expect_error(sdv_bins(1e308, 0, radius = 1, origin = c(-1e308, 0)), "overflow")
  expect_error(sdv_bin_ids(0, -1e308, radius = 1, origin = c(0, 1e308)), "overflow")
})

test_that("a group whose weights sum to 0 has NaN density", {
  d <- ggplot2::layer_data(ggplot2::ggplot(shots, ggplot2::aes(x, y, weight = 0 * x)) +
    geom_sdv_bins(shape = "square", side = 15))
  expect_true(all(d$weight == 0))
  expect_true(all(is.nan(d$density)))
})
