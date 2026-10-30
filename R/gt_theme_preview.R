#' Preview data in every theme
#'
#' Renders the same few rows through each `gt_theme_*` function in the package
#' and lays the results out in a grid, one panel per theme, labeled with its name.
#'
#' @param data A data frame. A `gt` table is also accepted, in which case its
#'   underlying data is used.
#' @param themes Character. The theme functions to show, by name. If `NULL`,
#'   every `gt_theme_*` in the package that needs nothing but the table is
#'   used, which leaves out [gt_theme_source()] (it needs a registry `name`)
#'   and [gt_theme_sdv_team()] (it needs a team). Defaults to `NULL`.
#' @param n Integer. How many rows of `data` to show in each panel. Defaults to
#'   `5`.
#' @param ncol Integer. The number of panels across. Defaults to `3`.
#' @param density Character. A `density` passed to every theme, so the panels are
#'   comparable. If `NULL`, each theme uses its own default. Defaults to
#'   `"compact"`.
#' @param file Optional. A path to write a PNG to. If `NULL`, the grid is
#'   returned for the viewer. Defaults to `NULL`.
#' @param ... Further arguments passed to [gt_grid()], such as `gap` or `bg`.
#'
#' @details
#' Each panel is captioned with the theme's name in a neutral style, set outside
#' the table. Using each theme's own heading instead would let a wide display
#' title stretch its panel out of shape.
#'
#' Themes that take extra arguments, such as `style` on [gt_theme_sofa()], are
#' shown at their defaults.
#'
#' @returns What [gt_grid()] returns: an `htmltools::browsable()` tag list of
#'   the previews, which prints in the viewer; with `file`, invisibly `file`
#'   after writing the PNG to it.
#'
#' @examples
#' nfl <- subset(
#'   sdv_example_standings, league == "nfl",
#'   c(team_name, wins, losses, win_pct)
#' )
#' gt_theme_preview(
#'   nfl,
#'   themes = c("gt_theme_sdv", "gt_theme_kenpom", "gt_theme_athletic")
#' )
#'
#' @examplesIf interactive() && rlang::is_installed("webshot2") && isTRUE(file.exists(chromote::find_chrome()))
#' # a subset, saved as one wide image; saving needs a headless Chrome (webshot2)
#' \donttest{
#' nba <- subset(
#'   sdv_example_standings, league == "nba",
#'   c(team_name, wins, losses, win_pct)
#' )
#' gt_theme_preview(
#'   nba,
#'   themes = c("gt_theme_broadsheet", "gt_theme_swiss", "gt_theme_midnight"),
#'   ncol = 3, file = tempfile(fileext = ".png")
#' )
#' }
#'
#' @seealso [gt_grid()], which does the layout.
#' @import gt
#' @export
gt_theme_preview <- function(data, themes = NULL, n = 5, ncol = 3,
                             density = "compact", file = NULL, ...) {
  if (inherits(data, "gt_tbl")) data <- data[["_data"]]
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame or a {.cls gt_tbl}.")
  }
  if (!nrow(data)) cli::cli_abort("{.arg data} has no rows.")

  if (is.null(themes)) {
    cand <- sort(grep("^gt_theme_", getNamespaceExports("sdvplotR"), value = TRUE))
    # this function matches its own pattern, and calling it as a theme recurses
    cand <- setdiff(cand, "gt_theme_preview")
    # keep only things shaped like a theme: first argument is the table, and
    # nothing else is required (gt_theme_source() needs a registry name,
    # gt_theme_sdv_team() a team)
    themes <- Filter(function(nm) {
      f <- formals(get(nm, envir = asNamespace("sdvplotR")))
      required <- names(f)[-1][vapply(f[-1], identical, logical(1), quote(expr = ))]
      length(f) && names(f)[[1]] == "gt_object" && all(required == "...")
    }, cand)
  }
  missing <- themes[!vapply(themes, exists, logical(1), where = asNamespace("sdvplotR"))]
  if (length(missing)) {
    cli::cli_abort("No such theme{?s}: {.val {missing}}.")
  }

  d <- utils::head(data, n)

  panels <- lapply(themes, function(nm) {
    fn <- get(nm, envir = asNamespace("sdvplotR"))
    # only pass density to the themes that take it
    args <- list(gt::gt(d))
    if (!is.null(density) && "density" %in% names(formals(fn))) {
      args$density <- density
    }
    do.call(fn, args)
  })

  # label outside the table, so a wide display title does not stretch its panel
  gt_grid(panels,
    ncol = ncol, labels = sub("^gt_theme_", "", themes),
    file = file, ...
  )
}
