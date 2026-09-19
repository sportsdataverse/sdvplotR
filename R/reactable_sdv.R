# reactable helpers for sdvplotR
# ============================================================================

#' Render Team Logos, Wordmarks and Headshots in 'reactable' Tables
#'
#' @description Cell renderers for [reactable::colDef()] that translate team
#'   abbreviations (or player IDs) into `<img>` tags. Values that cannot be
#'   resolved are returned unchanged so the original text is shown.
#'
#' @param sport Character string identifying the sport. One of
#'   [supported_sports()].
#' @param variant Character. Logo variant: `"primary"`, `"dark"`, `"light"`,
#'   `"alt"`, `"classic"`, or `"helmet"` (NFL only). Falls back to the primary
#'   image when the requested variant is not available for a team.
#' @param height Numeric. Image height in pixels.
#' @param default_img Character. Fallback image URL used when the value cannot
#'   be resolved. If `NULL` (the default) the raw value is shown instead.
#' @return A function with signature `function(value, index)` suitable for the
#'   `cell` argument of [reactable::colDef()].
#' @name reactable_sdv_images
#' @seealso [reactable_sdv_cols_label()], [reactable_sdv_team_color_bar()],
#'   [gt_sdv_logos()]
#' @examplesIf requireNamespace("reactable", quietly = TRUE)
#' library(reactable)
#' library(sdvplotR)
#'
#' df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))
#'
#' reactable(
#'   df,
#'   columns = list(
#'     team = colDef(cell = reactable_sdv_logos(sport = "nfl"), html = TRUE)
#'   )
#' )
NULL

#' @rdname reactable_sdv_images
#' @export
reactable_sdv_logos <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    variant = c("primary", "dark", "light", "alt", "classic", "helmet"),
    height = 30,
    default_img = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  variant <- rlang::arg_match0(variant, logo_variants)
  function(value, index) {
    img_tag(resolve_logo_url(value, sport, variant), value, height, default_img)
  }
}

#' @rdname reactable_sdv_images
#' @export
reactable_sdv_wordmarks <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    variant = c("primary", "dark", "light", "alt", "classic"),
    height = 30,
    default_img = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  variant <- rlang::arg_match0(variant, wordmark_variants)
  function(value, index) {
    img_tag(resolve_wordmark_url(value, sport, variant), value, height, default_img)
  }
}

#' @rdname reactable_sdv_images
#' @export
reactable_sdv_headshots <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    height = 40,
    default_img = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  function(value, index) {
    img_tag(headshot_from_id(value, sport = sport), value, height, default_img)
  }
}

img_tag <- function(url, value, height, default_img) {
  if (is.na(url) || !nzchar(url)) url <- default_img
  if (is.null(url)) return(as.character(value))
  sprintf(
    '<img src="%s" style="height:%spx;vertical-align:middle;" alt="%s" />',
    url, height, as.character(value)
  )
}

#' Replace 'reactable' Column Headers with Team Logos
#'
#' @description Builds a named list of [reactable::colDef()] objects whose
#'   headers are team logos, for data frames whose column names are team
#'   abbreviations. Columns that cannot be resolved are left out of the list so
#'   `reactable` falls back to the plain column name.
#'
#' @param .data A data frame whose column names are team abbreviations.
#' @param ... Additional arguments passed to every [reactable::colDef()].
#' @inheritParams reactable_sdv_images
#' @return A named list of `colDef` objects for the `columns` argument of
#'   [reactable::reactable()].
#' @export
#' @examplesIf requireNamespace("reactable", quietly = TRUE)
#' library(reactable)
#' library(sdvplotR)
#'
#' df <- data.frame(KC = 1:3, BUF = 4:6, SF = 7:9)
#' reactable(df, columns = reactable_sdv_cols_label(df, sport = "nfl"))
reactable_sdv_cols_label <- function(
    .data,
    ...,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    variant = c("primary", "dark", "light", "alt", "classic", "helmet"),
    height = 30
) {
  rlang::check_installed("reactable", "to build reactable column definitions.")
  sport <- rlang::arg_match0(sport, supported_sports())
  variant <- rlang::arg_match0(variant, logo_variants)
  out <- list()
  for (nm in names(.data)) {
    url <- resolve_logo_url(nm, sport, variant)
    if (is.na(url)) next
    out[[nm]] <- reactable::colDef(
      name = "",
      html = TRUE,
      header = sprintf('<img src="%s" style="height:%spx;" alt="%s" />', url, height, nm),
      ...
    )
  }
  out
}

#' Team-Colored Cell Styles for 'reactable' Tables
#'
#' @description Style functions for [reactable::colDef()] that color cells
#'   with a team's primary or secondary color: a horizontal bar whose length
#'   is proportional to the cell value, or a translucent background fill.
#'
#' @param data The data frame passed to [reactable::reactable()]. Needed to
#'   look up the team of each row.
#' @param team_col Character. Name of the column in `data` holding team
#'   abbreviations.
#' @param sport Character string identifying the sport. One of
#'   [supported_sports()].
#' @param type Character. `"primary"` or `"secondary"` team color.
#' @param max_value Numeric. Reference value that fills the whole cell. If
#'   `NULL` (the default), the maximum of the styled column is used.
#' @param alpha Numeric. Opacity of the background fill in `[0, 1]`.
#' @param na_color Color used when a team cannot be resolved.
#' @return A function with signature `function(value, index, name)` suitable
#'   for the `style` argument of [reactable::colDef()].
#' @name reactable_sdv_team_color
#' @examplesIf requireNamespace("reactable", quietly = TRUE)
#' library(reactable)
#' library(sdvplotR)
#'
#' df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(13, 12, 11))
#'
#' reactable(
#'   df,
#'   columns = list(
#'     team = colDef(style = reactable_sdv_team_color_bg(df, "team", sport = "nfl")),
#'     wins = colDef(style = reactable_sdv_team_color_bar(df, "team", sport = "nfl"))
#'   )
#' )
NULL

#' @rdname reactable_sdv_team_color
#' @export
reactable_sdv_team_color_bar <- function(
    data,
    team_col,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("primary", "secondary"),
    max_value = NULL,
    na_color = "grey70"
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary"))
  colors <- row_team_colors(data, team_col, sport, type, na_color)
  function(value, index, name) {
    top <- max_value %||% max(data[[name]], na.rm = TRUE)
    pct <- if (is.na(value) || !is.finite(top) || top == 0) 0 else round(100 * value / top, 1)
    sprintf(
      "background-image:linear-gradient(90deg, %s %s%%, transparent %s%%);",
      colors[index], pct, pct
    )
  }
}

#' @rdname reactable_sdv_team_color
#' @export
reactable_sdv_team_color_bg <- function(
    data,
    team_col,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("primary", "secondary"),
    alpha = 0.15,
    na_color = "grey70"
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary"))
  colors <- scales::alpha(row_team_colors(data, team_col, sport, type, na_color), alpha)
  function(value, index, name) {
    sprintf("background-color:%s;", colors[index])
  }
}

row_team_colors <- function(data, team_col, sport, type, na_color) {
  if (!team_col %in% names(data)) {
    cli::cli_abort("Column {.val {team_col}} not found in {.arg data}.")
  }
  colors <- sdv_team_colors(sport, as.character(data[[team_col]]), type = type)
  colors[is.na(colors)] <- na_color
  unname(colors)
}
