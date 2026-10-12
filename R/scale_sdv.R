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
#' @param league A league key from [sdv_leagues()].
#' @param which One of `"primary"` or `"secondary"`: which team colour to use.
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
#' team_abbr <- sdv_teams("nfl")$abbr[1:16]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' ggplot(df, aes(x = teams, y = random_value)) +
#'   geom_col(aes(color = teams, fill = teams), width = 0.5) +
#'   scale_color_sdv(league = "nfl", which = "secondary") +
#'   scale_fill_sdv(league = "nfl", alpha = 0.4) +
#'   theme_minimal() +
#'   theme(axis.text.x = element_text(angle = 45, hjust = 1))
#' }
NULL

#' @rdname scale_sdv
#' @export
scale_color_sdv <- function(
    league,
    which = c("primary", "secondary"),
    values = NULL,
    ...,
    aesthetics = "colour",
    breaks = ggplot2::waiver(),
    na.value = "grey50",
    guide = NULL,
    alpha = NA
) {
  league <- check_league(league)
  which <- rlang::arg_match0(which, c("primary", "secondary"))

  if (is.null(values)) {
    values <- get_team_colors(league, which)
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
    league,
    which = c("primary", "secondary"),
    values = NULL,
    ...,
    aesthetics = "fill",
    breaks = ggplot2::waiver(),
    na.value = "grey50",
    guide = NULL,
    alpha = NA
) {
  league <- check_league(league)
  which <- rlang::arg_match0(which, c("primary", "secondary"))

  if (is.null(values)) {
    values <- get_team_colors(league, which)
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
#'   by calling [theme_x_sdv()] or [theme_y_sdv()] after any complete theme such
#'   as [ggplot2::theme_minimal()], which replaces every theme element. To set
#'   the theme by hand, change the relevant `axis.text` and its position
#'   children (`axis.text.x.bottom`, ...) to [ggtext::element_markdown()]:
#'   complete themes in 'ggplot2' 4 set those children themselves.
#'
#' @inheritParams sdv_logo_url
#' @param league A league key from [sdv_leagues()].
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
#' team_abbr <- sdv_teams("nfl")$abbr[1:8]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' if (requireNamespace("ggtext", quietly = TRUE)) {
#'   ggplot(df, aes(x = teams, y = random_value)) +
#'     geom_col(aes(fill = teams), width = 0.5) +
#'     scale_fill_sdv(league = "nfl", alpha = 0.4) +
#'     scale_x_sdv(league = "nfl") +
#'     theme_minimal() +
#'     theme_x_sdv()
#' }
#' }
NULL

#' @rdname scale_axes_sdv
#' @export
scale_x_sdv <- function(
    ...,
    league,
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "bottom",
    size = 12,
    season = NULL,
    id_system = "auto"
) {
  league <- check_league(league)
  position <- rlang::arg_match0(position, c("top", "bottom"))

  ggplot2::scale_x_discrete(
    ...,
    labels = function(x) {
      logo_html(x, league, type = "height", size = size, season = season, id_system = id_system)
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
    league,
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "left",
    size = 12,
    season = NULL,
    id_system = "auto"
) {
  league <- check_league(league)
  position <- rlang::arg_match0(position, c("left", "right"))

  ggplot2::scale_y_discrete(
    ...,
    labels = function(x) {
      logo_html(x, league, type = "width", size = size, season = season, id_system = id_system)
    },
    expand = expand,
    guide = guide,
    position = position
  )
}

#' @inheritParams sdv_headshot_url
#' @rdname scale_axes_sdv
#' @export
scale_x_sdv_headshots <- function(
    ...,
    league,
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "bottom",
    size = 20,
    id_system = "espn"
) {
  league <- check_league(league)
  id_system <- check_id_system(id_system, league)
  position <- rlang::arg_match0(position, c("top", "bottom"))

  ggplot2::scale_x_discrete(
    ...,
    labels = function(x) {
      headshot_html(x, league, type = "height", size = size, id_system = id_system)
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
    league,
    expand = ggplot2::waiver(),
    guide = ggplot2::waiver(),
    position = "left",
    size = 30,
    id_system = "espn"
) {
  league <- check_league(league)
  id_system <- check_id_system(id_system, league)
  position <- rlang::arg_match0(position, c("left", "right"))

  ggplot2::scale_y_discrete(
    ...,
    labels = function(x) {
      headshot_html(x, league, type = "width", size = size, id_system = id_system)
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
#' @details These functions set [ggtext::element_markdown()] on `axis.text.x`
#'   and its position children `axis.text.x.bottom` / `axis.text.x.top`
#'   (`theme_x_sdv()`), or on `axis.text.y`, `axis.text.y.left` and
#'   `axis.text.y.right` (`theme_y_sdv()`). Complete themes in 'ggplot2' 4
#'   (`theme_minimal()`, ...) set those children themselves, and a markdown
#'   parent alone would not replace them. Add these after any complete theme,
#'   which replaces every element. They are made to be used in conjunction
#'   with [scale_x_sdv()] and [scale_y_sdv()] respectively.
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
#' team_abbr <- sdv_teams("nfl")$abbr[1:8]
#'
#' df <- data.frame(
#'   random_value = runif(length(team_abbr), 0, 1),
#'   teams = team_abbr
#' )
#'
#' if (requireNamespace("ggtext", quietly = TRUE)) {
#'   ggplot(df, aes(x = teams, y = random_value)) +
#'     geom_col(width = 0.5) +
#'     scale_x_sdv(league = "nfl") +
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
  # ggplot2 4's complete themes (theme_minimal(), ...) set axis.text.x.bottom
  # and .top themselves, which would shadow a markdown axis.text.x
  md <- ggtext::element_markdown()
  ggplot2::theme(axis.text.x = md, axis.text.x.bottom = md, axis.text.x.top = md)
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
  # ggplot2 4's complete themes (theme_minimal(), ...) set axis.text.y.left
  # and .right themselves, which would shadow a markdown axis.text.y
  md <- ggtext::element_markdown()
  ggplot2::theme(axis.text.y = md, axis.text.y.left = md, axis.text.y.right = md)
}


# ---------------------------------------------------------------------------
# Internal helper for team colors
# ---------------------------------------------------------------------------

# Every team's colour, named by its team_id and by every alias value that
# resolves to it (id_system = "auto", no season): a manual scale matches data
# values to these names exactly. Built once per league per index load.
get_team_colors <- function(league, which = c("primary", "secondary")) {
  which <- rlang::arg_match0(which, c("primary", "secondary"))
  key <- paste0("scale:", league)
  if (is.null(index_cache[[key]])) {
    a <- index_aliases()
    v <- unique(a$value[a$league == league & a$id_system %in% resolve_priority])
    index_cache[[key]] <- stats::setNames(resolve_ids(v, league)$ids, v)
  }
  ids <- index_cache[[key]]
  t <- sdv_teams(league)
  col <- t[[paste0("color_", which)]]
  vals <- c(stats::setNames(col, t$team_id), stats::setNames(col[match(ids, t$team_id)], names(ids)))
  vals[!is.na(vals) & !duplicated(names(vals))]
}
