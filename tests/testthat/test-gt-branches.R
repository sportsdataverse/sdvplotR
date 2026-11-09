skip_on_cran()

# Offline tests for the gt helpers' argument branches: each builds a small table,
# applies a helper with a non-default option and checks the rendered HTML (or the
# error / warning the option should raise). The image savers run with
# webshot2::webshot() mocked to write a blank PNG, so Chrome is never started.

branch_html <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))
nfc_north <- function() {
  d <- subset(sdv_example_standings, division == "NFC North", c(team_name, wins, losses, win_pct))
  rownames(d) <- NULL
  d
}
fake_webshot <- function(url, file, ...) {
  img <- magick::image_border(magick::image_blank(120, 60, "red"), "white", "10x10")
  magick::image_write(img, file, format = "png")
  invisible(file)
}

test_that("gt_legend_continuous() draws each bar type, title side and location", {
  tbl <- gt::gt(nfc_north())
  h <- branch_html(gt_legend_continuous(tbl, wins, title = "Wins"))
  expect_match(h, "Wins")
  expect_match(h, "background-color")

  for (type in c("steps", "blocks")) {
    h <- branch_html(gt_legend_continuous(tbl, wins,
      type = type, n_bins = 4, labels = "edges",
      border_color = "#333333", title = "Tiers", title_position = "bottom", align = "left"
    ))
    expect_match(h, "Tiers")
    expect_match(h, "solid #333333")
  }
  for (pos in c("left", "right")) {
    expect_match(branch_html(gt_legend_continuous(tbl, domain = c(0, 1), title = pos,
      title_position = pos, align = "right", labels = "mid", labels_position = "top"
    )), "mid")
  }
  expect_no_match(
    branch_html(gt_legend_continuous(tbl, domain = c(0, 10), labels_position = "none", reverse = TRUE)),
    ">10<"
  )

  # top: with no header, under a title, and under a title + subtitle
  expect_match(branch_html(gt_legend_continuous(tbl, wins, location = "top")), "background-color")
  titled <- gt::tab_header(tbl, title = "NFC North")
  expect_match(branch_html(gt_legend_continuous(titled, wins, location = "top")), "NFC North")
  both <- gt::tab_header(tbl, title = "NFC North", subtitle = "2025 season")
  h <- branch_html(gt_legend_continuous(both, wins, location = "top"))
  expect_match(h, "2025 season")

  # a Google font in the styles is imported on the legend's cell
  for (loc in c("bottom", "top")) {
    expect_match(branch_html(gt_legend_continuous(tbl, wins,
      title = "W", title_style = list(font = "Lato"), location = loc
    )), "Lato")
  }
  expect_match(branch_html(gt_legend_continuous(titled, wins,
    location = "top", labels_style = list(font = "Lato")
  )), "Lato")
})

test_that("gt_legend_continuous() picks up a recorded scale and checks its inputs", {
  tbl <- gt::gt(nfc_north())
  ranked <- gt_color_ranks(tbl, wins)
  expect_match(branch_html(gt_legend_continuous(ranked)), "background-color")

  expect_error(gt_legend_continuous(tbl), "columns")
  expect_error(gt_legend_continuous(tbl, team_name), "No numeric values")
  expect_error(gt_legend_continuous(tbl, domain = 1), "length-2")
  expect_error(gt_legend_continuous(tbl, wins, n_bins = 0), "n_bins")
})

test_that("gt_legend_discrete() handles each key form, shape and location", {
  tbl <- gt::gt(nfc_north())
  key <- c(Playoffs = "#1B7837", Missed = "#F5CCCC")
  h <- branch_html(gt_legend_discrete(tbl, key,
    label_placement = "inside", shape = "circle", border = FALSE,
    direction = "vertical", align = "left", heading = "Key", subtitle = "2025",
    location = "bottom", label_style = list(font = "Lato")
  ))
  expect_match(h, "Key")
  expect_match(h, "Lato")
  df_key <- data.frame(color = unname(key), label = names(key))
  expect_match(branch_html(gt_legend_discrete(tbl, df_key, border_color = "#000000")), "Playoffs")
  expect_match(branch_html(gt_legend_discrete(tbl, data.frame(c = unname(key), l = names(key)))), "Missed")
  expect_match(
    branch_html(gt_legend_discrete(gt::tab_header(tbl, title = "T", subtitle = "S"), key)),
    "Playoffs"
  )
  expect_match(branch_html(gt_legend_discrete(gt::tab_header(tbl, title = "T"), key)), "Playoffs")

  expect_error(gt_legend_discrete(tbl), "key_info")
  expect_error(gt_legend_discrete(tbl, data.frame(x = "#000000")), "color")
  expect_error(gt_legend_discrete(tbl, list(1, 2)), "named vector")
})

