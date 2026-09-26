# Build `theme_bg`: the background color each `gt_theme_*()` applies, read
# back from the themed table rather than typed by hand, so the lookup can't
# drift from the themes. Themes with a `style` argument get one row per style.
#
# Run from the package root: Rscript data-raw/theme_bg.R

pkgload::load_all(quiet = TRUE)

table_bg <- function(tbl) {
  opts <- tbl[["_options"]]
  opts$value[[match("table_background_color", opts$parameter)]]
}

themes <- sort(setdiff(
  grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE),
  "gt_theme_preview"
))

rows <- lapply(themes, function(nm) {
  fn <- get(nm, envir = asNamespace("sdvplotR"))
  styles <- if ("style" %in% names(formals(fn))) c("light", "dark") else ""
  bg <- vapply(styles, function(s) {
    args <- if (nzchar(s)) list(style = s) else list()
    table_bg(do.call(fn, c(list(gt::gt(head(mtcars))), args)))
  }, character(1))
  tibble::tibble(theme = nm, has_style = styles, bg = unname(bg))
})

theme_bg <- do.call(rbind, rows)
stopifnot(!anyNA(theme_bg$bg), setequal(unique(theme_bg$theme), themes))

usethis::use_data(theme_bg, overwrite = TRUE)
