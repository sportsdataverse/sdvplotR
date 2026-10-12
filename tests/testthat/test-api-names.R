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
  # sdv_team_tiers takes "auto" (dark marks on the dark theme), as sdvplot's team_tiers()
  for (f in setdiff(takes("variant"), "sdv_team_tiers")) {
    expect_identical(formals(get(f, ns))$variant, "default", info = f)
  }
  expect_identical(formals(sdv_team_tiers)$variant, "auto")
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

test_that("every helper that resolves teams takes season, id_system and strict", {
  ns <- asNamespace("sdvplotR")
  need <- list(
    list(args = c("season", "id_system", "strict"), fns = c(
      "gt_sdv_logos", "gt_sdv_wordmarks", "gt_sdv_cols_label", "reactable_sdv_logos",
      "reactable_sdv_wordmarks", "reactable_sdv_cols_label", "reactable_sdv_team_color_bar",
      "reactable_sdv_team_color_bg", "sdv_logo_url", "sdv_team_colors", "sdv_color_palette"
    )),
    list(args = c("id_system", "strict"), fns = c("geom_sdv_logos", "geom_sdv_wordmarks")),
    list(args = c("season", "id_system"), fns = c(
      "element_sdv_logo", "element_sdv_wordmark", "scale_x_sdv", "scale_y_sdv",
      "gt_merge_stack_team_color", "gt_theme_sdv_team"
    ))
  )
  for (n in need) for (f in n$fns) expect_true(all(n$args %in% names(formals(get(f, ns)))), info = f)
})
