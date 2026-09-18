## Release summary

This is the first CRAN submission of sdvplotR, a plotting package for sports
team logos, wordmarks, player headshots and team colors across eight leagues
in 'ggplot2', 'gt' and 'reactable'. It is built on 'ggpath' (CRAN) and follows
the conventions of 'nflplotR' (CRAN).

## Test environments

* local: Windows 10, R 4.6.1
* GitHub Actions: ubuntu-latest (R devel, release, oldrel-1),
  windows-latest (R release), macos-latest (R release)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the CRAN team

* All images are fetched at plot time from public league CDNs (ESPN,
  nflverse) through 'ggpath' and cached for the session; no image files are
  bundled. Examples that download images are wrapped in `\donttest{}`, and
  the one test that renders images skips on CRAN.
* The vignette evaluates only offline code (the reference data shipped in
  the package).
* There are no published references describing the methods in this package;
  it provides plotting utilities rather than a statistical method.
