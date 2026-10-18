skip_on_cran()

html_of <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))
tiny <- function() gt::gt(mtcars[1:3, 1:3], id = "tt")

test_that("sdv_table_themes lists the 122 registry themes and filters", {
  all <- sdv_table_themes()
  expect_equal(nrow(all), 122)
  expect_named(all, c("id", "source", "category", "dark_policy"))
  dark <- sdv_table_themes(mode = "dark")
  expect_true(all(dark$dark_policy != "none"))
  expect_lt(nrow(dark), nrow(all))
  sports <- sdv_table_themes(category = "sports")
  expect_true(all(sports$category == "sports"))
  expect_error(sdv_table_themes(mode = "sepia"), "mode")
})

test_that("table_theme_spec fills palette defaults and substitutes every {key}", {
  sp <- table_theme_spec("wikipedia")
  expect_named(sp, c("id", "source", "category", "fonts", "sizes", "palette", "structure", "dark_policy"))
  expect_true(all(c("page", "labelBg", "labelColor", "summaryBg") %in% names(sp$palette)))
  strs <- unlist(Filter(is.character, sp$structure))
  expect_false(any(grepl("[{}]", strs)))
  # an empty structure border reads "none", a missing palette key is filled, never emitted literally
  expect_identical(.tt_border("", sp$palette), "none")
  expect_identical(.tt_border("1px solid {summaryBg}", list(bg = "#fff")), "1px solid #f0f0f0")
  expect_identical(.tt_border("1px solid {nope}", list()), "1px solid #888888")
  # the darkest default ground applies when a dark palette omits bg
  expect_identical(table_theme_spec("datagolf", "dark")$palette$bg, "#141414")
})

test_that("every registry theme resolves in every mode it supports", {
  for (i in sdv_table_themes()$id) {
    expect_no_error(table_theme_spec(i, "light"))
  }
  for (i in sdv_table_themes(mode = "dark")$id) {
    expect_no_error(table_theme_spec(i, "dark"))
  }
})

test_that("dark on a light-only theme names the theme and three same-category dark themes", {
  light_only <- sdv_table_themes()
  light_only <- light_only[light_only$dark_policy == "none", ]
  expect_gt(nrow(light_only), 0)
  err <- tryCatch(table_theme_spec(light_only$id[1], "dark"), error = function(e) conditionMessage(e))
  expect_match(err, "light-only")
  expect_match(err, light_only$id[1], fixed = TRUE)
  expect_match(err, "dark-capable themes in category|no dark-capable themes in category")
  expect_error(table_theme_spec("nejm", "dark"), "light-only")
  # nejm's category has no dark-capable theme: the fallback names three from any category
  e <- conditionMessage(tryCatch(table_theme_spec("nejm", "dark"), error = identity))
  expect_match(e, "no dark-capable themes in category 'journal'; try: ", fixed = TRUE)
  expect_length(trimws(strsplit(sub(".*try: ", "", e), ",")[[1]]), 3)
  # a light-only theme whose category has dark themes gets three from that category
  reg <- sdv_table_themes()
  dark <- reg[reg$dark_policy != "none", ]
  lo <- reg[reg$dark_policy == "none" & reg$category %in% dark$category, ]
  expect_gt(nrow(lo), 0)
  e2 <- conditionMessage(tryCatch(table_theme_spec(lo$id[1], "dark"), error = identity))
  listed <- trimws(strsplit(sub(".*: ", "", e2), ",")[[1]])
  expect_length(listed, 3)
  expect_identical(listed, sort(dark$id[dark$category == lo$category[1]], method = "radix")[1:3])
})

test_that("unknown names suggest close matches; bare site names point at the -site id", {
  expect_error(table_theme_spec("datagolff"), "datagolf")
  expect_error(table_theme_spec("zzzzzzzzzz"), "Unknown table theme")
  for (n in c("espn", "fivethirtyeight", "pff")) {
    expect_error(table_theme_spec(n), paste0(n, "-site"))
  }
  expect_error(table_theme_spec("wikipedia", "sepia"), "mode")
})

