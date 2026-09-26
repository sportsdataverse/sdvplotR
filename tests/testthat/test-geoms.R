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
  local_headshot_map()
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
  # tier_desc is keyed by tier number, not position (non-contiguous tiers)
  gap <- data.frame(tier_no = c(1, 3), team = c("KC", "SF"))
  p2 <- sdv_team_tiers(gap, sport = "nfl", devel = TRUE, tier_desc = c("1" = "Elite", "3" = "Rebuild"))
  labs <- ggplot_build(p2)$layout$panel_params[[1]]$y$get_labels()
  expect_false(anyNA(labs))
  expect_true(all(c("Elite", "Rebuild") %in% labs))
})

test_that("headshot geom and scales pass id_type through", {
  df <- data.frame(x = 1:2, y = 1:2, id = c("2544", "201939"))
  p <- ggplot(df, aes(x, y)) + geom_sdv_headshots(aes(player_id = id), sport = "nba", id_type = "league")
  seen <- NULL
  local_mocked_bindings(
    headshot_from_id = function(player_id, sport, id_type = NULL) {
      seen <<- id_type
      rep(NA_character_, length(player_id))
    },
    .package = "sdvplotR"
  )
  suppressWarnings(layer_grob(p))
  expect_identical(seen, "league")
  expect_error(geom_sdv_headshots(sport = "cfb", id_type = "league"), "league player ID")
})

test_that("headshot axis scales pass id_type through", {
  sx <- scale_x_sdv_headshots(sport = "mlb", id_type = "league")
  expect_match(sx$labels("660271"), "img\\.mlbstatic\\.com/.*/people/660271/.*height = '20'")
})

test_that("color scales accept every key clean_team_abbrs() accepts", {
  pal <- scale_fill_sdv(sport = "mlb")$palette(0)
  expect_identical(pal[["AZ"]], pal[["ARI"]]) # MLB Stats API alias
  expect_identical(pal[["CWS"]], pal[["CHW"]])
  expect_identical(pal[["MON"]], pal[["WSH"]]) # historical (Expos)
  expect_identical(scale_color_sdv(sport = "nba")$palette(0)[["GSW"]], get_team_colors("nba")[["GS"]])
  # a canonical abbreviation keeps its own team's color
  expect_identical(unname(pal[names(get_team_colors("mlb"))[1:30]]), unname(get_team_ref("mlb")$color1[match(names(get_team_colors("mlb"))[1:30], get_team_ref("mlb")$team_abbr)]))
  df <- data.frame(team = c("AZ", "CWS"), v = 1:2)
  built <- ggplot_build(ggplot(df, aes(team, v, fill = team)) + geom_col() + scale_fill_sdv(sport = "mlb"))
  expect_false(any(built$data[[1]]$fill == "grey50"))
})

test_that("axis logo themes survive a complete theme added before them", {
  skip_if_not_installed("ggtext")
  df <- data.frame(t = c("**a**", "*b*"), v = 1:2)
  axis_grob_classes <- function(p, side) {
    g <- ggplotGrob(p)
    ax <- g$grobs[[which(g$layout$name == side)]]
    unlist(lapply(ax$children, function(ch) if (inherits(ch, "gtable")) lapply(ch$grobs, function(x) class(x)[1])))
  }
  px <- ggplot(df, aes(t, v)) + geom_col() + theme_minimal() + theme_x_sdv()
  expect_true("richtext_grob" %in% axis_grob_classes(px, "axis-b"))
  py <- ggplot(df, aes(v, t)) + geom_col() + theme_minimal() + theme_y_sdv()
  expect_true("richtext_grob" %in% axis_grob_classes(py, "axis-l"))
})
