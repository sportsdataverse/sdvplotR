# CLAUDE.md -- sdvplotR Development Guide

## Package Overview

`sdvplotR` plots team logos, wordmarks, player headshots and team colors for
eight leagues (NFL, NBA, WNBA, MLB, NHL, CFB, MBB, WBB) in ggplot2, gt and
reactable. It is the multi-league successor to `nflplotR` / `cfbplotR` /
`nbaplotR` / `mlbplotR`, built on `ggpath`, with one `sport` argument on every
function instead of one package per league.

- **Version**: 0.1.0 (`DESCRIPTION`); first CRAN submission in preparation
- **R**: >= 4.1; `ggplot2 (>= 4.0.0)`, `ggpath (>= 1.1.0)`, `gt (>= 0.10.0)`
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
  `nflreadr::load_teams()`. College keys also take the NCAA.com, KenPom and
  Torvik school names from sportsdataverse-py's NCAA / ESPN crosswalks and
  `hoopR::load_mbb_team_crosswalk()`, plus a hand-checked `sports_reference`
  table (the Sports Reference names none of those use), all joined on ESPN
  team id; ESPN's own keys win and a name used for two schools is dropped. Conferences are rows too
  (`type = "conference"`; the NFL shield is `"league"`), following nflplotR's
  AFC / NFC / NFL: logos from the ESPN groups, colors copied from cbbplotR,
  keys added only where no team uses the name (so the AAC is `"AAC"`), and the
  script asserts each conference resolves to itself. Former conference names
  (`"Pac-10"`) come from sportsdataverse-data's `{cfb,mbb,wbb}_groups`
  releases (`group_aliases`), joined lineage -> row on the ESPN group id; a
  name two lineages share, or one already mapped elsewhere, is skipped and
  logged. A conference ESPN no longer has a logo for (the WAC) is a
  `retired_confs` row in the script with ESPN's archived mark; its `through`
  season drops every lineage name a source dates after it, so the UAC the
  basketball WAC became never draws the WAC.
  `tests/testthat/fixtures/conference_keys.csv` pins every key that
  resolved to a conference before them. Divergence from nflplotR:
  `team_reference()` / `valid_team_names()` / `sdv_team_colors()` list
  conferences only with `include_conferences = TRUE`, because users filter and
  loop over those frames as teams. **Never hand-edit the `.rda`.**
- `R/sysdata.rda` also holds `logo_history` (sport, key, season_from,
  season_to, variant, url, identity_name): the season-aware marks behind
  `season` in `geom_sdv_logos()` / `gt_sdv_logos()`, resolved by
  `season_logo()` / `historical_logo_url()` in `R/utils.R`.
  `data-raw/generate_logo_history.R` builds it from the sdv-assets manifest
  (`manifest/marks.csv`): the NHL logo catalog (every era, NHL triCode keys,
  ending-year seasons; current clubs also keyed by sdvplotR's abbreviation)
  and ESPN's frozen NFL / WNBA relocated-identity files, whose seasons live
  in `data-raw/logo_history_legacy.csv`. URLs are the archive's
  content-addressed copies, never ESPN / NHL originals (overwritten in
  place). A historical key never goes through `resolve_historical_abbr()`,
  so `"COL"` never draws a Nordiques mark. Each script re-saves the other's
  objects; rerun this one after `generate_logo_ref.R`. NHL marks are SVG,
  which ggpath reads with `rsvg`.
- `R/sysdata.rda` also holds `logo_marks` (sport, key, type, variant, url):
  the archive's copies of today's logos and wordmarks, read FIRST by
  `resolve_logo_url()` / `resolve_wordmark_url()` (every geom, element and
  table helper goes through them); `logo_ref`'s ESPN / nflverse URLs are the
  fallback for a mark the archive lacks (none in the eight SDV sports; ~1,100
  of the 2,631 soccer clubs). Built by
  `data-raw/generate_logo_marks.R` from the same manifest: the files
  `logo_ref` lists joined on the manifest's `url` (so the image drawn is the
  same file; the copy seen last wins where ESPN replaced one), plus every
  named variant at least half of a sport's teams have (ESPN's
  `primary_logo_on_*` family, `scoreboard_dark`, `grayscale`, nflverse's
  `squared`, MLB's mlbstatic caps / wordmarks, SVG). A variant is valid for a
  sport iff `logo_variants` / `wordmark_variants` or `archive_variants(sport)`
  has it. Run order: `generate_logo_ref.R` -> `generate_logo_history.R` ->
  `generate_logo_marks.R`; all three save the four objects with `xz`.
  `team_reference()` keeps the source URLs on purpose (public columns).
