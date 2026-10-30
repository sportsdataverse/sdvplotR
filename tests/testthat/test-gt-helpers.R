skip_on_cran()

# Offline smoke tests for the gtUtils-port helpers that no other test names:
# each builds a small table, applies the helper and checks the result renders
# and carries the helper's mark.

helper_html <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))
standings <- function(...) {
  d <- subset(sdv_example_standings, ...)
  rownames(d) <- NULL
  d
}
expect_gt_renders <- function(tbl, pattern = NULL) {
  expect_s3_class(tbl, "gt_tbl")
  h <- helper_html(tbl)
  expect_match(h, "<table")
  if (!is.null(pattern)) expect_match(h, pattern)
  invisible(h)
}

test_that("caption, header, tag and watermark helpers add their text", {
  d <- standings(division == "NFC North", c(team_name, wins, losses))
  expect_gt_renders(
    gt_538_caption(gt::gt(d), top_caption = "Top line", bottom_caption = "Bottom line"),
    "Bottom line"
  )
  expect_gt_renders(
    gt_title_header(gt::gt(d), title = "The NFC North", subtitle = "2025", kicker = "NFL"),
    "The NFC North"
  )
  expect_gt_renders(gt_social_tag(gt::gt(d), c(x = "@sdv_handle")), "sdv_handle")
  expect_gt_renders(gt_watermark(gt::gt(d), text = "DRAFTMARK"), "DRAFTMARK")
  expect_gt_renders(gt_scale_note(gt::gt(d), wins, divisor = 10, decimals = 1))
})

test_that("row and cell styling helpers render", {
  d <- standings(division == "NFC West", c(team_name, wins, losses, win_pct, playoff_wins))
  expect_gt_renders(gt_bold_rows(gt::gt(d), rows = win_pct > 0.5, highlight_color = "#FFF3B0"), "FFF3B0")
  expect_gt_renders(gt_border_grid(gt::gt(d), color = "#BBBBBB", include_labels = TRUE), "BBBBBB")
  expect_gt_renders(gt_highlight_cells(gt::gt(d), wins, ~ .x >= 10, fill = "#FFD1A9"), "FFD1A9")
  expect_gt_renders(gt_highlight_na(gt::gt(d), playoff_wins, missing_text = "missed playoffs"))
  expect_gt_renders(gt_set_font(gt::gt(d), "Helvetica", from_google_font = FALSE), "Helvetica")
  expect_gt_renders(gt_wrap_labels(gt::cols_label(gt::gt(d), win_pct = "Winning Percentage"), win_pct, width = 8))
  expect_gt_renders(gt_cutline(gt::gt(d), after = 2, label = "Playoffs"), "border-top-style: dashed")
  expect_gt_renders(gt_marginalia(gt::gt(transform(d, note = paste(team_name, "note"))), note))
  accents <- transform(d, colour = c("#003366", "#C8102E", "#B8232F", "#C8102E"))
  expect_gt_renders(gt_row_accent(gt::gt(accents), colour), "003366")
})

test_that("grouped and column-label helpers render", {
  afc <- standings(conference == "AFC", c(team_name, division, wins, losses, points_for))
  expect_gt_renders(gt_group_stripes(gt::gt(afc, groupname_col = "division"), color = "#FBF3E4"), "FBF3E4")
  expect_gt_renders(
    gt_column_subheaders(
      gt::gt(afc[c("team_name", "wins")]),
      wins = list(heading = "Wins", subtitle = "W")
    ),
    "Wins"
  )
})

test_that("value formatters and colourers render", {
  nfc <- standings(conference == "NFC" & conference_rank <= 5, c(team_name, conference_rank, last_season_wins, wins))
  expect_gt_renders(gt_fmt_rank(gt::gt(nfc), conference_rank), "<sup")
  expect_gt_renders(gt_delta(gt::gt(nfc), last_season_wins, wins, arrows = TRUE))
  expect_gt_renders(gt_color_ranks(gt::gt(nfc), conference_rank))
  # pal_midnight is a five-colour palette gt_color_ranks() takes
  expect_length(pal_midnight, 5L)
  expect_true(all(grepl("^#[0-9A-F]{6}$", pal_midnight)))
  expect_gt_renders(gt_color_ranks(gt::gt(nfc), conference_rank, palette = pal_midnight), "3FBF87")

  results <- data.frame(game = paste("Game", 1:3), result = c("W", "L", "T"))
  expect_gt_renders(gt_color_results(gt::gt(results), win_color = "#1B7837"), "1B7837")
  roster <- data.frame(player = c("A", "B"), starter = c(1, 0), injured = c(0, 1))
  expect_gt_renders(gt_indicator_boxes(gt::gt(roster), key_columns = "player"))
  nba <- standings(league == "nba", c(team_name, points_for, points_against))
  expect_gt_renders(gt_outliers(gt::gt(nba), c(points_for, points_against), note = TRUE))
})

test_that("gt_legend_discrete() adds a legend with its labels", {
  d <- standings(division == "AFC West", c(team_name, wins))
  h <- expect_gt_renders(gt_legend_discrete(gt::gt(d), c(Playoffs = "#CCE7F5", Missed = "#F5CCCC")), "Playoffs")
  expect_match(h, "CCE7F5", ignore.case = TRUE)
})

test_that("gt_snake() reshapes into blocks and gt_snake_align() follows it", {
  nba <- standings(league == "nba", c(team, wins, losses))
  snaked <- gt_snake(gt::gt(nba), n_cols = 3)
  expect_gt_renders(snaked)
  expect_true(all(c("team_1", "team_2", "team_3") %in% names(snaked[["_data"]])))
  mask <- data.frame(team = FALSE, nba[c("wins", "losses")] >= 50)
  aligned <- gt_snake_align(mask, n_cols = 3)
  expect_identical(nrow(aligned), nrow(snaked[["_data"]]))
  expect_identical(sum(as.matrix(aligned), na.rm = TRUE), sum(as.matrix(mask)))
})

test_that("gt_grid() and gt_stack_tables() lay tables out without saving", {
  t1 <- gt::gt(standings(division == "AFC East", c(team_name, wins)))
  t2 <- gt::gt(standings(division == "Atlantic", c(team_name, wins)))
  grid <- gt_grid(list(t1, t2), ncol = 2, title = "A grid title")
  expect_match(as.character(htmltools::renderTags(grid)$html), "A grid title")
  stack <- gt_stack_tables(list(t1, t2), title = "A stack title")
  expect_match(as.character(htmltools::renderTags(stack)$html), "A stack title")
})

test_that("gt_social_crop() checks its table before starting Chrome", {
  expect_error(gt_social_crop(mtcars, tempfile(fileext = ".png")), "gt")
})

test_that("gt_theme_preview() with its default set renders every theme that needs only the table", {
  grid <- gt_theme_preview(head(mtcars), n = 2)
  html <- as.character(htmltools::renderTags(grid)$html)
  expect_match(html, "kenpom")
  expect_match(html, "sdv")
  # gt_theme_source() needs a registry name and gt_theme_sdv_team() a team
  expect_no_match(html, ">source<")
  expect_no_match(html, ">sdv_team<")
})
