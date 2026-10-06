test_that("the landmark table is the shared, hash-pinned copy", {
  skip_if(utils::packageVersion("cli") < "3.6.0") # cli::hash_file_sha256() arrived in 3.6.0
  path <- system.file("extdata", "pitch_landmarks.csv", package = "sdvplotR")
  expect_identical(
    unname(cli::hash_file_sha256(path)),
    "5e6b0b1181b80a338775ac6b3c9318c8154452f018b2e85ec3a7c5440723ed3d"
  )
})

test_that("each fixed provider has 9 ascending x and 8 y landmarks", {
  for (p in c("opta", "wyscout", "statsbomb", "uefa", "impect")) {
    m <- pitch_landmarks(p)
    expect_length(m$x, 9)
    expect_length(m$y, 8)
    expect_true(all(diff(m$x) > 0), info = p)
  }
  expect_identical(pitch_landmarks("impect")$x, c(-52.5, -47, -41.5, -36, 0, 36, 41.5, 47, 52.5))
  expect_identical(pitch_landmarks("statsbomb")$y, c(80, 62, 50, 44, 36, 30, 18, 0))
})

test_that("physical landmarks at 105 x 68 reproduce mplsoccer's, and keep regulation boxes on other venues", {
  t <- physical_landmarks("tracab", 105, 68)
  expect_equal(t$x, c(-5250, -4700, -4150, -3600, 0, 3600, 4150, 4700, 5250))
  expect_equal(t$y, c(-3400, -2016, -916, -366, 366, 916, 2016, 3400))
  s <- physical_landmarks("skillcorner", 105, 68)
  expect_equal(s$x, pitch_landmarks("impect")$x)
  expect_equal(s$y, pitch_landmarks("impect")$y)
  expect_identical(physical_landmarks("secondspectrum", 105, 68), s)
  m <- physical_landmarks("metrica", 105, 68)
  expect_equal(m$x, c(0, 5.5, 11, 16.5, 52.5, 88.5, 94, 99.5, 105) / 105)
  expect_equal(m$y[c(1, 8)], c(1, 0)) # Metrica's y = 0 is the top touchline: the attacker's left
  w <- physical_landmarks("tracab", 100, 64)
  expect_equal(w$x[c(1, 4, 5)], c(-5000, -3350, 0))
  expect_equal(w$y[c(1, 2)], c(-3200, -2016)) # the box is 40.32 m wide on any pitch
})

test_that("interp_landmarks hits landmarks, interpolates, and extrapolates beyond both ends", {
  from <- c(0, 10, 20)
  to <- c(-1, 0, 4)
  expect_equal(interp_landmarks(c(0, 5, 10, 15, 20), from, to), c(-1, -0.5, 0, 2, 4))
  expect_equal(interp_landmarks(c(-10, 30), from, to), c(-2, 8)) # end-segment slopes 0.1 and 0.4: never clamped
  expect_equal(interp_landmarks(c(NA, 5), from, to), c(NA, -0.5))
  expect_equal(interp_landmarks(numeric(0), from, to), numeric(0))
  expect_equal(interp_landmarks(c(0, 20), c(20, 10, 0), to), c(4, -1)) # landmarks given in descending order
})

test_that("Opta landmarks land on the regulation landmarks", {
  shots <- data.frame(x = c(88.5, 83, 50, 100, 0), y = c(50, 21.1, 100, 45.2, 0))
  out <- sdv_pitch_coords(shots, "opta")
  expect_equal(out$pitch_x, c(41.5, 36, 0, 52.5, -52.5))
  expect_equal(out$pitch_y, c(0, -20.16, 34, -3.66, -34))
  expect_named(out, c("x", "y", "pitch_x", "pitch_y"))
})

test_that("StatsBomb's top-origin y puts y = 0 on the attacker's left", {
  out <- sdv_pitch_coords(data.frame(x = c(108, 120, 60), y = c(40, 0, 80)), "statsbomb")
  expect_equal(out$pitch_x, c(41.5, 52.5, 0))
  expect_equal(out$pitch_y, c(0, 34, -34))
})

test_that("aliases, case and custom column names resolve", {
  shots <- data.frame(x = c(88.5, 17), y = c(50, 78.9))
  expect_identical(sdv_pitch_coords(shots, "statsperform"), sdv_pitch_coords(shots, "opta"))
  expect_identical(sdv_pitch_coords(shots, "Opta"), sdv_pitch_coords(shots, "opta"))
  named <- sdv_pitch_coords(data.frame(px = 88.5, py = 50), "opta", x_column = "px", y_column = "py")
  expect_equal(c(named$pitch_x, named$pitch_y), c(41.5, 0))
  replaced <- sdv_pitch_coords(data.frame(x = 88.5, y = 50, pitch_x = "old"), "opta")
  expect_identical(replaced$pitch_x, 41.5)
})

