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

test_that("ranking puts open-ended, then latest-ending marks first within a source (radix NA handling)", {
  r <- data.frame(source_rank = c(0L, 0L, 0L), valid_to = c(2010L, NA, 2020L), first_seen = "2026-01-01",
                  valid_from = NA_integer_, sha256 = c("a", "b", "c"))
  o <- order(r$source_rank, is.na(r$valid_to), r$valid_to, r$first_seen, r$valid_from, r$sha256,
             decreasing = c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE), method = "radix", na.last = TRUE)
  expect_identical(r$sha256[o], c("b", "c", "a"))
})

test_that("an unresolved team gives NA with the resolver's warning; vectors keep their length", {
  local_snapshot_index()
  expect_warning(u <- sdv_logo_url(c("KC", "nope", NA), "nfl"), class = "sdvplotR_unresolved_warning")
  expect_identical(is.na(u), c(FALSE, TRUE, TRUE))
})
