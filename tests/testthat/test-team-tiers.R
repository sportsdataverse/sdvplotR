skip_on_cran()

test_that("sdv_team_factor keeps input values, orders by abbreviation, drops non-teams", {
  f <- suppressWarnings(sdv_team_factor(c("Kansas City Chiefs", "BUF", "nope"), "nfl"))
  expect_s3_class(f, "factor")
  expect_identical(levels(f), c("BUF", "Kansas City Chiefs"))
  expect_true(is.na(f[3]))
})

test_that("sdv_team_tiers draws minor-league teams and dated marks", {
  d <- data.frame(tier_no = c(1, 2), team = sdv_teams("echl")$team_id[1:2])
  expect_s3_class(sdv_team_tiers(d, "echl"), "ggplot")
  p <- sdv_team_tiers(data.frame(tier_no = 1, team = "QUE"), "nhl", season = 1990, theme = "light")
  paths <- unlist(lapply(ggplot2::ggplot_build(p)$data, function(l) l$path))
  expect_true(sdv_logo_url("QUE", "nhl", season = 1990) %in% paths)
})
