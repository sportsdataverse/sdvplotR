# Team tier plots for sdvplotR
# ============================================================================

#' Create Team Tier Plots
#'
#' @description This function sets up a ggplot to visualize team tiers across
#'   any league supported by sdvplotR. Teams are organized by performance or
#'   other metrics into labeled tiers.
#'
#' @param data A data frame that must include the variables `tier_no` (the
#'   number of the tier starting from the top tier no. 1) and `team` (the
#'   team: anything [sdv_resolve()] accepts).
#'   If data includes the variable `tier_rank`, these ranks will be used within
#'   each tier. Otherwise, if `presort = FALSE`, the function will assume that
#'   data is already sorted and if `presort = TRUE`, teams will be sorted
#'   alphabetically within tiers.
#' @param league A league key from [sdv_leagues()].
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
#' @param theme `"dark"` (the default: a near-black background with white
#'   labels) or `"light"` (a white background with dark labels and lines).
#' @param variant The logo variant to draw. `"auto"` (the default, as sdvplot's
#'   `team_tiers()`) draws each team's dark-background mark (`"dark"`) on the
#'   dark theme and its default mark on the light theme, so dark logos such as
#'   the Capitals' or Penn State's don't fade into the dark background. Any
#'   other value is `"default"`, `"dark"` or a named variant from [sdv_marks()]
#'   (see [sdv_logo_url()]), drawn on either theme. A team without the variant
#'   draws its closest mark, with no warning.
#'
#' @return A ggplot object.
#' @export
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' # Build the team tiers data
#' df <- data.frame(
#'   tier_no = c(1, 1, 2, 2, 3, 3),
#'   team = c("KC", "DET", "BAL", "PHI", "BUF", "GB")
#' )
#'
#' # Plot team tiers, each team's primary logo on white
#' sdv_team_tiers(df, league = "nfl", theme = "light")
#' }
sdv_team_tiers <- function(
    data,
    league,
    title = glue::glue("{toupper(league)} Team Tiers"),
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
    devel = FALSE,
    theme = c("dark", "light"),
    variant = "auto"
) {
  league <- check_league(league)
  theme <- rlang::arg_match(theme)
  if (identical(variant, "auto")) variant <- if (theme == "dark") "dark" else "default"
  check_mark_variant(variant, league)

  required_vars <- c("tier_no", "team")

  if (!all(required_vars %in% names(data))) {
    cli::cli_abort(
      "The data frame {.var data} has to include the variables {.var {required_vars}}!"
    )
  }

  # background, tier lines, title and labels, subtitle and caption; the light
  # colors are sdvplot's (Python), each well past 4.5:1 on white
  look <- switch(theme,
    dark = c(bg = "#1e1e1e", lines = "#e0e0e0", text = "white", muted = "#8e8e93"),
    light = c(bg = "#ffffff", lines = "#3a3a3c", text = "#1e1e1e", muted = "#636366")
  )
  bg <- look[["bg"]]
  lines <- look[["lines"]]

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

  # a team without the variant falls back to its closest mark
  data$path <- logo_from_team(data$team, league, variant = variant)

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(y = .data$tier_no, x = .data$tier_rank)
  ) +
    ggplot2::geom_hline(yintercept = tierlines, color = lines)

  if (isFALSE(devel)) {
    p <- p +
      ggpath::geom_from_path(
        ggplot2::aes(path = .data$path),
        width = width,
        alpha = alpha
      )
  }

  if (isTRUE(devel)) {
    p <- p +
      ggplot2::geom_text(ggplot2::aes(label = .data$team), color = look[["text"]])
  }

  p <- p +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(add = 0.1),
      limits = rev(c(min(tiers) - 0.5, max(tiers) + 0.5)),
      breaks = rev(tiers),
      labels = function(x) {
        vapply(tier_desc[as.character(x)], function(s) paste(strwrap(s, 15), collapse = "\n"), "")
      },
      transform = "reverse"
    ) +
    ggplot2::labs(title = title, subtitle = subtitle, caption = caption) +
    ggplot2::theme_minimal(base_size = 11.5) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(color = look[["text"]], face = "bold"),
      plot.subtitle = ggplot2::element_text(color = look[["muted"]]),
      plot.caption = ggplot2::element_text(color = look[["muted"]], hjust = 1),
      plot.title.position = "plot",
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(
        color = look[["text"]],
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
#' @description Creates a factor of team names whose levels are the values
#'   that resolve to a team of `league` (see [sdv_resolve()]), so downstream
#'   ggplot2 scales drop invalid entries gracefully.
#'
#' @param teams Character vector of team names.
#' @param league A league key from [sdv_leagues()].
#' @return A `factor` of `teams`, levels limited to the values that resolve.
#' @export
#' @examples
#' sdv_team_factor(c("KC", "BUF", "invalid"), league = "nfl")
sdv_team_factor <- function(teams, league) {
  league <- check_league(league)

  ids <- resolve_ids(teams, league)$ids
  factor(teams, levels = sort(unique(as.character(teams)[!is.na(ids)])))
}
