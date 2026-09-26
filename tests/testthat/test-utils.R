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
  # the MLB Stats API / Savant (baseballr) and FanGraphs / Baseball-Reference keys
  expect_identical(clean_team_abbrs(c("AZ", "WSN"), "mlb", keep_non_matches = FALSE), c("ARI", "WSH"))
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

test_that("sdvplotR_clear_cache clears the caches and returns NULL", {
  expect_null(suppressMessages(sdvplotR_clear_cache()))
})

test_that("NFL headshots resolve GSIS ids through the published map", {
  local_headshot_map()
  u <- headshot_from_id(c("00-0033873", "00-0031078", "11765", "00-0099999", "bad", NA), sport = "nfl")
  # NFL.com image at the sized transform, with the .png gridtext needs
  expect_identical(
    u[[1]],
    "https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png"
  )
  # a player with no NFL.com image falls back to their ESPN headshot
  expect_identical(u[[2]], "https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/16885.png")
  # numeric NFL ids are ambiguous; unknown GSIS ids, garbage and NA stay NA
  expect_true(all(is.na(u[3:6])))
})

test_that("with no map (offline) every NFL id resolves to NA", {
  local_headshot_map(data.frame(gsis_id = character(), headshot_nfl = character(), espn_id = character()))
  expect_identical(headshot_from_id(c("00-0033873", NA), "nfl"), c(NA_character_, NA_character_))
})

test_that("load_headshot_map returns an empty map when the release can't be read", {
  local_mocked_bindings(rds_from_url = function(...) data.frame(), .package = "nflreadr")
  m <- load_headshot_map()
  expect_identical(nrow(m), 0L)
  expect_true(all(c("gsis_id", "headshot_nfl", "espn_id") %in% names(m)))
})

test_that("a failed map read is not cached, so the next call retries", {
  calls <- 0
  reader <- memoise::memoise(function(url) {
    calls <<- calls + 1
    data.frame()
  })
  local_mocked_bindings(rds_from_url = reader, .package = "nflreadr")
  load_headshot_map()
  load_headshot_map()
  expect_identical(calls, 2)
})

test_that("sdvplotR_clear_cache forgets the headshot map", {
  calls <- 0
  reader <- memoise::memoise(function(url) {
    calls <<- calls + 1
    headshot_map_fixture
  })
  local_mocked_bindings(rds_from_url = reader, .package = "nflreadr")
  load_headshot_map()
  load_headshot_map()
  expect_identical(calls, 1) # a good read stays cached
  suppressMessages(sdvplotR_clear_cache())
  load_headshot_map()
  expect_identical(calls, 2)
})

test_that("nfl_headshot_url sizes the image and adds .png once", {
  expect_identical(
    nfl_headshot_url("https://static.www.nfl.com/image/private/f_auto,q_auto/league/abc"),
    "https://static.www.nfl.com/image/private/t_headshot_desktop/f_auto/league/abc.png"
  )
  expect_identical(nfl_headshot_url("https://x.test/a.png"), "https://x.test/a.png")
})

test_that("round numeric player ids are not written in scientific notation", {
  expect_match(headshot_from_id(4000000, "nba"), "/full/4000000\\.png$")
})

test_that("the published headshot map loads and serves Mahomes' image", {
  skip_on_cran()
  skip_if_offline()
  m <- load_headshot_map()
  expect_gt(nrow(m), 15000)
  expect_false(anyDuplicated(m$gsis_id) > 0)
  h <- curlGetHeaders(headshot_from_id("00-0033873", sport = "nfl"))
  expect_identical(attr(h, "status"), 200L)
})

test_that("id_type = 'league' resolves league ids on the league's own CDN", {
  expect_identical(
    headshot_from_id(c("2544", "abc", NA), "nba", id_type = "league"),
    c("https://cdn.nba.com/headshots/nba/latest/260x190/2544.png", NA, NA)
  )
  expect_identical(
    headshot_from_id(1642286, "wnba", id_type = "league"),
    "https://cdn.wnba.com/headshots/wnba/latest/260x190/1642286.png"
  )
  # the NHL API's own headshot for players with no current team; same image as
  # the season/team mug, so no map is needed
  expect_identical(
    headshot_from_id(c(8478402, 8447400), "nhl", id_type = "league"),
    c("https://assets.nhle.com/mugs/nhl/latest/8478402.png", "https://assets.nhle.com/mugs/nhl/latest/8447400.png")
  )
  expect_match(
    headshot_from_id("660271", "mlb", id_type = "league"),
    "^https://img\\.mlbstatic\\.com/.*/v1/people/660271/headshot/67/current\\.png$"
  )
  # the default is unchanged: numeric ids outside the NFL are ESPN athlete ids
  expect_identical(
    headshot_from_id("2544", "nba"),
    "https://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/2544.png"
  )
})

test_that("id_type = 'espn' takes ESPN athlete ids for the NFL without the map", {
  local_mocked_bindings(load_headshot_map = function() stop("the map was read"), .package = "sdvplotR")
  expect_identical(
    headshot_from_id(c("3139477", "00-0033873"), "nfl", id_type = "espn"),
    c("https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/3139477.png", NA)
  )
})

test_that("id_type = 'league' for the NFL is the GSIS default", {
  local_headshot_map()
  expect_identical(headshot_from_id("00-0033873", "nfl", id_type = "league"), headshot_from_id("00-0033873", "nfl"))
})

test_that("check_id_type validates the id system for the sport", {
  expect_null(check_id_type(NULL, "nhl"))
  expect_identical(check_id_type("league", "wnba"), "league")
  expect_identical(check_id_type("espn", "nfl"), "espn")
  expect_identical(check_id_type("league", "nhl"), "league")
  expect_error(check_id_type("league", "wbb"), "not available by league player ID")
  expect_error(check_id_type("league", "cfb"), "not available by league player ID")
  expect_error(check_id_type("gsis", "nfl"))
})
