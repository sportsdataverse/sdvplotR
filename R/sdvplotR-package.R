#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom ggplot2 element_grob
#' @importFrom rlang .data
## usethis namespace: end
NULL

#' Supported Sports
#'
#' @description Returns the sport identifiers accepted by the `sport` argument
#'   of every sdvplotR function.
#'
#' @return A character vector: `"nfl"`, `"nba"`, `"wnba"`, `"mlb"`, `"nhl"`,
#'   `"cfb"` (college football), `"mbb"` (men's college basketball) and
#'   `"wbb"` (women's college basketball), and `"soccer"` (ESPN clubs, by
#'   ESPN team id).
#' @export
#' @examples
#' supported_sports()
supported_sports <- function() {
  c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer")
}
