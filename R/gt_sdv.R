# gt table helpers for sdvplotR
# ============================================================================

#' Render Logos in 'gt' Tables
#'
#' @description Translate team abbreviations into logos and render these images
#'   in html tables with the 'gt' package.
#'
#' @param gt_object A table object created using [gt::gt()].
#' @param columns The columns for which the image translation should be applied.
#'   Argument has no effect if `locations` is not `NULL`.
#' @param league A league key from [sdv_leagues()].
#' @param height The absolute height (px) of the image in the table cell.
#' @param locations If `NULL` (the default), the function will render logos in
#'   argument `columns`. Otherwise, the cell or set of cells to be associated
#'   with the team name transformation. Only [gt::cells_body()],
#'   [gt::cells_stub()], [gt::cells_column_labels()], and
#'   [gt::cells_row_groups()] helper functions can be used here.
#' @param include_name If `TRUE`, keep the cell's text after the logo, so a
#'   cell shows logo and name (what cbbplotR's `gt_cbb_teams()` did), and the
#'   image gets an empty `alt` so the name is not read twice. Defaults to
#'   `FALSE`, the logo alone, whose `alt` is the team's full name.
#' @param season `NULL` (the default) for today's marks, or one season whose
#'   marks every cell shows (the ending year for the NHL). See the Historical
#'   logos section.
#' @param id_system,strict How the team values are read and what an unresolved
#'   one does, as in [sdv_logo_url()].
#'
#' @inheritSection geom_sdv_logos Historical logos
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_wordmarks()], [gt_sdv_headshots()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' teams <- sdv_teams("nfl")$abbr[1:8]
#' df <- data.frame(
#'   team = teams,
#'   logo = teams,
#'   wins = sample(1:16, 8)
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_logos(columns = "logo", league = "nfl")
#'
#' # logo and name in one cell; NCAA.com school names resolve too
#' data.frame(team = c("Iowa St.", "St. John's (NY)"), net = c(8, 12)) |>
#'   gt() |>
#'   gt_sdv_logos(columns = "team", league = "mbb", height = 20, include_name = TRUE)
#'
#' # the marks of the 1994-95 season
#' data.frame(team = c("QUE", "HFD", "WIN"), pts = c(65, 43, 39)) |>
#'   gt() |>
#'   gt_sdv_logos(columns = "team", league = "nhl", season = 1995)
#' }
gt_sdv_logos <- function(
    gt_object,
    columns,
    league,
    height = 30,
    locations = NULL,
    include_name = FALSE,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)
  if (!is.null(season) && length(season) != 1) {
    cli::cli_abort("{.arg season} must be {.code NULL} or a single season.")
  }

  gt_sdv_image(
    gt_object = gt_object,
    columns = {{ columns }},
    height = height,
    locations = locations,
    league = league,
    type = "logo",
    include_name = include_name,
    season = season,
    id_system = id_system,
    strict = strict
  )
}

#' Render Wordmarks in 'gt' Tables
#'
#' @description Translate team abbreviations into wordmarks and render these
#'   images in html tables with the 'gt' package.
#'
#' @inheritParams gt_sdv_logos
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_headshots()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(14, 13, 12))
#' df |>
#'   gt() |>
#'   gt_sdv_wordmarks(columns = "team", league = "nfl")
#' }
gt_sdv_wordmarks <- function(
    gt_object,
    columns,
    league,
    height = 30,
    locations = NULL,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  league <- check_league(league)

  gt_sdv_image(
    gt_object = gt_object,
    columns = {{ columns }},
    height = height,
    locations = locations,
    league = league,
    type = "wordmark",
    season = season,
    id_system = id_system,
    strict = strict
  )
}

#' Render Player Headshots in 'gt' Tables
#'
#' @description Translate player IDs to player headshots and render these
#'   images in html tables with the 'gt' package. IDs are ESPN athlete IDs in
#'   every league, or as `id_system` says. IDs that resolve to no headshot
#'   are left as text.
#'
#' @inheritParams gt_sdv_logos
#' @inheritParams geom_sdv_headshots
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_wordmarks()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   player_id = c("00-0033873", "00-0026498", "00-0035228"),
#'   player_name = c("P.Mahomes", "M.Stafford", "K.Murray")
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_headshots(columns = "player_id", league = "nfl", id_system = "gsis")
#' }
gt_sdv_headshots <- function(
    gt_object,
    columns,
    league,
    height = 30,
    locations = NULL,
    id_system = "espn"
) {
  league <- check_league(league)
  id_system <- check_id_system(id_system, league)

  if (is.null(locations)) {
    locations <- gt::cells_body({{ columns }})
  }

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::text_transform(
    data = gt_object,
    locations = locations,
    fn = function(x) {
      image_urls <- headshot_from_id(x, league, id_system)
      missing <- is.na(image_urls)

      # web_image() needs a URL for every cell; IDs with none stay as text
      image_urls[missing] <- headshot_placeholder
      img_tags <- headshot_img(image_urls, x, height)
      img_tags[missing] <- x[missing]

      img_tags
    }
  )
}

