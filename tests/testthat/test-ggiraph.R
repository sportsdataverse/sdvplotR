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

test_that("interactive geoms embed small copies of the images", {
  # ggiraph writes each image into the page: the image layer asks for copies at most max_px a side
  ls <- geom_sdv_logos_interactive(ggplot2::aes(1, 1, team = "KC", tooltip = "KC"), league = "nfl")
  expect_identical(ls[[1]]$geom_params$max_px, 160)
  expect_null(geom_sdv_logos_interactive(ggplot2::aes(1, 1, team = "KC"), league = "nfl", max_px = NULL)[[1]]$geom_params$max_px)
  expect_null(geom_sdv_logos(ggplot2::aes(1, 1, team = "KC"), league = "nfl")$geom_params$max_px)

  src <- tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(500, 250, "red"), src, format = "png")
  small <- small_image(src, 160)
  info <- magick::image_info(magick::image_read(small))
  expect_identical(c(info$width, info$height), c(160L, 80L))
  expect_identical(small_image(src, 160), small) # made once per image and size
  expect_identical(small_image(file.path(tempdir(), "no-such-image.png"), 160), file.path(tempdir(), "no-such-image.png"))
})

test_that("axis-label images are copies at most 4 x the label size, with forward slashes", {
  # an SVG device (ggiraph, svglite) writes each label image into the file
  src <- tempfile(fileext = ".png")
  magick::image_write(magick::image_blank(500, 500, "blue"), src, format = "png")
  html <- img_html(c(src, NA), c("A", "B"), "width", 12)
  expect_identical(html[[2]], "B")
  path <- sub("^<img src='([^']+)'.*", "\\1", html[[1]])
  expect_false(grepl("\\", path, fixed = TRUE))
  expect_match(html[[1]], "width = '12'", fixed = TRUE)
  expect_identical(magick::image_info(magick::image_read(path))$width, 48L)
})

test_that("interactive wordmarks are the wordmark layer plus an invisible hover layer", {
  d <- data.frame(x = 1:2, y = 1:2, t = c("KC", "BUF"))
  ls <- geom_sdv_wordmarks_interactive(ggplot2::aes(x, y, team = t, tooltip = t, data_id = t), data = d, league = "nfl")
  expect_length(ls, 2L)
  expect_s3_class(ls[[1]]$geom, "GeomSDVwordmark")
  expect_true(inherits(ls[[2]]$geom, "GeomInteractivePoint"))
  expect_identical(ls[[1]]$geom_params$max_px, 160)
  expect_s3_class(ggplot2::ggplot_build(ggplot2::ggplot(d) + ls), "ggplot_built")
})
