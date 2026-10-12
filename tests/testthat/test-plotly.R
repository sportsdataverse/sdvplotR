skip_on_cran()
skip_if_not_installed("plotly")

base_plot <- function() {
  plotly::plot_ly(data.frame(x = 1:2, y = c(3, 5)), x = ~x, y = ~y, type = "scatter", mode = "markers")
}
built_images <- function(p) plotly::plotly_build(p)$x$layout$images

test_that("add_sdv_logos places one layout image per resolved team, in data units", {
  p <- add_sdv_logos(base_plot(), x = 1:2, y = c(3, 5), team = c("KC", "BUF"), league = "nfl")
  img <- built_images(p)
  expect_length(img, 2L)
  expect_identical(vapply(img, `[[`, "", "source"), sdv_logo_url(c("KC", "BUF"), "nfl"))
  expect_identical(img[[1]]$xref, "x")
  expect_equal(img[[1]]$sizey, 0.08 * 2)
})

test_that("marks are sized against the whole axis, not the values passed", {
  # logos for two of 101 plotted points: 8% of the axis the traces span (0-100), as sdvplot sizes them
  p <- plotly::plot_ly(x = 0:100, y = 0:100, type = "scatter", mode = "markers")
  img <- built_images(add_sdv_logos(p, c(40, 50), c(40, 50), c("KC", "BUF"), "nfl"))
  expect_equal(img[[1]]$sizey, 0.08 * 100)
  # a range set on the axis wins
  ranged <- plotly::layout(p, yaxis = list(range = c(0, 10)))
  expect_equal(built_images(add_sdv_logos(ranged, 40, 5, "KC", "nfl"))[[1]]$sizey, 0.08 * 10)
  # bars run from zero
  bars <- plotly::plot_ly(x = c("KC", "BUF"), y = c(5, 8), type = "bar")
  expect_equal(built_images(add_sdv_logos(bars, c("KC", "BUF"), c(5, 8), c("KC", "BUF"), "nfl"))[[1]]$sizey, 0.08 * 8)
})

test_that("calls accumulate, and unresolved teams are skipped with the resolver's warning", {
  p <- add_sdv_logos(base_plot(), 1, 3, "KC", "nfl")
  expect_warning(p <- add_sdv_logos(p, 1:2, 3:4, c("BUF", "nope"), "nfl"), class = "sdvplotR_unresolved_warning")
  expect_length(built_images(p), 2L)
})

test_that("categorical axes take category names", {
  p <- plotly::plot_ly(x = c("KC", "BUF"), y = 1:2, type = "bar")
  img <- built_images(add_sdv_logos(p, c("KC", "BUF"), 1:2, c("KC", "BUF"), "nfl"))
  expect_identical(img[[2]]$x, "BUF")
})

test_that("axis logos replace the tick labels", {
  p <- plotly::plot_ly(x = c("KC", "BUF"), y = 1:2, type = "bar")
  b <- plotly::plotly_build(sdv_axis_logos(p, c("KC", "BUF"), "nfl"))$x$layout
  expect_false(b$xaxis$showticklabels)
  expect_identical(b$images[[1]]$yref, "paper")
})

test_that("headshots and colorway", {
  img <- built_images(add_sdv_headshots(base_plot(), 1, 3, 3139477, "nfl"))
  expect_match(img[[1]]$source, "3139477")
  cw <- plotly::plotly_build(sdv_colorway(base_plot(), "nfl", c("KC", "BUF")))$x$layout$colorway
  expect_identical(unlist(cw), unname(sdv_color_palette("nfl", c("KC", "BUF"))))
})

user_image <- list(source = "https://example.com/u.png", xref = "paper", yref = "paper", x = 0, y = 0)

test_that("images the user set with layout() are kept, before or after, and chained calls accumulate", {
  p <- plotly::layout(base_plot(), images = list(user_image))
  p <- add_sdv_logos(p, 1, 3, "KC", "nfl")
  p <- add_sdv_logos(p, 2, 5, "BUF", "nfl")
  img <- built_images(p)
  expect_length(img, 3L)
  expect_identical(img[[1]]$source, user_image$source)
  expect_identical(
    vapply(img[-1], `[[`, "", "source"), sdv_logo_url(c("KC", "BUF"), "nfl")
  )

  q <- sdv_axis_logos(plotly::layout(plotly::plot_ly(x = c("KC", "BUF"), y = 1:2, type = "bar"),
    images = list(user_image)), c("KC", "BUF"), "nfl")
  expect_length(built_images(q), 3L)
})

test_that("two chained add_sdv_logos() calls give both sets", {
  p <- add_sdv_logos(add_sdv_logos(base_plot(), 1, 3, "KC", "nfl"), 2, 5, "BUF", "nfl")
  expect_length(built_images(p), 2L)
})

test_that("date axes abort", {
  expect_error(add_sdv_logos(base_plot(), as.Date("2026-01-01"), 3, "KC", "nfl"), "Date axes")
  expect_error(add_sdv_logos(base_plot(), 1, Sys.time(), "KC", "nfl"), "Date axes")
})

test_that("sdv_axis_logos keeps numeric axis values numeric", {
  p <- plotly::plot_ly(x = c(12, 2), y = 1:2, type = "bar")
  img <- plotly::plotly_build(sdv_axis_logos(p, c(12, 2), "nfl"))$x$layout$images
  expect_identical(img[[1]]$x, 12)
})
