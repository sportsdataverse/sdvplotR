skip_on_cran()

library(ggplot2)

test_that("element constructors return theme elements with the league recorded", {
  e <- element_sdv_logo(league = "nba", size = 1, color = "b/w")
  expect_s3_class(e, c("element_sdv_logo", "element_text", "element"))
  expect_identical(e$league, "nba")
  expect_identical(e$colour, "b/w")
  expect_s3_class(element_sdv_wordmark(league = "nfl"), "element_sdv_wordmark")
  expect_s3_class(element_sdv_headshot(league = "cfb"), "element_sdv_headshot")
  expect_error(element_sdv_logo(league = "xyz"), "Unknown league")
})

test_that("element_grob returns zeroGrob for NULL labels", {
  expect_s3_class(element_grob(element_sdv_logo("nfl"), label = NULL), "zeroGrob")
  expect_s3_class(element_grob(element_sdv_headshot("nfl"), label = NULL), "zeroGrob")
})

test_that("element_sdv_raster wraps ggpath::element_raster", {
  e <- element_sdv_raster("https://example.com/x.png")
  expect_identical(class(e), class(ggpath::element_raster("https://example.com/x.png")))
})

test_that("logo axis elements render through ggpath", {
  skip_on_cran()
  skip_if_offline()
  df <- data.frame(team = c("KC", "BUF"), y = 1:2)
  p <- ggplot(df, aes(team, y)) +
    geom_col() +
    theme(axis.text.x = element_sdv_logo(league = "nfl", size = 0.8))
  expect_s3_class(ggplot_gtable(ggplot_build(p)), "gtable")
})

test_that("image axis text set on axis.text.x / .y survives theme_minimal()'s position children", {
  # theme_minimal() sets axis.text.x.bottom / axis.text.y.left itself, and in
  # ggplot2 4 the child renders: it has to come out as the image element
  els <- list(
    element_sdv_logo = element_sdv_logo("nba"),
    element_sdv_wordmark = element_sdv_wordmark("nfl"),
    element_sdv_headshot = element_sdv_headshot("nba", id_system = "league")
  )
  for (cls in names(els)) {
    th <- theme_minimal() + theme(axis.text.x = els[[cls]], axis.text.y = els[[cls]])
    for (child in c("axis.text.x.bottom", "axis.text.x.top", "axis.text.y.left", "axis.text.y.right")) {
      el <- calc_element(child, th)
      expect_s3_class(el, cls)
      expect_identical(el@league, els[[cls]]@league)
    }
    # and keeps the child's own spacing
    expect_identical(
      calc_element("axis.text.x.bottom", th)@margin,
      calc_element("axis.text.x.bottom", theme_minimal())@margin
    )
  }
  expect_identical(calc_element("axis.text.y.left", th)@id_system, "league")

  img <- withr::local_tempfile(fileext = ".png")
  grDevices::png(img, width = 20, height = 20)
  grid::grid.rect(gp = grid::gpar(fill = "red"))
  grDevices::dev.off()
  local_mocked_bindings(logo_from_team = function(team, league, ...) rep(img, length(team)), .package = "sdvplotR")
  axis_grob_classes <- function(p, side) {
    g <- ggplotGrob(p)
    ax <- g$grobs[[which(g$layout$name == side)]]
    unlist(lapply(ax$children, function(ch) if (inherits(ch, "gtable")) lapply(ch$grobs, function(x) class(x)[1])))
  }
  withr::local_pdf(withr::local_tempfile(fileext = ".pdf"))
  df <- data.frame(team = c("KC", "BUF"), v = 1:2)
  px <- ggplot(df, aes(team, v)) + geom_col() + theme_minimal() + theme(axis.text.x = element_sdv_logo("nfl"))
  expect_true("ggpath_element" %in% axis_grob_classes(px, "axis-b"))
  py <- ggplot(df, aes(v, team)) + geom_col() + theme_minimal() + theme(axis.text.y = element_sdv_logo("nfl"))
  expect_true("ggpath_element" %in% axis_grob_classes(py, "axis-l"))
})

test_that("element_sdv_headshot records and uses id_system", {
  e <- element_sdv_headshot("nba", id_system = "league")
  expect_identical(e$id_system, "league")
  expect_identical(element_sdv_headshot("nba")$id_system, "espn")
  seen <- NULL
  local_mocked_bindings(
    headshot_from_id = function(player_id, league, id_system = "espn") {
      seen <<- id_system
      rep(NA_character_, length(player_id))
    },
    .package = "sdvplotR"
  )
  element_grob(e, label = "2544")
  expect_identical(seen, "league")
  expect_error(element_sdv_headshot("wbb", id_system = "league"), "league player id")
})
