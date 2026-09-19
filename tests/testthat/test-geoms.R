library(ggplot2)

df <- data.frame(
  x = 1:3, y = 3:1, team = c("KC", "BUF", "SF"),
  id = c("00-0033873", "00-0026498", "bad")
)

test_that("geoms build ggplot layers that resolve paths at draw time", {
  p <- ggplot(df, aes(x, y)) + geom_sdv_logos(aes(team = team), sport = "nfl")
  expect_s3_class(p, "ggplot")
  expect_s3_class(p$layers[[1]]$geom, "GeomSDVlogo")
  b <- ggplot_build(p)
  expect_in(c("team", "x", "y"), names(b$data[[1]]))

  p2 <- ggplot(df, aes(x, y)) + geom_sdv_wordmarks(aes(team = team), sport = "nfl")
  expect_s3_class(p2$layers[[1]]$geom, "GeomSDVwordmark")
  p3 <- ggplot(df, aes(x, y)) + geom_sdv_headshots(aes(player_id = id), sport = "nfl")
  expect_s3_class(p3$layers[[1]]$geom, "GeomSDVheadshot")
})

test_that("geoms validate the sport argument", {
  expect_snapshot(geom_sdv_logos(sport = "xfl"), error = TRUE)
})

test_that("color and fill scales carry team colours", {
  sc <- scale_color_sdv(sport = "nfl")
  expect_s3_class(sc, "Scale")
  expect_identical(sc$aesthetics, "colour")
  expect_identical(unname(sc$palette(0)["KC"]), unname(sdv_team_colors("nfl", "KC")))
  sf <- scale_fill_sdv(sport = "nba", type = "secondary", alpha = 0.5)
  expect_identical(sf$aesthetics, "fill")
  expect_match(sf$palette(0)[1], "^#[0-9A-F]{8}$")
  expect_identical(scale_colour_sdv, scale_color_sdv)
})

test_that("axis scales produce image labels", {
  sx <- scale_x_sdv(sport = "nfl", size = 20)
  expect_s3_class(sx, "ScaleDiscretePosition")
  expect_match(sx$labels(c("KC", "BUF")), "^<img src='https://.*height = '20'>$")
  sy <- scale_y_sdv_headshots(sport = "nfl")
  expect_match(sy$labels("00-0033873"), "width = '30'")
})

test_that("theme helpers require ggtext and return theme objects", {
  skip_if_not_installed("ggtext")
  expect_s3_class(theme_x_sdv(), "theme")
  expect_s3_class(theme_y_sdv(), "theme")
  expect_s3_class(theme_title_image(size = 10), "theme")
})

test_that("ggtitle_image resolves team logos and places the image", {
  l <- ggtitle_image("KC", "Chiefs", sport = "nfl")
  expect_match(l$title, "^<img src='https://.*kc\\.png' height='15'.*> Chiefs$")
  r <- ggtitle_image("https://example.com/x.png", "T", image_side = "right", sport = "nba")
  expect_match(r$title, "^T <img src='https://example.com/x.png'")
  expect_error(ggtitle_image(sport = "nfl"), "title_image")
  expect_match(ggtitle_image("KC", sport = "nfl")$title, "^<img")
})

test_that("sdv_team_tiers builds a plot and validates input", {
  tiers <- data.frame(tier_no = c(1, 1, 2, 3), team = c("KC", "BUF", "SF", "DAL"))
  p <- sdv_team_tiers(tiers, sport = "nfl", devel = TRUE)
  expect_s3_class(p, "ggplot")
  expect_s3_class(ggplot_gtable(ggplot_build(p)), "gtable")
  expect_snapshot(sdv_team_tiers(data.frame(team = "KC"), sport = "nfl"), error = TRUE)
})
