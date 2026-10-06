test_that("sdv_court_coords converts stats-API shot locations to the sportyR nba frame", {
  df <- data.frame(
    x_legacy = c(0, -220, 220, 0),
    y_legacy = c(0, 0, 0, 237.5)
  )
  out <- sdv_court_coords(df)

  expect_equal(out$court_x, c(-41.75, -41.75, -41.75, -18.0))
  expect_equal(out$court_y, c(0, -22, 22, 0))
})

test_that("sdv_court_coords honors custom x_column/y_column names", {
  df <- data.frame(LOC_X = -220, LOC_Y = 0)
  out <- sdv_court_coords(df, x_column = "LOC_X", y_column = "LOC_Y")

  expect_equal(out$court_x, -41.75)
  expect_equal(out$court_y, -22)
})

test_that("sdv_court_coords errors informatively on missing columns", {
  expect_error(sdv_court_coords(data.frame(x_legacy = 0)), "missing column.*y_legacy")
  expect_error(sdv_court_coords(data.frame(a = 1)), "missing column.*x_legacy")
})

test_that("sdv_court_coords rejects input that isn't a data frame", {
  expect_error(sdv_court_coords(list(x_legacy = 1, y_legacy = 2)), "must be a data frame")
  expect_error(sdv_court_coords(matrix(1:4, ncol = 2)), "must be a data frame")
})

test_that("sdv_court_coords validates x_column/y_column are single strings", {
  df <- data.frame(x_legacy = 0, y_legacy = 0)
  expect_error(sdv_court_coords(df, x_column = NULL), "single string")
  expect_error(sdv_court_coords(df, x_column = c("x_legacy", "y_legacy")), "single string")
})

test_that("sdv_court_coords rejects the same column for both axes", {
  df <- data.frame(LOC_X = -224, LOC_Y = 39)
  expect_error(
    sdv_court_coords(df, x_column = "LOC_X", y_column = "LOC_X"),
    "must name different columns"
  )
  expect_error(
    sdv_court_coords(df, x_column = c(x = "LOC_X"), y_column = c(y = "LOC_X")),
    "must name different columns"
  )
})

test_that("sdv_court_coords coerces character columns", {
  df <- data.frame(x_legacy = c("-224", "240"), y_legacy = c("39", "29"))
  out <- sdv_court_coords(df)

  expect_equal(out$court_y, c(-22.4, 24.0))
})

test_that("sdv_court_coords errors on non-coercible or factor columns", {
  bad_chr <- data.frame(x_legacy = c("abc", "240"), y_legacy = c("39", "29"))
  expect_error(sdv_court_coords(bad_chr), "coerced to numeric")

  bad_factor <- data.frame(x_legacy = factor(c("-224", "240")), y_legacy = c(39, 29))
  expect_error(sdv_court_coords(bad_factor), "numeric or character")
})

test_that("sdv_court_coords propagates NA", {
  df <- data.frame(x_legacy = c(-224, NA), y_legacy = c(39, NA))
  out <- sdv_court_coords(df)

  expect_equal(out$court_y, c(-22.4, NA))
  expect_true(is.na(out$court_x[2]))
})

test_that("sdv_court_coords treats all-NA logical columns as missing coordinates", {
  df <- data.frame(x_legacy = c(NA, NA), y_legacy = c(NA, NA))
  out <- sdv_court_coords(df)
  expect_type(out$court_x, "double")
  expect_type(out$court_y, "double")
  expect_true(all(is.na(out$court_x)) && all(is.na(out$court_y)))

  bad_lgl <- data.frame(x_legacy = c(TRUE, FALSE), y_legacy = c(39, 29))
  expect_error(sdv_court_coords(bad_lgl), "numeric or character")
})

test_that("sdv_court_coords replaces existing court_x/court_y and keeps every other column", {
  df <- data.frame(court_x = "old", x_legacy = -224, y_legacy = 39, player = "p", court_y = "old")
  out <- sdv_court_coords(df)

  expect_named(out, names(df))
  expect_equal(out$court_x, -37.85)
  expect_equal(out$court_y, -22.4)
  expect_equal(out[c("x_legacy", "y_legacy", "player")], df[c("x_legacy", "y_legacy", "player")])
})

