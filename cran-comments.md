## Release summary

This is the first CRAN submission of sdvplotR (version 0.3.0), a plotting
package for sports team logos, wordmarks, player headshots and team colors
across 49 leagues in 'ggplot2', 'gt' and 'reactable', and in 'plotly',
'ggiraph' and 'leaflet'. It is built on 'ggpath' (CRAN) and follows the
conventions of 'nflplotR' (CRAN). Earlier development builds, numbered 0.1.0,
were published only on r-universe.

## Test environments

* local: Windows 10 x64, R 4.6.0 (ucrt), `R CMD check --as-cran --run-donttest`
  on the tarball built from the submitted commit, with an empty user
  `.Renviron`: Status: 1 NOTE. The examples, `\donttest{}` included, ran in
  45 seconds in total. A second pass, `--run-donttest --no-tests --no-manual`
  with the network blocked (proxy set to a closed port): Status: OK.
* R-hub v2 (GitHub Actions, R-devel), 2026-11-06, on an earlier commit
  (6ef2e240): Linux, Windows, macOS and macOS arm64, all passing.
* GitHub Actions (R-CMD-check workflow): macOS (release), Windows (release),
  Ubuntu (devel, release, oldrel-1), passing on 2026-11-09 at d23e64ee, the
  commit before the submitted one's last data and documentation changes.
* win-builder (devel and release): to be run before submission.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The installed size is about 3.4 Mb (help 1.6 Mb, R 1.4 Mb, extdata 0.35 Mb);
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
  do); they pass under `--run-donttest` (all examples, 45 seconds locally).
  Examples that save images through a headless Chrome run only in
  interactive sessions.
* 'sportyR' (>= 2.4.5, CRAN) is in Suggests: `sdv_surface()` checks for it
  with `rlang::check_installed()` and calls only its exported functions.
* Most test files need network access, headless Chrome or image rendering,
  so they start with `skip_on_cran()`. `test-cfbplotr-coverage.R` and
  `test-cfbplotr-parity.R` run on CRAN: they read only the bundled index.
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
