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
  expect_error(sdv_court_coords(data.frame(x_legacy = 0)), "y_legacy")
  expect_error(sdv_court_coords(data.frame(a = 1)), "x_legacy")
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
