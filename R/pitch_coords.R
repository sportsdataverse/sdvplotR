#' Convert Soccer Event Coordinates to the sdvplotR Pitch Frame
#'
#' @description Every soccer data provider uses its own coordinate frame. Opta
#'   and Wyscout run 0-100 on both axes and are not to scale, StatsBomb uses
#'   120 x 80, tracking providers use meters or centimeters from the center
#'   spot, and ESPN reports the distance from the attacked goal as a fraction
#'   of half the pitch. `sdv_pitch_coords()` converts any of them to one frame:
#'   meters, origin at the center spot, a regulation 105 x 68 m pitch,
#'   attacking toward `+x`, with `+y` on the attacker's left. That is the pitch
#'   [sdv_surface()] draws for `"soccer"`.
#'
#' @details The conversion is piecewise-linear between pitch landmarks: goal
#'   line, six-yard line, penalty spot, box edge and halfway line along the
#'   pitch; touchline, box side, six-yard side and post across it. A shot on
#'   the edge of an Opta box therefore lands on the edge of the regulation box,
#'   not 1.35 m outside it as a linear rescale would put it. Points beyond the
#'   outermost landmark are extrapolated from the nearest segment, not clamped.
#'   The landmark values come from 'mplsoccer' and ship in
#'   `system.file("extdata", "pitch_landmarks.csv", package = "sdvplotR")`.
#'
#'   Tracking providers (`"tracab"`, `"skillcorner"`, `"secondspectrum"`,
#'   `"metrica"`) are measured on the venue's real pitch, so they need
#'   `pitch_length` and `pitch_width`. ESPN frames are derived from the Opta frame:
#'   `opta_x = 100 - 50 * x` and `opta_y = 100 * (1 - y)`. ESPN marks an event
#'   with no location as `(0, 0)`, which becomes `NA`.
#'
#'   Event providers record every action as if the team attacked left to
#'   right. To draw two teams (or two halves of tracking data) attacking
#'   opposite ends, `flip` them: a flipped row is turned half a turn, so its
#'   `x` and `y` both change sign and each wing stays on its own side.
#'
#' @param data A data frame of events.
#' @param provider The coordinate frame of `data`: `"opta"` (alias
#'   `"statsperform"`), `"wyscout"`, `"statsbomb"`, `"uefa"`, `"impect"`,
#'   `"espn"`, `"tracab"`, `"skillcorner"`, `"secondspectrum"` or `"metrica"`.
#'   Case is ignored.
#' @param x_column,y_column Strings naming the coordinate columns. `NULL` (the
#'   default) uses the provider's usual names: `"field_position_x"` and
#'   `"field_position_y"` for ESPN (the output of
#'   Python `espn_soccer_game_plays()`), `"x"` and `"y"` otherwise.
#' @param flip `NULL` (no row flipped), `TRUE`/`FALSE` for every row, or a
#'   string naming a logical column with no missing values; `TRUE` rows are
#'   turned half a turn.
#' @param pitch_length,pitch_width The venue's size in meters, for tracking
#'   providers only (the Laws of the Game allow 90-120 by 45-90).
#'
#' @return `data` with `pitch_x` and `pitch_y` added (existing columns of those
#'   names are replaced); every other input column is kept as-is:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | pitch_x | numeric | Meters along the pitch: -52.5 is the defended goal line, 52.5 the attacked one, 0 the halfway line |
#'   | pitch_y | numeric | Meters across the pitch: -34 to 34; positive = the attacker's left |
#'
#' @seealso [sdv_surface()] draws the pitch; [ggsoccer::rescale_coordinates()]
#'   converts between provider frames without the regulation-pitch output.
#' @examples
#' shots <- data.frame(x = c(88.5, 83, 50), y = c(50, 21.1, 100))
#' sdv_pitch_coords(shots, "opta")
#'
#' # two teams attacking opposite ends
#' shots$away <- c(FALSE, TRUE, FALSE)
#' sdv_pitch_coords(shots, "opta", flip = "away")
#'
#' # tracking data, measured on the venue's pitch
#' tracking <- data.frame(x = c(-4150, 3600), y = c(0, -2016))
#' sdv_pitch_coords(tracking, "tracab", pitch_length = 105, pitch_width = 68)
#' @export
sdv_pitch_coords <- function(data, provider, x_column = NULL, y_column = NULL, flip = NULL,
                             pitch_length = NULL, pitch_width = NULL) {
  if (!is.data.frame(data)) {
    cli::cli_abort(c(
      "{.arg data} must be a data frame.",
      "i" = "Got a {.cls {class(data)}}."
    ))
  }
  provider <- pitch_provider(provider)
  dims <- pitch_dims(provider, pitch_length, pitch_width)
  espn <- provider == "espn"
  x_column <- x_column %||% if (espn) "field_position_x" else "x"
  y_column <- y_column %||% if (espn) "field_position_y" else "y"
  check_column_arg(x_column, "x_column")
  check_column_arg(y_column, "y_column")
  if (x_column == y_column) {
    cli::cli_abort("{.arg x_column} and {.arg y_column} must name different columns, not both {.val {x_column}}.")
  }
  missing_cols <- setdiff(c(x_column, y_column), names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "{.arg data} is missing column{?s} {.val {missing_cols}}.",
      "i" = "Name the coordinate columns via {.arg x_column}/{.arg y_column}."
    ))
  }
  xs <- coerce_shot_coord(data[[x_column]], x_column)
  ys <- coerce_shot_coord(data[[y_column]], y_column)
  rotate <- pitch_flip(flip, data)

  if (espn) {
    none <- !is.na(xs) & !is.na(ys) & xs == 0 & ys == 0 # ESPN's "no location"
    xs <- 100 - 50 * xs
    ys <- 100 * (1 - ys)
    xs[none] <- NA_real_
    ys[none] <- NA_real_
    provider <- "opta"
  }
  marks <- if (provider %in% pitch_physical_providers) {
    physical_landmarks(provider, dims[["length"]], dims[["width"]])
  } else {
    pitch_landmarks(provider)
  }
  target <- pitch_landmarks("impect")
  px <- interp_landmarks(xs, marks$x, target$x)
  py <- interp_landmarks(ys, marks$y, target$y)
  px[rotate] <- -px[rotate]
  py[rotate] <- -py[rotate]
  data$pitch_x <- px
  data$pitch_y <- py
  data
}

