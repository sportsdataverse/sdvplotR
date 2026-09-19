# Team tier plots for sdvplotR
# ============================================================================

#' Create Team Tier Plots
#'
#' @description This function sets up a ggplot to visualize team tiers across
#'   any sport supported by sdvplotR. Teams are organized by performance or
#'   other metrics into labeled tiers.
#'
#' @param data A data frame that must include the variables `tier_no` (the
#'   number of the tier starting from the top tier no. 1) and `team` (the
#'   team abbreviation). `team` should be one of [valid_team_names()].
#'   If data includes the variable `tier_rank`, these ranks will be used within
#'   each tier. Otherwise, if `presort = FALSE`, the function will assume that
#'   data is already sorted and if `presort = TRUE`, teams will be sorted
#'   alphabetically within tiers.
#' @param sport Character string identifying the sport.
#' @param title The title of the plot. If `NULL`, it will be omitted.
#' @param subtitle The subtitle of the plot. If `NULL`, it will be omitted.
#' @param caption The caption of the plot. If `NULL`, it will be omitted.
#' @param tier_desc A named vector of tier descriptions. Names must equal the
#'   tier numbers from `tier_no`.
#' @param presort If `FALSE` (the default) the function assumes that the teams
#'   are already sorted within the tiers. Will otherwise sort alphabetically.
#' @param alpha The alpha channel of the logos (transparency level).
#' @param width The desired width of the logo in `npc`.
#' @param no_line_below_tier Vector of tier numbers. The function won't draw
#'   tier separation lines below these tiers.
#' @param devel Determines if logos shall be rendered. If `FALSE` (the default),
#'   logos will be rendered on each run. If `TRUE` the team abbreviations will
#'   be plotted instead of the logos. This is much faster and helps with plot
#'   development.
#'
#' @return A ggplot object.
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' team_abbr <- valid_team_names("nfl")
#' team_abbr <- sample(team_abbr)
#'
#' # Build the team tiers data
#' df <- data.frame(
#'   tier_no = sample(1:5, length(team_abbr), replace = TRUE),
#'   team = team_abbr
#' )
#'
#' # Plot team tiers
#' sdv_team_tiers(df, sport = "nfl")
#' }
sdv_team_tiers <- function(
    data,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    title = glue::glue("{toupper(sport)} Team Tiers"),
    subtitle = glue::glue("created with the #sdvplotR Tiermaker"),
    caption = NULL,
    tier_desc = c(
      "1" = "Elite",
      "2" = "Very Good",
      "3" = "Medium",
      "4" = "Bad",
      "5" = "What are they doing?",
      "6" = "",
      "7" = ""
    ),
    presort = FALSE,
    alpha = 0.8,
    width = 0.075,
    no_line_below_tier = NULL,
    devel = FALSE
) {
  sport <- rlang::arg_match0(sport, supported_sports())

  required_vars <- c("tier_no", "team")

  if (!all(required_vars %in% names(data))) {
    cli::cli_abort(
      "The data frame {.var data} has to include the variables {.var {required_vars}}!"
    )
  }

  bg <- "#1e1e1e"
  lines <- "#e0e0e0"

  tiers <- sort(unique(data$tier_no))
  tierlines <- tiers[!tiers %in% no_line_below_tier] + 0.5
  tierlines <- c(min(tiers) - 0.5, tierlines)

  if (isTRUE(presort)) {
    data <- data |>
      dplyr::arrange(.data$tier_no, .data$team) |>
      dplyr::group_by(.data$tier_no) |>
      dplyr::mutate(tier_rank = dplyr::row_number()) |>
      dplyr::ungroup()
  }

  if (!"tier_rank" %in% names(data)) {
    data <- data |>
      dplyr::group_by(.data$tier_no) |>
      dplyr::mutate(tier_rank = dplyr::row_number()) |>
      dplyr::ungroup()
  }

  data$team <- clean_team_abbrs(
    as.character(data$team),
    sport = sport,
    keep_non_matches = FALSE
  )

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(y = .data$tier_no, x = .data$tier_rank)
  ) +
    ggplot2::geom_hline(yintercept = tierlines, color = lines)

  if (isFALSE(devel)) {
    p <- p +
      geom_sdv_logos(
        ggplot2::aes(team = .data$team),
        sport = sport,
        width = width,
        alpha = alpha
      )
  }

  if (isTRUE(devel)) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = .data$team), color = "white")
  }

  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(add = 0.1),
      limits = rev(c(min(tiers) - 0.5, max(tiers) + 0.5)),
      breaks = rev(tiers),
      labels = function(x) {
        vapply(tier_desc[x], function(s) paste(strwrap(s, 15), collapse = "\n"), "")
      },
      transform = "reverse"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::theme_minimal(base_size = 11.5) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(color = "white", face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "#8e8e93"),
      plot.caption = ggplot2::element_text(color = "#8e8e93", hjust = 1),
      plot.title.position = "plot",
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(
        color = "white",
        face = "bold",
        size = ggplot2::rel(1.1)
      ),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.background = ggplot2::element_rect(fill = bg, color = bg),
      panel.background = ggplot2::element_rect(fill = bg, color = bg)
    )

  p
}


# ---------------------------------------------------------------------------
# Team factor helper
# ---------------------------------------------------------------------------

#' Order Team Names as a Factor
#'
#' @description Creates a factor of cleaned, valid team names. Levels are
#'   restricted to teams present in [valid_team_names()] so that downstream
#'   ggplot2 scales drop invalid entries gracefully.
#'
#' @param teams Character vector of team names.
#' @param sport Character string identifying the sport.
#' @return An ordered `factor` of the cleaned, valid team names.
#' @export
#' @examples
#' sdv_team_factor(c("KC", "BUF", "invalid"), sport = "nfl")
sdv_team_factor <- function(teams, sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")) {
  sport <- rlang::arg_match0(sport, supported_sports())

  teams <- clean_team_abbrs(as.character(teams), sport = sport)
  valid <- valid_team_names(sport)

  factor(teams, levels = sort(unique(teams[teams %in% valid])))
}
