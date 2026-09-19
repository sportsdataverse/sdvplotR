# NA

## Contribution checklist

Please confirm the following before submitting your pull request:

I have read the
[CONTRIBUTING.md](https://sdvplotR.sportsdataverse.org/CONTRIBUTING.md)
guidelines

I have forked the repo and created a feature/bugfix branch from `main`

I have updated the relevant documentation (roxygen2 `@description`,
`@examples`)

I have added/updated tests for any new behavior (using `testthat`)

`devtools::document()` has been run and `man/` + `NAMESPACE` are
committed

`devtools::check()` passes locally with no ERRORs or WARNINGs

`styler::style_pkg()` has been run on modified `.R` files

`lintr::lint_package()` has been run (or linting CI has passed)

I have added an entry to `NEWS.md` describing the change (under the
appropriate version header)

For data-only changes, I have updated `data-raw/generate_logo_ref.R`
rather than hand-editing `R/sysdata.rda`

## Type of change

Bug fix (non-breaking change that fixes an issue)

New feature (non-breaking change that adds functionality)

Breaking change (fix or feature that would cause existing functionality
to not work as expected)

Data update (team reference data, colors, URLs, historical mappings)

Documentation only (vignettes, README, roxygen docs)

CI / tooling (GitHub Actions, pkgdown, linting)

## What does this PR do?

Concise description of the change. Include the **sport(s) affected** if
applicable.

## Related issues

Closes \#

## Validation against oracle data

For ports, API recreations, model retrains, or data-regeneration
changes:

I have validated the output against **real captured/oracle data** (not
synthetic fixtures)

Validation gates are at the same threshold as before (if any gate fails,
the fix goes in the code, not the threshold)

I have documented the validation comparison in a comment below

## Visual output (if applicable)

For plot-rendering changes, paste before/after screenshots or the
generated plot. **Do not dump large text output here** — link to a gist
or attach as an image.

## Additional notes

Anything reviewers should know. Include any gotchas hit during
development.
