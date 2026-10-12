## Release summary

This is the first CRAN submission of sdvplotR, a plotting package for sports
team logos, wordmarks, player headshots and team colors across 28 leagues
in 'ggplot2', 'gt' and 'reactable'. It is built on 'ggpath' (CRAN) and follows
the conventions of 'nflplotR' (CRAN).

## Test environments

Local results (recorded 2026-10-12):

* local: Windows 10, R 4.6.1 (`R CMD check --as-cran --run-donttest` on the
  built tarball, 3.5 MB)

PENDING (run after the SportsDataverse CDN index is published, so the checks
exercise the live path):

* R-hub: linux, windows, macos, macos-arm64, atlas, clang-asan, gcc15, nold,
  ubuntu-next
* win-builder: release and devel

## R CMD check results

Local, Windows 10, R 4.6.1: 0 errors | 0 warnings | 2 notes

* This is a new submission.
* The Windows-only `'NULL'` directory note described below.

R-hub and win-builder: PENDING.

`urlchecker::url_check()` is clean. Words flagged as possibly misspelled in
the DESCRIPTION (`headshots`, `wordmarks`) are the sports-media terms for
player portrait images and text-only team logos.

On Windows with R 4.6.1 the local check additionally reports

    checking for non-standard things in the check directory ... NOTE
    Found the following files/directories: ''NULL''

This is not produced by package code: `R CMD check` runs examples and tests
with `R_LIBS_USER='NULL'` (`tools:::setRlibs`), and R 4.6.1 on Windows creates
the `R_LIBS_USER` directory at startup, so an empty directory literally named
`'NULL'` appears in the check directory. It reproduces with any package, e.g.
`R_LIBS_USER="'NULL'" Rscript --vanilla -e 1` in an empty directory, and does
not occur on Linux, macOS, or R 4.6.0 and earlier.

## Notes for the CRAN team

* The package reads the SportsDataverse CDN at runtime for its team index
  and logo manifest, and caches them for a day. Under `R CMD check`, on CRAN
  and with `options(sdvplotR.offline = TRUE)`, it uses the copy bundled in
  the package instead and writes nothing outside `tempdir()`.
* All images are fetched at plot time from public league CDNs (ESPN,
  nflverse) through 'ggpath' and cached for the session; no image files are
  bundled. Examples that download images are wrapped in `\donttest{}` (as
  'nflplotR' and 'ggpath' do); they pass under `--as-cran`, which runs them,
  each in under 5 seconds. Without network, the read of the NFL headshot
  map warns and returns no rows instead of erroring.
* The tests need network access, headless Chrome and image rendering, so
  every test file starts with `skip_on_cran()`. They run on every platform
  listed above.
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The slowest example, `sdv_surface()` (about 4 seconds), spends that time
  in 'sportyR' building the court geometry.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
