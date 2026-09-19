#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom ggplot2 element_grob
#' @importFrom rlang .data
## usethis namespace: end
NULL

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL

#' Supported Sports
#'
#' @description Returns the sport identifiers accepted by the `sport` argument
#'   of every sdvplotR function.
#'
#' @return A character vector: `"nfl"`, `"nba"`, `"wnba"`, `"mlb"`, `"nhl"`,
#'   `"cfb"` (college football), `"mbb"` (men's college basketball) and
#'   `"wbb"` (women's college basketball).
#' @export
#' @examples
#' supported_sports()
supported_sports <- function() {
  c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
}
