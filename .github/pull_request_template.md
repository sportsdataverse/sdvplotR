## Contribution checklist

Please confirm the following before submitting your pull request:

- [ ] I have read the [contributing guide](https://github.com/sportsdataverse/sdvplotR/blob/main/CONTRIBUTING.md)
- [ ] I have created a feature/bugfix branch from `main`
- [ ] I have updated the relevant documentation (roxygen2 `@description`, `@param`, `@return`, `@examples`)
- [ ] I have added/updated tests for any new behavior (`testthat`; every test file starts with `skip_on_cran()`)
- [ ] `devtools::document()` has been run and `man/` + `NAMESPACE` are committed
- [ ] `devtools::test()` passes and `devtools::check(args = "--as-cran")` has no ERRORs or WARNINGs
- [ ] `styler::style_file()` has been run on new `.R` files only (see CLAUDE.md, Formatting)
- [ ] `lintr::lint_package()` reports no lints (or linting CI has passed)
- [ ] I have added an entry to `NEWS.md` describing the change (under the top version header)
- [ ] New exported topics are listed in `_pkgdown.yml` (`pkgdown::check_pkgdown()` passes)
- [ ] For a snapshot refresh, I have rebuilt `R/sysdata.rda` with `data-raw/export_index.py` and `Rscript data-raw/build_index_snapshot.R` rather than hand-editing it (team data itself is fixed in [sdv-assets](https://github.com/sportsdataverse/sdv-assets) / the sdvplot team index)

## Type of change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Team data snapshot refresh
- [ ] Documentation only (articles, README, roxygen docs)
- [ ] CI / tooling (GitHub Actions, pkgdown, linting)

## What does this PR do?

Concise description of the change. Include the **league(s)** (`league = ...`) or surface keys affected, if any.

## Related issues

Closes #

## Visual output (if applicable)

For plot-rendering changes, paste before/after screenshots or the generated plot. **Do not dump large text output here**; link to a gist or attach an image.

## Additional notes

Anything reviewers should know.
