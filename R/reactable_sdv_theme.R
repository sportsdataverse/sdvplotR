#' A surveyed table style as a 'reactable' theme
#'
#' Builds a [reactable::reactableTheme()] from one of the 122 surveyed table
#' styles listed by [sdv_table_themes()]: the text, background, hairline, stripe
#' and hover colors, the header label style, the body font and the cell padding
#' come from the theme's spec ([table_theme_spec()]).
#'
#' The 27 themes of 'reactablefmtr' (`"espn"`, `"nytimes"`, `"fivethirtyeight"`,
#' ...) are not rebuilt here: call `reactablefmtr::<name>()` for those. Three of
#' their names (`"espn"`, `"fivethirtyeight"`, `"pff"`) are also sites in the
#' registry; the surveyed look of those is `"espn-site"`,
#' `"fivethirtyeight-site"` and `"pff-site"`.
#'
#' The theme does not load a font. Pass the result to
#' `reactable(theme = )`.
#'
#' @param name A registry theme id, for example `"wikipedia"`, `"datagolf"` or
#'   `"nejm"`.
#' @param mode `"light"` (default) or `"dark"`. `"dark"` on a light-only theme
#'   is an error that names three dark-capable themes in the same category.
#'
#' @returns A `reactableTheme` object.
#'
#' @examplesIf requireNamespace("reactable", quietly = TRUE)
#' library(reactable)
#' df <- data.frame(team = c("KC", "BUF", "BAL"), wins = c(12, 10, 9))
#' reactable(df, theme = reactable_sdv_theme("wikipedia"))
#' reactable(df, theme = reactable_sdv_theme("datagolf", mode = "dark"))
#'
#' @seealso [sdv_table_themes()], [table_theme_spec()], [gt_theme_source()]
#' @export
reactable_sdv_theme <- function(name, mode = "light") {
  rlang::check_installed("reactable", reason = "to build a 'reactable' theme.")
  .tt_check_mode(mode)
  if (is.character(name) && length(name) == 1L && name %in% .tt_fmtr_names) {
    port <- paste0("reactablefmtr::", name, "()")
    msg <- c(
      "{.val {name}} is a {.pkg reactablefmtr} theme, which {.fn reactable_sdv_theme} does not rebuild.",
      "i" = "Call {.code {port}} instead."
    )
    if (name %in% .tt_site_ports) {
      site <- paste0(name, "-site")
      msg <- c(msg, "i" = "For the surveyed site look, use {.val {site}}.")
    }
    cli::cli_abort(msg)
  }
  sp <- table_theme_spec(name, mode)
  pal <- sp$palette
  fonts <- sp$fonts
  sizes <- sp$sizes
  st <- sp$structure
  reactable::reactableTheme(
    color = pal$text,
    backgroundColor = pal$bg,
    borderColor = pal$hline,
    stripedColor = pal$stripe,
    highlightColor = tolower(.theme_mix(pal$text, pal$bg, 0.06)),
    cellPadding = paste0(sizes$padY, "px ", sizes$padX, "px"),
    style = list(
      fontFamily = .tt_font_stack(fonts$body),
      fontSize = paste0(sizes$body, "px")
    ),
    headerStyle = list(
      background = pal$labelBg,
      color = pal$labelColor,
      fontWeight = fonts$labelWeight,
      textTransform = st$labelTransform,
      letterSpacing = st$labelTracking,
      fontFamily = .tt_font_stack(fonts$label),
      borderBottom = st$labelBorderBottom,
      fontSize = paste0(sizes$label, "px")
    ),
    tableStyle = list(borderTop = st$tableBorderTop)
  )
}