- NFL headshots follow nflplotR: `load_headshot_map()` reads
  `headshot_gsis_map.rds` from this repo's `sdvplotr_infrastructure`
  pre-release (never "Latest", so `@*release` installs are unaffected)
  through `nflreadr::rds_from_url()`, memoised a day. A failed read (empty
  map) is dropped from that cache so the next call retries, and
  `sdvplotR_clear_cache()` drops only this URL, not the user's nflreadr cache.
  `data-raw/update_headshot_gsis_map.R` builds it from
  `nflreadr::load_rosters()` 1999 onward (one file per season; a combined map
  at each player's latest season with an NFL.com image, else their latest
  row; `nfl_player_id_crosswalk.rds/csv`), checks everything, then uploads;
  `.github/workflows/update-headshot-map.yaml` reruns the current season
  weekly. NFL.com image ids are opaque (not the GSIS digits). Divergences from
  nflplotR: URLs use the sized `t_headshot_desktop` transform (nflplotR the
  full-size image) plus `.png` as nflplotR does (gridtext needs it); unknown
  GSIS ids resolve to NA so each helper falls back as for every sport
  (nflplotR draws a silhouette); players with no NFL.com image use their ESPN
  headshot. By default NFL headshots take GSIS ids only: nflverse's numeric
  id systems collide with ESPN ids (`id_type = "espn"` takes ESPN's). Offline, the map is empty and NFL ids resolve to NA;
  tests mock `load_headshot_map()` (`tests/testthat/helper-headshots.R`).
- Other ID systems go through `id_type` on every headshot helper
  (`check_id_type()` validates it, `headshot_from_id()` resolves it). `NULL`
  keeps GSIS for the NFL and ESPN elsewhere; `"espn"` takes ESPN athlete ids
  for any sport; `"league"` builds the league CDN URL from `league_headshot_url`
  (NBA / WNBA Stats `PERSON_ID`, MLBAM, NHL API id, as hoopR, wehoop,
  mlbplotR and the NHL API build them; the NHL's `mugs/nhl/latest` path needs
  no season or team). Those CDNs are keyed by the league id, so no map is needed; they
  serve a silhouette for unknown ids, and cdn.nba.com / cdn.wnba.com return
  403 to datacenter IPs (the droplet, likely CI), so tests assert URLs only.
  College sports have no league option.
  ID systems can't be told apart by shape, so never guess.
- When nflverse / nflplotR already does something (data, headshots, caching),
  follow their approach and document any divergence.
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
2. **`ggpath::element_path` is S7.** `element_sdv_logo()` / `_wordmark()` /
   `_headshot()` are S7 subclasses of it (`R/theme_elements.R`) that also carry
   ggplot2's S3 classes `"element_text"` / `"element"`: ggplot2 4 lets a parent
   (`axis.text.x`) replace a plain child a complete theme sets
   (`theme_minimal()`'s `axis.text.x.bottom`) only for such a subclass. Their
   `element_grob()` methods map the labels to URLs and call `NextMethod()`.
   Never re-class a plain list as `element_path`.
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

A check NOTE "Found the following files/directories: ''NULL''" is not this
package. R CMD check starts R with `R_LIBS_USER='NULL'`, and on Windows the
quotes reach R. An R installed by rig 0.8.1 (the local R 4.6.1) has a
`## rig R_LIBS_USER` block in `library/base/R/Rprofile` that skips only an
unquoted `NULL`, so it runs `dir.create("'NULL'")` in the check directory as
the examples start. R without that block (the local R 4.6.0, CRAN, GitHub
Actions) gives no such NOTE.

`Rscript data-raw/generate_logo_ref.R` regenerates team data;
`Rscript data-raw/hex_logo.R` regenerates `man/figures/logo.png`.

## CRAN packaging notes

- The package ships no vignettes. Every article is a pkgdown-only article in
  `vignettes/articles/<slug>.Rmd` (named `articles/<slug>` in `_pkgdown.yml`,
  published at `articles/<slug>.html`), with its fixtures and images beside it
  in `vignettes/articles/fixtures/` and `vignettes/articles/images/`.
  `.Rbuildignore` drops the whole `^vignettes$` directory, and DESCRIPTION has
  no `VignetteBuilder` (and no knitr / rmarkdown). New articles take `title:`
  and `description:` front matter only (`usethis::use_article()`), never a
  `vignette:` block. They need the companion packages listed under
  `Config/Needs/website`; build one with
  `pkgdown::build_article("articles/<slug>")`. Paths inside an article are
  relative to `vignettes/articles/` (the repo root is `../../`).
- Examples that download images are wrapped in `\donttest{}`. Never use
  `\dontrun{}`: examples that save images through a headless Chrome go in an
  `@examplesIf interactive() && <webshot2 + Chrome available>` block wrapping
  `\donttest{}` (see `R/gt_save_crop.R`) and write to `tempfile()` /
  `tempdir()`, never to the working directory. `interactive()` is required:
  chromote starts Chrome through processx's supervisor, whose fifo
  connections stay open for the session, and R CMD check's `cleanEx()` then
  fails with "connections left open".
- `\figure{}` options use `style="width:100\%"`, not `width=100\%`; checkRd
  wants width/height attributes in pixels.
- `Suggests` is deliberately small (chromote, ggtext, gridtext, reactable,
  rsvg, sportyR, testthat, webshot2, withr); companion data packages are website /
  development needs, not package dependencies.
- `sdv_surface()` calls 'sportyR' (GPL-3) through its exported functions only,
  after `rlang::check_installed()`. sdvplotR is MIT: never copy, vendor or
  translate sportyR source.

## Formatting

- Run `styler` only on files a change adds. styler 1.11 rewrites this repo's
  double-indent function signatures (`f <- function(\n    arg,\n    arg) {`)
  in existing files, which turns a small fix into a diff across every
  signature; lintr's indentation_linter also disagrees with that style (the
  known lints on `main`).

## Commit convention

Conventional Commits: `feat(geom):`, `fix(gt):`, `data(nhl):`, `docs:`,
`test:`, `chore:`, `ci:`.
