test_that("supported_sports lists the eight leagues and soccer", {
  expect_identical(
    supported_sports(),
    c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer")
  )
})

test_that("valid_team_names returns complete, sorted pro rosters", {
  expect_length(valid_team_names("nfl"), 32)
  # the AFC, NFC and NFL logos only when asked for
  expect_length(valid_team_names("nfl", include_conferences = TRUE), 35)
  expect_in(c("AFC", "NFC", "NFL"), valid_team_names("nfl", include_conferences = TRUE))
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
      "logo_dark_url", "wordmark_url", "color1", "color2", "conference", "division", "type"
    ),
    names(ref)
  )
  expect_identical(nrow(ref), 32L)
  expect_false(anyNA(ref$logo_url))
  all <- team_reference("nfl", include_conferences = TRUE)
  expect_setequal(all$team_abbr[all$type != "team"], c("AFC", "NFC", "NFL"))
  expect_setequal(names(sdv_team_colors("cfb")), team_reference("cfb")$team_abbr[!is.na(team_reference("cfb")$color1)])
})

test_that("every team has real colors, with their source recorded", {
  teams <- logo_ref[logo_ref$type == "team", ]
  expect_false(anyNA(teams$color1))
  expect_match(teams$color1, "^#[0-9A-F]{6}$")
  # ESPN's stand-in (black alone, with its stock red, or on black) is not a team's color
  stand_in <- teams$color1 == "#000000" & (is.na(teams$color2) | teams$color2 %in% c("#000000", "#C60000"))
  expect_identical(teams$team_abbr[stand_in], character())
  expect_setequal(unique(teams$color_source), c("nflverse", "espn", "logo"))
  expect_true(all(teams$color_source[teams$sport == "nfl"] == "nflverse"))
  expect_true(all(teams$color_source[teams$sport %in% c("nba", "wnba", "mlb", "nhl")] == "espn"))
  # two of the 38 teams 0.1.0 drew black or NA: Chicago State from ESPN's basketball
  # entry, Campbell from its logo (both through sdvplot's index)
  expect_identical(sdv_team_colors("cfb", "CHST"), c(CHST = "#006700"))
  expect_identical(teams$color_source[teams$sport == "cfb" & teams$team_abbr == "CHST"], "espn")
  expect_identical(sdv_team_colors("mbb", "CAM", type = "all"), c(CAM = "#FF4713, #2E1811"))
  expect_identical(teams$color_source[teams$sport == "mbb" & teams$team_abbr == "CAM"], "logo")
  # conferences keep cbbplotR's colors; the AFC, NFC and NFL have none
  expect_in("color_source", names(team_reference("nfl")))
  confs <- team_reference("mbb", include_conferences = TRUE)
  expect_identical(unique(confs$color_source[confs$type == "conference" & !is.na(confs$color1)]), "cbbplotR")
  nfl <- team_reference("nfl", include_conferences = TRUE)
  expect_true(all(is.na(nfl$color_source[nfl$type != "team"])))
})