test_that("gt_spotlight() lights rows, draws an accent and handles no match", {
  tbl <- gt::gt(nfc_north())
  h <- branch_html(gt_spotlight(tbl, wins > 9,
    columns = c(team_name, wins), fill = "#FFF3B0",
    accent_color = "#C8102E", accent_column = wins
  ))
  expect_match(h, "FFF3B0", ignore.case = TRUE)
  expect_match(h, "C8102E", ignore.case = TRUE)
  expect_match(branch_html(gt_spotlight(tbl, 1, accent_color = "#003366")), "003366")
  expect_warning(gt_spotlight(tbl, 1, accent_color = "#003366", accent_column = losses,
    columns = team_name
  ) |> gt::cols_hide(losses), NA)
  hidden <- gt::cols_hide(tbl, losses)
  expect_warning(gt_spotlight(hidden, 1, accent_color = "#003366", accent_column = losses), "accent")

  expect_warning(out <- gt_spotlight(tbl, wins > 100), "matched no rows")
  expect_s3_class(out, "gt_tbl")
  expect_match(branch_html(gt_spotlight(tbl, wins > 100, if_none = "dim")), "color")
  expect_silent(gt_spotlight(tbl, wins > 100, if_none = "ignore"))
})

test_that("gt_percentile_bar() rescales, filters rows and draws missing values", {
  d <- data.frame(team = c("A", "B", "C"), pct = c(0.25, NA, 0.9), raw = c(10, 50, 95))
  tbl <- gt::gt(d)
  h <- branch_html(gt_percentile_bar(tbl, pct, reverse = TRUE, ring_color = "#000000", na_label = "n/a"))
  expect_match(h, "n/a")
  expect_match(h, "box-shadow")
  expect_match(branch_html(gt_percentile_bar(tbl, pct, na_label = NULL, scale = 100)), "<table")
  expect_match(branch_html(gt_percentile_bar(tbl, raw, scale = "none", rows = raw > 20)), "<table")
  expect_match(branch_html(gt_percentile_bar(tbl, raw, rows = 1:2)), "<table")
  expect_warning(out <- gt_percentile_bar(tbl, raw, rows = raw > 1000), "matched no rows")
  expect_s3_class(out, "gt_tbl")
  expect_identical(gt_percentile_bar(tbl, tidyselect::starts_with("zzz")), tbl)
})

test_that("gt_color_pills() filters rows, ranks and formats", {
  d <- data.frame(team = c("A", "B", "C"), v = c(0.1, NA, 0.7))
  tbl <- gt::gt(d)
  expect_warning(h <- branch_html(gt_color_pills(tbl, v, fill_type = "rank", reverse = TRUE,
    format_type = "percent", digits = 1, na_color = "#DDDDDD"
  )), "domain")
  expect_match(h, "DDDDDD", ignore.case = TRUE)
  expect_match(branch_html(gt_color_pills(tbl, v,
    domain = c(0, 1), rows = 1, rank_order = "asc", format_type = "number", digits = 2
  )), "<table")
  expect_match(branch_html(gt_color_pills(tbl, v, domain = c(0, 1), rows = c(TRUE, FALSE, TRUE))), "<table")
  expect_warning(gt_color_pills(tbl, v, domain = c(0, 1), rows = v > 5), "matched no rows")
  expect_error(gt_color_pills(tbl, tidyselect::starts_with("zzz")), "matched no columns")
})

test_that("gt_indicator_boxes() takes columns, formats and show_only", {
  d <- data.frame(player = c("A", "B", "C"), starter = c(1, 0, NA), share = c(0.5, 0.25, 1))
  tbl <- gt::gt(d)
  h <- branch_html(gt_indicator_boxes(tbl,
    columns = c(starter, share), indicator_rule = function(x, col) x >= 0.5,
    show_text = TRUE, show_na_as_na = TRUE, color_na = "#AAAAAA", border_color = "#111111",
    per_column_formats = list(share = list(digits = 1, format_type = "percent", suffix = "%"))
  ))
  expect_match(h, "111111")
  for (only in c("yes", "no", "NA", "other")) {
    expect_match(branch_html(gt_indicator_boxes(tbl, key_columns = "player",
      indicator_rule = function(x, col) x >= 0.5, show_text = TRUE, show_only = only
    )), "<table")
  }
  expect_error(gt_indicator_boxes(tbl, columns = starter, key_columns = "player"), "not both")
  expect_error(gt_indicator_boxes(tbl, key_columns = c("player", "starter", "share")), "No columns")
})

