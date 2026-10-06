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
  opt <- function(tbl, name) tbl[["_options"]]$value[[match(name, tbl[["_options"]]$parameter)]]
  label_color <- function(tbl) {
    st <- tbl[["_styles"]]
    st[st$locname == "columns_columns", ]$styles[[1]]$cell_text$color
  }
  kc_tbl <- gt_theme_sdv_team(gt::gt(head(mtcars)), team = "KC", sport = "nfl")
  expect_identical(opt(kc_tbl, "heading_background_color"), "#E31837")
  expect_identical(label_color(kc_tbl), "#E31837")
  expect_match(horizon(html_of(kc_tbl)), "#FFB612$")

  # a white secondary would vanish on the white table: the line takes the primary
  duke <- html_of(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "DUKE", sport = "mbb"))
  expect_match(horizon(duke), "#00539B$")

  # a pale primary is unreadable as label text on white: labels go navy
  no <- gt_theme_sdv_team(gt::gt(head(mtcars)), team = "NO", sport = "nfl")
  expect_identical(label_color(no), "#0B1A33")

  # every team has colors now (Chicago State's come from ESPN's basketball
  # entry); a key with none on file, the AFC, wears the SDV colors, with a warning
  chst <- gt_theme_sdv_team(gt::gt(head(mtcars)), team = "CHST", sport = "cfb")
  expect_identical(opt(chst, "heading_background_color"), "#006700")
  expect_warning(
    afc <- gt_theme_sdv_team(gt::gt(head(mtcars)), team = "AFC", sport = "nfl"),
    "No colors on file"
  )
  expect_identical(opt(afc, "heading_background_color"), "#0B1A33")

  expect_error(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "nope"), "No NFL team matches")
  expect_error(gt_theme_sdv_team(gt::gt(head(mtcars)), team = c("KC", "LV")), "single team")
})

test_that("gt_theme_sdv sets the navy background in dark style", {
  tbl <- gt_theme_sdv(gt::gt(head(mtcars)), style = "dark")
  opts <- tbl[["_options"]]
  expect_identical(opts$value[[match("table_background_color", opts$parameter)]], "#0B1A33")
  expect_error(gt_theme_sdv(gt::gt(head(mtcars)), style = "sepia"), "must be one of")
})

test_that("every theme lets options passed through ... override its own", {
  themes <- setdiff(
    grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE),
    "gt_theme_preview"
  )
  for (nm in themes) {
    tbl <- get(nm, envir = asNamespace("sdvplotR"))(
      gt::gt(head(mtcars)),
      table.background.color = "#123456", heading.align = "center"
    )
    opts <- tbl[["_options"]]
    expect_identical(opts$value[[match("table_background_color", opts$parameter)]], "#123456", info = nm)
    expect_identical(opts$value[[match("heading_align", opts$parameter)]], "center", info = nm)
  }
})

test_that("the caller's options survive density scaling and forced striping", {
  opt <- function(tbl, name) tbl[["_options"]]$value[[match(name, tbl[["_options"]]$parameter)]]
  themes <- setdiff(
    grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE),
    "gt_theme_preview"
  )
  for (nm in themes) {
    tbl <- get(nm, envir = asNamespace("sdvplotR"))(
      gt::gt(head(mtcars)),
      density = "compact", table.font.size = gt::px(20)
    )
    expect_identical(opt(tbl, "table_font_size"), "20px", info = nm)
  }
  for (nm in c("gt_theme_savant", "gt_theme_ncaa")) {
    tbl <- get(nm)(gt::gt(head(mtcars)), row.striping.include_table_body = FALSE)
    expect_false(opt(tbl, "row_striping_include_table_body"), info = nm)
  }
})

test_that("density rescales a table styled on locations with no size role", {
  g <- gt::gt(head(mtcars), rownames_to_stub = TRUE) |>
    gt::grand_summary_rows(columns = "mpg", fns = list(total = ~ sum(.))) |>
    gt::tab_style(gt::cell_text(weight = "bold"), gt::cells_grand_summary())
  expect_s3_class(gt_theme_sdv(g, density = "social"), "gt_tbl")
})

test_that("gt_save_batch() needs an explicit dir and fails before rendering", {
  wd <- withr::local_tempdir()
  withr::local_dir(wd)
  expect_error(
    gt_save_batch(mtcars, cyl, function(d, g) gt::gt(head(d)), "cars-{group}.png"),
    "dir"
  )
  expect_length(list.files(wd, recursive = TRUE), 0)
})

test_that("every theme hands the Bootstrap table variables back to the table", {
  # pkgdown and Quarto add Bootstrap's `.table` class to gt's <table>; its cell rule paints every
  # td with the page's --bs-table-bg, so a light theme went dark-on-dark on a dark page
  guard <- "--bs-table-bg:\\s*transparent;\\s*--bs-table-color:\\s*currentcolor"
  for (i in seq_len(nrow(theme_bg))) {
    row <- theme_bg[i, ]
    args <- if (nzchar(row$has_style)) list(style = row$has_style) else list()
    html <- html_of(do.call(row$theme, c(list(gt::gt(head(mtcars))), args)))
    expect_match(html, guard, info = paste(row$theme, row$has_style))
  }
  team <- html_of(gt_theme_sdv_team(gt::gt(head(mtcars)), team = "KC", sport = "nfl"))
  expect_match(team, guard)
})

test_that("Google Fonts links ask for discrete weights, not a range", {
  # css2 answers 400 to `wght@100..900` for a family that does not span it (Oswald, Lato, Bungee),
  # and the font then never loads
  href <- .google_fonts_href(c("Oswald", "Fira Mono"))
  expect_false(grepl("..", href, fixed = TRUE))
  expect_match(href, "family=Oswald:ital,wght@0,100;", fixed = TRUE)
  expect_match(href, "&family=Fira+Mono:ital,wght@0,100;", fixed = TRUE)
  expect_match(href, "&display=swap$")
})

test_that("theme preview figures carry a plain alt text", {
  # R's HTML help LaTeX-escapes `_` in the options string, so a file-name alt reads "gt\_theme\_x"
  src <- list.files(testthat::test_path("..", "..", "R"), "^gt_theme_.*\\.R$", full.names = TRUE)
  skip_if_not(length(src) > 0, "R/ sources not available (installed-package check)")
  lines <- unlist(lapply(src, readLines, warn = FALSE))
  figs <- grep("\\\\figure\\{", lines, value = TRUE)
  expect_gte(length(figs), 22)
  alt <- sub('.*alt="([^"]*)".*', "\\1", figs)
  expect_true(all(grepl('alt="', figs, fixed = TRUE)))
  expect_false(any(grepl("[_\\\\]", alt)))
  expect_true(all(nchar(alt) <= 80))
})
