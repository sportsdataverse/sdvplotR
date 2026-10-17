skip_on_cran()

# `x` resolves to the same teams as the canonical keys `as` (NA where `as` is NA)
expect_resolves_as <- function(x, league, as) {
  want <- ifelse(is.na(as), NA_character_, resolve_ids(as, league, marks = TRUE)$ids)
  expect_false(anyNA(want[!is.na(as)]))
  expect_identical(resolve_ids(x, league, marks = TRUE)$ids, want)
}

test_that("sdv_teams() returns complete pro rosters", {
  expect_length(sdv_teams("nfl")$abbr, 32)
  # the AFC, NFC and NFL rows only when asked for
  nfl <- sdv_teams("nfl", include_conferences = TRUE)
  expect_identical(nrow(nfl), 35L)
  expect_in(c("AFC", "NFC", "NFL"), nfl$team_id)
  expect_length(sdv_teams("nba")$abbr, 30)
  expect_length(sdv_teams("mlb")$abbr, 30)
  expect_length(sdv_teams("nhl")$abbr, 32)
  expect_in(c("KC", "BUF", "LA", "WAS"), sdv_teams("nfl")$abbr)
  expect_in("Kansas City Chiefs", sdv_teams("nfl")$name)
  expect_in(c("ALA", "UGA", "OSU"), sdv_teams("cfb")$abbr)
  expect_gt(nrow(sdv_teams("mbb")), 300)
})

test_that("sdv_teams() rejects unknown leagues", {
  expect_error(sdv_teams("xyz"), "Unknown league")
})

test_that("sdv_team_colors() with no team covers every team that has a colour", {
  cfb <- sdv_teams("cfb")
  cfb <- cfb[!is.na(cfb$color_primary), ]
  expect_setequal(names(sdv_team_colors("cfb")), ifelse(is.na(cfb$abbr), cfb$team_id, cfb$abbr))
  nfl <- sdv_teams("nfl", include_conferences = TRUE)
  expect_setequal(nfl$team_id[nfl$program %in% c("conference", "league")], c("AFC", "NFC", "NFL"))
})

test_that("every team has real colors, with their source recorded", {
  teams <- sdv_teams()
  expect_false(anyNA(teams$color_primary))
  expect_match(teams$color_primary, "^#[0-9A-Fa-f]{6}$")
  # ESPN's stand-in (black alone, with its stock red, or on black) is not a team's color
  p <- toupper(teams$color_primary)
  s <- toupper(teams$color_secondary)
  stand_in <- teams$color_source == "espn" & p == "#000000" & (is.na(s) | s %in% c("#000000", "#C60000"))
  expect_identical(teams$team_id[stand_in], character())
  expect_true(all(teams$color_source[teams$league == "nfl"] == "nflverse"))
  expect_true(all(teams$color_source[teams$league %in% c("nba", "wnba", "mlb", "nhl")] == "espn"))
  # Chicago State's colours from ESPN's basketball entry, Campbell's from its logo
  expect_identical(sdv_team_colors("cfb", "CHST"), c(CHST = "#006700"))
  expect_identical(tolower(sdv_team_colors("mbb", "CAM", which = "all")), c(CAM = "#ff4713, #2e1811"))
  expect_identical(teams$color_source[teams$league == "mbb" & teams$abbr %in% "CAM"], "logo")
})

