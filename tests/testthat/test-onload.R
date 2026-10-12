skip_on_cran()

no_check_env <- c(
  "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = NA,
  "_R_CHECK_THINGS_IN_OTHER_DIRS_" = NA,
  "_R_CHECK_THINGS_IN_OTHER_DIRS_XTRA_" = NA,
  "_R_CHECK_PACKAGE_NAME_" = NA
)

test_that("any R CMD check counts as CRAN unless NOT_CRAN is true", {
  # CRAN's regular check machines do not run --as-cran, so none of its variables is set there
  withr::local_envvar(c(no_check_env, "_R_CHECK_PACKAGE_NAME_" = "sdvplotR", NOT_CRAN = NA))
  expect_true(probably_cran())
  withr::local_envvar(NOT_CRAN = "true")
  expect_false(probably_cran())
  withr::local_envvar(c(no_check_env, NOT_CRAN = NA))
  expect_false(probably_cran())
})

test_that("under a CRAN check, loading turns off the sass cache", {
  withr::local_envvar(c(no_check_env, "_R_CHECK_THINGS_IN_OTHER_DIRS_" = "true"))
  withr::local_options(sass.cache = NULL)
  .onLoad(NULL, "sdvplotR")
  expect_false(getOption("sass.cache"))
})

test_that("a sass.cache setting the caller made is kept", {
  withr::local_envvar(c(no_check_env, "_R_CHECK_THINGS_IN_OTHER_DIRS_" = "true"))
  withr::local_options(sass.cache = TRUE)
  .onLoad(NULL, "sdvplotR")
  expect_true(getOption("sass.cache"))
})

test_that("outside a check, loading leaves the sass cache alone", {
  withr::local_envvar(no_check_env)
  withr::local_options(sass.cache = NULL)
  .onLoad(NULL, "sdvplotR")
  expect_null(getOption("sass.cache"))
})