test_that("sdv_court_coords preserves the tibble class", {
  df <- data.frame(x_legacy = -224, y_legacy = 39)
  class(df) <- c("tbl_df", "tbl", "data.frame")

  out <- sdv_court_coords(df)
  expect_s3_class(out, c("tbl_df", "tbl", "data.frame"))
})

test_that("sdv_court_coords pins the sign convention to real stats.nba.com rows", {
  # game 0022300001 (sdv-py fixture
  # tests/fixtures/nba_engine/0022300001/cdn_playbyplay.json): action 71 =
  # "Left Corner 3" (xLegacy -224, yLegacy 39), action 131 = "Right Corner 3"
  # (xLegacy 240, yLegacy 29).
  left_corner_3 <- data.frame(x_legacy = -224, y_legacy = 39)
  right_corner_3 <- data.frame(x_legacy = 240, y_legacy = 29)

  out_left <- sdv_court_coords(left_corner_3)
  expect_equal(out_left$court_y, -22.4)
  expect_equal(out_left$court_x, -37.85)

  out_right <- sdv_court_coords(right_corner_3)
  expect_equal(out_right$court_y, 24.0)
  expect_equal(out_right$court_x, -38.85)
})

test_that("sdv_court_coords provider = 'euroleague' lands shots on the FIBA court in meters", {
  # hoop, free-throw line (FIBA: 5.8 m from the baseline = 4.225 m from the basket), top of the arc (6.75 m),
  # a shot to the x < 0 side, and a free throw's -1,-1 sentinel
  euro <- data.frame(coord_x = c(0, 0, 0, -650, -1), coord_y = c(0, 422.5, 675, 50, -1))
  out <- sdv_court_coords(euro, "coord_x", "coord_y", provider = "euroleague")

  expect_equal(out$court_x, c(-12.425, -8.2, -5.675, -11.925, NA))
  expect_equal(out$court_y, c(0, 0, 0, -6.5, NA))
  expect_equal(out$court_x[1], -14 + 1.575) # sportyR's FIBA basket
  expect_equal(out$court_x[2], -14 + 5.8) # sportyR's FIBA free-throw line (lane_length)
  expect_equal(out$court_x[3], -12.425 + 6.75) # the FIBA three-point arc
  expect_named(out, c("coord_x", "coord_y", "court_x", "court_y"))
  expect_equal(out$coord_x[5], -1) # the input columns are not touched
})

test_that("sdv_court_coords only treats the full -1,-1 pair as the Euroleague sentinel", {
  euro <- data.frame(coord_x = c(-1, 5, NA), coord_y = c(5, -1, -1))
  out <- sdv_court_coords(euro, "coord_x", "coord_y", "euroleague")
  expect_equal(out$court_y, c(-0.01, 0.05, NA))
  expect_equal(out$court_x, c(-12.375, -12.435, -12.435))

  # the nba frame has no sentinel: (-1, -1) is a real location
  nba <- sdv_court_coords(data.frame(x_legacy = -1, y_legacy = -1))
  expect_equal(nba$court_y, -0.1)
})

test_that("sdv_court_coords provider is case-insensitive and rejects unknown frames", {
  df <- data.frame(coord_x = 0, coord_y = 0)
  expect_equal(sdv_court_coords(df, "coord_x", "coord_y", "EuroLeague")$court_x, -12.425)
  expect_equal(sdv_court_coords(df, "coord_x", "coord_y", "NBA")$court_x, -41.75)
  expect_error(sdv_court_coords(df, "coord_x", "coord_y", "fiba"), "must be one of.*nba.*euroleague")
  expect_error(sdv_court_coords(df, "coord_x", "coord_y", NULL), "must be one of")
  expect_error(sdv_court_coords(df, "coord_x", "coord_y", c("nba", "euroleague")), "must be one of")
})

test_that("sdv_court_coords's default provider is the nba frame, unchanged", {
  df <- data.frame(x_legacy = c(-224, 240, NA), y_legacy = c(39, 29, NA))
  expect_identical(sdv_court_coords(df), sdv_court_coords(df, provider = "nba"))
  expect_identical(sdv_court_coords(df)$court_x, c(-37.85, -38.85, NA))
})
