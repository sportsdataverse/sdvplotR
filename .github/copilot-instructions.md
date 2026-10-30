# GitHub Copilot Instructions -- sdvplotR

These instructions tell GitHub Copilot (and other AI coding assistants) how to
write code that fits this repository. The fuller guide is
[CLAUDE.md](../CLAUDE.md); [CONTRIBUTING.md](../CONTRIBUTING.md) covers the
workflow.

`sdvplotR` draws team logos, wordmarks, player headshots and team colors in
ggplot2, gt, reactable, plotly, ggiraph and leaflet across the 28 leagues of
the SportsDataverse team index (`sdv_leagues()`), built on
[`ggpath`](https://github.com/mrcaseb/ggpath). `sdv_surface()` draws 59
team-styled playing surfaces through 'sportyR' (>= 2.4.5).

## Golden rules

1. Never re-implement ggpath rendering: geoms set `data$path` and delegate to
   `ggpath::GeomFromPath$draw_panel()`. Theme elements
   (`element_sdv_logo()`, `_wordmark()`, `_headshot()`) are S7 subclasses of
   `ggpath::element_path` (`R/theme_elements.R`); never re-class a plain list
   as `element_path`.
2. Resolve every team through `resolve_ids()` (`R/resolve.R`, behind
   `sdv_resolve()`), then `mark_url()` / `select_mark()` (`R/marks.R`) for
   logos and wordmarks, or `headshot_from_id()` (`R/utils.R`) for players. Do
   not add per-function cleaning or URL logic.
3. Every team-aware function takes `league` (validated against
   `sdv_leagues()`) and `id_system`; those that draw marks or colors also take
   `season`, and `strict` raises instead of warning on an unresolved value.
   Headshot helpers take `id_system = "espn"` (default), `"gsis"` or
   `"league"`. The generic `gt` toolkit ported from gtUtils (`gt_theme_*()`,
   legends, cut lines, save/crop helpers) works on any table and takes no
   `league`.
4. Team data is read from the team index and the sdv-assets logo manifest
   (`R/index.R`: `index_teams()`, `index_aliases()`, `index_marks()`), with a
   bundled snapshot in `R/sysdata.rda`. Fix team data upstream (sdv-assets /
   the sdvplot team index); refresh the snapshot with
   `data-raw/export_index.py` then `Rscript data-raw/build_index_snapshot.R`.
   Never hand-edit `NAMESPACE`, `man/`, `README.md` or the `.rda`.
5. Call 'sportyR' only through its exported functions
   (`sportyR::get_surface_dimensions()`, the `geom_*()` functions), after
   `rlang::check_installed("sportyR", version = "2.4.5")`.
6. Tests run offline and assert on URLs / HTML. Every test file starts with
   `skip_on_cran()`; image rendering tests also use `skip_if_offline()`.
7. Never add AI assistants as commit co-authors.

## After changing code

- `devtools::document()`, `devtools::test()`, `devtools::check(args = "--as-cran")`.
- Add new exported topics to `_pkgdown.yml` `reference:` and run `pkgdown::check_pkgdown()`.
- Update `NEWS.md` for user-visible changes; re-render `README.Rmd` if edited.
- Commit with Conventional Commits (`feat(geom):`, `fix(gt):`, `data(nfl):`, ...).
