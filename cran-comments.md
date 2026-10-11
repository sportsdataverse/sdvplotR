## Release summary

This is the first CRAN submission of sdvplotR, a plotting package for sports
team logos, wordmarks, player headshots and team colors across nine leagues
in 'ggplot2', 'gt' and 'reactable'. It is built on 'ggpath' (CRAN) and follows
the conventions of 'nflplotR' (CRAN).

## Test environments

* local: Windows 10, R 4.6.1 (`R CMD check --as-cran --run-donttest`)
* GitHub Actions: ubuntu-latest (R devel, release, oldrel-1),
  windows-latest (R release), macos-latest (R release)
* R-hub: linux, windows, macos and macos-arm64 (R devel), ubuntu-next,
  ubuntu-release, atlas, nosuggests, donttest

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

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

* All images are fetched at plot time from public league CDNs (ESPN,
  nflverse) through 'ggpath' and cached for the session; no image files are
  bundled. Examples that download images are wrapped in `\donttest{}` (as
  'nflplotR' and 'ggpath' do); they pass under `--as-cran`, which runs them,
  each in under 5 seconds. Without network, the read of the NFL headshot
  map warns and returns no rows instead of erroring. The one test that
  renders images skips on CRAN.
* The slowest example, `sdv_surface()` (about 4 seconds), spends that time
  in 'sportyR' building the court geometry.
* The package ships no vignettes: its long-form documentation is articles on
  the pkgdown site, which need the companion data packages and network
  access.
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