test_that("reactable_sdv_theme maps the spec onto reactableTheme", {
  skip_if_not_installed("reactable")
  sp <- table_theme_spec("wikipedia")
  th <- reactable_sdv_theme("wikipedia")
  expect_s3_class(th, "reactableTheme")
  expect_identical(th$borderColor, sp$palette$hline)
  expect_identical(th$color, sp$palette$text)
  expect_identical(th$backgroundColor, sp$palette$bg)
  expect_identical(th$stripedColor, sp$palette$stripe)
  expect_identical(th$cellPadding, paste0(sp$sizes$padY, "px ", sp$sizes$padX, "px"))
  expect_match(th$style$fontFamily, paste0("^\"", sp$fonts$body, "\", (sans-serif|serif|monospace)$"))
  expect_identical(th$headerStyle$borderBottom, sp$structure$labelBorderBottom)
  expect_identical(th$tableStyle$borderTop, sp$structure$tableBorderTop)
  expect_identical(th$headerStyle$background, sp$palette$labelBg)
  # highlight = bg mixed 6% toward the text color
  expect_identical(tolower(.theme_mix(sp$palette$text, sp$palette$bg, 0.06)), th$highlightColor)
  # python parity: the same registry resolves to the same hover color
  expect_identical(reactable_sdv_theme("datagolf", "dark")$backgroundColor, "#141414")
})

test_that("reactable_sdv_theme refuses reactablefmtr names and unknown ids", {
  skip_if_not_installed("reactable")
  expect_error(reactable_sdv_theme("nytimes"), "reactablefmtr::nytimes")
  expect_error(reactable_sdv_theme("espn"), "espn-site")
  expect_error(reactable_sdv_theme("pff"), "pff-site")
  expect_error(reactable_sdv_theme("datagolff"), "datagolf")
  expect_error(reactable_sdv_theme("nejm", "dark"), "light-only")
  for (n in .tt_fmtr_names) expect_error(reactable_sdv_theme(n), "reactablefmtr")
  expect_length(.tt_fmtr_names, 27)
})

test_that("every id x mode builds a reactable theme", {
  skip_if_not_installed("reactable")
  for (i in sdv_table_themes()$id) {
    expect_s3_class(reactable_sdv_theme(i), "reactableTheme")
  }
  for (i in sdv_table_themes(mode = "dark")$id) {
    expect_s3_class(reactable_sdv_theme(i, "dark"), "reactableTheme")
  }
})

test_that("gt_theme_source themes a table with the spec's font and rules", {
  sp <- table_theme_spec("datagolf")
  h <- html_of(gt_theme_source(tiny(), "datagolf"))
  expect_match(h, "Fira Sans", fixed = TRUE)
  expect_match(tolower(h), tolower(sp$palette$text), fixed = TRUE)
  # the table font is the family then its generic, never one bogus quoted family
  expect_match(h, "font-family: 'Fira Sans', sans-serif", fixed = TRUE)
  expect_no_match(h, "'Fira Sans, sans-serif'", fixed = TRUE)
  expect_no_match(h, "\"Fira Sans, sans-serif\"", fixed = TRUE)
  # scoped css: the row rule and the label rule from the spec
  expect_match(h, paste0("border-bottom: ", sp$structure$rowRule), fixed = TRUE)
  expect_match(h, paste0("border-bottom: ", sp$structure$labelBorderBottom), fixed = TRUE)
  # serif sources fall back to serif
  h2 <- html_of(gt_theme_source(tiny(), "economist"))
  fam <- table_theme_spec("economist")$fonts$body
  expect_match(h2, paste0("'", fam, "', ", .tt_generic_family(fam)), fixed = TRUE)
})

test_that("gt_theme_source imports the title, label and subtitle Google fonts too", {
  h <- html_of(gt_theme_source(tiny(), "washington-post"))
  fonts <- table_theme_spec("washington-post")$fonts
  imports <- regmatches(h, gregexpr("@import url\\([\"']https://fonts.googleapis.com/css2\\?family=[^:&\"']+", h))[[1]]
  imported <- gsub("+", " ", sub(".*family=", "", imports), fixed = TRUE)
  # every distinct face (Libre Franklin, Libre Bodoni, Gelasio) is imported
  expect_setequal(unique(imported), unique(c(fonts$body, fonts$title, fonts$label, fonts$subtitle)))
  expect_true("Libre Bodoni" %in% imported)
})

