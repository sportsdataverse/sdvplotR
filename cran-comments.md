## Release summary

This is the first CRAN submission of sdvplotR (version 0.3.0), a plotting
package for sports team logos, wordmarks, player headshots and team colors
across 49 leagues in 'ggplot2', 'gt' and 'reactable', and in 'plotly',
'ggiraph' and 'leaflet'. It is built on 'ggpath' (CRAN) and follows the
conventions of 'nflplotR' (CRAN). Earlier development builds, numbered 0.1.0,
were published only on r-universe.

## Test environments

* local: Windows 10 x64, R 4.6.0 (ucrt) with S7 1.0.0 and ggplot2 4.0.4,
  2026-11-24, `R CMD check --as-cran --run-donttest` on the tarball built from
  5039773b, with an empty user `.Renviron`: Status: 1 NOTE (new submission).
  The examples, `\donttest{}` included, ran in 57 seconds in total. A second
  pass, `--run-donttest --no-tests --no-manual` with the network blocked
  (proxy set to a closed port): Status: OK. Later commits change only files
  that `.Rbuildignore` leaves out of the tarball (an article, contributor
  documentation and this file).
* GitHub Actions (R-CMD-check workflow): macOS (release), Windows (release),
  Ubuntu (devel, release, oldrel-1), all passing on 2026-11-24 on the
  submission branch, with S7 1.0.0 (built from source on R-devel); also
  `Status: OK` on all five on 2026-11-20 at 141aead2, whose package sources
  are the same.
* R-hub v2 (GitHub Actions, R-devel: Linux, Windows, macOS, macOS arm64):
  2026-11-24 on a189bc06, whose tarball is the same as the submitted
  commit's: all four passing.
* win-builder (devel and release): not yet run. win-builder.r-project.org
  did not answer from 15:36 to 16:41 UTC on 2026-11-24; to be submitted
  before the CRAN upload.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The installed size is about 3.3 Mb (help 1.5 Mb, R 1.4 Mb, extdata 0.33 Mb);
the tarball is 2.1 Mb.

## Reverse dependencies

There are none: this is a new package.

## Notes for the CRAN team

* The package reads the SportsDataverse CDN at runtime for its team index
  and logo manifest, and caches them under `tools::R_user_dir()` for a day,
  keeping only the current version. Under `R CMD check`, on CRAN
  and with `options(sdvplotR.offline = TRUE)`, it uses the copy bundled in
  the package instead and writes nothing outside `tempdir()`. When the CDN
  cannot be reached it falls back to the same bundled copy.
* Team logos and player headshots are fetched at plot time from the
  SportsDataverse logo archive and the league CDNs through 'ggpath' and
  cached for the session. The images in `man/figures` are the package logo
  and the table-theme previews used in the help pages. The previews show no
  team logos or headshots; the package logo shows muted team logos behind the
  package name, as the logo of 'nflplotR' (CRAN) does. Examples that
  download images are wrapped in `\donttest{}` (as 'nflplotR' and 'ggpath'
  do); they pass under `--run-donttest` (all examples, 57 seconds locally).
  Examples that save images through a headless Chrome run only in
  interactive sessions.
* 'sportyR' (>= 2.4.5, CRAN) is in Suggests: `sdv_surface()` checks for it
  with `rlang::check_installed()` and calls only its exported functions.
* Most test files need network access, headless Chrome or image rendering,
  so they start with `skip_on_cran()`. Most tests in `test-cfbplotr-coverage.R`
  and `test-cfbplotr-parity.R` run on CRAN: they read only the bundled index
  (the ones that write images skip on CRAN).
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
