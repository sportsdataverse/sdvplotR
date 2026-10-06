test_that("soccer clubs resolve by ESPN id, and by name when no other club shares it", {
  expect_true("soccer" %in% supported_sports())
  expect_identical(clean_team_abbrs("359", "soccer"), "359")
  expect_identical(clean_team_abbrs("Atlanta United FC", "soccer"), "18418")
  expect_identical(clean_team_abbrs("Canberra United ", "soccer"), "20288")
  expect_identical(clean_team_abbrs(" Atlanta United FC", "soccer"), "18418")
  expect_identical(toupper(unname(sdv_team_colors("soccer", "359", type = "primary"))), "#E20520")
})

test_that("a shared soccer name warns with its candidates and stays unresolved", {
  withr::local_options(sdvplotR.verbose = TRUE)
  expect_warning(
    out <- clean_team_abbrs("Manchester City", "soccer", keep_non_matches = FALSE),
    "382.*19257|19257.*382"
  )
  expect_identical(out, NA_character_)
})

test_that("a soccer surface takes a team: logo at the center spot, the pitch stays green", {
  skip_if_not_installed("sportyR")
  plain <- sdv_surface("soccer")
  team <- sdv_surface("soccer", "359")
  expect_identical(surface_colors(team), surface_colors(plain))
  with_logo <- sdv_surface("soccer", "359", center_logo = TRUE)
  expect_length(with_logo$layers, length(plain$layers) + 1L)
  expect_equal(with_logo$layers[[length(with_logo$layers)]]$geom_params$logo_size, 18.3)
})

test_that("no soccer alias key has leading or trailing whitespace", {
  k <- names(abbr_mapping$soccer)
  expect_identical(k, trimws(k))
})

test_that("names shared after trimming or accent-folding warn with both ids", {
  withr::local_options(sdvplotR.verbose = TRUE)
  expect_warning(
    out <- clean_team_abbrs("Sydney FC", "soccer", keep_non_matches = FALSE),
    "20285.*5327|5327.*20285"
  )
  expect_identical(out, NA_character_)
  expect_warning(
    out <- clean_team_abbrs("Guaraní", "soccer", keep_non_matches = FALSE),
    "3448.*7385|7385.*3448"
  )
  expect_identical(out, NA_character_)
  expect_identical(clean_team_abbrs("Atlanta United FC", "soccer", keep_non_matches = FALSE), "18418")
})
