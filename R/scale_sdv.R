# Scale helpers for sdvplotR
# ============================================================================

# ---------------------------------------------------------------------------
# Color and Fill Scales
# ---------------------------------------------------------------------------

#' Scales for Sports Team Colors
#'
#' @description These functions map team names to their team colors in
#'   color and fill aesthetics.
#'
#' @param sport Character string identifying the sport.
#' @param type One of `"primary"` or `"secondary"` to decide which color type to use.
#' @param values If `NULL` (the default) use the internal team color vectors. Otherwise
#'   a set of aesthetic values to map data values to.
#' @param aesthetics The aesthetic to apply the scale to (`"colour"` or `"fill"`).
#' @param breaks Breaks for the scale.
#' @param na.value Color for NA values.
#' @param guide Guide function or name.
#' @param alpha Factor to modify color transparency via [scales::alpha()].
#'   If `NA` (the default) no transparency will be applied.
#' @param ... Other arguments passed to [ggplot2::scale_color_manual()] or
#'   [ggplot2::scale_fill_manual()].
#'
#' @name scale_sdv
#' @aliases NULL
#' @return A ggplot2 scale object.
#'
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- valid_team_names("nfl")[1:16]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' ggplot(df, aes(x = teams, y = random_value)) +
#'   geom_col(aes(color = teams, fill = teams), width = 0.5) +
#'   scale_color_sdv(sport = "nfl", type = "secondary") +
#'   scale_fill_sdv(sport = "nfl", alpha = 0.4) +
#'   theme_minimal() +
#'   theme(axis.text.x = element_text(angle = 45, hjust = 1))
#' }
NULL

#' @rdname scale_sdv
#' @export
scale_color_sdv <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("primary", "secondary"),
    values = NULL,
    ...,
    aesthetics = "colour",
    breaks = ggplot2::waiver(),
    na.value = "grey50",
    guide = NULL,
    alpha = NA
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary"))

  if (is.null(values)) {
    values <- get_team_colors(sport = sport, type = type)
  }

  if (!is.na(alpha)) values <- scales::alpha(values, alpha = alpha)

  ggplot2::scale_color_manual(
    ...,
    values = values,
    aesthetics = aesthetics,
    breaks = breaks,
    na.value = na.value,
    guide = guide
  )
}

#' @rdname scale_sdv
#' @export
scale_colour_sdv <- scale_color_sdv

#' @rdname scale_sdv
#' @export
scale_fill_sdv <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("primary", "secondary"),
    values = NULL,
    ...,
    aesthetics = "fill",
    breaks = ggplot2::waiver(),
    na.value = "grey50",
    guide = NULL,
    alpha = NA
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary"))

  if (is.null(values)) {
    values <- get_team_colors(sport = sport, type = type)
  }

  if (!is.na(alpha)) values <- scales::alpha(values, alpha = alpha)

  ggplot2::scale_fill_manual(
    ...,
    values = values,
    aesthetics = aesthetics,
    breaks = breaks,
    na.value = na.value,
    guide = guide
  )
}


# ---------------------------------------------------------------------------
# Axis Scales (Logos as axis labels)
# ---------------------------------------------------------------------------

#' Axis Scales for Sports Team Logos
#'
#' @description These scale functions replace axis labels with team logos or
#'   player headshots. They work by modifying the axis text theme element to
#'   render images.
#'
#' @details The scale translates team names into raw image HTML and places the
#'   HTML as axis labels. Because of the way ggplots are constructed, it is
#'   necessary to adjust the theme after calling this scale. This can be done
#'   by calling [theme_x_sdv()] or [theme_y_sdv()] or alternatively by manually
#'   changing the relevant `axis.text` to [ggtext::element_markdown()].
#'
#' @param sport Character string identifying the sport.
#' @param size The logo size in pixels. It is applied as height for an x-scale
#'   and as width for a y-scale.
#' @param ... Other arguments passed to [ggplot2::scale_x_discrete()] or
#'   [ggplot2::scale_y_discrete()].
#' @param expand Expansion limits for the axis.
#' @param guide Guide for the axis.
#' @param position Position of the axis.
#'
#' @name scale_axes_sdv
#' @aliases NULL
#' @return A ggplot2 scale object.
#' @seealso [theme_x_sdv()], [theme_y_sdv()]
#'
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- valid_team_names("nfl")[1:8]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' if (requireNamespace("ggtext", quietly = TRUE)) {
#'   ggplot(df, aes(x = teams, y = random_value)) +
#'     geom_col(aes(fill = teams), width = 0.5) +
#'     scale_fill_sdv(sport = "nfl", alpha = 0.4) +
#'     scale_x_sdv(sport = "nfl") +
#'     theme_minimal() +
#'     theme_x_sdv()
#' }
#' }
NULL

#' @rdname scale_axes_sdv
#' @export
scale_x_sdv <- function(
    ...,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "bottom",
    size = 12
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  position <- rlang::arg_match0(position, c("top", "bottom"))

  ggplot2::scale_x_discrete(
    ...,
    labels = function(x) {
      logo_html(x, sport = sport, type = "height", size = size)
    },
    expand = expand,
    guide = guide,
    position = position
  )
}

