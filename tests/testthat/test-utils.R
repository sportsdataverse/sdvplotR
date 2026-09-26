test_that("supported_sports lists the eight leagues", {
  expect_identical(
    supported_sports(),
    c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
  )
})

test_that("valid_team_names returns complete, sorted pro rosters", {
  expect_length(valid_team_names("nfl"), 32)
  expect_length(valid_team_names("nba"), 30)
  expect_length(valid_team_names("mlb"), 30)
  expect_length(valid_team_names("nhl"), 32)
  expect_identical(valid_team_names("nfl"), sort(valid_team_names("nfl")))
  expect_in(c("KC", "BUF", "LA", "WAS"), valid_team_names("nfl"))
  expect_in("Kansas City Chiefs", valid_team_names("nfl", type = "name"))
  expect_in(c("ALA", "UGA", "OSU"), valid_team_names("cfb"))
  expect_gt(length(valid_team_names("mbb")), 300)
})

test_that("valid_team_names rejects unknown sports", {
  expect_snapshot(valid_team_names("xfl"), error = TRUE)
})

test_that("team_reference carries the documented columns", {
  ref <- team_reference("nfl")
  expect_s3_class(ref, "data.frame")
  expect_in(
    c(
      "sport", "espn_team_id", "team_abbr", "team_name", "logo_url",
      "logo_dark_url", "wordmark_url", "color1", "color2", "conference", "division"
    ),
    names(ref)
  )
  expect_identical(nrow(ref), 32L)
  expect_false(anyNA(ref$logo_url))
})

test_that("clean_team_abbrs handles case, names, aliases and history", {
  expect_identical(
    clean_team_abbrs(c("KC", "kc", "Kansas City Chiefs", "WSH", "GNB", "OAK"), "nfl"),
    c("KC", "KC", "KC", "WAS", "GB", "LV")
  )
  expect_identical(clean_team_abbrs(c("GSW", "SEA", "Lakers"), "nba"), c("GS", "OKC", "LAL"))
  expect_identical(clean_team_abbrs(c("OAK", "CWS", "MON"), "mlb"), c("ATH", "CHW", "WSH"))
  expect_identical(clean_team_abbrs(c("ARI", "LAK", "PHX"), "nhl"), c("UTAH", "LA", "UTAH"))
})

test_that("clean_team_abbrs keeps or drops non-matches as requested", {
  withr::local_options(sdvplotR.verbose = FALSE)
  expect_identical(clean_team_abbrs(c("KC", "nope"), "nfl"), c("KC", "nope"))
  expect_identical(clean_team_abbrs(c("KC", "nope"), "nfl", keep_non_matches = FALSE), c("KC", NA))
  expect_identical(clean_team_abbrs(c(NA, "KC"), "nfl"), c(NA, "KC"))
})

test_that("clean_team_abbrs warns about non-matches when verbose", {
  withr::local_options(sdvplotR.verbose = TRUE)
  expect_snapshot(clean_team_abbrs(c("KC", "nope"), "nfl"))
})

test_that("resolve_historical_abbr is vectorised and leaves unknowns alone", {
  expect_identical(resolve_historical_abbr(c("OAK", "SD", "KC", NA), "nfl"), c("LV", "LAC", "KC", NA))
  expect_identical(resolve_historical_abbr("ALA", "cfb"), "ALA")
  expect_identical(resolve_historical_abbr(character(), "nba"), character())
})

test_that("sdv_team_colors returns hex codes keyed by input", {
  cols <- sdv_team_colors("nfl", c("KC", "BUF", "zzz"))
  expect_named(cols, c("KC", "BUF", "zzz"))
  expect_match(cols[1:2], "^#[0-9A-Fa-f]{6}$")
  expect_identical(unname(cols[3]), NA_character_)
  expect_match(sdv_team_colors("nfl", "KC", type = "secondary"), "^#")
  expect_match(sdv_team_colors("nfl", "KC", type = "all"), "^#.*, #")
  all_cols <- sdv_team_colors("nba", type = "all")
  expect_named(all_cols, c("team_abbr", "team_name", "primary", "secondary"))
  expect_identical(nrow(all_cols), 30L)
})

test_that("sdv_color_palette drops unknown teams", {
  pal <- sdv_color_palette("nhl", c("TOR", "MTL", "nope"))
  expect_named(pal, c("TOR", "MTL"))
})

test_that("sdv_team_factor keeps only valid, cleaned teams as levels", {
  f <- sdv_team_factor(c("KC", "buf", "OAK", "bad"), sport = "nfl")
  expect_s3_class(f, "factor")
  expect_identical(levels(f), c("BUF", "KC", "LV"))
  expect_identical(as.character(f), c("KC", "BUF", "LV", NA))
})

test_that("sdvplotR_clear_cache is a quiet no-op that returns NULL", {
  expect_null(suppressMessages(sdvplotR_clear_cache()))
})

test_that("NFL headshots resolve GSIS ids through the crosswalk and ESPN ids directly", {
  u <- headshot_from_id(c("00-0033873", "3139477", "00-9999999", "bad", NA), sport = "nfl")
  # GSIS id -> NFL.com's own image id, at the sized transform
  expect_match(
    u[[1]],
    "^https://static\\.www\\.nfl\\.com/image/(private|upload)/t_headshot_desktop/f_auto/league/[A-Za-z0-9_-]+$"
  )
  expect_identical(
    sub(".*/(private|upload)/t_headshot_desktop/f_auto/league/", "\\1/", u[[1]]),
    unname(nfl_headshot_ids[["00-0033873"]])
  )
  # numeric id -> ESPN athlete headshot, as for the other sports
  expect_identical(u[[2]], "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/3139477.png")
  # unknown GSIS id, garbage and NA stay NA so the helpers can fall back
  expect_true(all(is.na(u[3:5])))
})

test_that("the NFL headshot crosswalk is well formed", {
  expect_gt(length(nfl_headshot_ids), 20000)
  expect_false(anyDuplicated(names(nfl_headshot_ids)) > 0)
  expect_true(all(grepl("^00-00", names(nfl_headshot_ids)) | grepl("^[A-Z]{3}", names(nfl_headshot_ids))))
  expect_true(all(grepl("^(private|upload)/[A-Za-z0-9_-]+$", nfl_headshot_ids)))
})

test_that("a resolved NFL headshot URL serves an image", {
  skip_on_cran()
  skip_if_offline()
  h <- curlGetHeaders(headshot_from_id("00-0033873", sport = "nfl"))
  expect_identical(attr(h, "status"), 200L)
})
