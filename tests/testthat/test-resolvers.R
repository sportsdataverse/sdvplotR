test_that("logo_from_team resolves every sport and NA for unknowns", {
  for (s in supported_sports()) {
    teams <- valid_team_names(s)[1:3]
    urls <- logo_from_team(teams, sport = s)
    expect_length(urls, 3)
    expect_match(urls, "^https://")
  }
  expect_identical(logo_from_team(c("KC", "nope"), "nfl")[2], NA_character_)
})

test_that("variant lookups fall back to the primary logo", {
  expect_match(resolve_logo_url("KC", "nfl", "dark"), "500-dark/kc\\.png$")
  expect_identical(resolve_logo_url("KC", "nfl", "helmet"), logo_from_team("KC", "nfl"))
  expect_identical(resolve_wordmark_url("KC", "nfl", "classic"), wordmark_from_team("KC", "nfl"))
  expect_identical(resolve_logo_url("nope", "nfl", "dark"), NA_character_)
})

test_that("NFL wordmarks come from nflverse, other leagues have none", {
  expect_match(wordmark_from_team("KC", "nfl"), "nflverse.*/KC\\.png$")
  expect_identical(wordmark_from_team("LAL", "nba"), NA_character_)
})

test_that("headshot_from_id builds sport-specific URLs", {
  local_headshot_map()
  # NFL: GSIS ids go through the published map to NFL.com's own image id
  expect_match(headshot_from_id("00-0033873", "nfl"), "/league/wdckwtob1lybvkmxnf7p\\.png$")
  # bare numeric NFL ids are ambiguous (nfl / pff / otc ids collide with ESPN's)
  expect_identical(headshot_from_id("11765", "nfl"), NA_character_)
  # a well-formed GSIS id that is not in the map
  expect_identical(headshot_from_id("00-0099999", "nfl"), NA_character_)
  expect_match(headshot_from_id("3917315", "cfb"), "college-football/players/full/3917315\\.png$")
  expect_match(headshot_from_id(3917315, "mbb"), "mens-college-basketball")
  expect_match(headshot_from_id("1966", "nba"), "headshots/nba/")
  expect_identical(headshot_from_id(c(NA, "", "abc"), "nba"), rep(NA_character_, 3))
})

test_that("axis html helpers embed images and keep unknown labels", {
  local_headshot_map()
  h <- logo_html(c("KC", "nope"), "nfl", type = "height", size = 20)
  expect_match(h[1], "^<img src='https://.*height = '20'>$")
  expect_identical(h[2], "nope")
  expect_match(headshot_html("00-0033873", "nfl", type = "width"), "^<img")
})

test_that("Division I programs missing from ESPN's teams list are in the reference", {
  # fetched one by one by data-raw/generate_logo_ref.R (ESPN ids 2815, 2511, 88, 2598, 2385)
  expect_true(all(c("LIN", "QUC", "USI", "SFPA") %in% team_reference("mbb")$team_abbr))
  expect_true(all(c("MERC", "SFPA") %in% team_reference("wbb")$team_abbr))
  expect_false(anyNA(logo_from_team(c("LIN", "QUC", "USI", "SFPA"), sport = "mbb")))
})

# the first ten hex digits of an archived mark's sha256
sha <- function(url) sub("^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/assets/public/sha256/../([0-9a-f]{10}).*$", "\\1", url)

test_that("a season draws the mark the team wore that season", {
  # NHL catalog eras: QUE_19791980-19941995, CHI_19571958-19611962, TBL_20012002-20062007
  expect_identical(sha(logo_from_team("QUE", "nhl", season = 1990)), "3c28d243dd")
  expect_identical(sha(logo_from_team("CHI", "nhl", season = 1960)), "f039358b7c")
  tb <- logo_from_team(c("TB", "TBL", "Tampa Bay Lightning"), "nhl", season = 2005)
  expect_identical(sha(tb), rep("a976228f16", 3))
  # a current key never draws a relocated identity: no 1990 COL era, no 2005 WPG era
  expect_identical(logo_from_team("COL", "nhl", season = 1990), logo_from_team("COL", "nhl"))
  expect_identical(logo_from_team("WPG", "nhl", season = 2005), logo_from_team("WPG", "nhl"))
  # NFL / WNBA relocated and defunct identities: ESPN's frozen stl.png and hou.png
  stl <- logo_from_team(c("STL", "STL"), "nfl", season = c(2010, 2020))
  expect_identical(sha(stl[1]), "519d52b925")
  expect_identical(stl[2], logo_from_team("LA", "nfl"))
  expect_identical(sha(logo_from_team("HOU", "wnba", season = 2000)), "8486bacdb1")
  expect_true(all(startsWith(logo_history$url, "https://sdv.nyc3.cdn.digitaloceanspaces.com/")))
})

test_that("season lookups are vectorised and fall back element by element", {
  urls <- logo_from_team("TB", "nhl", season = c(1995, 2005, NA, 1980))
  expect_identical(sha(urls[1:2]), c("0f2d71a124", "a976228f16"))
  expect_identical(urls[3:4], rep(logo_from_team("TB", "nhl"), 2))
  expect_identical(logo_from_team(c("QUE", "nope", NA), "nhl", season = 1990)[2:3], rep(NA_character_, 2))
  # dark marks, and variants with no historical mark fall back to the season's primary
  dark <- resolve_logo_url("QUE", "nhl", "dark", season = 1990)
  expect_match(dark, "digitaloceanspaces")
  expect_false(identical(dark, logo_from_team("QUE", "nhl", season = 1990)))
  expect_identical(resolve_logo_url("QUE", "nhl", "helmet", season = 1990), logo_from_team("QUE", "nhl", season = 1990))
})

test_that("without a season every sport resolves as before", {
  for (s in supported_sports()) {
    teams <- c(valid_team_names(s)[1:5], "QUE", "STL", "HOU", "nope", NA)
    today <- lookup_team_column(teams, s, "logo_url")
    expect_identical(logo_from_team(teams, s), today)
    expect_identical(logo_from_team(teams, s, season = NA), today)
    expect_identical(resolve_logo_url(teams, s, "dark", season = NULL), resolve_logo_url(teams, s, "dark"))
    expect_false(any(grepl("digitaloceanspaces", today)))
  }
  expect_identical(logo_from_team("QUE", "nhl"), logo_from_team("COL", "nhl"))
})
