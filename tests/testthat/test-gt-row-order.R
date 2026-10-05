# Row groups change the order gt shows rows in (A, A, B, B below, from data
# rows 1, 3, 2, 4). Each helper must decorate a cell from that cell's own row.

grouped <- function() {
  d <- data.frame(
    g = c("A", "B", "A", "B"),
    v = c(10, 20, 30, 40),
    p = c(0.5, 0.001, 0.5, 0.001),
    won = c(1, 5, 2, 6),
    lost = c(9, 5, 8, 4)
  )
  gt::gt(d, groupname_col = "g")
}

cells_of <- function(tbl, col) {
  h <- as.character(gt::as_raw_html(tbl, inline_css = FALSE))
  regmatches(h, gregexpr(paste0("<td headers=\"[^\"]*", col, "[^\"]*\"[^>]*>.*?</td>"), h))[[1]]
}

test_that("gt_color_pills colors each pill by its own value under row groups", {
  pal <- c("#000000", "#FFFFFF")
  cells <- cells_of(gt_color_pills(grouped(), v, domain = c(0, 100), palette = pal), "v")
  ramp <- scales::col_numeric(pal, c(0, 100))
  # shown in group order: data rows 1, 3, 2, 4
  shown <- c(10, 30, 20, 40)
  expect_length(cells, 4)
  for (k in seq_along(cells)) {
    expect_match(cells[[k]], paste0(">", shown[[k]], "</span>"))
    expect_match(cells[[k]], paste0("background-color: ", ramp(shown[[k]])), fixed = TRUE)
    # the width in ch holds the text even where the page sets border-box
    expect_match(cells[[k]], "box-sizing: content-box; width: 2ch;", fixed = TRUE)
  }
})

test_that("gt_percentile_bar draws each row's own value under row groups", {
  cells <- cells_of(gt_percentile_bar(grouped(), v), "v")
  # shown in group order: data rows 1, 3, 2, 4
  shown <- c(10, 30, 20, 40)
  expect_length(cells, 4)
  for (k in seq_along(cells)) {
    expect_match(cells[[k]], paste0(">", shown[[k]], "<"))
    expect_match(cells[[k]], sprintf("%.4f \\*", shown[[k]] / 100))
  }
})

test_that("gt_fmt_tally writes each row's own tally under row groups", {
  cells <- cells_of(gt_fmt_tally(grouped(), c(won, lost)), "won")
  expect_identical(sub("^<td[^>]*>(.*)</td>$", "\\1", cells), c("1-9", "2-8", "5-5", "6-4"))
})

test_that("gt_significance stars the rows whose own p-value is significant", {
  cells <- cells_of(gt_significance(grouped(), v, p, legend = FALSE), "v")
  # shown as 10, 30 (group A, p = 0.5), then 20, 40 (group B, p = 0.001)
  expect_identical(grepl("\\*\\*\\*", cells), c(FALSE, FALSE, TRUE, TRUE))
  expect_match(cells[[3]], "^<td[^>]*>20<sup")
})

test_that("gt_merge_stack_team_color stacks each row's own pair under row groups", {
  d <- data.frame(
    g = c("A", "B", "A"), top = c("r1", "r2", "r3"), bottom = c("b1", "b2 & co", "b3"),
    team = c("KC", "BUF", "SF")
  )
  stacked <- function(tbl) {
    h <- as.character(gt::as_raw_html(tbl, inline_css = FALSE))
    tops <- regmatches(h, gregexpr("font-variant:small-caps[^>]*>[^<]*<", h))[[1]]
    bottoms <- regmatches(h, gregexpr("color:#[0-9A-Fa-f]{6};font-size:12px'>[^<]*<", h))[[1]]
    list(top = sub(".*>(.*)<$", "\\1", tops), bottom = sub(".*>(.*)<$", "\\1", bottoms), html = h)
  }
  # shown in group order: rows 1, 3, 2
  body <- stacked(gt_merge_stack_team_color(gt::gt(d, groupname_col = "g"), top, bottom, team, sport = "nfl"))
  expect_identical(body$top, c("r1", "r3", "r2"))
  expect_identical(body$bottom, c("b1", "b3", "b2 &amp; co"))
  expect_match(body$html, paste0("color:", sdv_team_colors("nfl", "SF"), ";font-size:12px'>b3"))
  # the same when the top column is the stub
  stub <- stacked(gt_merge_stack_team_color(gt::gt(d, rowname_col = "top", groupname_col = "g"), top, bottom, team, sport = "nfl"))
  expect_identical(stub$top, c("r1", "r3", "r2"))
  expect_identical(stub$bottom, c("b1", "b3", "b2 &amp; co"))
})

test_that("the row helpers keep a table small", {
  set.seed(1)
  d <- data.frame(g = rep(c("A", "B"), 100), a = runif(200), b = runif(200), p = runif(200) / 5)
  tbl <- gt::gt(d, groupname_col = "g") |>
    gt_color_pills(c(a, b), domain = c(0, 1)) |>
    gt_significance(a, p, legend = FALSE)
  # one text_transform per row used to hold a copy of the table each: ~50 MB here
  expect_lt(length(serialize(tbl, NULL)), 5e6)
})
