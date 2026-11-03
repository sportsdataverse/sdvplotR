## Release summary

This is the first CRAN submission of sdvplotR (version 0.3.0), a plotting
package for sports team logos, wordmarks, player headshots and team colors
across 49 leagues in 'ggplot2', 'gt' and 'reactable', and in 'plotly',
'ggiraph' and 'leaflet'. It is built on 'ggpath' (CRAN) and follows the
conventions of 'nflplotR' (CRAN). Earlier development builds, numbered 0.1.0,
were published only on r-universe.

## Test environments

* local: Windows 10 x64, R 4.6.0 (ucrt), `R CMD check --as-cran` on the built
  tarball (which also runs the `\donttest{}` examples, 48 seconds in total), and
  again with `_R_CHECK_DEPENDS_ONLY_=true` (Suggests not installed): Status OK
* R-hub (GitHub Actions, R-devel): Linux, Windows, macOS (x86_64 and arm64),
  and the `nosuggests` platform
* GitHub Actions (R-CMD-check workflow): macOS (release), Windows (release),
  Ubuntu (devel, release, oldrel-1)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The installed size is about 3.3 Mb (tarball 2.1 Mb).

## Notes for the CRAN team

* The package reads the SportsDataverse CDN at runtime for its team index
  and logo manifest, and caches them under `tools::R_user_dir()` for a day,
  keeping only the current version. Under `R CMD check`, on CRAN
  and with `options(sdvplotR.offline = TRUE)`, it uses the copy bundled in
  the package instead and writes nothing outside `tempdir()`.
* Team logos and player headshots are fetched at plot time from the
  SportsDataverse logo archive and the league CDNs through 'ggpath' and
  cached for the session. The images in `man/figures` are the package logo
  and the table-theme previews used in the help pages. The previews show no
  team logos or headshots; the package logo shows muted team logos behind the
  package name, as the logo of 'nflplotR' (CRAN) does. Examples that
  download images
  are wrapped in `\donttest{}` (as 'nflplotR' and 'ggpath' do); they pass
  under `--as-cran`, which runs them (48 seconds in total locally).
* 'sportyR' (>= 2.4.5, CRAN) is in Suggests: `sdv_surface()` checks for it
  with `rlang::check_installed()` and calls only its exported functions.
* The tests need network access, headless Chrome or image rendering for
  most files, so every test file starts with `skip_on_cran()`.
* Rendering a 'gt' table compiles its CSS through 'sass', which caches it
  under `tools::R_user_dir("sass", "cache")`. During a CRAN check the package
  turns that cache off (unless the user has set `sass.cache`), so the check
  writes nothing outside its own directory.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
