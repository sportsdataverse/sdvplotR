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

test_that("gt_save_crop returns the path, or the image bytes when file is NULL", {
  # stand in for the headless-Chrome render: a white canvas with a black block
  local_mocked_bindings(
    gtsave_extra = function(data, filename, ...) {
      canvas <- magick::image_blank(60, 40, "white")
      block <- magick::image_blank(20, 10, "black")
      magick::image_write(magick::image_composite(canvas, block, offset = "+20+15"), filename)
    },
    .package = "gtExtras"
  )
  tbl <- gt::gt(head(mtcars))

  bytes <- gt_save_crop(tbl)
  expect_type(bytes, "raw")
  expect_identical(bytes[2:4], charToRaw("PNG"))

  out <- withr::local_tempfile(fileext = ".png")
  expect_identical(gt_save_crop(tbl, out, whitespace = 5), out)
  expect_identical(dim(magick::image_data(magick::image_read(out)))[2:3], c(30L, 20L))
})

test_that("deprecated gt_bold_rows() arguments warn without setting options", {
  rlang::local_options(rlib_warning_verbosity = "verbose")
  expect_warning(
    tbl <- gt_bold_rows(gt::gt(head(mtcars)), row = 2),
    "deprecated"
  )
  expect_s3_class(tbl, "gt_tbl")
  expect_null(getOption("sdvplotR_deprecated_row"))
})

test_that("gt_theme_sdv_team dresses the table in the team's colors", {
  horizon <- function(h) regmatches(h, regexpr("thead::after \\{[^}]*background: #[0-9A-Fa-f]{6}", h))
  kc <- html_of(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "KC", sport = "nfl"))
  expect_match(kc, "#E31837")
  expect_match(horizon(kc), "#FFB612$")

  # a white secondary would vanish on the white table: the line takes the primary
  duke <- html_of(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "DUKE", sport = "mbb"))
  expect_match(horizon(duke), "#00539B$")

  # a pale primary is unreadable as label text on white: labels go navy
  no <- gt_theme_sdv_team(gt::gt(head(mtcars)), team = "NO", sport = "nfl")
  label_styles <- no[["_styles"]][no[["_styles"]]$locname == "columns_columns", ]$styles
  expect_identical(label_styles[[1]]$cell_text$color, "#0B1A33")

  expect_error(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "nope"), "No NFL team matches")
  expect_error(gt_theme_sdv_team(gt::gt(head(mtcars)), team = c("KC", "LV")), "single team")
})

test_that("gt_theme_sdv sets the navy background in dark style", {
  tbl <- gt_theme_sdv(gt::gt(head(mtcars)), style = "dark")
  opts <- tbl[["_options"]]
  expect_identical(opts$value[[match("table_background_color", opts$parameter)]], "#0B1A33")
  expect_error(gt_theme_sdv(gt::gt(head(mtcars)), style = "sepia"))
})
