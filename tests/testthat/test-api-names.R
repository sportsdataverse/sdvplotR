skip_on_cran()

exported_fns <- function() {
  ns <- asNamespace("sdvplotR")
  fns <- getNamespaceExports("sdvplotR")
  fns[vapply(fns, function(f) is.function(get(f, ns)), logical(1))]
}

takes <- function(arg) {
  ns <- asNamespace("sdvplotR")
  Filter(function(f) arg %in% names(formals(get(f, ns))), exported_fns())
}

test_that("no exported function takes the old argument names", {
  ns <- asNamespace("sdvplotR")
  expect_identical(takes("sport"), character())
  expect_identical(takes("id_type"), character())
  # `type` survives only where it is not a team field (a legend style)
  expect_setequal(takes("type"), "gt_legend_continuous")
  for (f in takes("variant")) expect_identical(formals(get(f, ns))$variant, "default", info = f)
  for (f in takes("id_system")) {
    d <- formals(get(f, ns))$id_system
    expect_true(identical(d, "auto") || identical(d, "espn"), info = f)
  }
})

test_that("the removed helpers are gone", {
  removed <- c(
    "supported_sports", "team_reference", "valid_team_names", "clean_team_abbrs",
    "resolve_historical_abbr", "sdvplotR_clear_cache"
  )
  expect_identical(intersect(removed, ls(asNamespace("sdvplotR"))), character())
})

test_that("headshots default to ESPN ids in every league, NFL included", {
  expect_match(sdv_headshot_url(3139477, "nfl"), "espncdn.com/.*/nfl/players/full/3139477.png")
  expect_error(sdv_headshot_url("00-0033873", "nba", id_system = "gsis"), "NFL")
  expect_error(sdv_headshot_url(1, "cfb", id_system = "league"), "league player")
  expect_match(sdv_headshot_url(2544, "nba", id_system = "league"), "cdn.nba.com")
})

test_that("colours resolve any id system and name the result by the input", {
  kc <- sdv_team_colors("nfl", c("KC", "Kansas City Chiefs"))
  expect_named(kc, c("KC", "Kansas City Chiefs"))
  expect_identical(unname(kc[1]), unname(kc[2]))
  all <- sdv_team_colors("nfl", which = "all")
  expect_named(all, c("team_id", "abbr", "name", "primary", "secondary"))
  expect_identical(nrow(all), 32L)
  expect_error(sdv_team_colors("nfl", "KC", which = "tertiary"))
})