#' Render Logos in 'gt' Table Column Labels
#'
#' @description Translate team abbreviations into logos and render these images
#'   in column labels of 'gt' tables.
#'
#' @param gt_object A table object created using [gt::gt()].
#' @param columns The columns whose labels should be replaced with logos.
#' @param league A league key from [sdv_leagues()].
#' @param height The absolute height (px) of the image.
#' @param mark_type One of `"logo"`, `"wordmark"` or `"headshot"`: whether the
#'   column names are teams (logo / wordmark) or player IDs (headshot).
#' @param id_system How the column names are read. `"auto"` (the default) is
#'   [sdv_logo_url()]'s automatic reading for logo and wordmark labels, and
#'   means `"espn"` when `mark_type = "headshot"`; otherwise as in
#'   [sdv_headshot_url()].
#' @param season,strict For logo and wordmark labels only (headshots take
#'   neither): the season whose mark to show, and whether an unresolved label
#'   is an error. With `strict = TRUE` every label that is not a team errors,
#'   including the non-team columns the default `columns = gt::everything()`
#'   takes.
#'
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_wordmarks()], [gt_sdv_headshots()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   KC = 1:3,
#'   BUF = 4:6,
#'   SF = 7:9
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_cols_label(columns = c("KC", "BUF", "SF"), league = "nfl")
#' }
gt_sdv_cols_label <- function(
    gt_object,
    columns = gt::everything(),
    league,
    height = 30,
    mark_type = c("logo", "wordmark", "headshot"),
    id_system = "auto",
    season = NULL,
    strict = FALSE
) {
  league <- check_league(league)
  mark_type <- rlang::arg_match0(mark_type, c("logo", "wordmark", "headshot"))
  if (mark_type == "headshot") {
    id_system <- check_id_system(if (identical(id_system, "auto")) "espn" else id_system, league)
  }

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::cols_label_with(
    data = gt_object,
    columns = {{ columns }},
    fn = function(x) {
      if (mark_type == "headshot") {
        image_url <- headshot_from_id(x, league, id_system)
        out <- headshot_img(image_url, x, height)
        out[is.na(image_url)] <- x[is.na(image_url)]
      } else {
        # a label that is no team (the default columns take every one) stays text, quietly
        lookup <- if (mark_type == "logo") logo_from_team else wordmark_from_team
        img_url <- withCallingHandlers(lookup(x, league, season, id_system = id_system, strict = strict),
          sdvplotR_unresolved_warning = function(w) invokeRestart("muffleWarning")
        )

        # Generate the HTML img tag
        out <- paste0(
          "<img src=\"",
          img_url,
          "\" style=\"height:",
          height,
          ";\" alt=\"",
          htmltools::htmlEscape(team_alt(x, league, season, id_system), attribute = TRUE),
          "\">"
        )

        # If the image url is NA we didn't find a match. Return the actual value
        out[is.na(img_url)] <- x[is.na(img_url)]
      }
      gt::html(out)
    }
  )
}


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# What gt::web_image() writes, plus the alt text it has no argument for.
headshot_img <- function(url, id, height) {
  paste0(
    "<img src=\"", url, "\" style=\"height:", height, ";\" alt=\"",
    htmltools::htmlEscape(headshot_alt(id), attribute = TRUE), "\">"
  )
}

gt_sdv_image <- function(
    gt_object,
    columns,
    height = 30,
    locations = NULL,
    league = "nfl",
    type = c("logo", "wordmark"),
    include_name = FALSE,
    season = NULL,
    id_system = "auto",
    strict = FALSE
) {
  type <- match.arg(type)

  if (is.null(locations)) {
    locations <- gt::cells_body({{ columns }})
  }

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::text_transform(
    data = gt_object,
    locations = locations,
    fn = function(x) {
      # gt passes the cell text HTML-escaped ("Texas A&amp;M")
      text <- html_unescape(as.character(x))
      if (type == "logo") {
        img_url <- logo_from_team(text, league, season = season, id_system = id_system, strict = strict)
      } else {
        img_url <- wordmark_from_team(text, league, season = season, id_system = id_system, strict = strict)
      }

      # Generate the HTML img tag
      out <- paste0(
        "<img src=\"",
        img_url,
        "\" style=\"height:",
        height,
        if (isTRUE(include_name)) ";vertical-align:middle;margin-right:0.35em",
        # with include_name the cell's own text already names the team
        ";\" alt=\"",
        if (!isTRUE(include_name)) htmltools::htmlEscape(team_alt(text, league, season, id_system), attribute = TRUE),
        "\">",
        if (isTRUE(include_name)) x
      )

      out <- lapply(out, gt::html)

      # If the image url is NA we didn't find a match. Return the actual value
      # to allow the user to call gt::sub_missing()
      out[is.na(img_url)] <- x[is.na(img_url)]
      out
    }
  )
}


# ---------------------------------------------------------------------------
# Team stacking for gt tables (from cfbplotR)
# ---------------------------------------------------------------------------

#' Merge and Stack Text in gt Tables with Team Colors
#'
#' @description Takes an existing `gt` table and merges column 1 and column 2,
#'   stacking column 1's text on top of column 2's. Top text is in all caps with
#'   black bold text, while the lower text is smaller and colored by the team name.
#'
#' @details The lower text takes the team's primary color when it clears a
#'   4.5:1 contrast ratio (WCAG AA) against the cell background, else the secondary
#'   color, else the primary darkened (or lightened, on a dark background)
#'   until it does, so a light primary such as Missouri's gold stays readable
#'   on a white table and keeps its gold on a dark one.
#'
#' @param gt_object An existing gt table object of class `gt_tbl`.
#' @param col1 The column to stack on top. Will be all caps, black bold text.
#' @param col2 The column to merge and place below. Will be smaller and colored.
#' @param team_col The column of team names for the color of the bottom text.
#' @inheritParams sdv_logo_url
#' @param league A league key from [sdv_leagues()].
#' @param font_size_top Font size for the top text.
#' @param font_size_bottom Font size for the bottom text.
#' @param color The color for the top text.
#' @param background The cell background the lower text is checked against.
#'   `NULL` (the default) reads the table's background color, so a table
#'   theme such as [gt_theme_midnight()] applied **before** this function is
#'   taken into account; a theme applied afterwards isn't seen, so set
#'   `background` then. A table with no background color set counts as white.
#'
#' @return An object of class `gt_tbl`.
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   team = c("KC", "BUF", "SF"),
#'   mascot = c("Chiefs", "Bills", "49ers"),
#'   wins = c(11, 10, 12)
#' )
#'
#' df |>
#'   gt() |>
#'   gt_merge_stack_team_color(team, mascot, team, league = "nfl")
#' }
gt_merge_stack_team_color <- function(
    gt_object,
    col1,
    col2,
    team_col,
    league,
    font_size_top = 14,
    font_size_bottom = 12,
    color = "black",
    background = NULL,
    season = NULL,
    id_system = "auto"
) {
  league <- check_league(league)

  stopifnot(
    "'gt_object' must be a 'gt_tbl', have you accidentally passed raw data?" =
      "gt_tbl" %in% class(gt_object)
  )

  team <- rlang::enexpr(team_col) |> rlang::as_string()
  team_bare <- gt_object[["_data"]][[team]]

  if (is.null(team_bare)) {
    cli::cli_abort("Must include a column of team names, `team_col` is NULL")
  }

  # resolved once for both colours, so an unresolved team warns once
  t <- sdv_teams(league)
  i <- match(sdv_resolve(team_bare, league, season = season, id_system = id_system), t$team_id)
  team_color <- t$color_primary[i]
  team_color[is.na(team_color)] <- "grey"
  team_color <- sdv_readable_ink(team_color, t$color_secondary[i], background %||% .table_background(gt_object))

  col1_bare <- rlang::enexpr(col1) |> rlang::as_string()
  col2_bare <- rlang::enexpr(col2) |> rlang::as_string()
  data_in <- gt_object[["_data"]][[col2_bare]]

  # built per data row and set through fmt(), which gt applies in data order
  # (the stub column included), so row groups can't shuffle the pairs
  top <- htmltools::htmlEscape(as.character(gt_object[["_data"]][[col1_bare]]))
  html <- glue::glue(
    "<div style='line-height:{font_size_top - 2}px'>",
    "<span style='font-weight:bold;font-variant:small-caps;color:{color};font-size:{font_size_top}px'>",
    "{top}</span></div>\n",
    "<div style='line-height:{font_size_bottom - 2}px'>",
    "<span style='font-weight:bold;color:{team_color};font-size:{font_size_bottom}px'>",
    "{htmltools::htmlEscape(as.character(data_in))}</span></div>"
  )
  .fmt_rows(gt_object, col1_bare, as.character(html)) |>
    gt::cols_hide(columns = {{ col2 }})
}

# Text color that clears `target` contrast on `bg`: the primary, else the
# secondary, else the primary blended toward black / white (whichever reads on
# `bg`) until it passes. Vectorised over the team colors.
sdv_readable_ink <- function(primary, secondary, bg, target = 4.5) {
  toward <- .theme_on_color(bg)
  vapply(seq_along(primary), function(i) {
    for (cand in c(primary[i], secondary[i])) {
      if (!is.na(cand) && .theme_contrast(cand, bg) >= target) return(cand)
    }
    for (w in seq(0.95, 0, by = -0.05)) {
      cand <- .theme_mix(primary[i], toward, w)
      if (.theme_contrast(cand, bg) >= target) return(cand)
    }
    toward
  }, character(1), USE.NAMES = FALSE)
}

# undo the escaping gt applies to cell text before text_transform() sees it;
# &amp; last, so "&amp;lt;" stays "&lt;"
html_unescape <- function(x) {
  entities <- c("&lt;" = "<", "&gt;" = ">", "&quot;" = "\"", "&#39;" = "'", "&amp;" = "&")
  for (e in names(entities)) x <- gsub(e, entities[[e]], x, fixed = TRUE)
  x
}