test_that("flip turns rows half a turn: x and y both change sign", {
  d <- data.frame(x = c(88.5, 88.5), y = c(21.1, 21.1), away = c(FALSE, TRUE))
  out <- sdv_pitch_coords(d, "opta", flip = "away")
  expect_equal(out$pitch_x, c(41.5, -41.5))
  expect_equal(out$pitch_y, c(-20.16, 20.16))
  expect_equal(sdv_pitch_coords(d, "opta", flip = TRUE)$pitch_x, c(-41.5, -41.5))
  expect_equal(sdv_pitch_coords(d, "opta", flip = FALSE)$pitch_x, c(41.5, 41.5))
  expect_error(sdv_pitch_coords(d, "opta", flip = "nope"), "does not have")
  expect_error(sdv_pitch_coords(transform(d, away = c(TRUE, NA)), "opta", flip = "away"), "no missing values")
  expect_error(sdv_pitch_coords(transform(d, away = c(1, 0)), "opta", flip = "away"), "TRUE/FALSE")
  expect_error(sdv_pitch_coords(d, "opta", flip = c(TRUE, FALSE)), "must be NULL")
})

test_that("sdv_pitch_coords validates its arguments", {
  d <- data.frame(x = 1, y = 2)
  expect_error(sdv_pitch_coords(list(x = 1, y = 2), "opta"), "must be a data frame")
  expect_error(sdv_pitch_coords(d, "optaa"), "must be one of")
  expect_error(sdv_pitch_coords(d, c("opta", "wyscout")), "must be one of")
  expect_error(sdv_pitch_coords(d, "opta", pitch_length = 105), "only apply to tracking providers")
  expect_error(sdv_pitch_coords(d, "tracab"), "needs .*pitch_length")
  expect_error(sdv_pitch_coords(d, "tracab", pitch_length = 80, pitch_width = 68), "from 90 to 120")
  expect_error(sdv_pitch_coords(d, "tracab", pitch_length = 105, pitch_width = "68"), "from 45 to 90")
  expect_error(sdv_pitch_coords(d, "opta", x_column = "y"), "must name different columns")
  expect_error(sdv_pitch_coords(data.frame(x = 1), "opta"), "missing column.*y")
  expect_error(sdv_pitch_coords(data.frame(x = "a", y = 2), "opta"), "can't be coerced")
  expect_error(sdv_pitch_coords(data.frame(x = factor(1), y = 2), "opta"), "must be numeric or character")
})

test_that("empty frames, missing values, integers and number strings behave like sdv_court_coords", {
  empty <- sdv_pitch_coords(data.frame(x = numeric(0), y = numeric(0)), "opta")
  expect_identical(nrow(empty), 0L)
  expect_type(empty$pitch_x, "double")
  expect_type(empty$pitch_y, "double")
  na <- sdv_pitch_coords(data.frame(x = c(NA, 88.5), y = c(50, NA)), "opta")
  expect_equal(na$pitch_x, c(NA, 41.5))
  expect_equal(na$pitch_y, c(0, NA))
  ints <- sdv_pitch_coords(data.frame(x = c(100L, 50L), y = c(0L, 100L)), "opta")
  expect_equal(ints$pitch_x, c(52.5, 0))
  expect_equal(ints$pitch_y, c(-34, 34))
  strs <- sdv_pitch_coords(data.frame(x = c("88.5", "50"), y = c("50", "100")), "opta")
  expect_equal(strs$pitch_x, c(41.5, 0))
  off <- sdv_pitch_coords(data.frame(x = -0.5, y = 101), "opta") # off the pitch: extrapolated, not clamped
  expect_lt(off$pitch_x, -52.5)
  expect_gt(off$pitch_y, 34)
})

