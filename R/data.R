#' Background colors used by the `gt_theme_*()` table themes
#'
#' A lookup of the background color each `gt_theme_*` function sets, used to match
#' a saved image's canvas to the table sitting on it. [gt_save_crop()] and
#' [gt_social_crop()] pad the image using their own `bg` argument, and a mismatch
#' shows up as a border around the table.
#'
#' @format A tibble with one row per theme, and one per style for the themes
#'   that take a `style` argument:
#' \describe{
#'   \item{theme}{The theme function name.}
#'   \item{has_style}{The `style` value the row applies to (`"light"` or
#'     `"dark"`) for [gt_theme_sofa()] and [gt_theme_tier()], or `""` for themes
#'     without one.}
#'   \item{bg}{The background color the theme applies, as a hex code.}
#' }
#'
#' @source Read back from each theme's `table.background.color` by
#'   `data-raw/theme_bg.R`. [gt_theme_drench()] takes its background from its
#'   `color` argument and [gt_theme_broadsheet()] from its `paper` argument;
#'   their rows hold the default.
#'
#' @examples
#' \dontrun{
#' # look up the background a theme uses, then match the canvas to it
#' bg <- theme_bg$bg[theme_bg$theme == "gt_theme_gtutils"]
#'
#' gt::gt(head(mtcars)) %>%
#'   gt_theme_gtutils() %>%
#'   gt_save_crop("table.png", bg = bg)
#' }
#'
#' @seealso [gt_save_crop()], [gt_social_crop()].
"theme_bg"
