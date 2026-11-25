## Release summary

This is the first CRAN submission of sdvplotR (version 0.3.0), a plotting
package for sports team logos, wordmarks, player headshots and team colors
across 70 leagues in 'ggplot2', 'gt' and 'reactable', and in 'plotly',
'ggiraph' and 'leaflet'. It is built on 'ggpath' (CRAN) and follows the
conventions of 'nflplotR' (CRAN). Earlier development builds, numbered 0.1.0,
were published only on r-universe.

## Test environments

* local: Windows 10 x64, R 4.6.0 (ucrt) with ggplot2 4.0.3, S7 0.2.2 and
  sportyR 2.4.5, 2026-11-25, `R CMD check --as-cran --run-donttest` on the
  tarball built from commit c2611a0d, with an empty user `.Renviron`:
  Status: 1 NOTE (new submission). The examples, `\donttest{}` included, ran in 57 seconds.
  The full test suite with `NOT_CRAN=true` passed too (2,799 expectations, 0
  failures).
* GitHub Actions (R-CMD-check workflow), commit c2611a0d: ubuntu-latest and
  macos-latest, R release: Status: OK.
* R-hub v2 (GitHub Actions, R-devel), commit c2611a0d: linux, windows and
  macos-arm64 passed. The macos (x86_64) job had not finished after an hour
  on 2026-11-25; it is to be re-run before the CRAN upload.
* win-builder (devel and release): not yet run. win-builder.r-project.org
  could not be reached on 2026-11-24 or 2026-11-25 (the last try was at
  22:47 UTC on 2026-11-25). It is to be run before the CRAN upload.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The incoming check can also report three README URLs as "Forbidden" (HTTP
403): <https://sportsdataverse.r-universe.dev/sdvplotR>,
<https://www.npmjs.com/package/@sportsdataverse/sdvplot> and
<https://www.npmjs.com/package/@sportsdataverse/sdvtables>. These sites
answer 403 to automated clients. All three open in a web browser.

The installed size is about 3.5 Mb (help 1.6 Mb, R 1.5 Mb, extdata 0.35 Mb).
The tarball is 2.2 Mb.

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
  and `test-cfbplotr-parity.R` run on CRAN and read only the bundled index;
  the few that write images, render a 'gt' table or read the network skip on
  CRAN.
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
