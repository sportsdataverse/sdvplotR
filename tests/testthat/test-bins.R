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
