html_of <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))

test_that("every gt_theme_* returns a gt table that renders", {
  themes <- setdiff(
    grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE),
    "gt_theme_preview"
  )
  expect_gte(length(themes), 18)
  for (nm in themes) {
    tbl <- get(nm, envir = asNamespace("sdvplotR"))(gt::gt(head(mtcars)))
    expect_s3_class(tbl, "gt_tbl")
    expect_match(html_of(tbl), "<table", info = nm)
  }
})

test_that("theme_bg matches the background every theme applies", {
  themes <- setdiff(
    grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE),
    "gt_theme_preview"
  )
  expect_setequal(unique(theme_bg$theme), themes)
  for (i in seq_len(nrow(theme_bg))) {
    row <- theme_bg[i, ]
    args <- if (nzchar(row$has_style)) list(style = row$has_style) else list()
    tbl <- do.call(row$theme, c(list(gt::gt(head(mtcars))), args))
    opts <- tbl[["_options"]]
    applied <- opts$value[[match("table_background_color", opts$parameter)]]
    expect_identical(applied, row$bg, info = paste(row$theme, row$has_style))
  }
})

test_that("gt_sdv_logos keep their size inside a table theme", {
  df <- data.frame(team = c("KC", "BUF"), wins = c(15, 13))
  h <- gt::gt(df) |>
    gt_sdv_logos(columns = "team", sport = "nfl", height = 30) |>
    gt_theme_kenpom() |>
    html_of()
  expect_match(h, "kc\\.png\" style=\"height:30px;\"")
  expect_match(h, "buf\\.png\" style=\"height:30px;\"")
})
