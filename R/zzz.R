# TRUE while R CMD check --as-cran (and CRAN's own check machines) run. The
# three --as-cran variables are nfl4th's and cfb4th's detection; CRAN's regular
# check machines do not run --as-cran, so also any R CMD check (which sets
# _R_CHECK_PACKAGE_NAME_) unless NOT_CRAN is "true", as testthat::skip_on_cran()
# decides it. CI and local test runs set NOT_CRAN=true.
probably_cran <- function() {
  envvars <- c(
    "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_XTRA_"
  )
  checking <- nzchar(Sys.getenv("_R_CHECK_PACKAGE_NAME_", unset = "")) &&
    !identical(tolower(Sys.getenv("NOT_CRAN")), "true")
  any(nzchar(Sys.getenv(envvars, unset = ""))) || checking
}

.onLoad <- function(libname, pkgname) {
  # gt compiles its table CSS through 'sass', which caches the result under
  # tools::R_user_dir("sass", "cache"): during a CRAN check that is a write
  # outside the check directory ("checking for new files in some other
  # directories"). Turn the cache off there only, and never over a setting the
  # caller already made.
  if (probably_cran() && is.null(getOption("sass.cache"))) {
    options(sass.cache = FALSE)
  }
  invisible()
}
