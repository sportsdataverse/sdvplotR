# Every cfbplotR export (its NAMESPACE's 40 export() lines) and both of its
# datasets has an sdvplotR counterpart that takes the cfbplotR-style call with
# league = "cfb". Offline, on the bundled index. Rows that need data the
# bundled snapshot does not carry yet (CFB wordmarks from sdv-assets, the
# index's division column and cfbplotR's aliases from sdvplot) skip, naming
# what is missing; after a snapshot refresh with that data every row runs.
# The table of rows is ClaudeCowork notes/2026-11-06-cfbplotR-vs-sdvplotR-overlap.md.

library(ggplot2)

teams <- c("Alabama", "Utah", "Florida State", "Oregon")
df <- data.frame(x = 1:4, y = 4:1, team = teams)
ns <- asNamespace("sdvplotR")

has_cfb_wordmarks <- function() {
  m <- index_marks()
  any(m$league == "cfb" & m$mark_type == "wordmark")
}
skip_without_wordmarks <- function() {
  skip_if_not(has_cfb_wordmarks(), "the bundled snapshot has no cfb wordmarks yet (sdv-assets cfbplotr_wordmarks)")
}
skip_without_division <- function() {
  skip_if_not("division" %in% names(index_teams()), "the bundled index has no division column yet (sdvplot)")
}
# cfbplotR names the 2026-11-03 index does not resolve; sdvplot adds them
cfbplotr_aliases <- c(
  "UT San Antonio", "NC St.", "North Carolina State", "Charlotte", "Presbyterian College", "St Francis (PA)"
)
skip_without_aliases <- function() {
  ok <- !is.na(resolve_ids(cfbplotr_aliases, "cfb")$ids)
  skip_if_not(all(ok), paste(
    "the bundled index does not resolve", paste0("'", cfbplotr_aliases[!ok], "'", collapse = ", "),
    "yet (sdvplot cfbplotR aliases)"
  ))
}
built <- function(p) ggplot_build(p)$data[[1]]

test_that("1-7: the ggpath re-exports are the same objects", {
  for (f in c(
    "GeomFromPath", "GeomRefLines", "element_path", "element_raster",
    "geom_from_path", "geom_mean_lines", "geom_median_lines"
  )) {
    expect_identical(getExportedValue("sdvplotR", f), getExportedValue("ggpath", f), label = f)
  }
})

test_that("8, 11: geom_cfb_logos / GeomCFBlogo -> geom_sdv_logos / GeomSDVlogo", {
  p <- ggplot(df, aes(x, y, team = team)) +
    geom_sdv_logos(league = "cfb", width = 0.1)
  expect_s3_class(p$layers[[1]]$geom, "GeomSDVlogo")
  expect_in(c("x", "y", "team"), names(built(p)))
  expect_false(anyNA(logo_from_team(teams, "cfb")))
})

test_that("9, 12: geom_cfb_headshots / GeomCFBheads -> geom_sdv_headshots / GeomSDVheadshot", {
  p <- ggplot(data.frame(x = 1, y = 1, id = "4241479"), aes(x, y, player_id = id)) +
    geom_sdv_headshots(league = "cfb", height = 0.1)
  expect_s3_class(p$layers[[1]]$geom, "GeomSDVheadshot")
  expect_in("player_id", names(built(p)))
  expect_match(sdv_headshot_url("4241479", "cfb"), "headshots/college-football/players/full/4241479")
})

test_that("10, 13: geom_cfb_wordmarks / GeomCFBwordmark -> geom_sdv_wordmarks / GeomSDVwordmark", {
  p <- ggplot(df, aes(x, y, team = team)) +
    geom_sdv_wordmarks(league = "cfb", height = 0.1)
  expect_s3_class(p$layers[[1]]$geom, "GeomSDVwordmark")
  skip_without_wordmarks()
  expect_false(anyNA(wordmark_from_team(c("Alabama", "Utah"), "cfb")))
})

test_that("14-16: element_cfb_* -> element_sdv_*(league = \"cfb\")", {
  expect_s3_class(element_sdv_logo(league = "cfb"), "element_sdv_logo")
  expect_s3_class(element_sdv_headshot(league = "cfb"), "element_sdv_headshot")
  expect_s3_class(element_sdv_wordmark(league = "cfb"), "element_sdv_wordmark")
  skip_without_wordmarks()
  expect_false(anyNA(wordmark_from_team("Alabama", "cfb")))
})

test_that("17-19: scale_color_cfb / scale_colour_cfb / scale_fill_cfb(alt_colors =) -> scale_*_sdv", {
  alt <- sdv_team_colors("cfb", "Utah", which = "secondary")
  for (s in list(
    scale_color_sdv(league = "cfb", alt_colors = df$team),
    scale_colour_sdv(league = "cfb", alt_colors = df$team),
    scale_fill_sdv(league = "cfb", alt_colors = df$team)
  )) {
    expect_s3_class(s, "ScaleDiscrete")
    expect_identical(unname(s$palette(0)["Utah"]), unname(alt))
  }
})

