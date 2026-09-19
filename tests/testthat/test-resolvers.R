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
  expect_match(headshot_from_id("00-0033873", "nfl"), "nfl\\.com.*000033873$")
  expect_identical(headshot_from_id("123", "nfl"), NA_character_)
  expect_match(headshot_from_id("3917315", "cfb"), "college-football/players/full/3917315\\.png$")
  expect_match(headshot_from_id(3917315, "mbb"), "mens-college-basketball")
  expect_match(headshot_from_id("1966", "nba"), "headshots/nba/")
  expect_identical(headshot_from_id(c(NA, "", "abc"), "nba"), rep(NA_character_, 3))
})

test_that("axis html helpers embed images and keep unknown labels", {
  h <- logo_html(c("KC", "nope"), "nfl", type = "height", size = 20)
  expect_match(h[1], "^<img src='https://.*height = '20'>$")
  expect_identical(h[2], "nope")
  expect_match(headshot_html("00-0033873", "nfl", type = "width"), "^<img")
})
