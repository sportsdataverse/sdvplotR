# logo_marks: the SportsDataverse logo archive's copies of today's marks
# (data-raw/generate_logo_marks.R), read first by every logo / wordmark helper.

cdn <- "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/"
sdv_sports <- c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
# <cdn>/<ab>/<sha256>.<ext>, the directory being the hash's first two digits
sha_re <- paste0("^", cdn, "([0-9a-f]{2})/\\1[0-9a-f]{62}\\.(png|svg|gif|jpg)$")

test_that("logo_marks holds one archive copy per sport, key, type and variant", {
  expect_named(logo_marks, c("sport", "key", "type", "variant", "url"))
  expect_false(anyNA(logo_marks))
  expect_true(all(grepl(sha_re, logo_marks$url, perl = TRUE)))
  expect_identical(anyDuplicated(logo_marks[c("sport", "key", "type", "variant")]), 0L)
  expect_true(all(paste(logo_marks$sport, logo_marks$key) %in% paste(logo_ref$sport, logo_ref$team_abbr)))
  # every row of the eight SDV sports (conferences and the NFL shield included)
  # has an archived primary logo, and every team a dark one; soccer clubs are
  # archived as far as the archive has them (the rest fall back to ESPN)
  ref <- logo_ref[logo_ref$sport %in% sdv_sports, ]
  prim <- logo_marks[logo_marks$type == "logo" & logo_marks$variant == "primary", ]
  expect_true(all(paste(ref$sport, ref$team_abbr) %in% paste(prim$sport, prim$key)))
  teams <- ref[ref$type == "team", ]
  expect_identical(nrow(teams), 1136L)
  dark <- logo_marks[logo_marks$type == "logo" & logo_marks$variant == "dark", ]
  expect_true(all(paste(teams$sport, teams$team_abbr) %in% paste(dark$sport, dark$key)))
  expect_gt(sum(prim$sport == "soccer"), 1000)
})

test_that("current logos and wordmarks come from the archive, not a live CDN", {
  for (s in sdv_sports) {
    expect_match(logo_from_team(valid_team_names(s)[1:3], s), paste0("^", cdn))
    expect_match(resolve_logo_url(valid_team_names(s)[1], s, "dark"), paste0("^", cdn))
  }
  # a soccer club the archive has no copy of falls back to ESPN's live file
  soccer <- logo_ref[logo_ref$sport == "soccer", ]
  archived <- logo_marks$key[logo_marks$sport == "soccer" & logo_marks$type == "logo" & logo_marks$variant == "primary"]
  club <- soccer[!soccer$team_abbr %in% archived, ][1, ]
  expect_identical(logo_from_team(club$team_abbr, "soccer"), club$logo_url)
  expect_match(logo_from_team(club$team_abbr, "soccer"), "^https://a\\.espncdn\\.com/")
  expect_match(logo_from_team(soccer$team_abbr[soccer$team_abbr %in% archived][1], "soccer"), paste0("^", cdn))
  expect_match(logo_from_team("SEC", "cfb"), paste0("^", cdn))
  expect_match(logo_from_team("AFC", "nfl"), paste0("^", cdn))
  expect_match(wordmark_from_team("KC", "nfl"), paste0("^", cdn))
  # the Capitals' dark mark is a different file from their primary
  expect_false(identical(resolve_logo_url("WSH", "nhl", "dark"), logo_from_team("WSH", "nhl")))
  # team_reference() still lists the sources' live URLs
  expect_match(team_reference("nfl")$logo_url, "^https://a\\.espncdn\\.com/")
})

# A stand-in archive: the Chiefs' primary and a "neon" mark for the Chiefs and
# the Bills; nothing else.
marks_fixture <- data.frame(
  sport = "nfl",
  key = c("KC", "KC", "BUF"),
  type = "logo",
  variant = c("primary", "neon", "neon"),
  url = paste0(cdn, c("aa/aa", "bb/bb", "cc/cc"), strrep("0", 62), ".png")
)

