## Release summary

This is the first CRAN submission of sdvplotR, a plotting package for sports
team logos, wordmarks, player headshots and team colors across 28 leagues
in 'ggplot2', 'gt' and 'reactable'. It is built on 'ggpath' (CRAN) and follows
the conventions of 'nflplotR' (CRAN).

## Test environments

* local: Windows 10, R 4.6.1 (`R CMD check --as-cran --run-donttest`)
* R-hub: linux (R-devel), windows (R-devel), macos (R-devel), macos-arm64
  (R-devel), atlas, nold, ubuntu-next

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

Words flagged as possibly misspelled in the DESCRIPTION (`headshots`,
`wordmarks`) are the sports-media terms for player portrait images and
text-only team logos.

## Notes for the CRAN team

* The package reads the SportsDataverse CDN at runtime for its team index
  and logo manifest, and caches them for a day. Under `R CMD check`, on CRAN
  and with `options(sdvplotR.offline = TRUE)`, it uses the copy bundled in
  the package instead and writes nothing outside `tempdir()`.
* All images are fetched at plot time from public league CDNs (ESPN,
  nflverse) through 'ggpath' and cached for the session; no image files are
  bundled. Examples that download images are wrapped in `\donttest{}` (as
  'nflplotR' and 'ggpath' do); they pass under `--as-cran`, which runs them,
  each in under 5 seconds.
* The tests need network access, headless Chrome and image rendering, so
  every test file starts with `skip_on_cran()`.
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
