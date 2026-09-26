#' SportsDataverse theme for `gt` tables
#'
#' The SportsDataverse house table: Chivo titles and column labels, a Lato body
#' set in tabular figures, faint row dividers, and the SDV gradient
#' (`#3346F0` to `#7FE6DC`) drawn as a single horizon line under the column
#' labels. `style = "dark"` sets the same table on the SportsDataverse navy,
#' matching the dark mode of the package websites.
#'
#' @details
#' The gradient line is the theme's one accent; everything else stays quiet so
#' logos from [gt_sdv_logos()] and team colors carry the table. Titles and the
#' heading are left-aligned. Column labels keep the case you give them rather
#' than being forced to capitals. For a table dressed in one team's colors, see
#' [gt_theme_sdv_team()].
#'
#' The line under the column labels is a CSS `::after` element. gt's CSS inliner
#' removes those, so `gt::as_raw_html(inline_css = TRUE)` output (as used for
#' email) shows the table without it; knitted documents, websites and images
#' saved with [gt_save_crop()] keep it.
#'
#' @section Density:
#'
#' `density` scales the theme's type and row padding together. `"comfortable"`
#' leaves every size as the theme sets it, `"compact"` scales both down, and
#' `"social"` scales both up, to the scale [gt_save_crop()] and
#' [gt_social_crop()] export at.
#'
#' @param gt_object A `gt` table object to modify.
#' @param style Character. `"light"` for a white table, or `"dark"` for the
#'   SportsDataverse navy. Defaults to `"light"`.
#' @param density Character. The type and padding scale. One of `"comfortable"`,
#'   `"compact"`, or `"social"`. See Density. Defaults to `"comfortable"`.
#' @param ... Additional arguments passed to `gt::tab_options`, applied last so
#'   they override anything the theme sets.
#'
#' @returns Returns a modified `gt` table with the theme applied.
#'
#' @section Figures:
#' \if{html}{\figure{gt_theme_sdv.png}{options: style="width:100\%"}}
#'
#' \if{html}{\figure{gt_theme_sdv_dark.png}{options: style="width:100\%"}}
#'
#' @seealso [gt_theme_sdv_team()], [theme_bg] for the background to pad a saved
#'   image with.
#' @examples
#' library(gt)
#' standings <- data.frame(
#'   team = c("KC", "LAC", "DEN", "LV"),
#'   w = c(15, 11, 10, 4), l = c(2, 6, 7, 13)
#' )
#' gt(standings) |>
#'   gt_sdv_logos(columns = "team", sport = "nfl") |>
#'   tab_header("AFC West standings", "Through week 18") |>
#'   gt_theme_sdv()
#'
#' gt(standings) |> gt_theme_sdv(style = "dark", density = "social")
#'
#' @export
gt_theme_sdv <- function(gt_object, style = c("light", "dark"),
                         density = c("comfortable", "compact", "social"),
                         ...) {
  .check_gt(gt_object)
  style <- rlang::arg_match(style)
  pal <- if (style == "dark") {
    list(
      bg = "#0B1A33", heading_bg = "#0B1A33", title = "#FFFFFF", muted = "#A9B8D0",
      label = "#9CCBFF", text = "#EAEBEC", rule = "#1D3A66", group_bg = "#16305C",
      horizon = "linear-gradient(90deg, #3346F0, #7FE6DC)"
    )
  } else {
    .sdv_light_palette(horizon = "linear-gradient(90deg, #3346F0, #7FE6DC)")
  }
  .sdv_theme_build(gt_object, pal, density, ...)
}