test_that("conferences resolve like teams for the logo helpers, and a team keeps a shared name", {
  mbb <- sdv_teams("mbb", include_conferences = TRUE)
  confs <- mbb$team_id[mbb$program %in% "conference"]
  expect_in(c("ACC", "Big Ten", "SEC", "A-10", "AAC", "MAAC", "WCC"), confs)
  expect_resolves_as(confs, "mbb", confs)
  # names a team already uses stay the team's
  expect_resolves_as(c("American", "SC"), "mbb", c("AMER", "SC"))
  expect_resolves_as("Southern", "cfb", "SOU")
  expect_match(logo_from_team("SEC", "cfb"), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
  expect_match(logo_from_team("AFC", "nfl"), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
  expect_false(identical(logo_from_team("SEC", "cfb"), logo_from_team("AFC", "nfl")))
  # a conference key draws a logo but is never a team
  expect_warning(expect_identical(sdv_resolve("SEC", "cfb"), NA_character_), class = "sdvplotR_unresolved_warning")
})

test_that("the WAC draws its archived mark, and the UAC it became does not resolve", {
  for (s in c("cfb", "mbb", "wbb")) {
    expect_resolves_as(c("WAC", "wac"), s, rep("WAC", 2))
    expect_match(logo_from_team("WAC", s), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
    expect_resolves_as(c("UAC", "United Athletic Conference"), s, c(NA, NA))
  }
  # a conference row, listed with the conferences only
  expect_false("WAC" %in% sdv_teams("mbb")$team_id)
  expect_true("WAC" %in% sdv_teams("mbb", include_conferences = TRUE)$team_id)
})

test_that("team values resolve through case, names, provider aliases and history", {
  expect_resolves_as(c("KC", "kc", "Kansas City Chiefs", "WSH", "GNB", "OAK"), "nfl", c("KC", "KC", "KC", "WAS", "GB", "LV"))
  expect_resolves_as(c("GSW", "SEA", "Lakers"), "nba", c("GS", "OKC", "LAL"))
  expect_resolves_as(c("OAK", "CWS", "MON"), "mlb", c("ATH", "CHW", "WSH"))
  # the MLB Stats API / Savant (baseballr) and FanGraphs / Baseball-Reference keys
  expect_resolves_as(c("AZ", "WSN"), "mlb", c("ARI", "WSH"))
  expect_resolves_as(c("ARI", "LAK", "PHX"), "nhl", c("UTAH", "LA", "UTAH"))
  expect_resolves_as(c("NOH", "NOK", "WSB"), "nba", c("NO", "NO", "WSH"))
  expect_resolves_as("STL", "nfl", "LA")
  # ESPN box scores abbreviate Butler and New Orleans differently from its teams list
  expect_resolves_as(c("BUT", "UNO"), "mbb", c("BTLR", "NOLA"))
  expect_resolves_as(c("BUT", "UNO"), "wbb", c("BTLR", "NOLA"))
  # ESPN's FPI writes Buffalo BUFF and Air Force AFA
  expect_resolves_as(c("BUFF", "AFA"), "cfb", c("BUF", "AF"))
  # NCAA.com / stats.ncaa.org, KenPom and Torvik school names
  ncaa <- c("Iowa St.", "St. John's (NY)", "Saint Mary's (CA)", "Southern California", "Miami (FL)", "Miami (OH)")
  expect_resolves_as(ncaa, "mbb", c("ISU", "SJU", "SMC", "USC", "MIA", "M-OH"))
  expect_resolves_as(ncaa, "wbb", c("ISU", "SJU", "SMC", "USC", "MIA", "M-OH"))
  expect_resolves_as(c("Iowa St.", "Southern California", "Miami (OH)"), "cfb", c("ISU", "USC", "M-OH"))
  expect_resolves_as(c("Miami", "Iowa State"), "mbb", c("MIA", "ISU"))
  # Sports Reference's names
  sr <- c("Brigham Young", "Virginia Commonwealth", "Loyola (IL)", "Texas-Rio Grande Valley")
  expect_resolves_as(sr, "mbb", c("BYU", "VCU", "LUC", "RGV"))
  expect_resolves_as(c("Brigham Young", "Louisiana State", "Nevada-Las Vegas"), "cfb", c("BYU", "LSU", "UNLV"))
  # typographic dashes and apostrophes fold too: Sports Reference's UNLV, a curly "Saint Mary's"
  unlv <- intToUtf8(c(78, 101, 118, 97, 100, 97, 8211, 76, 97, 115, 32, 86, 101, 103, 97, 115))
  smc <- intToUtf8(c(83, 97, 105, 110, 116, 32, 77, 97, 114, 121, 8217, 115))
  expect_resolves_as(c(unlv, "Nevada-Las Vegas", smc), "mbb", c("UNLV", "UNLV", "SMC"))
  # accents fold on both sides: the NHL API's accented name, ESPN's accented key
  expect_resolves_as(intToUtf8(c(77, 111, 110, 116, 114, 233, 97, 108, 32, 67, 97, 110, 97, 100, 105, 101, 110, 115)), "nhl", "MTL")
  expect_resolves_as(c("San Jose State", intToUtf8(c(83, 97, 110, 32, 74, 111, 115, 233, 32, 83, 116, 97, 116, 101))), "cfb", c("SJSU", "SJSU"))
  # a stray space does not stop a value matching
  expect_resolves_as(c("KC ", " kansas city chiefs"), "nfl", c("KC", "KC"))
})

test_that("sdv_team_colors returns hex codes keyed by input", {
  expect_warning(cols <- sdv_team_colors("nfl", c("KC", "BUF", "zzz")), class = "sdvplotR_unresolved_warning")
  expect_named(cols, c("KC", "BUF", "zzz"))
  expect_match(cols[1:2], "^#[0-9A-Fa-f]{6}$")
  expect_identical(unname(cols[3]), NA_character_)
  expect_match(sdv_team_colors("nfl", "KC", which = "secondary"), "^#")
  expect_match(sdv_team_colors("nfl", "KC", which = "all"), "^#.*, #")
  all_cols <- sdv_team_colors("nba", which = "all")
  expect_named(all_cols, c("team_id", "abbr", "name", "primary", "secondary"))
  expect_identical(nrow(all_cols), 30L)
})

test_that("sdv_color_palette drops unknown teams", {
  expect_warning(pal <- sdv_color_palette("nhl", c("TOR", "MTL", "nope")), class = "sdvplotR_unresolved_warning")
  expect_named(pal, c("TOR", "MTL"))
})

test_that("sdv_team_factor keeps only resolving values as levels", {
  f <- suppressWarnings(sdv_team_factor(c("KC", "buf", "OAK", "bad"), league = "nfl"))
  expect_s3_class(f, "factor")
  expect_setequal(levels(f), c("buf", "KC", "OAK"))
  expect_identical(as.character(f), c("KC", "buf", "OAK", NA))
})

test_that("sdv_clear_cache clears the caches and returns NULL", {
  withr::local_envvar(R_USER_CACHE_DIR = withr::local_tempdir())
  expect_null(suppressMessages(sdv_clear_cache()))
})

test_that("NFL headshots resolve GSIS ids through the published map", {
  local_headshot_map()
  u <- headshot_from_id(c("00-0033873", "00-0031078", "11765", "00-0099999", "bad", NA), "nfl", "gsis")
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
  expect_identical(headshot_from_id(c("00-0033873", NA), "nfl", "gsis"), c(NA_character_, NA_character_))
})

# online, as a user's session is: setup.R turns sdvplotR.offline on for the suite
local_fresh_headshot_map <- function(env = parent.frame()) {
  withr::local_options(sdvplotR.offline = FALSE, .local_envir = env)
  # an --as-cran check (R-hub ubuntu-next) sets these, and probably_cran() then reads the snapshot
  withr::local_envvar(
    "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = "",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_" = "",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_XTRA_" = "",
    "_R_CHECK_PACKAGE_NAME_" = "",
    .local_envir = env
  )
  forget_headshot_map()
  withr::defer(forget_headshot_map(), envir = env)
}

test_that("offline, the headshot map is never fetched", {
  local_fresh_headshot_map()
  withr::local_options(sdvplotR.offline = TRUE)
  calls <- 0
  local_mocked_bindings(read_rds_url = function(...) {
    calls <<- calls + 1
    headshot_map_fixture
  })
  expect_identical(nrow(load_headshot_map()), 0L)
  expect_identical(calls, 0)
})

test_that("read_rds_url reads a compressed .rds through a url connection", {
  path <- withr::local_tempfile(fileext = ".rds")
  saveRDS(headshot_map_fixture, path) # gzip, as the release asset is
  url <- paste0("file:///", gsub("\\", "/", normalizePath(path), fixed = TRUE))
  expect_identical(read_rds_url(url), headshot_map_fixture)
})

test_that("read_rds_url warns and returns NULL when the read fails", {
  path <- withr::local_tempfile(fileext = ".rds")
  writeLines("not an rds", path)
  url <- paste0("file:///", gsub("\\", "/", normalizePath(path), fixed = TRUE))
  expect_warning(out <- read_rds_url(url), "Failed to read")
  expect_null(out)
})

test_that("read_rds_url warns and returns NULL when the url can't be opened", {
  # the offline / 404 case: the failure is in opening the connection, not reading it
  missing <- file.path(withr::local_tempdir(), "absent.rds")
  url <- paste0("file:///", gsub("\\", "/", missing, fixed = TRUE))
  expect_warning(out <- read_rds_url(url), "Failed to read")
  expect_null(out)
})

test_that("load_headshot_map returns an empty map when the release can't be read", {
  local_fresh_headshot_map()
  local_mocked_bindings(read_rds_url = function(...) NULL)
  m <- load_headshot_map()
  expect_identical(nrow(m), 0L)
  expect_true(all(c("gsis_id", "headshot_nfl", "espn_id") %in% names(m)))
})

test_that("a failed map read is not cached, so the next call retries", {
  local_fresh_headshot_map()
  calls <- 0
  reader <- function(url) {
    calls <<- calls + 1
    data.frame()
  }
  local_mocked_bindings(read_rds_url = reader)
  load_headshot_map()
  load_headshot_map()
  expect_identical(calls, 2)
})

test_that("sdv_clear_cache forgets the headshot map", {
  withr::local_envvar(R_USER_CACHE_DIR = withr::local_tempdir())
  local_fresh_headshot_map()
  calls <- 0
  reader <- function(url) {
    calls <<- calls + 1
    headshot_map_fixture
  }
  local_mocked_bindings(read_rds_url = reader)
  load_headshot_map()
  load_headshot_map()
  expect_identical(calls, 1) # a good read stays cached
  suppressMessages(sdv_clear_cache())
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
  local_fresh_headshot_map() # online: the suite runs offline
  m <- load_headshot_map()
  expect_gt(nrow(m), 15000)
  expect_false(anyDuplicated(m$gsis_id) > 0)
  h <- curlGetHeaders(headshot_from_id("00-0033873", "nfl", "gsis"))
  expect_identical(attr(h, "status"), 200L)
})

test_that("id_system = 'league' resolves league ids on the league's own CDN", {
  expect_identical(
    headshot_from_id(c("2544", "abc", NA), "nba", id_system = "league"),
    c("https://cdn.nba.com/headshots/nba/latest/260x190/2544.png", NA, NA)
  )
  expect_identical(
    headshot_from_id(1642286, "wnba", id_system = "league"),
    "https://cdn.wnba.com/headshots/wnba/latest/260x190/1642286.png"
  )
  # the NHL API's own headshot for players with no current team; same image as
  # the season/team mug, so no map is needed
  expect_identical(
    headshot_from_id(c(8478402, 8447400), "nhl", id_system = "league"),
    c("https://assets.nhle.com/mugs/nhl/latest/8478402.png", "https://assets.nhle.com/mugs/nhl/latest/8447400.png")
  )
  expect_match(
    headshot_from_id("660271", "mlb", id_system = "league"),
    "^https://img\\.mlbstatic\\.com/.*/v1/people/660271/headshot/67/current\\.png$"
  )
  # the default: numeric ids are ESPN athlete ids
  expect_identical(
    headshot_from_id("2544", "nba"),
    "https://a.espncdn.com/combiner/i?img=/i/headshots/nba/players/full/2544.png"
  )
})

test_that("ESPN athlete ids for the NFL need no map (the default)", {
  local_mocked_bindings(load_headshot_map = function() stop("the map was read"), .package = "sdvplotR")
  expect_identical(
    headshot_from_id(c("3139477", "00-0033873"), "nfl"),
    c("https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/3139477.png", NA)
  )
})

test_that("id_system = 'league' for the NFL is the gsis id", {
  local_headshot_map()
  expect_identical(check_id_system("league", "nfl"), "gsis")
  expect_identical(
    headshot_from_id("00-0033873", "nfl", check_id_system("league", "nfl")),
    headshot_from_id("00-0033873", "nfl", "gsis")
  )
})

test_that("check_id_system validates the id system for the league", {
  expect_identical(check_id_system("espn", "nhl"), "espn")
  expect_identical(check_id_system("league", "wnba"), "league")
  expect_identical(check_id_system("gsis", "nfl"), "gsis")
  expect_identical(check_id_system("league", "nhl"), "league")
  expect_error(check_id_system("league", "wbb"), "not available by league player id")
  expect_error(check_id_system("league", "cfb"), "not available by league player id")
  expect_error(check_id_system("gsis", "nba"), "NFL")
  expect_error(check_id_system("espn", "ahl"), "No ESPN headshots")
  expect_error(check_id_system("nfl", "nfl"))
})

test_that("the accent pass never errors on unmarked or latin1 input", {
  mtl <- sdv_resolve("MTL", "nhl")
  latin1 <- iconv("Montr\u00e9al Canadiens", "UTF-8", "latin1")
  expect_identical(sdv_resolve(latin1, "nhl"), mtl)
  skip_on_os("windows")
  # a CSV read without an encoding in a C locale (a Docker image with no locale)
  unmarked <- "Montr\u00e9al Canadiens"
  Encoding(unmarked) <- "unknown"
  withr::with_locale(c(LC_CTYPE = "C"), {
    expect_no_error(suppressWarnings(sdv_resolve(c("TOR", unmarked), "nhl")))
    expect_identical(sdv_resolve(c("TOR", latin1), "nhl"), c(sdv_resolve("TOR", "nhl"), mtl))
  })
})

test_that("sdv_example_standings keys resolve to themselves in every league", {
  d <- sdv_example_standings
  expect_identical(as.vector(table(d$league)[c("nfl", "nba")]), c(32L, 30L))
  for (lg in unique(d$league)) {
    k <- d$team[d$league == lg]
    expect_identical(sdv_resolve(k, lg), sdv_teams(lg)$team_id[match(k, sdv_teams(lg)$abbr)])
  }
  # NA only where a team missed the playoffs (14 NFL and 16 NBA teams made them)
  expect_identical(sum(!is.na(d$playoff_wins)), 30L)
  expect_false(anyNA(d[setdiff(names(d), "playoff_wins")]))
})


test_that("with_chrome_timeout() gives Chrome at least 60 seconds, keeps a longer setting, and restores", {
  withr::local_options(chromote.timeout = NULL)
  seen <- with_chrome_timeout(getOption("chromote.timeout"))
  expect_equal(seen, 60)
  expect_null(getOption("chromote.timeout"))
  withr::local_options(chromote.timeout = 5)
  expect_equal(with_chrome_timeout(getOption("chromote.timeout")), 60)
  expect_equal(getOption("chromote.timeout"), 5)
  withr::local_options(chromote.timeout = 120)
  expect_equal(with_chrome_timeout(getOption("chromote.timeout")), 120)
  expect_equal(getOption("chromote.timeout"), 120)
})

test_that(".resolve_palette passes hex vectors through without paletteer", {
  pal <- c("#3D8B6E", "#BE4D3A")
  expect_identical(.resolve_palette(pal), pal)
})

test_that(".resolve_palette expands a paletteer name from either registry", {
  skip_if_not_installed("paletteer")
  d <- .resolve_palette("viridis::mako", pal_type = "continuous")
  expect_length(d, 256)
  expect_match(d, "^#[0-9A-Fa-f]{6}")
})
