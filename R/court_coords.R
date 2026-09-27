#' Convert stats.nba.com/stats.wnba.com Shot Locations to a sportyR Court Frame
#'
#' @description stats.nba.com / stats.wnba.com shot-chart data reports shot
#'   locations in the NBA's legacy frame: tenths of a foot, origin at the
#'   hoop, relative to the shooter's basket. hoopR's/wehoop's
#'   `load_nba_stats_shots()` / `load_wnba_stats_shots()` ship these columns
#'   as `x_legacy`/`y_legacy` (snake_case); the `Shot_Chart_Detail` element of
#'   hoopR's `nba_shotchartdetail()` ships the same values as the
#'   `LOC_X`/`LOC_Y` columns stats.nba.com returns (upper snake case). This
#'   converts them (feet, not tenths) into the frame
#'   `sportyR::geom_basketball("nba")` draws: origin at center court, baseline
#'   at `x = -47`, basket on the **left** at `x = -41.75`.
#'
#' @details The NBA legacy shot-location frame (`LOC_X`/`LOC_Y`, or
#'   `x_legacy`/`y_legacy`; tenths of a foot, hoop at the origin, relative to
#'   the shooter's basket) maps with negative x as the shooter's left corner:
#'   `court_y` is `x_column / 10` with no sign flip, so a left-corner three
#'   lands at negative `court_y` (the TV-bottom sideline), which is the
#'   shooter's left when facing the TV-left basket. Verified on real 2022-23
#'   `shotchartdetail` data (Left Corner 3 `LOC_X` -249..-221, Right Corner 3
#'   +221..+248).
#'
#'   Shots land on sportyR's TV-left half, so draw half-court charts with
#'   `sportyR::geom_basketball("nba", display_range = "defense")` or the full
#'   court; `display_range = "offense"` shows the TV-right half and none of
#'   the shots.
#'
#'   The converted points also fit sportyR's `"wnba"` and `"ncaa"` courts,
#'   which share the `"nba"` court's 94-foot floor and 5.25-foot basket
#'   offset. The input must still be in the NBA legacy frame (tenths of a
#'   foot, hoop at the origin: `x_legacy`/`y_legacy` or `LOC_X`/`LOC_Y`).
#'   Don't pass ESPN `coordinate_x`/`coordinate_y` from hoopR/wehoop
#'   play-by-play: they are already in feet on a center-court frame.
#'
#'   Coordinate columns must be numeric, or character holding numbers, which
#'   is coerced (`nba_shotchartdetail()` returns every column as character).
#'   Factors, `TRUE`/`FALSE` and strings that aren't numbers (such as `""` or
#'   `"NA"`) raise an error. Missing values stay `NA`, and an all-`NA` column
#'   (even a logical one) gives `NA` coordinates.
#'
#' @param data A data frame with shot-location columns, e.g. from
#'   `hoopR::load_nba_stats_shots()` / `wehoop::load_wnba_stats_shots()`
#'   (`x_legacy`/`y_legacy`). `hoopR::nba_shotchartdetail()` returns a named
#'   list: pass its `Shot_Chart_Detail` data frame and name the `LOC_X`/`LOC_Y`
#'   columns, e.g. `sdv_court_coords(res$Shot_Chart_Detail, "LOC_X", "LOC_Y")`.
#' @param x_column String naming the column holding the stats-API `LOC_X` /
#'   `x_legacy` value (tenths of a foot). Default `"x_legacy"`.
#' @param y_column String naming the column holding the stats-API `LOC_Y` /
#'   `y_legacy` value (tenths of a foot). Default `"y_legacy"`.
#'
#' @return `data` with `court_x` and `court_y` added (existing columns of
#'   those names are replaced); every other input column is kept as-is:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | court_x | numeric | Feet along the court's length: baseline at -47, basket at -41.75, half-court line at 0 |
#'   | court_y | numeric | Feet across the court's width: -25 to 25; negative = shooter's left (TV-bottom sideline) |
#'
#' @examples
#' shots <- data.frame(x_legacy = c(-224, 240), y_legacy = c(39, 29))
#' sdv_court_coords(shots)
#'
#' @export
sdv_court_coords <- function(data, x_column = "x_legacy", y_column = "y_legacy") {
  # A named list passes the column checks below and would come back as a
  # list, not a data frame.
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame.",
      "i" = "Got a {.cls {class(data)}}."
    ))
  }
  check_column_arg(x_column, "x_column")
  check_column_arg(y_column, "y_column")
  if (identical(x_column, y_column)) {
    cli::cli_abort("{.arg x_column} and {.arg y_column} must name different columns, not both {.val {x_column}}.")
  }

  missing_cols <- setdiff(c(x_column, y_column), names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "{.arg data} is missing column{?s} {.val {missing_cols}}.",
      "i" = "Pass the stats-API column names via {.arg x_column}/{.arg y_column} (e.g. {.val LOC_X}/{.val LOC_Y})."
    ))
  }

  x_vals <- coerce_shot_coord(data[[x_column]], x_column)
  y_vals <- coerce_shot_coord(data[[y_column]], y_column)

  data$court_x <- -47 + 5.25 + y_vals / 10
  data$court_y <- x_vals / 10
  data
}

# ---------------------------------------------------------------------------
# Input validation helpers
# ---------------------------------------------------------------------------

# `x_column`/`y_column` must each name exactly one column: a NULL, a
# length != 1 vector or an NA would silently drop the argument in the
# setdiff() missing-column check above instead of raising a clear error.
check_column_arg <- function(value, arg_name, call = rlang::caller_env()) {
  if (!is.character(value) || length(value) != 1 || is.na(value)) {
    cli::cli_abort(c(
      "{.arg {arg_name}} must be a single string.",
      "i" = "Got a {.cls {class(value)}} of length {length(value)}."
    ), call = call)
  }
}

# hoopR's `nba_shotchartdetail()` returns every column as character; coerce
# and reject anything that doesn't round-trip cleanly. Factors are rejected
# rather than coerced: as.numeric(factor) returns the level codes, not the
# labels' values, which would silently corrupt the coordinates.
coerce_shot_coord <- function(values, column_name, call = rlang::caller_env()) {
  if (is.numeric(values)) {
    return(as.numeric(values))
  }
  # An all-NA column is logical (`data.frame(x = NA)`, or readr reading an
  # all-empty column): treat it as missing coordinates. TRUE/FALSE still errors.
  if (is.logical(values) && all(is.na(values))) {
    return(as.numeric(values))
  }
  if (is.character(values)) {
    coerced <- suppressWarnings(as.numeric(values))
    bad <- is.na(coerced) & !is.na(values)
    if (any(bad)) {
      cli::cli_abort(c(
        "Column {.val {column_name}} has value{?s} that can't be coerced to numeric: {.val {unique(values[bad])}}.",
        "i" = "Pass the correct column name via {.arg x_column}/{.arg y_column}, or fix the input data."
      ), call = call)
    }
    return(coerced)
  }
  cli::cli_abort(c(
    "Column {.val {column_name}} must be numeric or character, not {.cls {class(values)}}.",
    "i" = "Pass the correct column name via {.arg x_column}/{.arg y_column}, or fix the input data."
  ), call = call)
}