test_that("20-23: scale_[xy]_cfb(_headshots) -> scale_[xy]_sdv(_headshots)(league = \"cfb\")", {
  expect_s3_class(scale_x_sdv(league = "cfb"), "ScaleDiscretePosition")
  expect_s3_class(scale_y_sdv(league = "cfb"), "ScaleDiscretePosition")
  expect_s3_class(scale_x_sdv_headshots(league = "cfb"), "ScaleDiscretePosition")
  expect_s3_class(scale_y_sdv_headshots(league = "cfb"), "ScaleDiscretePosition")
})

test_that("24, 25, 27: theme_x_cfb / theme_y_cfb / theme_title_image -> theme_x_sdv / theme_y_sdv / theme_title_image", {
  skip_if_not_installed("ggtext")
  expect_s3_class(theme_x_sdv(), "theme")
  expect_s3_class(theme_y_sdv(), "theme")
  expect_s3_class(theme_title_image(), "theme")
})

test_that("26: ggtitle_image -> ggtitle_image(league = \"cfb\")", {
  l <- ggtitle_image(title_image = "Utah", title = "Utes", league = "cfb")
  expect_match(l$title, logo_from_team("Utah", "cfb"), fixed = TRUE)
})

test_that("28-31: gt_fmt_cfb_* and gt_cfb_cols_label -> gt_sdv_*(league = \"cfb\")", {
  skip_on_cran()
  html <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))
  t <- gt::gt(data.frame(team = c("Alabama", "Utah"), player = "4241479"))
  expect_match(html(gt_sdv_logos(t, columns = "team", league = "cfb")), logo_from_team("Alabama", "cfb"), fixed = TRUE)
  expect_match(html(gt_sdv_headshots(t, columns = "player", league = "cfb")), "college-football/players/full/4241479")
  wide <- gt::gt(data.frame(Georgia = 1, Alabama = 2))
  expect_match(html(gt_sdv_cols_label(wide, columns = c(Georgia, Alabama), league = "cfb")), "<img")
  expect_s3_class(gt_sdv_wordmarks(t, columns = "team", league = "cfb"), "gt_tbl")
  skip_without_wordmarks()
  expect_match(html(gt_sdv_wordmarks(t, columns = "team", league = "cfb")), "<img")
})

test_that("32: gt_merge_stack_team_color -> gt_merge_stack_team_color(league = \"cfb\")", {
  t <- gt::gt(data.frame(team = "Utah", conf = "Big 12"))
  expect_s3_class(gt_merge_stack_team_color(t, team, conf, team, league = "cfb"), "gt_tbl")
})

test_that("33, 34: cfb_team_factor / cfb_team_tiers -> sdv_team_factor / sdv_team_tiers(league = \"cfb\")", {
  f <- sdv_team_factor(teams, "cfb")
  expect_s3_class(f, "factor")
  expect_setequal(levels(f), teams)
  expect_s3_class(sdv_team_tiers(data.frame(tier_no = c(1, 2, 2, 3), team = teams), "cfb"), "ggplot")
})

test_that("35: valid_team_names(division) -> sdv_teams(\"cfb\", division = )", {
  expect_true(all(c("Alabama", "Notre Dame") %in% sdv_teams("cfb", division = "P5")$location))
  expect_gt(nrow(sdv_teams("cfb", division = "G5")), 50)
  expect_gt(nrow(sdv_teams("cfb", division = "Conference")), 20)
  skip_without_division()
  for (d in c("FBS", "FCS", "DII", "DIII")) {
    expect_gt(nrow(sdv_teams("cfb", division = d)), 50)
  }
  expect_setequal(sdv_teams("cfb", division = "FBS")$team_id, sdv_teams("cfb", division = c("P5", "G5"))$team_id)
})

test_that("36, 37: clean_school_names / clean_team_abbrs -> sdv_clean_names(league = \"cfb\")", {
  x <- c("utah", "San Jose State", "Hawaii", "UTSA", "SLC", "USC")
  expect_identical(sdv_clean_names(x, "cfb"), c("Utah", "San Jos\u00e9 State", "Hawai'i", "UTSA", "SLC", "USC"))
  expect_identical(
    suppressWarnings(sdv_clean_names(x, "cfb", keep_non_matches = FALSE)),
    c("Utah", "San Jos\u00e9 State", "Hawai'i", "UTSA", NA, "USC")
  )
  skip_without_aliases()
  expect_identical(sdv_resolve(cfbplotr_aliases[1:4], "cfb"), sdv_resolve(c("UTSA", "NC State", "NC State", "2429"), "cfb"))
  expect_false(anyNA(sdv_clean_names(cfbplotr_aliases, "cfb", keep_non_matches = FALSE)))
})

