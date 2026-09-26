test_that("sdv_court_coords converts stats-API shot locations to the sportyR nba frame", {
  df <- data.frame(
    loc_x = c(0, -220, 220, 0),
    loc_y = c(0, 0, 0, 237.5)
  )
  out <- sdv_court_coords(df)

  expect_equal(out$court_x, c(-41.75, -41.75, -41.75, -18.0), tolerance = 0.1)
  expect_equal(out$court_y, c(0, -22, 22, 0), tolerance = 0.1)
})

test_that("sdv_court_coords honors custom x/y column names", {
  df <- data.frame(LOC_X = -220, LOC_Y = 0)
  out <- sdv_court_coords(df, x = "LOC_X", y = "LOC_Y")

  expect_equal(out$court_x, -41.75, tolerance = 0.1)
  expect_equal(out$court_y, -22, tolerance = 0.1)
})

test_that("sdv_court_coords errors informatively on missing columns", {
  expect_error(sdv_court_coords(data.frame(loc_x = 0)), "loc_y")
  expect_error(sdv_court_coords(data.frame(a = 1)), "loc_x")
})
