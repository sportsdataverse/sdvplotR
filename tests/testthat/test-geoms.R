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

test_that("ggtitle_image draws the image beside the title, centred on the text", {
  skip_if_not_installed("ggtext")
  img <- withr::local_tempfile(fileext = ".png")
  grDevices::png(img, width = 20, height = 20)
  grid::grid.rect(gp = grid::gpar(fill = "red"))
  grDevices::dev.off()
  # the image box and the text glyphs of the title, in the title's own points
  title_parts <- function(side, height) {
    p <- ggplot(mtcars, aes(hp, mpg)) +
      ggtitle_image(img, "Title text", image_height = height, image_side = side, sport = "nfl") +
      theme_title_image(size = 15)
    g <- ggplotGrob(p)
    box <- g$grobs[[which(g$layout$name == "title")]]$children[[1]]
    is_img <- vapply(box$children, inherits, logical(1), "rastergrob")
    pt <- function(u) grid::convertUnit(u, "pt", valueOnly = TRUE)
    img_grob <- box$children[is_img][[1]]
    # gridtext also leaves empty text boxes around the image
    txt <- Filter(function(t) nzchar(trimws(t$label)), box$children[!is_img])
    list(
      img_x = pt(img_grob$x), img_mid = pt(img_grob$y) + pt(img_grob$height) / 2,
      txt_x = vapply(txt, function(t) pt(t$x), 1), txt_y = vapply(txt, function(t) pt(t$y), 1)
    )
  }
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  cap <- grid::convertHeight(grid::grobHeight(grid::textGrob("H", gp = grid::gpar(fontsize = 15))), "pt", valueOnly = TRUE)
  for (h in c(30, 8)) {
    left <- title_parts("left", h)
    expect_true(all(left$img_x < left$txt_x)) # on the same line, before the text
    expect_equal(left$img_mid, unique(left$txt_y) + cap / 2, tolerance = 1e-6)
    right <- title_parts("right", h)
    expect_true(all(right$img_x > right$txt_x))
    expect_equal(right$img_mid, unique(right$txt_y) + cap / 2, tolerance = 1e-6)
  }
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

test_that("sdv_team_tiers draws a light theme for dark logos", {
  tiers <- data.frame(tier_no = c(1, 2), team = c("KC", "SF"))
  look <- function(p) {
    th <- ggplot2:::plot_theme(p)
    list(
      bg = calc_element("plot.background", th)$fill,
      title = calc_element("plot.title", th)$colour,
      label = calc_element("axis.text.y.left", th)$colour,
      sub = calc_element("plot.subtitle", th)$colour,
      line = p$layers[[1]]$aes_params$colour,
      text = p$layers[[2]]$aes_params$colour
    )
  }
  dark <- look(sdv_team_tiers(tiers, sport = "nfl", devel = TRUE))
  expect_identical(dark$bg, "#1e1e1e")
  expect_identical(dark$label, "white")
  light <- look(sdv_team_tiers(tiers, sport = "nfl", devel = TRUE, theme = "light"))
  expect_identical(light$bg, "#ffffff")
  # every label and line is dark on the white background
  for (col in light[c("title", "label", "sub", "line", "text")]) {
    expect_lt(sum(grDevices::col2rgb(col)), 3 * 128)
  }
  expect_error(sdv_team_tiers(tiers, sport = "nfl", theme = "blue"), "theme")
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

test_that("geom_sdv_logos passes the season aesthetic to the resolver", {
  df <- data.frame(x = 1:2, y = 1:2, team = c("QUE", "COL"), season = c(1990, NA))
  seen <- list()
  local_mocked_bindings(
    logo_from_team = function(team, sport, season = NULL) {
      seen[[length(seen) + 1]] <<- season
      rep(NA_character_, length(team))
    },
    .package = "sdvplotR"
  )
  suppressWarnings(layer_grob(ggplot(df, aes(x, y)) + geom_sdv_logos(aes(team = team, season = season), sport = "nhl")))
  suppressWarnings(layer_grob(ggplot(df, aes(x, y)) + geom_sdv_logos(aes(team = team), sport = "nhl")))
  expect_identical(seen[[1]], c(1990, NA))
  expect_identical(seen[[2]], c(NA, NA))
})

test_that("geom_sdv_logos draws period marks with and without a season", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not_installed("rsvg")
  df <- data.frame(x = 1:2, y = 1, team = c("QUE", "HFD"), season = c(1990, 1995))
  for (m in list(aes(team = team, season = season), aes(team = team))) {
    expect_no_warning(g <- layer_grob(ggplot(df, aes(x, y)) + geom_sdv_logos(m, sport = "nhl"))[[1]])
    expect_true(all(vapply(g$children, inherits, logical(1), "rastergrob")))
  }
})
