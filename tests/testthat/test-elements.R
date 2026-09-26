library(ggplot2)

test_that("element constructors return theme elements with the sport recorded", {
  e <- element_sdv_logo(sport = "nba", size = 1, color = "b/w")
  expect_s3_class(e, c("element_sdv_logo", "element_text", "element"))
  expect_identical(e$sport, "nba")
  expect_identical(e$colour, "b/w")
  expect_s3_class(element_sdv_wordmark(sport = "nfl"), "element_sdv_wordmark")
  expect_s3_class(element_sdv_headshot(sport = "cfb"), "element_sdv_headshot")
  expect_snapshot(element_sdv_logo(sport = "xfl"), error = TRUE)
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
    theme(axis.text.x = element_sdv_logo(sport = "nfl", size = 0.8))
  expect_s3_class(ggplot_gtable(ggplot_build(p)), "gtable")
})

test_that("element_sdv_headshot records and uses id_type", {
  e <- element_sdv_headshot("nba", id_type = "league")
  expect_identical(e$id_type, "league")
  expect_null(element_sdv_headshot("nba")$id_type)
  seen <- NULL
  local_mocked_bindings(
    headshot_from_id = function(player_id, sport, id_type = NULL) {
      seen <<- id_type
      rep(NA_character_, length(player_id))
    },
    .package = "sdvplotR"
  )
  element_grob(e, label = "2544")
  expect_identical(seen, "league")
  expect_error(element_sdv_headshot("wbb", id_type = "league"), "league player ID")
})
