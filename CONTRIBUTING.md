# Contributing to sdvplotR

Thanks for helping make sdvplotR better. Bug reports, data corrections,
documentation fixes and new features are all welcome.

## Filing an issue

- Use the **Bug report** template and include a minimal
  [reprex](https://reprex.tidyverse.org/) plus
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).
- Use the **Missing or incorrect team data** template for a wrong logo,
  color, abbreviation or historical mapping. Include what
  [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md),
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  or
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
  return and cite a source (team media guide, league site, ESPN).
- Use the **Feature request** template for new functionality. Link the
  equivalent in nflplotR / cfbplotR / nbaplotR / mlbplotR if one exists.

## Development setup

``` r

# R >= 4.1
install.packages(c("devtools", "roxygen2", "testthat", "pkgdown", "styler", "lintr"))
devtools::load_all()
devtools::document()
devtools::test()
devtools::check(args = "--as-cran")
```

[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
needs ‘sportyR’ 2.4.5 or later (`install.packages("sportyR")`).

## How the package is put together

sdvplotR is a domain layer on top of
[ggpath](https://mrcaseb.github.io/ggpath/):

1.  Team data comes from two shared artifacts: the SportsDataverse
    **team index** (teams and their aliases across 18 id systems, the
    same index sdvplot and the JavaScript packages read) and the
    **sdv-assets logo manifest** (every archived logo and wordmark by
    team, variant and season). `R/index.R` reads both from the
    SportsDataverse CDN and caches them for a day; `R/sysdata.rda` holds
    a bundled snapshot for offline use and CRAN checks
    (`options(sdvplotR.offline = TRUE)`).
2.  Every function that takes a team takes a `league` (one of the 28
    leagues of
    [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md))
    and an `id_system`; those that draw marks or colors also take a
    `season`. All of them resolve teams through `resolve_ids()`
    (`R/resolve.R`, behind
    [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)),
    so aliases, id systems and codes reused across eras apply
    everywhere. Don’t add per-function cleaning.
3.  `mark_url()` / `select_mark()` (`R/marks.R`) pick a logo or wordmark
    by variant and season; `headshot_from_id()` (`R/utils.R`) builds
    player headshot URLs for `id_system = "espn"`, `"gsis"` or
    `"league"`.
4.  Geoms
    ([`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
    [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md),
    [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md))
    set a `path` column and delegate rendering to
    `ggpath::GeomFromPath$draw_panel()`.
5.  Theme elements
    ([`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
    and friends, `R/theme_elements.R`) are S7 subclasses of
    [`ggpath::element_path`](https://mrcaseb.github.io/ggpath/reference/element_path.html).
    Never re-class a plain list as `element_path`.
6.  The gt, reactable, plotly, ggiraph and leaflet helpers emit `<img>`
    tags, inline CSS or layout images from the same resolvers. The
    generic `gt` toolkit ported from gtUtils (`gt_theme_*()`, legends,
    cut lines, save/crop helpers) works on any table and takes no
    `league`.
7.  [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
    draws 59 playing-surface keys through ‘sportyR’’s exported functions
    only.

## Making changes

- Branch from `main` (`feat/...`, `fix/...`, `docs/...`).
- Follow the [tidyverse style guide](https://style.tidyverse.org/). Run
  `styler::style_file()` on files you add; styler rewrites the repo’s
  double-indented function signatures in existing files (see
  `CLAUDE.md`, Formatting). `lintr::lint_package()` should report no
  lints.
- Add or update tests in `tests/testthat/test-<file>.R`. Every test file
  starts with `skip_on_cran()`. Tests run offline
  (`tests/testthat/setup.R` sets `sdvplotR.offline`): assert on the
  resolved URLs / HTML, and add `skip_if_offline()` for anything that
  renders images.
- Every exported function needs roxygen docs with `@param`, `@return`
  and `@examples`. Examples that download images go in `\donttest{}`;
  never use `\dontrun{}`.
- Run `devtools::document()` and commit `man/` and `NAMESPACE`; never
  edit them by hand. List new exported topics in `_pkgdown.yml` and run
  [`pkgdown::check_pkgdown()`](https://pkgdown.r-lib.org/reference/check_pkgdown.html).
- **Team data** (logos, colors, aliases, relocations) is fixed upstream
  in [sdv-assets](https://github.com/sportsdataverse/sdv-assets) and the
  sdvplot team index, not here. To refresh the bundled snapshot, run
  `python data-raw/export_index.py` and then
  `Rscript data-raw/build_index_snapshot.R` from the package root. Never
  hand-edit `R/sysdata.rda`.
- Add a bullet to `NEWS.md` for user-facing changes.
- If `README.Rmd` changed, re-render with `devtools::build_readme()`.
- `devtools::check(args = "--as-cran")` should report 0 errors, 0
  warnings and 0 notes (a “New submission” note aside) before you open
  the pull request.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):
`feat(geom): ...`, `fix(gt): ...`, `data(nhl): ...`, `docs: ...`,
`test: ...`, `chore: ...`, `ci: ...`. Do not add AI assistants as commit
co-authors.

## Code of Conduct

This project is released with a [Contributor Code of
Conduct](https://sdvplotR.sportsdataverse.org/CODE_OF_CONDUCT.md). By
participating you agree to abide by its terms.
