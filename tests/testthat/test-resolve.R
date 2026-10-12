skip_on_cran()

golden <- function() {
  utils::read.csv(testthat::test_path("fixtures", "resolve_golden.csv"),
    colClasses = "character", na.strings = NULL, encoding = "UTF-8"
  )
}

test_that("the golden file was made from the same index as the snapshot", {
  expect_identical(unique(golden()$index_version), snapshot_meta$index_version)
})

test_that("sdv_resolve() gives Python's answer for every golden key", {
  local_snapshot_index()
  g <- golden()
  g <- g[g$kind == "resolve", ]
  got <- vapply(seq_len(nrow(g)), function(i) {
    v <- if (g$value_type[i] == "integer") as.integer(g$value[i]) else g$value[i]
    s <- if (nzchar(g$season[i])) as.integer(g$season[i]) else NULL
    suppressWarnings(sdv_resolve(v, g$league[i], season = s, id_system = g$id_system[i]))
  }, character(1))
  got[is.na(got)] <- ""
  bad <- g[got != g$expected, ]
  expect_identical(nrow(bad), 0L, info = paste(utils::capture.output(print(utils::head(cbind(bad, got = got[got != g$expected]), 20))), collapse = "\n"))
  # ok / none (normalizes to nothing, never reported) / unknown / ambiguous, as Python's _resolve_ids classifies it
  why <- vapply(seq_len(nrow(g)), function(i) {
    v <- if (g$value_type[i] == "integer") as.integer(g$value[i]) else g$value[i]
    s <- if (nzchar(g$season[i])) as.integer(g$season[i]) else NULL
    r <- resolve_ids(v, g$league[i], season = s, id_system = g$id_system[i])
    if (!is.na(r$ids)) "ok" else if (is.na(r$why)) "none" else sub(":.*", "", r$why)
  }, character(1))
  expect_identical(why, g$reason, info = paste(which(why != g$reason), collapse = ", "))
})

test_that("sdv_suggest() puts Python's top candidate first", {
  local_snapshot_index()
  g <- golden()
  g <- g[g$kind == "suggest", ]
  top <- vapply(seq_len(nrow(g)), function(i) {
    s <- sdv_suggest(g$value[i], g$league[i], n = 1)
    if (nrow(s)) s$team_id[[1]] else ""
  }, character(1))
  expect_identical(top, g$expected)
})

test_that("factors, numbers and padded strings resolve like the plain string", {
  local_snapshot_index()
  kc <- sdv_resolve("KC", "nfl")
  expect_identical(sdv_resolve(factor(c("KC", "KC")), "nfl"), c(kc, kc))
  expect_identical(sdv_resolve(c(12, 12.0), "nfl"), sdv_resolve(c("12", "12.0"), "nfl"))
  expect_identical(sdv_resolve(" 12 ", "nfl"), sdv_resolve("12", "nfl"))
  expect_no_warning(out <- sdv_resolve(c(NA, "", "KC"), "nfl"))
  expect_identical(out, c(NA, NA, kc))
})

test_that("Unicode spaces fold like Python's strip() and NFKD", {
  local_snapshot_index()
  kc <- sdv_resolve("Kansas City Chiefs", "nfl")
  expect_false(is.na(kc))
  expect_identical(sdv_resolve("Kansas\u00a0City Chiefs", "nfl"), kc)
  expect_identical(sdv_resolve("Kansas City Chiefs\u00a0", "nfl"), kc)
})

test_that("sdv_suggest() keeps its columns when nothing is close", {
  local_snapshot_index()
  s <- sdv_suggest("zzzzzzzz", "nfl")
  expect_named(s, c("team_id", "name"))
  expect_identical(nrow(s), 0L)
})

test_that("unknown values warn once and strict errors", {
  local_snapshot_index()
  expect_warning(out <- sdv_resolve(c("nope", "nope", "KC"), "nfl"), class = "sdvplotR_unresolved_warning")
  expect_identical(is.na(out), c(TRUE, TRUE, FALSE))
  expect_error(sdv_resolve("nope", "nfl", strict = TRUE), class = "sdvplotR_unresolved")
})

test_that("season picks the team that used a reused code", {
  local_snapshot_index()
  expect_identical(sdv_resolve("OAK", "nfl"), sdv_resolve("LV", "nfl"))
  # whether the Nordiques are their own team_id or the Avalanche's is the index's call; the golden file pins it
  expect_false(is.na(sdv_resolve("QUE", "nhl", season = 1990)))
})

test_that("bad seasons and lengths say what to pass", {
  local_snapshot_index()
  expect_error(sdv_resolve("KC", "nfl", season = "2020-21"), "2021")
  expect_error(sdv_resolve(c("KC", "BUF", "SF"), "nfl", season = c(2020, 2021)), "3 teams")
  expect_error(sdv_resolve("KC", "nfl", season = 20042005), "outside")
  # too big for an integer, or not finite: an error, never a silently dropped season
  expect_no_warning(expect_error(sdv_resolve("KC", "nfl", season = 1e10), "must be a year"))
  expect_no_warning(expect_error(sdv_resolve("KC", "nfl", season = Inf), "must be a year"))
})

test_that("league and id_system are checked", {
  local_snapshot_index()
  expect_error(sdv_resolve("KC", "nfll"), "Unknown league")
  expect_error(sdv_resolve("KC", c("nfl", "nba")), "one league key")
  expect_error(sdv_resolve("KC", "nfl", id_system = "gsis"), "id_system")
  expect_length(sdv_leagues(), 28L)
})

test_that("sdv_teams() lists teams, and conferences on request", {
  local_snapshot_index()
  t <- sdv_teams("cfb")
  ct <- sdv_teams("cfb", include_conferences = TRUE)
  expect_named(t, c(
    "league", "team_id", "abbr", "name", "short_name", "location", "program",
    "conference_id", "conference", "color_primary", "color_secondary", "color_source"
  ))
  expect_false(any(t$program %in% c("conference", "league")))
  expect_true("SEC" %in% ct$team_id)
  expect_identical(nrow(sdv_teams("nfl")), 32L)
})

test_that("an ambiguous value's warning names every candidate", {
  local_snapshot_index()
  expect_warning(
    out <- sdv_resolve("Manchester City", "soccer"),
    "ambiguous: 19257[[:space:]]+Manchester City[[:space:]]+or[[:space:]]+382[[:space:]]+Manchester City",
    class = "sdvplotR_unresolved_warning"
  )
  expect_identical(out, NA_character_)
})