test_that("38: .cfbplotR_clear_cache -> sdv_clear_cache", {
  expect_true(is.function(getExportedValue("sdvplotR", "sdv_clear_cache")))
  expect_length(formals(sdv_clear_cache), 0)
})

test_that("39: add_athlete_id_col -> sdv_add_athlete_id(league = \"cfb\")", {
  local_mocked_bindings(load_roster = function(league, season) {
    data.frame(
      season = as.integer(season), athlete_id = c("4241479", "4240069"),
      name = c("Britain Covey", "JT Daniels"), team = c("Utah", "Georgia"), headshot_url = "u"
    )
  })
  x <- data.frame(player_name = c("Britain Covey", "JT Daniels"))
  expect_identical(sdv_add_athlete_id(x, player_name)$athlete_id, c("4241479", "4240069"))
  x$season <- 2021
  x$team <- c("Utah", "Georgia")
  out <- sdv_add_athlete_id(x, player_name, team, headshot_urls = TRUE)
  expect_identical(out$athlete_id, c("4241479", "4240069"))
  expect_identical(out$headshot_url, c("u", "u"))
})

test_that("40: ggpreview -> sdv_ggpreview", {
  path <- sdv_ggpreview(ggplot(df, aes(x, y)) +
    geom_point(), width = 1, asp = 1, dpi = 20)
  withr::defer(unlink(path))
  expect_true(file.exists(path))
})

test_that("D1: logo_ref -> sdv_teams(\"cfb\") with sdv_logo_url()", {
  ref <- transform(
    sdv_teams("cfb"),
    logo = sdv_logo_url(team_id, "cfb"),
    wordmark = suppressWarnings(sdv_logo_url(team_id, "cfb", mark_type = "wordmark"))
  )
  # logo_ref's school, logo, color and alt_color; type is division (row 35)
  expect_in(c("location", "logo", "wordmark", "color_primary", "color_secondary"), names(ref))
  expect_gt(mean(!is.na(ref$logo)), 0.95)
  skip_without_wordmarks()
  expect_gt(sum(!is.na(ref$wordmark)), 200)
})

test_that("D2: team_name_mapping -> sdv_aliases(\"cfb\")", {
  a <- sdv_aliases("cfb")
  expect_gt(sum(a$id_system == "name"), 500)
  skip_without_aliases()
  expect_false(anyNA(sdv_resolve(cfbplotr_aliases, "cfb")))
})

test_that("the coverage table above names all 40 cfbplotR exports", {
  rows <- c(
    "GeomFromPath", "GeomRefLines", "element_path", "element_raster", "geom_from_path",
    "geom_mean_lines", "geom_median_lines", "geom_cfb_logos", "geom_cfb_headshots", "geom_cfb_wordmarks",
    "GeomCFBlogo", "GeomCFBheads", "GeomCFBwordmark", "element_cfb_logo", "element_cfb_headshot",
    "element_cfb_wordmark", "scale_color_cfb", "scale_colour_cfb", "scale_fill_cfb", "scale_x_cfb",
    "scale_y_cfb", "scale_x_cfb_headshots", "scale_y_cfb_headshots", "theme_x_cfb", "theme_y_cfb",
    "ggtitle_image", "theme_title_image", "gt_fmt_cfb_logo", "gt_fmt_cfb_headshot", "gt_fmt_cfb_wordmark",
    "gt_cfb_cols_label", "gt_merge_stack_team_color", "cfb_team_factor", "cfb_team_tiers", "valid_team_names",
    "clean_school_names", "clean_team_abbrs", ".cfbplotR_clear_cache", "add_athlete_id_col", "ggpreview"
  )
  expect_length(unique(rows), 40)
  counterpart <- c(
    "GeomFromPath", "GeomRefLines", "element_path", "element_raster", "geom_from_path",
    "geom_mean_lines", "geom_median_lines", "geom_sdv_logos", "geom_sdv_headshots", "geom_sdv_wordmarks",
    "GeomSDVlogo", "GeomSDVheadshot", "GeomSDVwordmark", "element_sdv_logo", "element_sdv_headshot",
    "element_sdv_wordmark", "scale_color_sdv", "scale_colour_sdv", "scale_fill_sdv", "scale_x_sdv",
    "scale_y_sdv", "scale_x_sdv_headshots", "scale_y_sdv_headshots", "theme_x_sdv", "theme_y_sdv",
    "ggtitle_image", "theme_title_image", "gt_sdv_logos", "gt_sdv_headshots", "gt_sdv_wordmarks",
    "gt_sdv_cols_label", "gt_merge_stack_team_color", "sdv_team_factor", "sdv_team_tiers", "sdv_teams",
    "sdv_clean_names", "sdv_clean_names", "sdv_clear_cache", "sdv_add_athlete_id", "sdv_ggpreview"
  )
  expect_in(counterpart, getNamespaceExports(ns))
  expect_in(c("sdv_teams", "sdv_aliases"), getNamespaceExports(ns)) # the datasets' counterparts
})