#' @rdname scale_axes_sdv
#' @export
scale_y_sdv <- function(
    ...,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "left",
    size = 12
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  position <- rlang::arg_match0(position, c("left", "right"))

  ggplot2::scale_y_discrete(
    ...,
    labels = function(x) {
      logo_html(x, sport = sport, type = "width", size = size)
    },
    expand = expand,
    guide = guide,
    position = position
  )
}

#' @param id_type Which ID system the player IDs hold: `NULL` (the default;
#'   GSIS IDs for the NFL, ESPN athlete IDs otherwise), `"espn"` or `"league"`
#'   (NBA / WNBA Stats `PERSON_ID`, MLBAM ID, GSIS). See [geom_sdv_headshots()].
#' @rdname scale_axes_sdv
#' @export
scale_x_sdv_headshots <- function(
    ...,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "bottom",
    size = 20,
    id_type = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  id_type <- check_id_type(id_type, sport)
  position <- rlang::arg_match0(position, c("top", "bottom"))

  ggplot2::scale_x_discrete(
    ...,
    labels = function(x) {
      headshot_html(x, sport = sport, type = "height", size = size, id_type = id_type)
    },
    expand = expand,
    guide = guide,
    position = position
  )
}

#' @rdname scale_axes_sdv
#' @export
scale_y_sdv_headshots <- function(
    ...,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "left",
    size = 30,
    id_type = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  id_type <- check_id_type(id_type, sport)
  position <- rlang::arg_match0(position, c("left", "right"))

  ggplot2::scale_y_discrete(
    ...,
    labels = function(x) {
      headshot_html(x, sport = sport, type = "width", size = size, id_type = id_type)
    },
    expand = expand,
    guide = guide,
    position = position
  )
}


# ---------------------------------------------------------------------------
# Theme helpers for axis text
# ---------------------------------------------------------------------------

#' Theme Helpers for SDV Axis Labels
#'
#' @description These functions are convenience wrappers around a theme call
#'   that activates markdown in x-axis and y-axis labels using
#'   [ggtext::element_markdown()].
#'
#' @details These functions are a wrapper around the function calls
#'   `ggplot2::theme(axis.text.x = ggtext::element_markdown())` as well as
#'   `ggplot2::theme(axis.text.y = ggtext::element_markdown())`.
#'   They are made to be used in conjunction with [scale_x_sdv()] and
#'   [scale_y_sdv()] respectively.
#'
#' @name theme_sdv
#' @aliases NULL
#' @return A ggplot2 theme object.
#' @seealso [scale_x_sdv()], [scale_y_sdv()]
#'
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- valid_team_names("nfl")[1:8]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' if (requireNamespace("ggtext", quietly = TRUE)) {
#'   ggplot(df, aes(x = teams, y = random_value)) +
#'     geom_col(width = 0.5) +
#'     scale_x_sdv(sport = "nfl") +
#'     theme_minimal() +
#'     theme_x_sdv()
#' }
#' }
NULL

#' @rdname theme_sdv
#' @export
theme_x_sdv <- function() {
  if (!is_installed("ggtext")) {
    cli::cli_abort(c(
      "Package {.val ggtext} required to use this theme.",
      "i" = 'Please install it with {.code install.packages("ggtext")}'
    ))
  }
  loadNamespace("gridtext", versionCheck = list(op = ">=", version = "0.1.4"))
  ggplot2::theme(axis.text.x = ggtext::element_markdown())
}

#' @rdname theme_sdv
#' @export
theme_y_sdv <- function() {
  if (!is_installed("ggtext")) {
    cli::cli_abort(c(
      "Package {.val ggtext} required to use this theme.",
      "i" = 'Please install it with {.code install.packages("ggtext")}'
    ))
  }
  loadNamespace("gridtext", versionCheck = list(op = ">=", version = "0.1.4"))
  ggplot2::theme(axis.text.y = ggtext::element_markdown())
}


# ---------------------------------------------------------------------------
# Internal helper for team colors
# ---------------------------------------------------------------------------

get_team_colors <- function(sport, type = c("primary", "secondary")) {
  type <- rlang::arg_match0(type, c("primary", "secondary"))
  ref <- get_team_ref(sport)

  col_name <- if (type == "primary") "color1" else "color2"

  colors <- ref[[col_name]]
  names(colors) <- ref$team_abbr
  colors <- colors[!is.na(colors)]

  # Manual scales match data values to these names exactly, so also name each
  # color by every other key clean_team_abbrs() accepts: provider aliases
  # ("AZ", "GSW"), full names and historical abbreviations ("MON").
  keys <- unique(c(names(abbr_mapping[[sport]]), names(historical_team_mappings[[sport]])))
  keys <- setdiff(keys, names(colors))
  old <- options(sdvplotR.verbose = FALSE)
  on.exit(options(old), add = TRUE)
  canon <- clean_team_abbrs(keys, sport = sport, keep_non_matches = FALSE)
  keep <- canon %in% names(colors)
  c(colors, stats::setNames(unname(colors[canon[keep]]), keys[keep]))
}
