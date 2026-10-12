# Points the data layer at the committed two-league fixture index (file://),
# with a private cache dir and the CRAN-check variables cleared, so the live
# path runs under R CMD check too.
# Verified on Windows R 4.6.1: download.file() reads "file:///C:/..." as built here
# (normalizePath(winslash = "/"), leading slash stripped, then "file:///" added); no adjustment needed.
local_fixture_index <- function(env = parent.frame(), ttl = 86400) {
  fx <- normalizePath(testthat::test_path("fixtures"), winslash = "/")
  withr::local_options(
    sdvplotR.index_url = paste0("file:///", sub("^/", "", fx), "/index"),
    sdvplotR.manifest_url = paste0("file:///", sub("^/", "", fx), "/marks.csv"),
    sdvplotR.offline = FALSE, sdvplotR.index_ttl = ttl, .local_envir = env
  )
  withr::local_envvar(
    R_USER_CACHE_DIR = withr::local_tempdir(.local_envir = env),
    "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_" = "",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_" = "",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_XTRA_" = "",
    .local_envir = env
  )
  forget_index()
  withr::defer(forget_index(), envir = env)
  invisible(fx)
}

# The snapshot only, quietly: what the parity and plotting tests run against.
local_snapshot_index <- function(env = parent.frame()) {
  withr::local_options(sdvplotR.offline = TRUE, .local_envir = env)
  forget_index()
  withr::defer(forget_index(), envir = env)
}
