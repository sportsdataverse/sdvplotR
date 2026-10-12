skip_on_cran()
skip_if_not_installed("ggiraph")

test_that("interactive logos are the image layer plus an invisible hover layer", {
  d <- data.frame(x = 1:2, y = 1:2, t = c("KC", "BUF"))
  ls <- geom_sdv_logos_interactive(ggplot2::aes(x, y, team = t, tooltip = t, data_id = t), data = d, league = "nfl")
  expect_length(ls, 2L)
  expect_s3_class(ls[[1]]$geom, "GeomSDVlogo")
  expect_true(inherits(ls[[2]]$geom, "GeomInteractivePoint"))
  expect_false(any(c("tooltip", "data_id") %in% names(ls[[1]]$mapping)))
  expect_false("team" %in% names(ls[[2]]$mapping))
  expect_identical(ls[[2]]$aes_params$alpha, 0)
  p <- ggplot2::ggplot(d) + ls
  expect_s3_class(ggplot2::ggplot_build(p), "ggplot_built")
})

test_that("headshot hover layers drop player_id", {
  ls <- geom_sdv_headshots_interactive(ggplot2::aes(1, 1, player_id = 3139477, tooltip = "x"), league = "nfl")
  expect_false("player_id" %in% names(ls[[2]]$mapping))
})