#' Team-colored SportsDataverse theme for `gt` tables
#'
#' [gt_theme_sdv()] dressed in one team's colors: the title block is filled
#' with the team's primary color, the horizon line under the column labels takes
#' the secondary color, and the column labels are set in the primary color. The
#' colors come from [sdv_team_colors()], so any abbreviation, alias or name
#' [clean_team_abbrs()] resolves works here.
#'
#' @details
#' Text on the filled title block is black or white, whichever contrasts more
#' with the team's primary color, and the subtitle is blended toward it until it
#' still clears a 4.5:1 contrast ratio. When the secondary color would vanish
#' against the white table (a white or pale secondary), the horizon line uses the
#' primary color instead, and column labels fall back to the SportsDataverse
#' navy when the primary color is too light to read on white. With
#' `team = NULL` the table wears the SportsDataverse navy and cyan.
#'
#' @inheritSection gt_theme_sdv Density
#'
#' @param gt_object A `gt` table object to modify.
#' @param team Character. One team, as an abbreviation, alias or name for
#'   `sport`. Defaults to `NULL`, which uses the SportsDataverse colors.
#' @param sport Character. The league `team` belongs to; see
#'   [supported_sports()]. Defaults to `"nfl"`.
#' @inheritParams gt_theme_sdv
#'
#' @returns Returns a modified `gt` table with the theme applied.
#'
#' @section Figures:
#' \if{html}{\figure{gt_theme_sdv_team.png}{options: style="width:100\%"}}
#'
#' @seealso [gt_theme_sdv()], [sdv_team_colors()].
#' @examples
#' library(gt)
#' leaders <- data.frame(
#'   player = c("Patrick Mahomes", "Travis Kelce", "Isiah Pacheco"),
#'   yards = c(4183, 984, 935)
#' )
#' gt(leaders) |>
#'   tab_header("Chiefs yardage leaders", "2023 regular season") |>
#'   gt_theme_sdv_team(team = "KC", sport = "nfl")
#'
#' @export
gt_theme_sdv_team <- function(gt_object, team = NULL,
                              sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
                              density = c("comfortable", "compact", "social"),
                              ...) {
  .check_gt(gt_object)
  sport <- rlang::arg_match0(sport, supported_sports())

  if (is.null(team)) {
    primary <- "#0B1A33"
    secondary <- "#7FE6DC"
  } else {
    if (length(team) != 1) {
      cli::cli_abort("{.arg team} must be a single team, not {length(team)}.")
    }
    if (is.na(clean_team_abbrs(as.character(team), sport = sport, keep_non_matches = FALSE))) {
      cli::cli_abort(c(
        "No {toupper(sport)} team matches {.val {team}}.",
        "i" = "See {.run sdvplotR::valid_team_names(\"{sport}\")} for accepted keys."
      ))
    }
    primary <- unname(sdv_team_colors(sport, team, "primary"))
    secondary <- unname(sdv_team_colors(sport, team, "secondary"))
    if (is.na(primary) || !nzchar(primary)) {
      cli::cli_warn("No colors on file for {toupper(sport)} team {.val {team}}; using the SportsDataverse colors.")
      primary <- "#0B1A33"
      secondary <- "#7FE6DC"
    }
    if (is.na(secondary) || !nzchar(secondary)) secondary <- primary
  }

  title <- .theme_on_color(primary)
  horizon <- if (.theme_contrast(secondary, "#FFFFFF") >= 1.5) secondary else primary
  label <- if (.theme_contrast(primary, "#FFFFFF") >= 3) primary else "#0B1A33"

  pal <- .sdv_light_palette(horizon = horizon)
  pal$heading_bg <- primary
  pal$title <- title
  pal$subtitle <- .theme_secondary_on(primary, title)
  pal$label <- label
  .sdv_theme_build(gt_object, pal, density, ...)
}

.sdv_light_palette <- function(horizon) {
  list(
    bg = "#FFFFFF", heading_bg = "#FFFFFF", title = "#0B1A33", muted = "#4A5A75",
    label = "#16305C", text = "#0B1A33", rule = "#E3E8F1", group_bg = "#EEF3FA",
    horizon = horizon
  )
}

