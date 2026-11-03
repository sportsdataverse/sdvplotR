skip_on_cran()

test_that("sdv_logo_url() returns archive URLs for every league's teams", {
  local_snapshot_index()
  for (lg in c("nfl", "ahl", "pwhl", "cfb", "soccer", "milb")) {
    t <- sdv_teams(lg)$team_id[1:5]
    u <- suppressWarnings(sdv_logo_url(t, lg)) # a team the archive lacks is NA with a warning (tested below)
    expect_gte(sum(!is.na(u)), 3L)
    expect_match(u[!is.na(u)], "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/assets/public/sha256/", info = lg)
  }
})

test_that("season picks the era's mark and conferences draw by key", {
  local_snapshot_index()
  old <- sdv_logo_url("QUE", "nhl", season = 1990)
  expect_false(identical(old, sdv_logo_url("COL", "nhl")))
  expect_match(sdv_logo_url("SEC", "cfb"), "^https://")
})

test_that("variants: default/dark always valid, a typo lists the league's variants", {
  local_snapshot_index()
  expect_match(sdv_logo_url("KC", "nfl", variant = "dark"), "^https://")
  expect_error(sdv_logo_url("KC", "nfl", variant = "primary"), "default")
  expect_error(sdv_logo_url("KC", "nfl", mark_type = "headshot"), "mark_type")
})

test_that("wordmarks come from the manifest, NA with a warning where a league has none", {
  local_snapshot_index()
  expect_match(sdv_logo_url("KC", "nfl", mark_type = "wordmark"), "^https://")
  expect_warning(u <- sdv_logo_url("BOS", "nba", mark_type = "wordmark"), "wordmark")
  expect_true(is.na(u))
})

test_that("select_mark ranks by variant, then season coverage, then source", {
  local_snapshot_index()
  kc <- sdv_resolve("KC", "nfl")
  m <- sdv_marks("KC", "nfl")
  expect_true(all(m$team_id == kc))
  expect_true(all(diff(m$source_rank) >= 0))
  row <- select_mark(kc, "nfl", NA_integer_, "default", "logo")
  expect_identical(row$archive_url, sdv_logo_url("KC", "nfl"))
})

test_that("ranking puts open-ended, then latest-ending marks first within a source", {
  local_snapshot_index()
  default_logos <- function(m, src) m[m$variant == "default" & m$mark_type == "logo" & m$source == src, ]
  lv <- default_logos(sdv_marks("LV", "nfl"), "espn") # source_rank 0: today's logo, then 1960-2019
  expect_identical(lv$valid_to, c(NA, 2019L))
  col <- default_logos(sdv_marks("COL", "nhl"), "nhl") # three closed eras, latest-ending first
  expect_length(col$valid_to, 3L)
  expect_true(all(diff(col$valid_to) < 0))
})

test_that("select_mark takes a dated row covering the season, and dark falls back to default", {
  local_snapshot_index()
  lv <- sdv_resolve("LV", "nfl")
  expect_true(is.na(select_mark(lv, "nfl", NA_integer_, "default", "logo")$valid_to))
  old <- select_mark(lv, "nfl", 2000L, "default", "logo")
  expect_true(old$valid_from <= 2000L && old$valid_to >= 2000L)
  # the AHL's Hartford Wolf Pack have no dark logo: the season's default, the latest-ending covering row
  hw <- select_mark("307", "ahl", 2010L, "dark", "logo")
  expect_identical(hw$variant, "default")
  r <- ranked_marks("ahl")
  cov <- r[which(r$team_id == "307" & r$mark_type == "logo" & r$valid_from <= 2010L & r$valid_to >= 2010L), ]
  expect_gt(nrow(cov), 1L)
  expect_identical(hw$valid_to, max(cov$valid_to))
})

test_that("an unresolved team gives NA with the resolver's warning; vectors keep their length", {
  local_snapshot_index()
  expect_warning(u <- sdv_logo_url(c("KC", "nope", NA), "nfl"), class = "sdvplotR_unresolved_warning")
  expect_identical(is.na(u), c(FALSE, TRUE, TRUE))
})

test_that("every conference and league row draws", {
  local_snapshot_index()
  nt <- sdv_teams(include_conferences = TRUE)
  nt <- nt[nt$program %in% c("conference", "league"), , drop = FALSE]
  u <- suppressWarnings(mapply(sdv_logo_url, nt$team_id, nt$league))
  expect_identical(nt$team_id[is.na(u)], character(0)) # names the undrawable rows on failure
})

test_that("pro league, conference and division marks draw", {
  local_snapshot_index()
  # an NHL division is archived at manifest level "division", not "conference"
  for (k in list(
    c("MLB", "mlb"), c("AL", "mlb"), c("NL", "mlb"), c("NBA", "nba"), c("East", "nba"),
    c("WNBA", "wnba"), c("NHL", "nhl"), c("Metropolitan", "nhl"), c("Atlantic", "nhl"), c("AAF", "aaf"),
    # the NHL's conferences have only their Conference Final wordmarks, drawn as their logos
    c("Eastern", "nhl"), c("Western", "nhl"),
    c("CFL", "cfl"), c("Hockey East", "ncaa_mhockey"), c("NEWHA", "ncaa_whockey")
  )) {
    expect_match(sdv_logo_url(k[1], k[2]), "^https://", info = k[1])
  }
})

test_that("a team never borrows its wordmark as a logo", {
  local_snapshot_index()
  # MLB teams have wordmarks; their logo is still a logo row
  expect_false(identical(sdv_logo_url("NYY", "mlb"), sdv_logo_url("NYY", "mlb", mark_type = "wordmark")))
})

test_that("the new leagues resolve and draw", {
  local_snapshot_index()
  for (lg in c("cfl", "cebl", "easl", "lba", "f1", "nbl", "fiba", "iihf", "sphl", "ojhl")) {
    t <- sdv_teams(lg)
    expect_gt(nrow(t), 0)
    expect_match(sdv_logo_url(t$team_id[1], lg), "^https://", info = lg)
  }
})

test_that("a team's conference name draws its conference's logo", {
  local_snapshot_index()
  for (lg in c("ncaa_baseball", "ncaa_softball", "ncaa_mhockey", "ncaa_whockey")) {
    carried <- unique(stats::na.omit(sdv_teams(lg)$conference))
    u <- suppressWarnings(vapply(carried, function(x) sdv_logo_url(x, lg), ""))
    expect_identical(carried[is.na(u)], character(0), info = lg)
  }
})
