#' A surveyed table style as a `gt` theme
#'
#' Styles a table like one of the 122 surveyed sources listed by
#' [sdv_table_themes()] (`"datagolf"`, `"wikipedia"`, `"economist"`, ...).
#' Fonts, ground, text and rule colors, row rules, column rules, striping, label
#' case and tracking, and padding come from the theme's spec
#' ([table_theme_spec()]).
#'
#' @details
#' The spec's sizes are the `"comfortable"` baseline; `density` rescales type
#' and padding by the house density ratios, as the other `gt_theme_*()`
#' functions do. Each face is a Google font written with its generic family
#' (`'Lora', serif`), so a face that fails to load degrades to the right kind
#' of font. The borders, stripes and tracking `gt` has no option for are written
#' as css scoped to this table's id.
#'
#' @param gt_object A `gt` table object to modify.
#' @param name A registry theme id, for example `"datagolf"` or `"wikipedia"`.
#' @param mode `"light"` (default) or `"dark"`. `"dark"` on a light-only theme
#'   is an error that names three dark-capable themes in the same category.
#' @param density Character. The type and padding scale. One of
#'   `"comfortable"` (the spec's own sizes), `"compact"` or `"social"`.
#'
#' @returns A modified `gt` table with the theme applied.
#'
#' @examples
#' library(gt)
#' central <- subset(
#'   sdv_example_standings, division == "Central",
#'   c(team_name, wins, losses, win_pct)
#' )
#' gt(central) |> gt_theme_source("datagolf")
#' gt(central) |> gt_theme_source("datagolf", mode = "dark", density = "compact")
#'
#' @seealso [sdv_table_themes()], [table_theme_spec()], [reactable_theme_sdv()]
#' @import gt
#' @export
gt_theme_source <- function(gt_object, name, mode = "light", density = "comfortable") {
  .check_gt(gt_object)
  .tt_check_mode(mode)
  sp <- table_theme_spec(name, mode)
  d <- .theme_density(density)
  base <- .theme_density("comfortable")
  k <- lapply(names(d), function(r) d[[r]] / base[[r]])
  names(k) <- names(d)
  pal <- sp$palette
  fonts <- sp$fonts
  sizes <- sp$sizes
  st <- sp$structure
  tr <- function(size, role) round(size * k[[role]], 1)
  pad_y <- tr(sizes$padY, "pad")
  pad_x <- tr(sizes$padX, "pad")

  res <- .table_id(gt_object)
  gt_object <- res$object
  tid <- res$id

  # a face with its generic family: gt writes 'Lora', serif. Only the table font imports
  # the Google font (below), so the stylesheet carries one @import per family, not one per style
  face <- function(family) c(family, .tt_generic_family(family))
  text <- function(role, family, weight, color, ...) {
    gt::cell_text(
      font = face(family), weight = weight, size = gt::px(tr(sizes[[role]], role)),
      color = color, ...
    )
  }
  case <- function(transform) {
    if (transform %in% c("uppercase", "lowercase", "capitalize")) list(transform = transform) else list()
  }
  label <- do.call(text, c(list("label", fonts$label, fonts$labelWeight, pal$labelColor), case(st$labelTransform)))
  subtitle_extra <- if (isTRUE(fonts$subtitleItalic)) list(style = "italic") else list()

  out <- gt_object |>
    gt::opt_table_font(font = list(
      gt::google_font(fonts$body), .tt_generic_family(fonts$body), gt::default_fonts()
    )) |>
    gt::tab_style(
      gt::cell_text(
        font = face(fonts$body), weight = fonts$bodyWeight,
        size = gt::px(tr(sizes$body, "body")), color = pal$text
      ),
      gt::cells_body()
    ) |>
    gt::tab_style(
      do.call(text, c(list("title", fonts$title, fonts$titleWeight, pal$text), case(st$titleTransform))),
      gt::cells_title("title")
    ) |>
    gt::tab_style(
      do.call(text, c(list("subtitle", fonts$subtitle, 400, pal$muted), subtitle_extra)),
      gt::cells_title("subtitle")
    ) |>
    gt::tab_style(label, gt::cells_column_labels()) |>
    gt::tab_style(label, gt::cells_column_spanners()) |>
    gt::tab_style(text("label", fonts$label, fonts$labelWeight, pal$text), gt::cells_row_groups()) |>
    gt::tab_style(text("source", fonts$body, 400, pal$muted), gt::cells_source_notes()) |>
    gt::tab_style(text("source", fonts$body, 400, pal$muted), gt::cells_footnotes()) |>
    gt::tab_options(
      table.background.color = pal$bg,
      table.font.color = pal$text,
      table.font.size = gt::px(tr(sizes$body, "body")),
      heading.background.color = pal$bg,
      heading.align = st$headingAlign,
      heading.border.bottom.style = "none",
      heading.padding = gt::px(pad_y),
      column_labels.background.color = pal$labelBg,
      column_labels.padding = gt::px(pad_y),
      column_labels.padding.horizontal = gt::px(pad_x),
      row_group.background.color = pal$summaryBg,
      row_group.padding = gt::px(pad_y),
      data_row.padding = gt::px(pad_y),
      data_row.padding.horizontal = gt::px(pad_x),
      source_notes.background.color = pal$bg,
      source_notes.padding = gt::px(pad_y),
      table.border.top.style = "none",
      table.border.bottom.style = "none",
      table_body.border.top.style = "none",
      table_body.border.bottom.style = "none",
      column_labels.border.top.style = "none",
      column_labels.border.bottom.style = "none",
      source_notes.border.bottom.style = "none",
      source_notes.border.lr.style = "none"
    )

  scoped <- function(selectors, rule) {
    paste0(paste0("#", tid, " ", selectors, collapse = ", "), " {", rule, "}")
  }
  heads <- c(".gt_col_heading", ".gt_column_spanner")
  css <- c(
    .theme_tabular_nums(tid),
    scoped(".gt_table", paste0("border-top: ", st$tableBorderTop, "; border-bottom: ", st$tableBorderBottom, ";")),
    scoped(".gt_col_headings", paste0("border-top: ", st$labelBorderTop, "; border-bottom: ", st$labelBorderBottom, ";")),
    scoped("td.gt_row", paste0("border-top: none; border-bottom: ", st$rowRule, ";")),
    scoped(heads, paste0("text-align: ", st$labelAlign, "; letter-spacing: ", st$labelTracking, ";"))
  )
  if (!identical(st$frame, "none")) {
    css <- c(css, scoped(".gt_table", paste0("outline: ", st$frame, "; outline-offset: -1px;")))
  }
  if (!identical(st$colRule, "none")) {
    css <- c(css, scoped(
      c(".gt_col_heading:not(:first-child)", "td.gt_row:not(:first-child)"),
      paste0("border-left: ", st$colRule, ";")
    ))
  }
  if (isTRUE(st$stripe)) {
    css <- c(css, scoped("tbody tr:nth-child(even) td.gt_row", paste0("background-color: ", pal$stripe, ";")))
  }
  gt::opt_css(out, paste(css, collapse = "\n"))
}
