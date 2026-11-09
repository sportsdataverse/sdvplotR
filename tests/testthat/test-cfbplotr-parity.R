# The pieces ported from cfbplotR: alt_colors, sdv_teams(division =),
# sdv_clean_names(), sdv_aliases(), sdv_add_athlete_id() and sdv_ggpreview().

test_that("alt_colors gives the listed teams their other colour", {
  pal <- scale_fill_sdv(league = "cfb", alt_colors = c("Alabama", "Utah Utes"))$palette(0)
  col <- sdv_team_colors("cfb", c("Alabama", "Utah", "Oregon"), which = "all")
  two <- strsplit(col, ", ", fixed = TRUE)
  expect_identical(unname(pal[c("Alabama", "333", "Utah")]), c(two[[1]][2], two[[1]][2], two[[2]][2]))
  expect_identical(unname(pal["Oregon"]), two[[3]][1])
  # which = "secondary": the listed teams take their primary
  pal2 <- scale_color_sdv(league = "cfb", which = "secondary", alt_colors = "Alabama")$palette(0)
  expect_identical(unname(pal2[c("Alabama", "Oregon")]), c(two[[1]][1], two[[3]][2]))
  # without alt_colors nothing changes
  expect_identical(scale_fill_sdv(league = "nfl")$palette(0), get_team_colors("nfl", "primary"))
  # given values win, as in cfbplotR
  expect_identical(scale_fill_sdv(league = "cfb", values = c(a = "red"), alt_colors = "Utah")$palette(0), c(a = "red"))
  expect_warning(scale_fill_sdv(league = "cfb", alt_colors = "nope"), class = "sdvplotR_unresolved_warning")
})

test_that("sdv_teams(division =) filters college football tiers by conference", {
  p4 <- sdv_teams("cfb", division = "P4")
  p5 <- sdv_teams("cfb", division = "P5")
  g5 <- sdv_teams("cfb", division = "G5")
  expect_true(all(c("Alabama", "Notre Dame", "Utah") %in% p4$location))
  expect_true(all(p4$team_id %in% p5$team_id))
  expect_true(all(p5$conference_id[!p5$team_id %in% p4$team_id] == "cfb:pac-12"))
  expect_length(intersect(p5$team_id, g5$team_id), 0)
  expect_true(all(c("UConn", "Memphis") %in% g5$location))
  expect_false("Notre Dame" %in% g5$location)
  both <- sdv_teams("cfb", division = c("P5", "G5"))
  expect_setequal(both$team_id, c(p5$team_id, g5$team_id))
  conf <- sdv_teams("cfb", division = "Conference")
  expect_true(all(conf$program %in% c("conference", "league")))
  expect_true("SEC" %in% conf$team_id)
})

test_that("sdv_teams(division =) reads the index's division column when it has one", {
  t <- snapshot_teams
  cfb <- t$league == "cfb"
  t$division <- NA_character_
  t$division[cfb & t$conference_id %in% c(cfb_power4, cfb_group5, "cfb:pac-12", "cfb:fbs-independents")] <- "FBS"
  t$division[cfb & t$conference_id %in% "cfb:big-sky"] <- "fcs"
  local_mocked_bindings(index_teams = function() t)
  fbs <- sdv_teams("cfb", division = "FBS")
  expect_setequal(fbs$team_id, sdv_teams("cfb", division = c("P5", "G5"))$team_id)
  expect_true(all(sdv_teams("cfb", division = "FCS")$conference_id == "cfb:big-sky"))
  expect_identical(nrow(sdv_teams("cfb", division = "DII")), 0L)
})

test_that("sdv_teams(division =) says what it cannot do", {
  skip_if(any(!is.na(sdv_teams("cfb")$division)), "the bundled index has cfb divisions")
  expect_error(sdv_teams("cfb", division = "FBS"), "divisions for")
  expect_error(sdv_teams("cfb", division = "FBS"), "work without it")
})

test_that("sdv_teams(division =) checks its arguments", {
  expect_error(sdv_teams(division = "P5"), "needs a")
  expect_error(sdv_teams("cfb", division = "D1"), "must be one or more of")
  expect_error(sdv_teams("nfl", division = "P5"), "college football tier")
  # without division, nothing changes
  expect_identical(sdv_teams("cfb"), sdv_teams("cfb", division = NULL))
})

test_that("the index reader keeps an optional division column", {
  # the loaded index always has it, NA where the index predates it
  expect_in("division", names(index_teams()))
  expect_in("division", names(sdv_teams("nfl")))
  path <- withr::local_tempfile(fileext = ".csv")
  writeLines(c(paste(c(team_cols, "division", "extra"), collapse = ","), paste(c(rep("x", 12), "FBS", "y"), collapse = ",")), path)
  df <- read_index_csv(path, team_cols, team_optional_cols)
  expect_identical(names(df), c(team_cols, "division"))
  expect_identical(names(read_index_csv(path, team_cols)), team_cols)
})