test_that("gt_outliers() flags by sd and bounds, with symbols and notes", {
  d <- data.frame(team = letters[1:6], pts = c(10, 11, 12, 11, 10, 40), flat = 5)
  tbl <- gt::gt(d)
  expect_match(branch_html(gt_outliers(tbl, c(pts, flat),
    method = "sd", threshold = 1, side = "high", fill = "#FFEEEE", symbol = "*", note = TRUE
  )), "standard deviation")
  expect_match(branch_html(gt_outliers(tbl, pts, method = "sd", threshold = 2, note = TRUE)), "deviations")
  expect_match(branch_html(gt_outliers(tbl, pts, method = "bounds", bounds = c(10.5, 20),
    side = "low", note = TRUE
  )), "outside")
  expect_match(branch_html(gt_outliers(tbl, pts, note = "Custom note")), "Custom note")
  expect_match(branch_html(gt_outliers(tbl, pts, bounds = c(0, 1), method = "bounds", side = "high")), "<table")
  expect_error(gt_outliers(tbl, pts, method = "bounds"), "bounds")
  expect_error(gt_outliers(tbl, tidyselect::starts_with("zzz")), "matched no columns")
  expect_warning(out <- gt_outliers(tbl, team), "No numeric")
  expect_s3_class(out, "gt_tbl")
})

test_that(".table_id() sets the table's id even after an option call reorders them", {
  # opt_row_striping() moves its option ahead of table_id; .table_id() then wrote the
  # id over that option, so the table failed to render and kept no id
  striped <- gt::opt_row_striping(gt::gt(nfc_north()))
  res <- .table_id(striped)
  opts <- res$object[["_options"]]
  expect_identical(opts$value[[which(opts$parameter == "table_id")]], res$id)
  expect_identical(
    opts$value[opts$parameter == "row_striping_include_table_body"],
    striped[["_options"]]$value[striped[["_options"]]$parameter == "row_striping_include_table_body"]
  )
  expect_match(branch_html(gt_theme_kenpom(striped)), "<table")
})

test_that("gt_cutline() checks after, drops bad lines and pads gaps", {
  tbl <- gt::gt(nfc_north())
  expect_identical(gt_cutline(tbl, after = integer(0)), tbl)
  expect_error(gt_cutline(tbl, after = "2"), "must be numeric row numbers")
  expect_error(gt_cutline(tbl, after = 2, gap = -1), "gap")
  expect_warning(out <- gt_cutline(tbl, after = c(2, 9), label = c("In", "Out")), "Dropped")
  expect_s3_class(out, "gt_tbl")
  expect_warning(out <- gt_cutline(tbl, after = 9), "Dropped")
  expect_identical(out, tbl)
  h <- branch_html(gt_cutline(gt::opt_row_striping(tbl), after = 2, label = "Playoffs",
    label_position = "above", gap = c(4, 6)
  ))
  expect_match(h, "padding-")
  expect_match(branch_html(gt_cutline(tbl, after = c(1, 3), label = c("", "Last"), gap = 3)), "padding-")
  expect_match(branch_html(gt_cutline(tbl, after = 0, label = "Top")), "<table")
})

test_that("gt_snake() takes rows_per_col, fills the last block and keeps styles", {
  d <- data.frame(team = letters[1:7], wins = 1:7)
  tbl <- gt::tab_style(gt::gt(d), gt::cell_fill("#EEEEEE"), gt::cells_body(columns = wins, rows = 2))
  tbl <- gt::tab_style(tbl, gt::cell_text(weight = "bold"), gt::cells_column_labels(columns = team))
  snaked <- gt_snake(tbl, rows_per_col = 3, fill = "-")
  expect_true(all(c("team_1", "team_3") %in% names(snaked[["_data"]])))
  expect_match(branch_html(snaked), "EEEEEE")
  expect_identical(gt_snake(tbl, n_cols = 1), tbl)
  expect_error(gt_snake(tbl, rows_per_col = 0), "rows_per_col")
  expect_error(gt_snake(tbl, n_cols = 0), "n_cols")
})

