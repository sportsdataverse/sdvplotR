# CLAUDE.md – sdvplotR Development Guide

## Package Overview

`sdvplotR` plots team logos, wordmarks, player headshots and team colors
for eight leagues (NFL, NBA, WNBA, MLB, NHL, CFB, MBB, WBB) in ggplot2,
gt and reactable. It is the multi-league successor to `nflplotR` /
`cfbplotR` / `nbaplotR` / `mlbplotR`, built on `ggpath`, with one
`league` argument on every function instead of one package per league.

- **Version**: 0.1.0 (`DESCRIPTION`); first CRAN submission in
  preparation
- **R**: \>= 4.1; `ggplot2 (>= 4.0.0)`, `ggpath (>= 1.1.0)`,
  `gt (>= 0.10.0)`
- **License**: MIT; **Branch**: `main`
- **Docs**: <https://sdvplotR.sportsdataverse.org> (pkgdown, deployed to
  `gh-pages` by `.github/workflows/pkgdown.yaml`)
- **Local R toolchain**: use R 4.6.x
  (`C:/Program Files/R/R-4.6.1/bin/Rscript.exe`); the 4.5 library is
  missing roxygen2.

## Architecture

    team id / name / code (any of 19 id systems)
       -> resolve_ids()                 (R/resolve.R; behind sdv_resolve() and every helper)
       -> mark_url() -> select_mark()   (logo / wordmark by variant + season, from index_marks())
          headshot_from_id()            (player ids; id_system "espn" | "gsis" | "league")
       -> image URL (the sdv-assets archive's content-addressed copy)
       -> ggpath renders:  GeomFromPath$draw_panel()  (geoms)
                           element_path S7 object     (theme elements)
          gt / reactable helpers emit <img> tags or inline CSS

- Team data comes from two shared artifacts, not from anything built
  here: sdvplot’s **team index** (teams + aliases; the same index
  sdvplot and the JS packages read) and the **sdv-assets logo manifest**
  (every archived mark, by team, variant and season). `R/index.R`
  fetches both from the SportsDataverse CDN and caches them on disk for
  a day (`tools::R_user_dir("sdvplotR", "cache")`); teams and aliases
  always load as one unit at one version. Nothing else in the package
  touches the network or the snapshot for team data: everything reads
  `index_teams()`, `index_aliases()` and `index_marks()`.
  [`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md)
  reports what is loaded;
  [`sdv_clear_cache()`](https://sdvplotR.sportsdataverse.org/reference/sdv_clear_cache.md)
  drops it.

- `R/sysdata.rda` holds the offline / CRAN fallback (`snapshot_teams`,
  `snapshot_aliases`, `snapshot_marks`, `snapshot_meta`, plus
  `fold_from` / `fold_to`), used when `options(sdvplotR.offline = TRUE)`
  or the CDN read fails. Rebuild it with `data-raw/export_index.py`,
  then `Rscript data-raw/build_index_snapshot.R` from the package root.
  **Never hand-edit the `.rda`.**

- Conferences and leagues are rows in the index too (`non_team_programs`
  in `R/resolve.R`);
  [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)
  and
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
  list them only with `include_conferences = TRUE`, because users filter
  and loop over those frames as teams. A team’s code wins over a
  conference’s (cfb’s `"MAC"` is Macalester).

- [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  turns team identifiers into canonical ids using `season` for codes
  reused across eras;
  [`sdv_suggest()`](https://sdvplotR.sportsdataverse.org/reference/sdv_suggest.md)
  proposes candidates for a value that doesn’t resolve. Helpers that
  take a team take `league` and `id_system`; those that draw marks or
  colours also take `season`; `strict` raises instead of warning on an
  unresolved value. See NEWS.md (0.1.0) for exactly which helpers take
  which.

- NFL headshots follow nflplotR: `load_headshot_map()` reads
  `headshot_gsis_map.rds` from this repo’s `sdvplotr_infrastructure`
  pre-release (never “Latest”, so `@*release` installs are unaffected)
  through
  [`nflreadr::rds_from_url()`](https://nflreadr.nflverse.com/reference/rds_from_url.html),
  memoised a day. A failed read (empty map) is dropped from that cache
  so the next call retries, and
  [`sdv_clear_cache()`](https://sdvplotR.sportsdataverse.org/reference/sdv_clear_cache.md)
  drops only this URL, not the user’s nflreadr cache.
  `data-raw/update_headshot_gsis_map.R` builds it from
  [`nflreadr::load_rosters()`](https://nflreadr.nflverse.com/reference/load_rosters.html)
  1999 onward (one file per season; a combined map at each player’s
  latest season with an NFL.com image, else their latest row;
  `nfl_player_id_crosswalk.rds/csv`), checks everything, then uploads;
  `.github/workflows/update-headshot-map.yaml` reruns the current season
  weekly. NFL.com image ids are opaque (not the GSIS digits).
  Divergences from nflplotR: URLs use the sized `t_headshot_desktop`
  transform (nflplotR the full-size image) plus `.png` as nflplotR does
  (gridtext needs it); unknown GSIS ids resolve to NA so each helper
  falls back as for every sport (nflplotR draws a silhouette); players
  with no NFL.com image use their ESPN headshot. Headshot helpers read
  ESPN athlete ids in every league by default; NFL GSIS ids need
  `id_system = "gsis"` (nflverse’s numeric id systems collide with ESPN
  ids, so the two are never guessed between). Offline, the map is empty
  and NFL ids resolve to NA; tests mock `load_headshot_map()`
  (`tests/testthat/helper-headshots.R`).

- Other ID systems go through `id_system` on every headshot helper
  (`check_id_system()` validates it, `headshot_from_id()` resolves it).
  `"espn"` (the default) takes ESPN athlete ids for any league; `"gsis"`
  nflverse NFL ids; `"league"` builds the league CDN URL from
  `league_headshot_url` (NBA / WNBA Stats `PERSON_ID`, MLBAM, NHL API
  id, as hoopR, wehoop, mlbplotR and the NHL API build them; the NHL’s
  `mugs/nhl/latest` path needs no season or team). Those CDNs are keyed
  by the league id, so no map is needed; they serve a silhouette for
  unknown ids, and cdn.nba.com / cdn.wnba.com return 403 to datacenter
  IPs (the droplet, likely CI), so tests assert URLs only. College
  sports have no league option. ID systems can’t be told apart by shape,
  so never guess.

- When nflverse / nflplotR already does something (data, headshots,
  caching), follow their approach and document any divergence.

- Canonical keys: nflverse abbreviations for the NFL (`LA`, `LV`,
  `WAS`), ESPN abbreviations everywhere else (`GS`, `NY`, `UTAH`, `ATH`,
  `CON`). Aliases from other providers live in the `aliases` list of the
  data script; relocations live in `R/historical_teams.R`.

- Wordmarks exist only for the NFL (nflverse). Other leagues resolve to
  `NA` and the helpers fall back gracefully.

- **gtUtils port**: the generic `gt` table toolkit (themes, legends, cut
  lines, save/crop helpers; `R/gt_*.R` other than `gt_sdv.R`,
  `R/utils-*.R`, `R/data.R`, `R/deprecated.R`, `data/theme_bg.rda`) is
  copied from Andrew Weatherman’s
  [gtUtils](https://github.com/andreweatherman/gtUtils) v1.0.0 (MIT,
  credited in `Authors@R`). These functions work on any table, so they
  take no `league` argument and skip the team resolver. The port has
  been restyled (styler, `|>`, lintr), so sync upstream changes by
  diffing gtUtils against commit `619c64a` (the v1.0.0 the port was
  taken from; upstream has no tags) and applying the hunks, never by
  copying files over; keep `"sdvplotR"` in the namespace strings
  ([`gt_theme_preview()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_preview.md),
  `deprecated.R`). `theme_bg` is built by `data-raw/theme_bg.R`; rerun
  it after adding or recoloring a theme.

