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