test_that("gt_tiers(), gt_fmt_tally() and gt_highlight_cells() check their inputs", {
  d <- data.frame(tier = c("A", "B"), team = c("x", "y"))
  tbl <- gt::gt(d)
  expect_error(gt_tiers(tbl, levels = c("A", "B")), "colors")
  expect_error(gt_tiers(tbl, levels = c("A", "B"), colors = "#000000"), "same length")
  expect_error(gt_tiers(tbl, c(A = "#000000"), tier_column = "nope"), "not a column")
  expect_warning(gt_tiers(tbl, c(A = "#000000", C = "#FFFFFF")), "not in")

  rec <- data.frame(team = c("x", "y"), w = c(3, 0), l = c(1, 0))
  rtbl <- gt::gt(rec)
  expect_error(gt_fmt_tally(rtbl, w), "at least two")
  expect_match(branch_html(gt_fmt_tally(rtbl, c(w, l), share = TRUE, share_of = "w", label = "Record")), "Record")
  expect_match(branch_html(gt_fmt_tally(rtbl, c(w, l), share = TRUE, share_location = "column")), "%")
  expect_error(gt_fmt_tally(rtbl, c(w, l), share = TRUE, share_of = 5), "share_of")

  expect_error(gt_highlight_cells(rtbl, tidyselect::starts_with("zzz"), ~ .x > 1), "matched no columns")
  mask <- data.frame(w = c(TRUE, FALSE), l = c(NA, TRUE))
  expect_match(branch_html(gt_highlight_cells(rtbl, c(w, l), mask, text_color = "#123456", bold = TRUE)), "123456")
  expect_error(gt_highlight_cells(rtbl, c(w, l), data.frame(w = TRUE)), "one column per")
  expect_error(gt_highlight_cells(rtbl, c(team, w), ~ .x > 1 + "a"), "could not be applied")
  expect_error(gt_highlight_cells(rtbl, w, ~ TRUE), "one value per row")
})

test_that("gt_grid() and gt_stack_tables() check inputs and compose captions", {
  t1 <- gt::gt(nfc_north())
  for (f in list(gt_grid, gt_stack_tables)) {
    # a bare gt_tbl, and two bad items, used to fail inside cli's pluralization
    expect_error(f(t1), "must be a list")
    expect_error(f(list(t1, mtcars)), "item 2 is not")
    expect_error(f(list(t1, mtcars, 1)), "items 2 and 3 are not")
    composed <- f(list(t1, t1),
      title = gt::md("**Bold title**"), subtitle = "Sub", caption = "A caption",
      source_note = "A source", caption_rule = TRUE, title_style = list(font = "Lato")
    )
    html <- as.character(htmltools::renderTags(composed)$html)
    expect_match(html, "<strong>Bold title</strong>")
    expect_match(html, "A source")
  }
  expect_error(gt_grid(list(t1), ncol = 0), "ncol")
})

test_that("the image savers write a PNG through a mocked webshot", {
  skip_if_not_installed("magick")
  skip_if_not_installed("webshot2")
  local_mocked_bindings(webshot = fake_webshot, .package = "webshot2")
  t1 <- gt::gt(nfc_north())
  dir <- withr::local_tempdir()

  expect_true(file.exists(gt_grid(list(t1, t1), file = file.path(dir, "grid.png"))))
  expect_true(file.exists(gt_stack_tables(list(t1, t1), file = file.path(dir, "stack.png"))))
  expect_true(file.exists(gt_webshot(t1, file.path(dir, "one.png"))))

  gt_social_crop(t1, file.path(dir, "wide.png"), aspect_ratio = "16:9", width = 300)
  expect_identical(magick::image_info(magick::image_read(file.path(dir, "wide.png")))$width, 300L)
  gt_social_crop(t1, file.path(dir, "tall.png"), aspect_ratio = 0.5)
  info <- magick::image_info(magick::image_read(file.path(dir, "tall.png")))
  expect_equal(info$width / info$height, 0.5, tolerance = 0.02)
  expect_error(gt_social_crop(t1, file.path(dir, "bad.png"), aspect_ratio = "wide"), "ratio")

  cars <- transform(mtcars[1:6, 1:3], grp = c("a b", "a b", "c", "c", NA, "c"))
  expect_warning(
    paths <- gt_save_batch(cars, grp, function(d, g) {
      if (identical(g, "c")) gt::gt(d) else "not a table"
    }, "cars-{group}.png", dir = file.path(dir, "batch")),
    "1 group failed"
  )
  expect_identical(basename(paths), "cars-c.png")
  expect_true(file.exists(paths))
  paths <- gt_save_batch(cars, grp, function(d, g) gt::gt(d), "cars-{group}.png",
    dir = file.path(dir, "batch2"), match_width = FALSE, quiet = TRUE
  )
  expect_setequal(basename(paths), c("cars-a-b.png", "cars-c.png"))
  expect_error(gt_save_batch(cars, grp, function(d, g) "no", "x-{group}.png",
    dir = file.path(dir, "b3"), quiet = TRUE
  ), "No group built")
})

test_that("gt_save_batch() checks its arguments", {
  dir <- withr::local_tempdir()
  expect_error(gt_save_batch(1, cyl, identity, "{group}.png", dir), "data frame")
  expect_error(gt_save_batch(mtcars, cyl, 1, "{group}.png", dir), "function")
  expect_error(gt_save_batch(mtcars, cyl, identity, "x.png", dir), "group")
  expect_error(gt_save_batch(mtcars, c(cyl, gear), identity, "{group}.png", dir), "exactly one")
  expect_error(gt_save_batch(data.frame(g = NA), g, identity, "{group}.png", dir), "non-missing")
})
