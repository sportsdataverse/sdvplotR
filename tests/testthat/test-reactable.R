test_that("reactable cell renderers return img tags or the raw value", {
  f <- reactable_sdv_logos("nfl", variant = "dark", height = 20)
  expect_match(f("KC", 1), "^<img src=\"https://.*500-dark/kc\\.png\" style=\"height:20px;")
  expect_identical(f("nope", 2), "nope")
  expect_identical(
    reactable_sdv_logos("nfl", default_img = "x.png")("nope", 1),
    "<img src=\"x.png\" style=\"height:30px;vertical-align:middle;\" alt=\"nope\" />"
  )
  expect_match(reactable_sdv_wordmarks("nfl")("KC", 1), "wordmarks/KC\\.png")
  expect_match(reactable_sdv_headshots("cfb")("3917315", 1), "college-football")
  expect_identical(reactable_sdv_headshots("cfb")("abc", 1), "abc")
})

test_that("team colour styles index rows of the supplied data", {
  d <- data.frame(team = c("KC", "BUF", "zz"), wins = c(13, 12, 1))
  bar <- reactable_sdv_team_color_bar(d, "team", sport = "nfl")
  expect_identical(
    bar(13, 1, "wins"),
    "background-image:linear-gradient(90deg, #E31837 100%, transparent 100%);"
  )
  expect_match(bar(1, 3, "wins"), "grey70 7\\.7%")
  expect_match(reactable_sdv_team_color_bar(d, "team", sport = "nfl", max_value = 26)(13, 1, "wins"), " 50%")
  expect_match(bar(NA, 1, "wins"), " 0%")
  bg <- reactable_sdv_team_color_bg(d, "team", sport = "nfl", alpha = 0.5)
  expect_identical(bg(13, 1, "wins"), "background-color:#E3183780;")
  expect_snapshot(reactable_sdv_team_color_bg(d, "club", sport = "nfl"), error = TRUE)
})

test_that("reactable_sdv_cols_label builds colDefs for resolvable columns", {
  skip_if_not_installed("reactable")
  cols <- reactable_sdv_cols_label(data.frame(KC = 1, BUF = 2, other = 3), sport = "nfl", height = 18)
  expect_named(cols, c("KC", "BUF"))
  expect_s3_class(cols$KC, "colDef")
  expect_match(cols$KC$header, "kc\\.png\" style=\"height:18px;\"")
})

test_that("reactable_sdv_headshots passes id_type through", {
  expect_match(reactable_sdv_headshots("wnba", id_type = "league")("1642286", 1), "cdn\\.wnba\\.com/.*/1642286\\.png")
  expect_match(reactable_sdv_headshots("nba")("1966", 1), "a\\.espncdn\\.com/.*/nba/players/full/1966\\.png")
})
