test_that("reactable cell renderers return img tags or the raw value", {
  f <- reactable_sdv_logos("nfl", variant = "dark", height = 20)
  expect_match(f("KC", 1), paste0("<img src=\"", resolve_logo_url("KC", "nfl", "dark"), "\" style=\"height:20px;"), fixed = TRUE)
  expect_match(f("KC", 1), "^<img src=\"https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
  expect_identical(f("nope", 2), "nope")
  expect_identical(
    reactable_sdv_logos("nfl", default_img = "x.png")("nope", 1),
    "<img src=\"x.png\" style=\"height:30px;vertical-align:middle;\" alt=\"nope\" />"
  )
  expect_match(reactable_sdv_wordmarks("nfl")("KC", 1), wordmark_from_team("KC", "nfl"), fixed = TRUE)
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
  expect_match(cols$KC$header, paste0(logo_from_team("KC", "nfl"), "\" style=\"height:18px;\""), fixed = TRUE)
})

test_that("reactable_sdv_headshots passes id_type through", {
  expect_match(reactable_sdv_headshots("wnba", id_type = "league")("1642286", 1), "cdn\\.wnba\\.com/.*/1642286\\.png")
  expect_match(reactable_sdv_headshots("nba")("1966", 1), "a\\.espncdn\\.com/.*/nba/players/full/1966\\.png")
})

test_that("reactable image helpers alt-name the team or the player id", {
  alt <- function(x) sub('.*alt="([^"]*)".*', "\\1", x)
  expect_identical(alt(reactable_sdv_logos("nfl")("KC", 1)), "Kansas City Chiefs")
  expect_identical(alt(reactable_sdv_wordmarks("nfl")("KC", 1)), "Kansas City Chiefs")
  expect_identical(alt(reactable_sdv_headshots("cfb")("3917315", 1)), "Player 3917315 headshot")
  skip_if_not_installed("reactable")
  cols <- reactable_sdv_cols_label(data.frame(KC = 1, BUF = 2), sport = "nfl")
  expect_identical(alt(cols$KC$header), "Kansas City Chiefs")
  expect_identical(alt(cols$BUF$header), "Buffalo Bills")
})

test_that("a logo variant falls back to the primary logo when it fails to load", {
  # an NFL team whose dark mark is a different file from its primary (the
  # Texans' is ESPN's primary re-encoded, so the archive holds one copy)
  m <- logo_marks[logo_marks$sport == "nfl" & logo_marks$type == "logo", ]
  team <- m$key[m$variant == "dark" & !m$url %in% m$url[m$variant == "primary"]][[1]]
  primary <- logo_from_team(team, "nfl")
  h <- reactable_sdv_logos("nfl", variant = "dark")(team, 1)
  expect_match(h, resolve_logo_url(team, "nfl", "dark"), fixed = TRUE)
  expect_match(h, paste0(" onerror=\"this.onerror=null;this.src=&#39;", primary, "&#39;\""), fixed = TRUE)
  # the primary logo has nothing to fall back to
  expect_no_match(reactable_sdv_logos("nfl")(team, 1), "onerror", fixed = TRUE)
  # a dark mark that is the same file as the primary has nothing to fall back to either
  expect_no_match(reactable_sdv_logos("nfl", variant = "dark")("HOU", 1), "onerror", fixed = TRUE)
  # a key the data has no dark logo for (a conference) gets the primary outright
  no_dark <- logo_ref$team_abbr[logo_ref$sport == "cfb" & is.na(logo_ref$logo_dark_url)][[1]]
  expect_identical(resolve_logo_url(no_dark, "cfb", "dark"), logo_from_team(no_dark, "cfb"))
  expect_no_match(reactable_sdv_logos("cfb", variant = "dark")(no_dark, 1), "onerror", fixed = TRUE)
  skip_if_not_installed("reactable")
  cols <- reactable_sdv_cols_label(stats::setNames(data.frame(1), team), sport = "nfl", variant = "dark")
  expect_match(cols[[team]]$header, paste0("this.src=&#39;", primary, "&#39;"), fixed = TRUE)
})