test_that("sdv_clean_names cleans to one display name, as clean_school_names()", {
  x <- c("utah", "San Jose State", "Hawaii", "UTSA", "SLC", "USC")
  expect_no_warning(out <- sdv_clean_names(x, "cfb"))
  expect_identical(out, c("Utah", "San Jos\u00e9 State", "Hawai'i", "UTSA", "SLC", "USC"))
  expect_warning(out2 <- sdv_clean_names(x, "cfb", keep_non_matches = FALSE), class = "sdvplotR_unresolved_warning")
  expect_identical(out2, c("Utah", "San Jos\u00e9 State", "Hawai'i", "UTSA", NA, "USC"))
  expect_identical(sdv_clean_names(c("Kansas City Chiefs", "OAK"), "nfl", column = "abbr"), c("KC", "LV"))
  expect_identical(sdv_clean_names(333, "cfb"), "Alabama")
  expect_identical(sdv_clean_names(NA, "cfb"), NA_character_)
  expect_error(sdv_clean_names("Utah", "cfb", column = "logo"))
})

test_that("sdv_aliases lists the alias table sdv_resolve() reads", {
  a <- sdv_aliases("cfb")
  expect_identical(names(a), alias_cols)
  expect_true(all(a$league == "cfb"))
  expect_identical(nrow(sdv_aliases()), nrow(index_aliases()))
  nm <- a[a$id_system == "name", ]
  expect_true(all(nm$team_id %in% sdv_teams("cfb", include_conferences = TRUE)$team_id))
  expect_error(sdv_aliases("xyz"), "Unknown league")
})

fake_rosters <- function(league, season) {
  r <- data.frame(
    season = as.integer(season),
    athlete_id = c("4241479", "4240069", "1", "2"),
    name = c("Britain Covey", "JT Daniels", "John Smith", "John Smith"),
    team = c("Utah", "Georgia", "Utah", "Georgia")
  )
  r$headshot_url <- espn_headshot_url(r$athlete_id, league)
  if (season == latest_roster_season() - 1L) r$athlete_id[1] <- "9"
  r
}

test_that("sdv_add_athlete_id matches names, teams and seasons to athlete ids", {
  local_mocked_bindings(load_roster = fake_rosters)
  x <- data.frame(player_name = c("britain covey ", "JT Daniels", "Nobody", NA))
  out <- sdv_add_athlete_id(x, player_name)
  expect_identical(out$athlete_id, c("4241479", "4240069", NA, NA))
  expect_identical(names(out), c("player_name", "athlete_id"))
  # a string column name, a team column read by its name, and headshots
  x2 <- data.frame(who = c("John Smith", "John Smith"), school = c("Utah Utes", "UGA"), season = 2021)
  out2 <- sdv_add_athlete_id(x2, "who", headshot_urls = TRUE)
  expect_identical(out2$athlete_id, c("1", "2"))
  expect_match(out2$headshot_url, "college-football/players/full/[12]\\.png")
  # without the team, one name is two athletes: NA, with a warning
  expect_warning(out3 <- sdv_add_athlete_id(x2["who"], who), "more than one athlete")
  expect_identical(out3$athlete_id, c(NA_character_, NA_character_))
  # the season column picks that season's roster
  x4 <- data.frame(n = "Britain Covey", yr = latest_roster_season() - 1L)
  expect_identical(sdv_add_athlete_id(x4, n, season_col = yr)$athlete_id, "9")
  expect_message(o5 <- sdv_add_athlete_id(data.frame(n = "Britain Covey", season = 1990), n), "using")
  expect_identical(o5$athlete_id, "4241479")
})

test_that("sdv_add_athlete_id leaves a row with a missing team unmatched", {
  local_mocked_bindings(load_roster = function(league, season) {
    data.frame(season = as.integer(season), athlete_id = "7", name = "Solo Player", team = NA_character_, headshot_url = NA)
  })
  out <- sdv_add_athlete_id(data.frame(n = c("Solo Player", "Solo Player"), team = c(NA, "")), n)
  expect_identical(out$athlete_id, c(NA_character_, NA_character_))
})

test_that("the tier filters warn when the index has renamed a tier conference", {
  t <- snapshot_teams
  t$conference_id[t$conference_id %in% "cfb:sec"] <- "cfb:sec-new"
  local_mocked_bindings(index_teams = function() t)
  expect_warning(p4 <- sdv_teams("cfb", division = "P4"), "cfb:sec")
  expect_false("Alabama" %in% p4$location)
  expect_no_warning(sdv_teams("cfb", division = "Conference"))
})

