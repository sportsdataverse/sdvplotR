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
