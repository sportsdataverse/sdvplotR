# reactable helpers for sdvplotR
# ============================================================================

#' Render Team Logos, Wordmarks and Headshots in 'reactable' Tables
#'
#' @description Cell renderers for [reactable::colDef()] that translate team
#'   abbreviations (or player IDs) into `<img>` tags. Values that cannot be
#'   resolved are returned unchanged so the original text is shown. Logos and
#'   wordmarks get the team's full name as `alt` text, headshots
#'   `"Player <id> headshot"`.
#'
#' @inheritParams sdv_logo_url
#' @param league A league key from [sdv_leagues()].
#' @param variant Character. `"default"`, `"dark"`, or a named variant from
#'   [sdv_marks()] (`"scoreboard"`, `"grayscale"`, ...); see [sdv_logo_url()].
#'   A team without it gets its closest mark, and in the browser the image
#'   falls back to the default mark when the variant's file fails to load.
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
#'     team = colDef(cell = reactable_sdv_logos(league = "nfl"), html = TRUE)
#'   )
#' )
NULL

#' @rdname reactable_sdv_images
#' @export
reactable_sdv_logos <- function(
    league,
    variant = "default",
    height = 30,
    default_img = NULL,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)
  check_mark_variant(variant, league)
  cell_mark <- cell_marks(logo_from_team, league, season, variant, id_system, strict)
  function(value, index) {
    m <- cell_mark(value, index)
    img_tag(m$url, m$alt, height, default_img, fallback = m$fallback)
  }
}

#' @rdname reactable_sdv_images
#' @export
reactable_sdv_wordmarks <- function(
    league,
    variant = "default",
    height = 30,
    default_img = NULL,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)
  check_mark_variant(variant, league)
  cell_mark <- cell_marks(wordmark_from_team, league, season, variant, id_system, strict)
  function(value, index) {
    m <- cell_mark(value, index)
    img_tag(m$url, m$alt, height, default_img, fallback = m$fallback)
  }
}

#' @inheritParams sdv_headshot_url
#' @rdname reactable_sdv_images
#' @export
reactable_sdv_headshots <- function(
    league,
    height = 40,
    default_img = NULL,
    id_system = "espn"
) {
  league <- check_league(league)
  id_system <- check_id_system(id_system, league)
  function(value, index) {
    img_tag(headshot_from_id(value, league, id_system), headshot_alt(value), height, default_img, value)
  }
}

# A cell's mark, resolved once per distinct value and season: reactable calls
# the renderer per cell, so a 300-row table would otherwise resolve each team
# (and warn about each unresolved one) once per row. `season` is one value, or
# one per row (`index` is the row reactable passes).
cell_marks <- function(lookup, league, season, variant, id_system, strict) {
  memo <- new.env(parent = emptyenv()) # nolint: object_usage_linter. read and written in the closure below
  function(value, index) {
    s <- if (length(season) > 1L) season[index] else season
    key <- paste(value, is.na(value), s %||% "", sep = "\r")
    if (is.null(memo[[key]])) {
      memo[[key]] <- list(
        url = lookup(value, league, s, variant, id_system, strict),
        alt = team_alt(value, league, s, id_system),
        fallback = variant_fallback(value, league, variant, lookup, s, id_system)
      )
    }
    memo[[key]]
  }
}

# `alt` is the image's alt text; `value` (the cell's raw value) is shown as
# text when there is no image, and is the alt of the `default_img` stand-in.
# `fallback` is the default image a variant (dark, light, ...) swaps to in the
# browser when the variant fails to load.
img_tag <- function(url, alt, height, default_img, value = alt, fallback = NA) {
  force(value)
  if (is.na(url) || !nzchar(url)) {
    url <- default_img
    alt <- value
    fallback <- NA
  }
  if (is.null(url)) {
    return(as.character(value))
  }
  sprintf(
    '<img src="%s" style="height:%spx;vertical-align:middle;" alt="%s"%s />',
    url, height, htmltools::htmlEscape(as.character(alt), attribute = TRUE),
    img_onerror(url, fallback)
  )
}

# A variant image falls back to the default mark in the browser rather than
# breaking. Marks come from the SportsDataverse logo archive (immutable copies),
# so this guards only the live-source fallback: ESPN has dropped a variant file
# the team data still listed (a dark logo 404'd, #61).
img_onerror <- function(url, fallback) {
  if (is.na(fallback) || identical(url, fallback)) {
    return("")
  }
  js <- paste0("this.onerror=null;this.src='", gsub("'", "\\\\'", fallback), "'")
  paste0(' onerror="', htmltools::htmlEscape(js, attribute = TRUE), '"')
}

# The default mark a variant falls back to in the browser; none for the default
# itself (resolution has already warned about a value it could not resolve).
variant_fallback <- function(value, league, variant, lookup, season = NULL, id_system = "auto") {
  if (identical(variant, "default")) NA_character_ else quiet_miss(lookup(value, league, season, id_system = id_system))
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
#' reactable(df, columns = reactable_sdv_cols_label(df, league = "nfl"))
reactable_sdv_cols_label <- function(
    .data,
    ...,
    league,
    variant = "default",
    height = 30,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  rlang::check_installed("reactable", "to build reactable column definitions.")
  league <- check_league(league)
  check_mark_variant(variant, league)
  out <- list()
  for (nm in names(.data)) {
    url <- quiet_miss(logo_from_team(nm, league, season, variant, id_system, strict))
    if (is.na(url)) next
    out[[nm]] <- reactable::colDef(
      name = "",
      html = TRUE,
      header = sprintf(
        '<img src="%s" style="height:%spx;" alt="%s"%s />',
        url, height, htmltools::htmlEscape(team_alt(nm, league, season, id_system), attribute = TRUE),
        img_onerror(url, variant_fallback(nm, league, variant, logo_from_team, season, id_system))
      ),
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
#' @inheritParams sdv_logo_url
#' @param league A league key from [sdv_leagues()].
#' @param which Character. `"primary"` or `"secondary"` team color.
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
#'     team = colDef(style = reactable_sdv_team_color_bg(df, "team", league = "nfl")),
#'     wins = colDef(style = reactable_sdv_team_color_bar(df, "team", league = "nfl"))
#'   )
#' )
NULL

#' @rdname reactable_sdv_team_color
#' @export
reactable_sdv_team_color_bar <- function(
    data,
    team_col,
    league,
    which = c("primary", "secondary"),
    max_value = NULL,
    na_color = "grey70",
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)
  which <- rlang::arg_match0(which, c("primary", "secondary"))
  colors <- row_team_colors(data, team_col, league, which, na_color, season, id_system, strict)
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
    league,
    which = c("primary", "secondary"),
    alpha = 0.15,
    na_color = "grey70",
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)
  which <- rlang::arg_match0(which, c("primary", "secondary"))
  colors <- scales::alpha(row_team_colors(data, team_col, league, which, na_color, season, id_system, strict), alpha)
  function(value, index, name) {
    sprintf("background-color:%s;", colors[index])
  }
}

row_team_colors <- function(
    data,
    team_col,
    league,
    which,
    na_color,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  if (!team_col %in% names(data)) {
    cli::cli_abort("Column {.val {team_col}} not found in {.arg data}.")
  }
  colors <- sdv_team_colors(league, data[[team_col]],
    which = which,
    season = season, id_system = id_system, strict = strict
  )
  colors[is.na(colors)] <- na_color
  unname(colors)
}
