#' Convert stats.nba.com/stats.wnba.com Shot Locations to a sportyR Court Frame
#'
#' @description stats.nba.com and stats.wnba.com shot-chart endpoints
#'   (`LOC_X`/`LOC_Y`, e.g. hoopR's `nba_shotchartdetail()` /
#'   `load_nba_stats_shots()`) report shot locations in tenths of a foot,
#'   origin at the hoop, with `LOC_Y` increasing away from the hoop toward
#'   half-court. This rescales them (feet, not tenths) into the frame
#'   `sportyR::geom_basketball("nba")` draws: origin at center court, baseline
#'   at `x = -47`, basket on the **left** at `x = -41.75`.
#'
#' @details Sign-convention note: the NBA's `SHOT_ZONE_AREA` labels ("Left
#'   Side(L)", "Right Side(R)", ...) are named from the shooter's perspective
#'   facing the basket, and the well-established convention across published
#'   NBA shot-chart code (plotting `LOC_X` directly on a standard left-to-right
#'   axis) is that `SHOT_ZONE_AREA == "Left Side(L)"` carries **negative**
#'   `LOC_X`. `court_y` is therefore `loc_x / 10` with no sign flip, so a
#'   left-side corner three (`LOC_X = -220`) lands at `court_y = -22`, on the
#'   same (negative) side as sportyR's left-side markings. This session could
#'   not confirm that against a live release capture (`hoopR::load_nba_stats_shots()`
#'   requires the `hoopR` package, which is not installed in this environment) —
#'   re-verify against a real capture before relying on this for a recipe, and
#'   flip the `court_y` sign here (and in `tests/testthat/test-court_coords.R`)
#'   if a live check disagrees.
#'
#' @param df A data frame with shot-location columns, e.g. from
#'   `hoopR::nba_shotchartdetail()` / `load_nba_stats_shots()`. Column names
#'   may arrive upper camel (`LOC_X`) or snake_case (`loc_x`) depending on the
#'   source; pass the actual names via `x`/`y` if they differ from the default.
#' @param x Column holding the stats-API `LOC_X` (tenths of a foot). Default `"loc_x"`.
#' @param y Column holding the stats-API `LOC_Y` (tenths of a foot). Default `"loc_y"`.
#'
#' @return `df` with two additional numeric columns, `court_x` and `court_y`
#'   (feet, sportyR `geom_basketball("nba")` frame).
#'
#' @examples
#' \dontrun{
#' shots <- hoopR::load_nba_stats_shots(seasons = 2025)
#' shots <- sdv_court_coords(shots, x = "loc_x", y = "loc_y")
#' }
#'
#' @export
sdv_court_coords <- function(df, x = "loc_x", y = "loc_y") {
  missing_cols <- setdiff(c(x, y), names(df))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "{.arg df} is missing column{?s} {.val {missing_cols}}.",
      "i" = "Pass the actual stats-API column names via {.arg x}/{.arg y} (e.g. {.val LOC_X}/{.val LOC_Y})."
    ))
  }
  df$court_x <- -47 + 5.25 + df[[y]] / 10
  df$court_y <- df[[x]] / 10
  df
}