- **SportsDataverse themes**:
  [`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
  /
  [`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
  (`R/gt_theme_sdv.R`) share `.sdv_theme_build()`; a palette list
  decides the look. Their `man/figures` previews come from
  `data-raw/theme_previews.R` (real 2023 NFL data, saved with
  [`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md));
  rerun it after changing either theme.

## Golden rules

1.  **Delegate rendering to ggpath.** Geoms set `data$path` then call
    `ggpath::GeomFromPath$draw_panel()`.
2.  **[`ggpath::element_path`](https://mrcaseb.github.io/ggpath/reference/element_path.html)
    is S7.**
    [`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
    / `_wordmark()` / `_headshot()` are S7 subclasses of it
    (`R/theme_elements.R`) that also carry ggplot2’s S3 classes
    `"element_text"` / `"element"`: ggplot2 4 lets a parent
    (`axis.text.x`) replace a plain child a complete theme sets
    (`theme_minimal()`’s `axis.text.x.bottom`) only for such a subclass.
    Their `element_grob()` methods map the labels to URLs and call
    [`NextMethod()`](https://rdrr.io/r/base/UseMethod.html). Never
    re-class a plain list as `element_path`.
3.  **One resolver path.** All team lookups go through `resolve_ids()`
    so aliases, id systems and season-reused codes apply everywhere
    (geoms, elements, gt, reactable). Don’t add per-function cleaning.
4.  Never hand-edit `NAMESPACE`, `man/`, `README.md` (edit `README.Rmd`)
    or `R/sysdata.rda`.
5.  Tests are offline: assert on resolved URLs / HTML. Anything that
    renders an image uses `skip_on_cran()` + `skip_if_offline()`.
6.  No AI co-author trailers on commits.

## Build & check

``` r

devtools::document()
devtools::test()
devtools::check(args = "--as-cran")   # must be 0 / 0 / 0
pkgdown::check_pkgdown(); pkgdown::build_site()
devtools::build_readme()
```

A check NOTE “Found the following files/directories: ‘’NULL’’” is not
this package. R CMD check starts R with `R_LIBS_USER='NULL'`, and on
Windows the quotes reach R. An R installed by rig 0.8.1 (the local R
4.6.1) has a `## rig R_LIBS_USER` block in `library/base/R/Rprofile`
that skips only an unquoted `NULL`, so it runs `dir.create("'NULL'")` in
the check directory as the examples start. R without that block (the
local R 4.6.0, CRAN, GitHub Actions) gives no such NOTE.

`python data-raw/export_index.py` then
`Rscript data-raw/build_index_snapshot.R` refresh the offline team-data
snapshot; `Rscript data-raw/hex_logo.R` regenerates
`man/figures/logo.png`.

## CRAN packaging notes

- The package ships no vignettes. Every article is a pkgdown-only
  article in `vignettes/<slug>.Rmd` (named `<slug>` in `_pkgdown.yml`,
  published at `articles/<slug>.html`), with its fixtures and images
  beside it in `vignettes/fixtures/` and `vignettes/images/`, as in
  cfbfastR. `.Rbuildignore` drops the whole `^vignettes$` directory, and
  DESCRIPTION has no `VignetteBuilder` (and no knitr / rmarkdown), so R
  CMD check and CRAN never build them. Front matter follows the
  SportsDataverse vignette template: `title`, `description`, `author`
  (Saiem Gilani with the X and GitHub follow badges), `opengraph` (the
  image is the article’s gallery picture, else the site’s social card,
  `pkgdown/assets/sdvplotR-social-card.png`;
  `twitter: site "@SportsDataverse", card summary_large_image, creator "@saiemgilani"`)
  and `output: html_document`, never a `vignette:` block. Every article
  ends with **Our Authors**, **Citation** and **Related SportsDataverse
  packages** sections; copy them from an existing article. They need the
  companion packages listed under `Config/Needs/website`; build one with
  `pkgdown::build_article("<slug>")`. Paths inside an article are
  relative to `vignettes/` (the repo root is `../`).
- Examples that download images are wrapped in `\donttest{}`. Never use
  `\dontrun{}`: examples that save images through a headless Chrome go
  in an `@examplesIf interactive() && <webshot2 + Chrome available>`
  block wrapping `\donttest{}` (see `R/gt_save_crop.R`) and write to
  [`tempfile()`](https://rdrr.io/r/base/tempfile.html) /
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html), never to the
  working directory.
  [`interactive()`](https://rdrr.io/r/base/interactive.html) is
  required: chromote starts Chrome through processx’s supervisor, whose
  fifo connections stay open for the session, and R CMD check’s
  `cleanEx()` then fails with “connections left open”.
- `\figure{}` options use `style="width:100\%"`, not `width=100\%`;
  checkRd wants width/height attributes in pixels.
- `Suggests` is deliberately small (chromote, ggtext, gridtext,
  reactable, rsvg, sportyR, testthat, webshot2, withr); companion data
  packages are website / development needs, not package dependencies.
- [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  calls ‘sportyR’ (GPL-3) through its exported functions only, after
  [`rlang::check_installed()`](https://rlang.r-lib.org/reference/is_installed.html).
  sdvplotR is MIT: never copy, vendor or translate sportyR source.

## Formatting

- Run `styler` only on files a change adds. styler 1.11 rewrites this
  repo’s double-indent function signatures
  (`f <- function(\n arg,\n arg) {`) in existing files, which turns a
  small fix into a diff across every signature; lintr’s
  indentation_linter also disagrees with that style. To apply styler’s
  other fixes across the package (as on 2026-10-12), style a copy of
  `R/` and `tests/` and keep every hunk except the whitespace-only ones,
  which are the signature re-indents.
- `lintr::lint_package()` is at 0. Roxygen lines that cannot wrap
  (markdown table rows, `\figure{}` macros) sit inside
  `# nolint start: line_length_linter.` / `# nolint end` placed outside
  the `#'` block.

## Commit convention

Conventional Commits: `feat(geom):`, `fix(gt):`, `data(nhl):`, `docs:`,
`test:`, `chore:`, `ci:`.