# shared by gt_theme_sdv() and gt_theme_sdv_team(): the palette decides the look
.sdv_theme_build <- function(gt_object, pal, density, ...) {
  res <- .table_id(gt_object)
  gt_object <- res$object
  table_id <- res$id
  subtitle <- pal$subtitle %||% pal$muted
  sel <- paste0("#", table_id)

  table <- gt_object |>
    gt::opt_table_font(font = list(gt::google_font("Lato"), gt::default_fonts())) |>
    gt::tab_style(
      locations = gt::cells_title("title"),
      style = gt::cell_text(font = gt::google_font("Chivo"), weight = 800, size = gt::px(22), color = pal$title)
    ) |>
    gt::tab_style(
      locations = gt::cells_title("subtitle"),
      style = gt::cell_text(font = gt::google_font("Lato"), size = gt::px(14), color = subtitle)
    ) |>
    gt::tab_style(
      locations = list(gt::cells_column_labels(), gt::cells_column_spanners()),
      style = gt::cell_text(font = gt::google_font("Chivo"), weight = 500, size = gt::px(13), color = pal$label)
    ) |>
    gt::tab_style(
      locations = gt::cells_row_groups(),
      style = list(
        gt::cell_text(font = gt::google_font("Chivo"), weight = 500, size = gt::px(13), color = pal$label),
        gt::cell_fill(color = pal$group_bg)
      )
    ) |>
    gt::tab_style(
      locations = list(gt::cells_source_notes(), gt::cells_footnotes()),
      style = gt::cell_text(size = gt::px(12), color = pal$muted)
    )

  # the theme's options with the caller's `...` merged on top, so passing an
  # option the theme also sets overrides it instead of erroring
  opts <- utils::modifyList(
    list(
      table.background.color = pal$bg,
      table.font.color = pal$text,
      table.font.size = gt::px(15),
      heading.align = "left",
      heading.background.color = pal$heading_bg,
      heading.padding = gt::px(4),
      heading.border.bottom.style = "none",
      column_labels.background.color = pal$bg,
      column_labels.border.top.style = "none",
      column_labels.border.bottom.style = "none",
      column_labels.padding = gt::px(6),
      table_body.hlines.color = pal$rule,
      table_body.hlines.width = gt::px(1),
      table_body.border.top.style = "none",
      table_body.border.bottom.style = "none",
      row_group.border.top.style = "none",
      row_group.border.bottom.style = "none",
      data_row.padding = gt::px(7),
      table.border.top.style = "none",
      table.border.bottom.style = "none",
      source_notes.border.bottom.style = "none",
      footnotes.border.bottom.style = "none"
    ),
    list(...)
  )
  table <- do.call(gt::tab_options, c(list(table), opts)) |>
    gt::opt_css(c(
      # the horizon: one line under the column labels, drawn over the thead so
      # a gradient spans the whole table rather than restarting in each cell
      paste0(sel, " thead {position: relative;}"),
      paste0(
        sel, " thead::after {content: \"\"; position: absolute; left: 0; right: 0; ",
        "bottom: 0; height: 4px; background: ", pal$horizon, ";}"
      ),
      paste0(sel, " .gt_col_headings th {padding-bottom: 10px;}"),
      # one 14px inset shared by the heading, the outer columns and the notes, so
      # the title, first column and source note start on the same edge
      paste0(
        sel, " .gt_heading, ", sel, " .gt_sourcenote, ", sel, " .gt_footnote, ",
        sel, " .gt_col_headings th:first-child, ", sel, " tbody td:first-child ",
        "{padding-left: 14px !important;}"
      ),
      paste0(
        sel, " .gt_heading, ", sel, " .gt_sourcenote, ", sel, " .gt_footnote, ",
        sel, " .gt_col_headings th:last-child, ", sel, " tbody td:last-child ",
        "{padding-right: 14px !important;}"
      ),
      paste0(sel, " .gt_title {padding-top: 12px !important;}"),
      paste0(sel, " .gt_subtitle {padding-bottom: 12px !important;}"),
      .theme_last_row_border(table_id, pal$bg),
      .theme_tabular_nums(table_id)
    ))

  .theme_scale_output(table, density)
}
