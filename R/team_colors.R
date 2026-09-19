# Team color functions for sdvplotR
# ============================================================================

#' Get Team Colors
#'
#' @description Returns the primary and secondary colors (hex codes) for a given team.
#'
#' @param sport Character string identifying the sport.
#' @param team Character string or vector of team name(s) or abbreviation(s).
#'   If `NULL`, returns colors for all teams.
#' @param type Character string, `"primary"`, `"secondary"`, or `"all"`.
#'
#' @return With `team` supplied, a named character vector (one element per
#'   team, `NA` for unmatched teams): the primary or secondary hex code, or for
#'   `type = "all"` the two codes as one `"primary, secondary"` string. With
#'   `team = NULL` and `type = "all"`, a data frame with columns:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | team_abbr | character | Canonical team abbreviation |
#'   | team_name | character | Full team name |
#'   | primary | character | Primary team color (hex) |
#'   | secondary | character | Secondary team color (hex) |
#'
#'   With `team = NULL` and any other `type`, a named character vector of
#'   every team's color.
#' @export
#' @examples
#' # Get primary color for Kansas City Chiefs
#' sdv_team_colors("nfl", "KC")
#'
#' # Get both colors for multiple teams
#' sdv_team_colors("nfl", c("KC", "BUF"), type = "all")
#'
#' # Get all NFL team primary colors
#' sdv_team_colors("nfl", type = "primary")
sdv_team_colors <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    team = NULL,
    type = c("primary", "secondary", "all")
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary", "all"))

  team_ref <- get_team_ref(sport)

  if (is.null(team)) {
    # Return all teams' colors
    if (type == "all") {
      return(
        dplyr::select(
          team_ref,
          "team_abbr",
          "team_name",
          primary = "color1",
          secondary = "color2"
        )
      )
    } else if (type == "primary") {
      colors <- team_ref$color1
      names(colors) <- team_ref$team_abbr
      return(colors[!is.na(colors)])
    } else {
      colors <- team_ref$color2
      names(colors) <- team_ref$team_abbr
      return(colors[!is.na(colors)])
    }
  }

  # Resolve team names/abbreviations to colors
  team_clean <- clean_team_abbrs(as.character(team), sport = sport, keep_non_matches = FALSE)

  result <- character(length(team))
  names(result) <- team

  for (i in seq_along(team)) {
    match_idx <- match(team_clean[i], team_ref$team_abbr)

    if (!is.na(match_idx)) {
      if (type == "primary") {
        result[i] <- team_ref$color1[match_idx]
      } else if (type == "secondary") {
        result[i] <- team_ref$color2[match_idx]
      } else {
        result[i] <- paste(
          team_ref$color1[match_idx],
          team_ref$color2[match_idx],
          sep = ", "
        )
      }
    } else {
      result[i] <- NA_character_
    }
  }

  result
}

#' Get Team Color Palette
#'
#' @description Returns a color palette for a given sport, suitable for use with
#'   ggplot2 `scale_fill_manual` or `scale_color_manual`.
#'
#' @param sport Character string identifying the sport.
#' @param teams Character vector of team names or abbreviations. If `NULL`,
#'   returns all teams.
#' @param type Character string, `"primary"` or `"secondary"`.
#'
#' @return Named character vector of colors.
#' @export
#' @examples
#' sdv_color_palette("nfl", c("KC", "BUF", "SF"))
sdv_color_palette <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    teams = NULL,
    type = c("primary", "secondary")
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("primary", "secondary"))

  if (is.null(teams)) {
    teams <- valid_team_names(sport)
  }

  colors <- sdv_team_colors(sport, teams, type = type)
  colors[!is.na(colors)]
}