test_that("sdv_add_athlete_id falls back to the season before when the latest is not published", {
  index_aliases() # loaded before use_snapshot() is mocked, so the bundled index is the one read
  local_mocked_bindings(load_roster = function(league, season) {
    if (season == latest_roster_season()) empty_roster() else fake_rosters(league, season)
  }, use_snapshot = function() FALSE)
  expect_message(o <- sdv_add_athlete_id(data.frame(n = "Britain Covey"), n), "using")
  expect_identical(o$athlete_id, "9")
})

test_that("sdv_add_athlete_id warns instead of erroring with no rosters", {
  # the test session is offline: no roster is read
  x <- data.frame(n = c("Britain Covey", "JT Daniels"))
  expect_warning(out <- sdv_add_athlete_id(x, n, headshot_urls = TRUE), class = "sdvplotR_no_roster_warning")
  expect_identical(out$athlete_id, c(NA_character_, NA_character_))
  expect_identical(out$headshot_url, c(NA_character_, NA_character_))
})

test_that("sdv_add_athlete_id checks its arguments", {
  x <- data.frame(n = "a")
  expect_error(sdv_add_athlete_id(x, n, league = "nfl"), "rosters for")
  expect_error(sdv_add_athlete_id("a", n), "must be a data frame")
  expect_error(sdv_add_athlete_id(data.frame(n = "a", athlete_id = 1), n), "already has")
  expect_error(sdv_add_athlete_id(data.frame(n = "a", m = "b"), c(n, m)), "one column")
})

test_that("the latest roster season starts on August 15", {
  expect_identical(latest_roster_season(as.Date("2026-08-14")), 2025L)
  expect_identical(latest_roster_season(as.Date("2026-08-15")), 2026L)
  expect_identical(latest_roster_season(as.Date("2027-01-10")), 2026L)
})

test_that("sdv_add_athlete_id reads the published rosters", {
  skip_on_cran()
  skip_if_offline("raw.githubusercontent.com")
  skip_if(Sys.getenv("SDVPLOTR_LIVE_TESTS") != "1", "set SDVPLOTR_LIVE_TESTS=1 for network tests")
  withr::local_options(sdvplotR.offline = FALSE)
  withr::defer(forget_headshot_map())
  x <- data.frame(player_name = c("Britain Covey", "JT Daniels"), team = c("Utah", "Georgia"), season = 2021)
  out <- sdv_add_athlete_id(x, player_name)
  expect_false(anyNA(out$athlete_id))
})

test_that("sdv_ggpreview saves the plot at the asked size", {
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  opened <- NULL
  local_mocked_bindings(open_preview = function(file) opened <<- file)
  path <- sdv_ggpreview(p, width = 2, asp = 2, dpi = 50)
  withr::defer(unlink(path))
  expect_true(file.exists(path))
  expect_match(path, "\\.png$")
  info <- magick::image_info(magick::image_read(path))
  expect_identical(c(info$width, info$height), c(100L, 50L))
  if (interactive()) expect_identical(opened, path) else expect_null(opened)
  # asp with only a height, and with neither (ggsave's 7 inches)
  p2 <- sdv_ggpreview(p, height = 1, asp = 2, dpi = 50)
  withr::defer(unlink(p2))
  expect_equal(unlist(magick::image_info(magick::image_read(p2))[c("width", "height")]), c(width = 100, height = 50))
  p3 <- sdv_ggpreview(p, asp = 2, dpi = 10)
  withr::defer(unlink(p3))
  expect_equal(unlist(magick::image_info(magick::image_read(p3))[c("width", "height")]), c(width = 70, height = 35))
  # a device function names the file by its format
  expect_identical(preview_ext(grDevices::pdf), "pdf")
  expect_identical(preview_ext("svg"), "svg")
  expect_identical(preview_ext(function(...) NULL), "png")
})

test_that("cfbplotR's legacy wordmarks rank after every other source, and an unknown source has a rank", {
  expect_identical(unname(source_rank["cfbplotr-legacy"]), max(source_rank))
  m <- data.frame(
    level = "team", league = "cfb", entity_id = "333", entity_name = "Alabama", mark_type = "wordmark",
    variant = "default", valid_from = NA_integer_, valid_to = NA_integer_,
    source = c("cfbplotr-legacy", "some-new-source", "espn"), first_seen = "2026-11-06",
    sha256 = c("a", "b", "c"), ext = "png", archive_url = paste0("https://x/", c("a", "b", "c"), ".png")
  )
  local_mocked_bindings(index_marks = function() m, mark_aliases = function(league) {
    data.frame(key = paste0(m$source, ":333"), team_id = "333", valid_from = NA_integer_, valid_to = NA_integer_)
  })
  forget_index()
  withr::defer(forget_index())
  r <- ranked_marks("cfb")
  expect_false(anyNA(r$source_rank))
  expect_identical(r$source[r$team_id == "333"], c("espn", "some-new-source", "cfbplotr-legacy"))
})
