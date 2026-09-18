# Contributing to sdvplotR

Thanks for helping make sdvplotR better. Bug reports, data corrections,
documentation fixes and new features are all welcome.

## Filing an issue

* Use the **Bug report** template and include a minimal
  [reprex](https://reprex.tidyverse.org/) plus `sessionInfo()`.
* Use the **Missing or incorrect team data** template for a wrong logo,
  color, abbreviation or historical mapping. Cite a source (team media
  guide, league site, ESPN).
* Use the **Feature request** template for new functionality. Link the
  equivalent in nflplotR / cfbplotR / nbaplotR / mlbplotR if one exists.

## Development setup

```r
# R >= 4.1
install.packages(c("devtools", "roxygen2", "testthat", "pkgdown", "styler", "lintr"))
devtools::load_all()
devtools::test()
devtools::document()
devtools::check()
```

## How the package is put together

sdvplotR is a thin domain layer on top of [ggpath](https://mrcaseb.github.io/ggpath/):

1. `R/utils.R` resolves a team abbreviation or player id to an image URL
   (`logo_from_team()`, `wordmark_from_team()`, `headshot_from_id()`,
   variant-aware `resolve_logo_url()`).
2. Geoms resolve the `team` / `player_id` aesthetic to a `path` column and
   delegate rendering to `ggpath::GeomFromPath$draw_panel()`.
3. Theme elements are plain S3 lists; their `element_grob()` methods build a
   real `ggpath::element_path()` (an S7 object) and hand off to ggplot2.
   Never re-class a list as `element_path`.
4. gt / reactable helpers emit `<img>` tags or inline CSS from the same
   resolvers.
5. Team data lives in `R/sysdata.rda` (`logo_ref`, `abbr_mapping`), built by
   `data-raw/generate_logo_ref.R` from the ESPN team endpoints and
   `nflreadr::load_teams()`. Historical / relocated abbreviations are in
   `R/historical_teams.R`.

## Making changes

* Branch from `main` (`feat/...`, `fix/...`, `docs/...`).
* Follow the [tidyverse style guide](https://style.tidyverse.org/); run
  `styler::style_pkg()` on files you touched.
* Add or update tests in `tests/testthat/test-<file>.R`. Tests must run
  offline: assert on the resolved URLs / HTML, and `skip_on_cran()` +
  `skip_if_offline()` for anything that renders images.
* Every exported function needs roxygen docs with `@param`, `@return` and
  `@examples`. Examples that download images go in `\donttest{}`.
* Run `devtools::document()` and commit `man/` and `NAMESPACE`; never edit
  them by hand.
* **Team data changes** go in `data-raw/generate_logo_ref.R` (or
  `R/historical_teams.R` for relocations), then re-run the script and commit
  the regenerated `R/sysdata.rda`. Never hand-edit the `.rda`.
* Add a bullet to `NEWS.md` for user-facing changes.
* If `README.Rmd` changed, re-render with `devtools::build_readme()`.
* `devtools::check()` should report 0 errors, 0 warnings, 0 notes before you
  open the pull request.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):
`feat(geom): ...`, `fix(gt): ...`, `data(nhl): ...`, `docs: ...`, `test: ...`,
`chore: ...`. Do not add AI assistants as commit co-authors.

## Code of Conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating you agree to abide by its terms.
