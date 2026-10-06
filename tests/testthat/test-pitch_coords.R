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