# ---------------------------------------------------------------------------
# Argument helpers
# ---------------------------------------------------------------------------

pitch_provider <- function(provider, call = rlang::caller_env()) {
  valid <- c(pitch_fixed_providers, "espn", pitch_physical_providers, names(pitch_provider_aliases))
  if (!is.character(provider) || length(provider) != 1L || is.na(provider) || !tolower(provider) %in% valid) {
    cli::cli_abort(c(
      "{.arg provider} must be one of {.val {valid}}.",
      "x" = "Got {.val {provider}}."
    ), call = call)
  }
  provider <- tolower(provider)
  if (provider %in% names(pitch_provider_aliases)) pitch_provider_aliases[[provider]] else provider
}

pitch_dims <- function(provider, pitch_length, pitch_width, call = rlang::caller_env()) {
  if (!provider %in% pitch_physical_providers) {
    if (!is.null(pitch_length) || !is.null(pitch_width)) {
      cli::cli_abort(c(
        "{.arg pitch_length} and {.arg pitch_width} only apply to tracking providers ({.val {pitch_physical_providers}}).",
        "i" = "{.val {provider}} has a fixed frame."
      ), call = call)
    }
    return(NULL)
  }
  if (is.null(pitch_length) || is.null(pitch_width)) {
    cli::cli_abort(c(
      "{.val {provider}} needs {.arg pitch_length} and {.arg pitch_width}: the venue's size in meters.",
      "i" = "A regulation international pitch is 105 x 68."
    ), call = call)
  }
  check_pitch_size(pitch_length, "pitch_length", 90, 120, call)
  check_pitch_size(pitch_width, "pitch_width", 45, 90, call)
  c(length = pitch_length, width = pitch_width)
}