local_logo_marks <- function(marks = marks_fixture, env = parent.frame()) {
  testthat::local_mocked_bindings(logo_marks = marks, .package = "sdvplotR", .env = env)
}

test_that("an archived mark is drawn over ESPN's; a team the archive lacks falls back to ESPN", {
  local_logo_marks()
  ref <- get_team_ref("nfl")
  # the Chiefs: the archive's primary, however the team is keyed
  expect_identical(logo_from_team("KC", "nfl"), marks_fixture$url[1])
  expect_identical(sdv_logo_url("Kansas City Chiefs", "nfl"), marks_fixture$url[1])
  expect_match(reactable_sdv_logos("nfl")("KC", 1), marks_fixture$url[1], fixed = TRUE)
  # the Bills: no archive copy, ESPN's live file
  expect_identical(logo_from_team("BUF", "nfl"), ref$logo_url[ref$team_abbr == "BUF"])
  # a variant the archive lacks for the Chiefs: ESPN's file of that variant
  expect_identical(resolve_logo_url("KC", "nfl", "dark"), ref$logo_dark_url[ref$team_abbr == "KC"])
  # the named variant: the archive's marks; the Bears have none and draw their primary
  expect_identical(
    sdv_logo_url(c("KC", "BUF", "CHI"), "nfl", variant = "neon"),
    c(marks_fixture$url[2:3], ref$logo_url[ref$team_abbr == "CHI"])
  )
  # no NBA mark has it
  expect_error(sdv_logo_url("LAL", "nba", variant = "neon"), "`variant` must be one of")
  expect_identical(sdv_logo_url("nope", "nfl", variant = "neon"), NA_character_)
})

test_that("named variants are the archive's, per sport", {
  expect_true(all(
    c("grayscale", "squared", "scoreboard_dark", "primary_logo_on_black_color") %in% archive_variants("nfl", "logo")
  ))
  expect_setequal(archive_variants("mlb", "wordmark"), c("on_light", "on_dark"))
  expect_identical(archive_variants("nba", "wordmark"), character())
  expect_match(sdv_logo_url("KC", "nfl", variant = "grayscale"), paste0("^", cdn))
  expect_match(sdv_logo_url("NYY", "mlb", variant = "cap_on_light"), "\\.svg$")
  expect_error(sdv_logo_url("LAL", "nba", variant = "grayscale"), "`variant` must be one of")
  expect_error(resolve_wordmark_url("KC", "nfl", "on_dark"), "`variant` must be one of")
  # MLB wordmarks: the league's light-background mark is the primary
  expect_identical(resolve_wordmark_url("NYY", "mlb"), resolve_wordmark_url("NYY", "mlb", "on_light"))
  expect_match(resolve_wordmark_url("NYY", "mlb", "on_dark"), "\\.svg$")
  expect_false(identical(resolve_wordmark_url("NYY", "mlb", "on_dark"), resolve_wordmark_url("NYY", "mlb")))
  # a function's default vector still picks the primary
  expect_identical(sdv_logo_url("KC", "nfl"), sdv_logo_url("KC", "nfl", variant = "primary"))
})

test_that("gt_tiers names an archived mark by its team", {
  expect_identical(.tier_alt(logo_from_team("KC", "nfl")), "Kansas City Chiefs")
  expect_identical(.tier_alt(resolve_logo_url("NYY", "mlb", "cap_on_light")), "New York Yankees")
})

test_that("archive files hash to the sha256 in their URL", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(getRversion() >= "4.5.0", "tools::sha256sum() needs R 4.5")
  urls <- c(
    logo_from_team("KC", "nfl"),
    resolve_logo_url("TOR", "nhl", "dark"),
    resolve_wordmark_url("NYY", "mlb"),
    logo_from_team("SEC", "cfb")
  )
  for (u in urls) {
    f <- withr::local_tempfile()
    utils::download.file(u, f, mode = "wb", quiet = TRUE)
    # a mismatch is a corrupt or substituted file, never accepted
    expect_identical(unname(tools::sha256sum(f)), sub("\\.[^.]+$", "", basename(u)))
  }
})