test_that("conferences resolve like teams, and a team keeps a shared name", {
  mbb <- team_reference("mbb", include_conferences = TRUE)
  confs <- mbb$team_abbr[mbb$type == "conference"]
  expect_in(c("ACC", "Big Ten", "SEC", "A-10", "AAC", "MAAC", "WCC"), confs)
  # every conference resolves to itself, and every team's conference has a row
  # (the UAC has no ESPN logo)
  expect_identical(clean_team_abbrs(confs, "mbb", keep_non_matches = FALSE), confs)
  expect_in(setdiff(mbb$conference[mbb$type == "team"], "UAC"), confs)
  # ESPN, NCAA and KenPom names for a conference
  expect_identical(
    clean_team_abbrs(c("Big Ten Conference", "B10", "Atlantic 10", "MWC"), "mbb", keep_non_matches = FALSE),
    c("Big Ten", "Big Ten", "A-10", "Mountain West")
  )
  # names a team already uses stay the team's
  expect_identical(clean_team_abbrs(c("American", "SC"), "mbb"), c("AMER", "SC"))
  expect_identical(clean_team_abbrs("Southern", "cfb"), "SOU")
  expect_match(logo_from_team("SEC", "cfb"), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
  expect_match(logo_from_team("AFC", "nfl"), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
  expect_false(identical(logo_from_team("SEC", "cfb"), logo_from_team("AFC", "nfl")))
})

test_that("historical conference names draw the conference's lineage", {
  # sportsdataverse-data's cfb_groups / mbb_groups: Pac-8, Pac-10 and the AAWU
  # are one lineage with the Pac-12
  expect_identical(
    clean_team_abbrs(c("Pac-10", "pac-10", "Pacific-10 Conference", "Pac-8", "AAWU"), "cfb", keep_non_matches = FALSE),
    rep("Pac-12", 5)
  )
  expect_identical(clean_team_abbrs(c("Pac-10", "P10"), "mbb", keep_non_matches = FALSE), c("Pac-12", "Pac-12"))
  expect_identical(clean_team_abbrs("Pac-10", "wbb", keep_non_matches = FALSE), "Pac-12")
  expect_identical(logo_from_team("Pac-10", "cfb"), logo_from_team("Pac-12", "cfb"))
  # other renamed conferences: Mid-Continent -> Summit, Midwestern Collegiate
  # -> Horizon, Colonial -> CAA, Gateway -> MVFC, Colonial League -> Patriot
  expect_identical(
    clean_team_abbrs(
      c("Mid-Continent Conference", "Midwestern Collegiate Conference", "Colonial Athletic Association"),
      "mbb",
      keep_non_matches = FALSE
    ),
    c("Summit", "Horizon", "CAA")
  )
  expect_identical(
    clean_team_abbrs(c("Gateway Football Conference", "Colonial League", "I-AA Independents"), "cfb", keep_non_matches = FALSE),
    c("MVFC", "Patriot", "FCS Indep.")
  )
  # a name two lineages share stays unmatched; a team's name stays the team's;
  # a lineage without a conference row (cfb's Big West) gets no names
  expect_identical(
    clean_team_abbrs(c("Western", "South", "USA", "Southern", "Big West", "IND", "CL", "COL"), "cfb", keep_non_matches = FALSE),
    c(NA, NA, "USA", "SOU", NA, NA, NA, NA)
  )
  # generic short codes stay unmatched rather than drawing a conference logo
  expect_identical(clean_team_abbrs("COL", "mbb", keep_non_matches = FALSE), NA_character_)
  expect_identical(clean_team_abbrs("American", "mbb", keep_non_matches = FALSE), "AMER")
})

test_that("the WAC draws ESPN's archived mark, and the UAC it became does not", {
  # ESPN has no logo for football's WAC (gone after 2022) or for basketball
  # group 30, which it now labels the United Athletic Conference
  for (s in c("cfb", "mbb", "wbb")) {
    expect_identical(
      clean_team_abbrs(c("WAC", "wac", "Western Athletic Conference"), s, keep_non_matches = FALSE),
      rep("WAC", 3)
    )
    # ESPN's archived wac.png, served from the SportsDataverse archive
    expect_match(logo_from_team("WAC", s), "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/")
    expect_identical(logo_from_team("WAC", s), logo_from_team("WAC", "cfb"))
    expect_identical(
      clean_team_abbrs(c("UAC", "United Athletic Conference"), s, keep_non_matches = FALSE),
      c(NA_character_, NA_character_)
    )
  }
  # CFBD's short name for football's WAC
  expect_identical(clean_team_abbrs("Western Athletic", "cfb", keep_non_matches = FALSE), "WAC")
  # a conference row, listed with the conferences only
  expect_false("WAC" %in% valid_team_names("mbb"))
  expect_true("WAC" %in% valid_team_names("mbb", include_conferences = TRUE))
})

test_that("every key that resolved to a conference still resolves to it", {
  # every key abbr_mapping sent to a conference / league row before the
  # historical names were added (R/sysdata.rda at 3dd4514)
  keys <- utils::read.csv(test_path("fixtures", "conference_keys.csv"), colClasses = "character")
  for (s in unique(keys$sport)) {
    k <- keys[keys$sport == s, ]
    expect_identical(clean_team_abbrs(k$key, s, keep_non_matches = FALSE), k$abbr)
  }
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
  # ESPN box scores abbreviate Butler and New Orleans differently from its teams list
  expect_identical(clean_team_abbrs(c("BUT", "UNO"), "mbb", keep_non_matches = FALSE), c("BTLR", "NOLA"))
  expect_identical(clean_team_abbrs(c("BUT", "UNO"), "wbb", keep_non_matches = FALSE), c("BTLR", "NOLA"))
  # ESPN's FPI writes Buffalo BUFF and Air Force AFA
  expect_identical(clean_team_abbrs(c("BUFF", "AFA"), "cfb", keep_non_matches = FALSE), c("BUF", "AF"))
  # NCAA.com / stats.ncaa.org, KenPom and Torvik school names
  ncaa <- c("Iowa St.", "St. John's (NY)", "Saint Mary's (CA)", "Southern California", "Miami (FL)", "Miami (OH)")
  expect_identical(clean_team_abbrs(ncaa, "mbb", keep_non_matches = FALSE), c("ISU", "SJU", "SMC", "USC", "MIA", "M-OH"))
  expect_identical(clean_team_abbrs(ncaa, "wbb", keep_non_matches = FALSE), c("ISU", "SJU", "SMC", "USC", "MIA", "M-OH"))
  expect_identical(clean_team_abbrs(c("Iowa St.", "Southern California", "Miami (OH)"), "cfb", keep_non_matches = FALSE), c("ISU", "USC", "M-OH"))
  # ESPN's own names keep their meaning
  expect_identical(clean_team_abbrs(c("Miami", "Iowa State"), "mbb", keep_non_matches = FALSE), c("MIA", "ISU"))
  # Sports Reference's names, keyed by ESPN id, so they serve football too
  sr <- c("Brigham Young", "Virginia Commonwealth", "Loyola (IL)", "Texas-Rio Grande Valley")
  expect_identical(clean_team_abbrs(sr, "mbb", keep_non_matches = FALSE), c("BYU", "VCU", "LUC", "RGV"))
  expect_identical(clean_team_abbrs(c("Brigham Young", "Louisiana State", "Nevada-Las Vegas"), "cfb", keep_non_matches = FALSE), c("BYU", "LSU", "UNLV"))
  # typographic dashes and apostrophes fold too: Sports Reference's UNLV, a curly "Saint Mary's"
  unlv <- intToUtf8(c(78, 101, 118, 97, 100, 97, 8211, 76, 97, 115, 32, 86, 101, 103, 97, 115))
  smc <- intToUtf8(c(83, 97, 105, 110, 116, 32, 77, 97, 114, 121, 8217, 115))
  expect_identical(clean_team_abbrs(c(unlv, "Nevada-Las Vegas", smc), "mbb", keep_non_matches = FALSE), c("UNLV", "UNLV", "SMC"))
  # accents fold on both sides: the NHL API's accented name, ESPN's accented key
  expect_identical(clean_team_abbrs("Montr\u00e9al Canadiens", "nhl", keep_non_matches = FALSE), "MTL")
  expect_identical(
    clean_team_abbrs(c("San Jose State", "San Jos\u00e9 State"), "cfb", keep_non_matches = FALSE),
    rep(clean_team_abbrs("San Jos\u00e9 State", "cfb"), 2)
  )
  expect_false(is.na(clean_team_abbrs("San Jose State", "cfb", keep_non_matches = FALSE)))
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

test_that("resolve_historical_abbr returns the package's canonical keys and agrees with clean_team_abbrs", {
  # the Rams are "LA" (nflverse), the Pelicans "NO" and the Wizards "WSH" (ESPN)
  expect_identical(resolve_historical_abbr("STL", "nfl"), "LA")
  expect_identical(resolve_historical_abbr(c("NOH", "NOK", "WSB"), "nba"), c("NO", "NO", "WSH"))
  # "WIN" is the original Jets (1979-96, now Utah), not today's Jets ("WPG")
  expect_identical(resolve_historical_abbr("WIN", "nhl"), "UTAH")
  expect_identical(clean_team_abbrs("WIN", "nhl"), "UTAH")
  expect_identical(clean_team_abbrs("WPG", "nhl"), "WPG")
  for (s in names(historical_team_mappings)) {
    m <- historical_team_mappings[[s]]
    canonical <- get_team_ref(s)$team_abbr
    expect_in(unname(m), canonical)
    # a relocation key is never a current team's abbreviation
    expect_false(any(names(m) %in% canonical), label = s)
    expect_identical(resolve_historical_abbr(names(m), s), unname(m), label = s)
    expect_identical(clean_team_abbrs(names(m), s), unname(m), label = s)
  }
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

test_that("the accent pass never errors on unmarked or latin1 input", {
  latin1 <- iconv("Montr\u00e9al Canadiens", "UTF-8", "latin1")
  expect_identical(clean_team_abbrs(latin1, "nhl", keep_non_matches = FALSE), "MTL")
  skip_on_os("windows")
  # a CSV read without an encoding in a C locale (a Docker image with no locale)
  unmarked <- "Montr\u00e9al Canadiens"
  Encoding(unmarked) <- "unknown"
  withr::with_locale(c(LC_CTYPE = "C"), {
    expect_no_error(clean_team_abbrs(c("TOR", unmarked), "nhl"))
    expect_identical(clean_team_abbrs(c("TOR", latin1), "nhl", keep_non_matches = FALSE), c("TOR", "MTL"))
  })
})

test_that("sdv_example_standings keys resolve to themselves in every league", {
  d <- sdv_example_standings
  expect_identical(as.vector(table(d$league)[c("nfl", "nba")]), c(32L, 30L))
  for (lg in unique(d$league)) {
    k <- d$team[d$league == lg]
    expect_identical(clean_team_abbrs(k, lg, keep_non_matches = FALSE), k)
  }
  # NA only where a team missed the playoffs (14 NFL and 16 NBA teams made them)
  expect_identical(sum(!is.na(d$playoff_wins)), 30L)
  expect_false(anyNA(d[setdiff(names(d), "playoff_wins")]))
})

test_that("a stray space around a team value does not stop it matching", {
  expect_identical(clean_team_abbrs("KC ", "nfl"), "KC")
  expect_identical(clean_team_abbrs(" kansas city chiefs", "nfl"), "KC")
})
