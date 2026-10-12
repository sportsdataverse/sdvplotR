# Team color functions for sdvplotR
# ============================================================================

#' Team colours
#'
#' @description Primary and secondary colours (hex) for teams, resolved from
#'   any identifier [sdv_resolve()] accepts. The R counterpart of sdvplot's
#'   `team_colors()`.
#' @inheritParams sdv_resolve
#' @param team Team identifiers, or `NULL` for every team in the league.
#' @param which `"primary"`, `"secondary"`, or `"all"` (both).
#' @param include_conferences With `team = NULL`, also list conference and
#'   league rows (see [sdv_teams()]).
#' @return With `team` given, a character vector named by `team` (`NA` where a
#'   team does not resolve); for `which = "all"`, `"primary, secondary"`
#'   strings. With `team = NULL`, a vector named by abbreviation (the
#'   `team_id` where a team has none), or for `which = "all"` a data frame:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | team_id | character | Canonical team id |
#'   | abbr | character | Abbreviation (`NA` where the league has none) |
#'   | name | character | Full name |
#'   | primary | character | Primary colour (hex) |
#'   | secondary | character | Secondary colour (hex; `NA` where none) |
#' @export
#' @examples
#' sdv_team_colors("nfl", "KC")
#' sdv_team_colors("nfl", c("KC", "Buffalo Bills"), which = "all")
#' sdv_team_colors("ahl", which = "primary")
sdv_team_colors <- function(league, team = NULL, which = c("primary", "secondary", "all"),
                            season = NULL, id_system = "auto", strict = FALSE, include_conferences = FALSE) {
  check_league(league)
  which <- rlang::arg_match(which)
  if (is.null(team)) {
    t <- sdv_teams(league, include_conferences)
    if (which == "all") {
      return(data.frame(
        team_id = t$team_id, abbr = t$abbr, name = t$name,
        primary = t$color_primary, secondary = t$color_secondary
      ))
    }
    col <- t[[paste0("color_", which)]]
    names(col) <- ifelse(is.na(t$abbr), t$team_id, t$abbr)
    return(col[!is.na(col)])
  }
  ids <- sdv_resolve(team, league, season = season, id_system = id_system, strict = strict)
  t <- sdv_teams(league)
  i <- match(ids, t$team_id)
  out <- switch(which,
    primary = t$color_primary[i],
    secondary = t$color_secondary[i],
    all = ifelse(is.na(i), NA_character_, paste(t$color_primary[i], t$color_secondary[i], sep = ", "))
  )
  stats::setNames(out, as.character(team))
}

#' Team colour palette
#'
#' @description A named colour vector for [ggplot2::scale_colour_manual()]
#'   and friends. The R counterpart of sdvplot's `palette()`.
#' @inheritParams sdv_team_colors
#' @param teams Team identifiers, or `NULL` for every team.
#' @param which `"primary"` or `"secondary"`.
#' @return A named character vector of hex colours, unresolved teams dropped.
#' @export
#' @examples
#' sdv_color_palette("nfl", c("KC", "BUF", "SF"))
sdv_color_palette <- function(league, teams = NULL, which = c("primary", "secondary"),
                              season = NULL, id_system = "auto", strict = FALSE) {
  which <- rlang::arg_match(which)
  colors <- sdv_team_colors(league, teams, which = which, season = season, id_system = id_system, strict = strict)
  colors[!is.na(colors)]
}
