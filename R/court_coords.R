#' Convert Shot Locations to a sportyR Court Frame
#'
#' @description stats.nba.com / stats.wnba.com shot-chart data reports shot
#'   locations in the NBA's legacy frame: tenths of a foot, origin at the
#'   hoop, relative to the shooter's basket. hoopR's/wehoop's
#'   `load_nba_stats_shots()` / `load_wnba_stats_shots()` ship these columns
#'   as `x_legacy`/`y_legacy` (snake_case); the `Shot_Chart_Detail` element of
#'   hoopR's `nba_shotchartdetail()` uses the same frame, in the
#'   `LOC_X`/`LOC_Y` columns stats.nba.com returns (upper snake case). This
#'   converts them (feet, not tenths) into the frame
#'   `sportyR::geom_basketball("nba")` draws: origin at center court, baseline
#'   at `x = -47`, basket on the **left** at `x = -41.75`.
#'
#'   `provider = "euroleague"` converts the Euroleague shot frame of hoopR's
#'   `euroleague_game_points()` (`coord_x`/`coord_y`) instead, onto the FIBA
#'   court `sdv_surface("fiba")` draws, in meters.
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
#'   The Euroleague frame (`provider = "euroleague"`; measured on real games,
#'   2026-10-06) is integer centimeters with the hoop at the origin, both
#'   teams mapped onto one basket, `coord_y` growing away from the baseline
#'   toward the court, and free throws encoded as `coord_x = coord_y = -1`
#'   (a sentinel, not a location), which become `NA`. The FIBA court is
#'   28 x 15 m with its basket 1.575 m from the baseline, so
#'   `court_x = -12.425 + coord_y / 100` and `court_y = coord_x / 100`. Which
#'   sideline is positive `coord_x` is unverified, so a chart may be
#'   left-right mirrored; the court is symmetric, so distances and zones are
#'   unaffected.
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
#'   `x_legacy` value (tenths of a foot), or Euroleague `coord_x` (centimeters).
#'   Default `"x_legacy"`.
#' @param y_column String naming the column holding the stats-API `LOC_Y` /
#'   `y_legacy` value (tenths of a foot), or Euroleague `coord_y` (centimeters).
#'   Default `"y_legacy"`.
#' @param provider The frame of `data`, which sets the output's units:
#'   `"nba"` (the default; stats.nba.com / stats.wnba.com, tenths of a foot in,
#'   **feet** out on the NBA/WNBA/NCAA court) or `"euroleague"` (hoopR's
#'   `euroleague_game_points()` `coord_x`/`coord_y`, centimeters in,
#'   **meters** out on the FIBA court). Case is ignored.
#'
#' @return `data` with `court_x` and `court_y` added (existing columns of
#'   those names are replaced); every other input column is kept as-is:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | court_x | numeric | Along the court: the basket at -41.75 ft (nba) or -12.425 m (euroleague), half court at 0 |
#'   | court_y | numeric | Across the court: -25 to 25 ft (nba; negative = shooter's left) or -7.5 to 7.5 m (euroleague) |
#'
#' @examples
#' shots <- data.frame(x_legacy = c(-224, 240), y_legacy = c(39, 29))
#' sdv_court_coords(shots)
#'
#' # Euroleague shots (hoopR::euroleague_game_points() columns) onto the FIBA court
#' euro <- data.frame(coord_x = c(0, 12, 650, -1), coord_y = c(0, 422, 50, -1))
#' sdv_court_coords(euro, "coord_x", "coord_y", provider = "euroleague")
#' \donttest{
#' if (requireNamespace("sportyR", quietly = TRUE)) {
#'   library(ggplot2)
#'   euro <- sdv_court_coords(euro, "coord_x", "coord_y", provider = "euroleague")
#'   sdv_surface("fiba", display_range = "defense") +
#'     geom_point(aes(court_x, court_y), data = euro, colour = "red", size = 3, na.rm = TRUE)
#' }
#' }
#'
#' @export
sdv_court_coords <- function(data, x_column = "x_legacy", y_column = "y_legacy", provider = "nba") {
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
  frame <- court_provider(provider)
  # `==`, not identical(): identical() also compares names, so c(x = "LOC_X")
  # and c(y = "LOC_X") would slip through.
  if (x_column == y_column) {
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
  if (!is.null(frame$sentinel)) {
    none <- !is.na(x_vals) & !is.na(y_vals) & x_vals == frame$sentinel[[1]] & y_vals == frame$sentinel[[2]]
    x_vals[none] <- NA_real_
    y_vals[none] <- NA_real_
  }

  # Divide, don't multiply by 0.1: -224 / 10 is -22.4, -224 * 0.1 is not.
  data$court_x <- frame$basket_x + y_vals / frame$per_unit
  data$court_y <- x_vals / frame$per_unit
  data
}

# One row per shot frame: `per_unit` input units per output unit, `basket_x`
# the basket's position on the sportyR court the output lands on (center-court
# origin), `sentinel` the provider's "no location" pair, if any.
court_providers <- list(
  nba = list(per_unit = 10, basket_x = -47 + 5.25, sentinel = NULL),
  euroleague = list(per_unit = 100, basket_x = -12.425, sentinel = c(-1, -1)) # 28 m court, basket 1.575 m in
)

court_provider <- function(provider, call = rlang::caller_env()) {
  valid <- names(court_providers)
  if (!is.character(provider) || length(provider) != 1L || is.na(provider) || !tolower(provider) %in% valid) {
    cli::cli_abort(c(
      "{.arg provider} must be one of {.val {valid}}.",
      "x" = "Got {.val {provider}}."
    ), call = call)
  }
  court_providers[[tolower(provider)]]
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
