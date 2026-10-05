#' Focus on rows of a `gt` table by dimming the rest
#'
#' Emphasizes one or more rows and mutes everything else.
#' `gtExtras::gt_highlight_rows()` makes a row louder; this leaves it as the only
#' row at full strength.
#'
#' Rows can be given as a filtering expression evaluated against the underlying
#' data, or as plain row numbers.
#'
#' @param gt_object A `gt` table object to modify.
#' @param rows The rows to focus on. Either an expression evaluated against the
#'   table's data, such as `cyl == 8`, or a numeric vector of row indices.
#' @param columns The columns the spotlight covers. Cells outside this selection
#'   are dimmed, in the focused rows as well as the others, so only the selected
#'   cells are left at full strength. Defaults to all of them, which lights the
#'   whole row.
#' @param fill Optional. A hex color for the fill behind the focused rows.
#'   Defaults to `NULL`.
#' @param text_color Optional. A hex color for the text of the focused rows.
#'   Defaults to `NULL`.
#' @param bold Logical. Should the focused rows be bolded? Defaults to `TRUE`.
#' @param accent_color Optional. A color for a bar drawn on the left edge of the
#'   focused rows. Supplying one is what turns the bar on, the same way `fill`
#'   and `text_color` work. Defaults to `NULL`, no bar.
#' @param accent_width Numeric. The width of that bar in pixels, used only when
#'   `accent_color` is given. Defaults to `4`.
#' @param accent_column The column to draw the bar against, on its left edge. If
#'   `NULL`, the leftmost rendered column is used, which is what marks the start
#'   of the row. Name a column when the row you are lighting sits elsewhere, as
#'   with the second block of a [gt_snake()] table. More than one may be given,
#'   which draws a bar against each. Defaults to `NULL`.
#' @param dim_color Character. The text color applied to every other row.
#'   `"auto"`, the default, blends the table's text toward its background until
#'   it sits just above 4.5:1 contrast against it (WCAG AA for text), so the
#'   rows read as muted rather than disabled, on a light or a dark theme. Apply
#'   the theme first: the background is read from the table as set so far.
#'   Pass a color to choose it yourself, or `NULL` to leave the other rows
#'   alone, emphasizing without dimming.
#' @param if_none Character. What to do when `rows` matches nothing. `"warn"`
#'   leaves the table alone and says so. `"dim"` dims the whole table, which is
#'   what you want when several tables are laid out together with [gt_grid()] and
#'   the highlighted row lives in only one of them. `"ignore"` leaves it alone
#'   silently. Defaults to `"warn"`.
#'
#' @returns Returns a modified `gt` table with the chosen rows emphasized.
#'
#' @examples
#' library(gt)
#'
#' nfc <- subset(sdv_example_standings, division %in% c("NFC North", "NFC West"),
#'   c(team_name, wins, losses, conference_rank))
#'
#' # by expression: the playoff seeds
#' gt(nfc) %>% gt_spotlight(rows = conference_rank <= 7)
#'
#' # by position, with an accent bar
#' gt(nfc) %>%
#'   gt_spotlight(rows = 2, accent_color = "#0054AD", fill = "#EEF3FA")
#'
#' # narrowing the spotlight to some columns dims the rest of the row too
#' gt(nfc) %>% gt_spotlight(wins:losses, rows = 3, accent_color = "darkblue")
#'
#' # put the bar somewhere other than the first column
#' gt(nfc) %>%
#'   gt_spotlight(losses, rows = 3, accent_color = "darkblue", accent_column = losses)
#'
#' # across several tables: blocks without a 12-win team dim rather than stay lit
#' chunks <- split(nfc, ceiling(seq_len(nrow(nfc)) / 4))
#' tbls <- lapply(chunks, function(x) {
#'   gt(x) %>% gt_spotlight(rows = wins >= 12, if_none = "dim")
#' })
#' gt_grid(tbls, ncol = 2)
#'
#' @seealso [gt_cutline()] for marking a threshold rather than a row.
#' @import gt
#' @importFrom magrittr %>%
#' @export
gt_spotlight <- function(gt_object, rows, columns = gt::everything(),
                         fill = NULL, text_color = NULL, bold = TRUE,
                         accent_color = NULL, accent_width = 4,
                         accent_column = NULL, dim_color = "auto",
                         if_none = c("warn", "dim", "ignore")) {
  .check_gt(gt_object)
  if_none <- match.arg(if_none)

  # gtUtils dimmed to a fixed #BBBBBB: 1.9:1 on white, under WCAG AA, and on a
  # dark theme barely dimmer than the text. muted but legible on either ground
  if (identical(dim_color, "auto")) {
    bg <- .table_background(gt_object)
    dim_color <- .theme_secondary_on(bg, .theme_on_color(bg), target = 4.5)
  }

  data <- gt_object[["_data"]]
  n <- nrow(data)

  # rows can be a data-masked expression or raw indices
  res <- rlang::eval_tidy(rlang::enquo(rows), data = data)
  focus_idx <- if (is.logical(res)) which(res) else as.integer(res)
  focus_idx <- focus_idx[!is.na(focus_idx)]
  other_idx <- setdiff(seq_len(n), focus_idx)

  if (length(focus_idx) == 0) {
    # no focused rows means the whole table is "the rest", which is what makes a
    # spotlight read across a gt_grid()
    if (if_none == "dim" && !is.null(dim_color)) {
      return(gt_object |>
        gt::tab_style(
          style = gt::cell_text(color = dim_color),
          locations = gt::cells_body(columns = gt::everything())
        ))
    }
    if (if_none == "warn") {
      cli::cli_warn(c(
        "{.arg rows} matched no rows, so the table is unchanged.",
        "i" = "Set {.code if_none = \"dim\"} to dim the whole table instead."
      ))
    }
    return(gt_object)
  }

  # dim everything outside the lit cells: other rows, plus the focus row's other
  # columns, which would otherwise read as neither
  sel_cols <- names(dplyr::select(data, {{ columns }}))
  boxhead <- gt_object[["_boxhead"]]
  rendered <- boxhead[["var"]][boxhead[["type"]] == "default"]
  rest_cols <- setdiff(rendered, sel_cols)

  if (!is.null(dim_color)) {
    if (length(other_idx)) {
      gt_object <- gt_object |>
        gt::tab_style(
          style = gt::cell_text(color = dim_color),
          locations = gt::cells_body(columns = gt::everything(), rows = other_idx)
        )
    }
    if (length(rest_cols)) {
      gt_object <- gt_object |>
        gt::tab_style(
          style = gt::cell_text(color = dim_color),
          locations = gt::cells_body(
            columns = tidyselect::all_of(rest_cols),
            rows = focus_idx
          )
        )
    }
  }

  # focus fill + text
  focus_styles <- list()
  if (!is.null(fill)) focus_styles <- c(focus_styles, list(gt::cell_fill(color = fill)))
  tc_args <- list(color = text_color, weight = if (bold) "bold" else NULL)
  tc_args <- tc_args[!vapply(tc_args, is.null, logical(1))]
  if (length(tc_args)) focus_styles <- c(focus_styles, list(do.call(gt::cell_text, tc_args)))

  if (length(focus_styles)) {
    gt_object <- gt_object |>
      gt::tab_style(
        style = focus_styles,
        locations = gt::cells_body(columns = {{ columns }}, rows = focus_idx)
      )
  }

  # accent bar, on the leftmost body column unless told otherwise
  if (!is.null(accent_color)) {
    acc_q <- rlang::enquo(accent_column)
    acc_cols <- if (rlang::quo_is_null(acc_q)) {
      rendered[1]
    } else {
      names(dplyr::select(data, !!acc_q))
    }
    acc_cols <- intersect(acc_cols, rendered)

    if (!length(acc_cols)) {
      cli::cli_warn("{.arg accent_column} matched no rendered column; no accent drawn.")
    } else {
      gt_object <- gt_object |>
        gt::tab_style(
          style = gt::cell_borders(
            sides = "left", color = accent_color,
            weight = gt::px(accent_width)
          ),
          locations = gt::cells_body(
            columns = tidyselect::all_of(acc_cols),
            rows = focus_idx
          )
        )
    }
  }

  gt_object
}