test_that("fixed providers agree with ggsoccer::rescale_coordinates()", {
  skip_if_not_installed("ggsoccer")
  dims <- list(
    opta = ggsoccer::pitch_opta, wyscout = ggsoccer::pitch_wyscout,
    statsbomb = ggsoccer::pitch_statsbomb, uefa = ggsoccer::pitch_international
  )
  # impect is left out on purpose. ggsoccer 0.2.0's pitch_impect declares a centered origin (origin_x = -52.5,
  # origin_y = -34) but rescale_coordinates() ignores it: it maps impect x = -52.5 to -105 and y = -34 to -68, a
  # whole pitch off. Impect is already our target frame, so the correct result is the identity; that is asserted
  # directly below.
  top_origin <- c("wyscout", "statsbomb") # ggsoccer keeps their y = 0 at the bottom; we put it on the attacker's left
  for (p in names(dims)) {
    marks <- pitch_landmarks(p)
    mid <- function(v) (utils::head(v, -1) + utils::tail(v, -1)) / 2
    xs <- sort(unique(c(marks$x, mid(sort(marks$x)))))
    ys <- sort(unique(c(marks$y, mid(sort(marks$y)))))
    # ggsoccer puts Opta's posts at 44.2 / 55.8, mplsoccer (our table) at 45.2 / 54.8: skip the strip between them
    if (p == "opta") ys <- ys[ys <= 36.8 | ys >= 63.2]
    grid <- expand.grid(x = xs, y = ys)
    ours <- sdv_pitch_coords(grid, p)
    f <- ggsoccer::rescale_coordinates(from = dims[[p]], to = ggsoccer::pitch_international)
    gy <- f$y(grid$y)
    expect_equal(ours$pitch_x, f$x(grid$x) - 52.5, tolerance = 1e-9, info = p)
    expect_equal(ours$pitch_y, if (p %in% top_origin) 34 - gy else gy - 34, tolerance = 1e-9, info = p)
  }
  marks <- pitch_landmarks("impect")
  centered <- expand.grid(x = marks$x, y = marks$y)
  same <- sdv_pitch_coords(centered, "impect")
  expect_equal(same$pitch_x, centered$x)
  expect_equal(same$pitch_y, centered$y)
})

espn_events <- function() {
  utils::read.csv(test_path("fixtures", "espn_soccer_events.csv"),
    colClasses = c(event_id = "character", play_id = "character"), na.strings = ""
  )
}

test_that("ESPN: every penalty lands on the spot (real events)", {
  out <- sdv_pitch_coords(espn_events(), "espn")
  pens <- out[startsWith(out$type, "Penalty"), ]
  expect_gte(nrow(pens), 10)
  expect_true(all(abs(pens$pitch_x - 41.5) < 0.5))
  expect_true(all(abs(pens$pitch_y) < 1))
})

test_that("ESPN: the commentary's side of the box matches the sign of pitch_y (real events)", {
  out <- sdv_pitch_coords(espn_events(), "espn")
  sided <- out[!is.na(out$side), ]
  expect_gte(nrow(sided), 20)
  expect_true(all((sided$side == "left") == (sided$pitch_y > 0)))
})

test_that("ESPN: (0, 0) is no location, but one zero axis is a real location", {
  d <- data.frame(field_position_x = c(0, 0, 0.23), field_position_y = c(0, 0.4, 0.5))
  out <- sdv_pitch_coords(d, "espn")
  expect_identical(c(out$pitch_x[1], out$pitch_y[1]), c(NA_real_, NA_real_))
  expect_equal(out$pitch_x[2], 52.5) # on the attacked goal line
  expect_gt(out$pitch_y[2], 0) # y = 0.4 is the shooter's left
  expect_equal(c(out$pitch_x[3], out$pitch_y[3]), c(41.5, 0))
  expect_true(all(is.na(sdv_pitch_coords(espn_events(), "espn")$pitch_x[
    espn_events()$field_position_x == 0 & espn_events()$field_position_y == 0
  ])))
})

test_that("tracking providers convert from the venue's real size", {
  d <- data.frame(x = c(4150, 0, -5250, 5400), y = c(0, 3400, -2016, 0))
  out <- sdv_pitch_coords(d, "tracab", pitch_length = 105, pitch_width = 68)
  expect_equal(out$pitch_x, c(41.5, 0, -52.5, 54)) # 5400 cm: past the goal line, extrapolated
  expect_equal(out$pitch_y, c(0, 34, -20.16, 0))
  m <- sdv_pitch_coords(data.frame(x = 0.5, y = 0), "metrica", pitch_length = 105, pitch_width = 68)
  expect_equal(c(m$pitch_x, m$pitch_y), c(0, 34)) # Metrica's y = 0 is the top: the attacker's left
  v <- sdv_pitch_coords(data.frame(x = 39, y = 0), "skillcorner", pitch_length = 100, pitch_width = 64)
  expect_equal(v$pitch_x, 41.5) # 11 m from a 100 m pitch's goal line is still the penalty spot
  metres <- transform(d, x = x / 100, y = y / 100) # Second Spectrum and SkillCorner share one frame
  expect_identical(
    sdv_pitch_coords(metres, "secondspectrum", pitch_length = 105, pitch_width = 68)[c("pitch_x", "pitch_y")],
    sdv_pitch_coords(metres, "skillcorner", pitch_length = 105, pitch_width = 68)[c("pitch_x", "pitch_y")]
  )
})