check_pitch_size <- function(value, arg, lo, hi, call) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) || value < lo || value > hi) {
    cli::cli_abort(
      "{.arg {arg}} must be one number of meters from {lo} to {hi} (the Laws of the Game), not {.val {value}}.",
      call = call
    )
  }
}

pitch_flip <- function(flip, data, call = rlang::caller_env()) {
  n <- nrow(data)
  if (is.null(flip)) {
    return(rep(FALSE, n))
  }
  if (is.logical(flip) && length(flip) == 1L && !is.na(flip)) {
    return(rep(flip, n))
  }
  if (is.character(flip) && length(flip) == 1L && !is.na(flip)) {
    if (!flip %in% names(data)) {
      cli::cli_abort("{.arg flip} names column {.val {flip}}, which {.arg data} does not have.", call = call)
    }
    values <- data[[flip]]
    if (!is.logical(values) || anyNA(values)) {
      cli::cli_abort(
        "Column {.val {flip}} must be TRUE/FALSE with no missing values: it says which rows attack the other way.",
        call = call
      )
    }
    return(values)
  }
  cli::cli_abort("{.arg flip} must be NULL, TRUE/FALSE, or the name of a logical column.", call = call)
}

# ---------------------------------------------------------------------------
# Landmark frames
# ---------------------------------------------------------------------------

pitch_fixed_providers <- c("opta", "wyscout", "statsbomb", "uefa", "impect")
pitch_physical_providers <- c("tracab", "skillcorner", "secondspectrum", "metrica")
pitch_provider_aliases <- c(statsperform = "opta")

# The landmarks of a fixed-frame provider, from the shared table: x from the
# defended goal line to the attacked one, y from the attacker's right touchline
# to the left one (so a top-origin provider's y values descend).
pitch_landmarks <- function(provider) {
  path <- system.file("extdata", "pitch_landmarks.csv", package = "sdvplotR", mustWork = TRUE)
  tab <- utils::read.csv(path, comment.char = "#")
  rows <- tab[tab$provider == provider, ]
  axis <- function(a) {
    r <- rows[rows$axis == a, ]
    r$value[order(r$i)]
  }
  list(x = axis("x"), y = axis("y"))
}

# Tracking providers draw the venue's real pitch, so their landmarks come from
# the Laws of the Game's fixed distances (six-yard line 5.5 m, penalty spot
# 11 m, box 16.5 m deep; goal 7.32 m, six-yard box 18.32 m and box 40.32 m
# wide) placed on a `length` x `width` meter pitch, in the provider's units.
physical_landmarks <- function(provider, length, width) {
  along <- c(0, 5.5, 11, 16.5, length / 2, length - 16.5, length - 11, length - 5.5, length)
  half <- width / 2
  across <- c(0, half - 20.16, half - 9.16, half - 3.66, half + 3.66, half + 9.16, half + 20.16, width)
  switch(provider,
    tracab = list(x = (along - length / 2) * 100, y = (across - half) * 100),
    skillcorner = ,
    secondspectrum = list(x = along - length / 2, y = across - half),
    metrica = list(x = along / length, y = 1 - across / width)
  )
}

# Piecewise-linear from `from` to `to`, extending the end segments beyond both
# ends (stats::approx() would give NA or clamp). sdvplot's _interp() uses the
# same index and the same arithmetic, so the two packages agree to the last bit.
interp_landmarks <- function(v, from, to) {
  o <- order(from)
  from <- from[o]
  to <- to[o]
  j <- pmin(pmax(findInterval(v, from), 1L), length(from) - 1L)
  to[j] + (to[j + 1L] - to[j]) * ((v - from[j]) / (from[j + 1L] - from[j]))
}
