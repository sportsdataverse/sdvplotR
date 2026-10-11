# TRUE while R CMD check --as-cran (and CRAN's own check machines) run. Same
# detection as nfl4th and cfb4th.
probably_cran <- function() {
  envvars <- c(
    "_R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_",
    "_R_CHECK_THINGS_IN_OTHER_DIRS_XTRA_"
  )
  any(nzchar(Sys.getenv(envvars, unset = "")))
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