# the same two lists are asserted in sdvplot and sdvtables, so the three heuristics agree on every face
test_that("every registry face gets the shared generic family", {
  serif <- c(
    "Crimson Text", "Fraunces", "Gelasio", "Libre Bodoni", "Libre Caslon Display", "Libre Caslon Text",
    "Lora", "Newsreader", "Playfair Display", "Roboto Slab", "Source Serif 4", "Spectral", "Tinos"
  )
  mono <- c("Courier Prime", "DM Mono", "IBM Plex Mono", "JetBrains Mono", "Roboto Mono")
  faces <- unique(unlist(lapply(.tt_registry(), function(t) Filter(is.character, t$fonts))))
  g <- vapply(faces, .tt_generic_family, character(1))
  expect_setequal(faces[g == "serif"], serif)
  expect_setequal(faces[g == "monospace"], mono)
  expect_identical(.tt_font_stack(table_theme_spec("evolving-hockey")$fonts$body), "\"Crimson Text\", serif")
  expect_identical(.tt_font_stack(table_theme_spec("gtextras-dot-matrix")$fonts$body), "\"Courier Prime\", monospace")
})

test_that("gt_theme_source honours mode, density and rejects bad input", {
  light <- html_of(gt_theme_source(tiny(), "datagolf"))
  dark <- html_of(gt_theme_source(tiny(), "datagolf", mode = "dark"))
  expect_match(dark, "#141414", fixed = TRUE)
  expect_false(identical(light, dark))
  expect_false(identical(light, html_of(gt_theme_source(tiny(), "datagolf", density = "compact"))))
  expect_error(gt_theme_source(tiny(), "nejm", mode = "dark"), "light-only")
  expect_error(gt_theme_source(tiny(), "datagolff"), "datagolf")
  expect_error(gt_theme_source(tiny(), "datagolf", density = "huge"), "density|should be one of")
  expect_error(gt_theme_source(mtcars, "datagolf"), "gt_tbl")
})

test_that("every id x mode builds a gt theme, and a sample renders", {
  for (i in sdv_table_themes()$id) {
    expect_s3_class(gt_theme_source(tiny(), i), "gt_tbl")
  }
  for (i in sdv_table_themes(mode = "dark")$id) {
    expect_s3_class(gt_theme_source(tiny(), i, "dark"), "gt_tbl")
  }
  for (i in c("wikipedia", "nejm", "economist", "gtextras-espn")) {
    if (i %in% sdv_table_themes()$id) expect_match(html_of(gt_theme_source(tiny(), i)), "<table", fixed = TRUE)
  }
})

test_that("the 20 shortcuts equal gt_theme_source for their id", {
  ns <- asNamespace("sdvplotR")
  for (id in curated_themes) {
    fn <- paste0("gt_theme_", gsub("-", "_", id))
    expect_true(exists(fn, envir = ns), info = fn)
    expect_identical(
      html_of(get(fn, envir = ns)(tiny())),
      html_of(gt_theme_source(tiny(), id)),
      info = fn
    )
  }
  expect_identical(
    html_of(gt_theme_datagolf(tiny(), mode = "dark", density = "compact")),
    html_of(gt_theme_source(tiny(), "datagolf", "dark", "compact"))
  )
})

test_that("the shortcut generator is in sync (--check exits 0)", {
  skip_if(!file.exists(testthat::test_path("../../data-raw/gen_gt_shortcuts.R")), "source tree only")
  rscript <- file.path(R.home("bin"), "Rscript")
  status <- suppressWarnings(system2(
    rscript, c(shQuote(normalizePath(testthat::test_path("../../data-raw/gen_gt_shortcuts.R"))), "--check"),
    stdout = FALSE, stderr = FALSE
  ))
  expect_identical(status, 0L)
})
