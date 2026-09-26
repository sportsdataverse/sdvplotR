# CLAUDE.md -- sdvplotR Development Guide

## Package Overview

`sdvplotR` plots team logos, wordmarks, player headshots and team colors for
eight leagues (NFL, NBA, WNBA, MLB, NHL, CFB, MBB, WBB) in ggplot2, gt and
reactable. It is the multi-league successor to `nflplotR` / `cfbplotR` /
`nbaplotR` / `mlbplotR`, built on `ggpath`, with one `sport` argument on every
function instead of one package per league.

- **Version**: 0.1.0 (`DESCRIPTION`); first CRAN submission in preparation
- **R**: >= 4.1; `ggplot2 (>= 3.5.0)`, `ggpath (>= 1.1.0)`, `gt (>= 0.10.0)`
- **License**: MIT; **Branch**: `main`
- **Docs**: <https://sdvplotR.sportsdataverse.org> (pkgdown, deployed to
  `gh-pages` by `.github/workflows/pkgdown.yaml`)
- **Local R toolchain**: use R 4.6.x (`C:/Program Files/R/R-4.6.1/bin/Rscript.exe`);
  the 4.5 library is missing roxygen2.

## Architecture

```
team abbr / player id
   -> clean_team_abbrs()           (R/utils.R; aliases + historical mappings)
   -> logo_from_team() / wordmark_from_team() / headshot_from_id()
      resolve_logo_url() / resolve_wordmark_url()   (variant-aware, fallback to primary)
   -> image URL
   -> ggpath renders:  GeomFromPath$draw_panel()  (geoms)
                       element_path S7 object     (theme elements)
      gt / reactable helpers emit <img> tags or inline CSS
```

- `R/sysdata.rda` holds `logo_ref` (one row per team, 1,128 rows: ESPN id,
  abbr, names, primary / dark / scoreboard logo URLs, wordmark URL, colors,
  conference, division) and `abbr_mapping` (per-sport named vector: every
  accepted key -> canonical abbr). Both are built by
  `data-raw/generate_logo_ref.R` from the ESPN `site.web.api.espn.com` teams
  endpoints (the `site.api.espn.com` host 403s non-browser clients), the ESPN
  core API group endpoints (FBS = 80, FCS = 81, D-I = 50) and
  `nflreadr::load_teams()`. **Never hand-edit the `.rda`.**
- Canonical keys: nflverse abbreviations for the NFL (`LA`, `LV`, `WAS`), ESPN
  abbreviations everywhere else (`GS`, `NY`, `UTAH`, `ATH`, `CON`). Aliases
  from other providers live in the `aliases` list of the data script;
  relocations live in `R/historical_teams.R`.
- Wordmarks exist only for the NFL (nflverse). Other leagues resolve to `NA`
  and the helpers fall back gracefully.

- **gtUtils port**: the generic `gt` table toolkit (themes, legends, cut
  lines, save/crop helpers; `R/gt_*.R` other than `gt_sdv.R`, `R/utils-*.R`,
  `R/data.R`, `R/deprecated.R`, `data/theme_bg.rda`) is copied from
  Andrew Weatherman's [gtUtils](https://github.com/andreweatherman/gtUtils)
  v1.0.0 (MIT, credited in `Authors@R` and `LICENSE.md`). These functions
  work on any table, so they take no `sport` argument and skip
  `clean_team_abbrs()`. The port has been restyled (styler, `|>`, lintr), so
  sync upstream changes by diffing gtUtils against commit `619c64a` (the v1.0.0 the port was taken from; upstream has no tags) and applying
  the hunks, never by copying files over; keep `"sdvplotR"` in the namespace
  strings (`gt_theme_preview()`, `deprecated.R`). `theme_bg` is built by
  `data-raw/theme_bg.R`; rerun it after adding or recoloring a theme.
- **SportsDataverse themes**: `gt_theme_sdv()` / `gt_theme_sdv_team()`
  (`R/gt_theme_sdv.R`) share `.sdv_theme_build()`; a palette list decides the
  look. Their `man/figures` previews come from `data-raw/theme_previews.R`
  (real 2023 NFL data, saved with `gt_save_crop()`); rerun it after changing
  either theme.

## Golden rules

1. **Delegate rendering to ggpath.** Geoms set `data$path` then call
   `ggpath::GeomFromPath$draw_panel()`.
2. **`ggpath::element_path` is S7.** Theme elements are plain S3 lists; the
   `element_grob.element_sdv_*` methods build a real `ggpath::element_path(...)`
   via `sdv_element_to_path_grob()`. Never re-class a list as `element_path`.
3. **One resolver path.** All lookups go through `clean_team_abbrs()` so
   aliases and historical abbreviations apply everywhere (geoms, elements, gt,
   reactable). Don't add per-function cleaning.
4. Never hand-edit `NAMESPACE`, `man/`, `README.md` (edit `README.Rmd`) or
   `R/sysdata.rda`.
5. Tests are offline: assert on resolved URLs / HTML. Anything that renders an
   image uses `skip_on_cran()` + `skip_if_offline()`.
6. No AI co-author trailers on commits.

## Build & check

```r
devtools::document()
devtools::test()
devtools::check(args = "--as-cran")   # must be 0 / 0 / 0
pkgdown::check_pkgdown(); pkgdown::build_site()
devtools::build_readme()
```

`Rscript data-raw/generate_logo_ref.R` regenerates team data;
`Rscript data-raw/hex_logo.R` regenerates `man/figures/logo.png`.

## CRAN packaging notes

- Only `vignettes/getting-started.Rmd` ships in the tarball (it evaluates
  offline code only). The 12 per-sport / cookbook vignettes are build-ignored
  in `.Rbuildignore` and published as pkgdown articles; they need the
  companion packages listed under `Config/Needs/website`.
- Examples that download images are wrapped in `\donttest{}`. Never use
  `\dontrun{}`: examples that save images through a headless Chrome go in an
  `@examplesIf <webshot2 + Chrome available>` block wrapping `\donttest{}`
  (see `R/gt_save_crop.R`) and write to `tempfile()` / `tempdir()`, never to
  the working directory.
- `Suggests` is deliberately small (ggtext, gridtext, knitr, reactable,
  rmarkdown, sjmisc, testthat, withr); companion data packages are website /
  development needs, not package dependencies.

## Commit convention

Conventional Commits: `feat(geom):`, `fix(gt):`, `data(nhl):`, `docs:`,
`test:`, `chore:`, `ci:`.
