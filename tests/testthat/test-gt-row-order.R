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
  expect_length(cells, 4)
  ramp <- scales::col_numeric(pal, c(0, 100))
  for (cell in cells) {
    value <- as.numeric(sub(".*>([0-9.]+)</span>.*", "\\1", cell))
    expect_match(cell, paste0("background-color: ", ramp(value)), fixed = TRUE)
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
