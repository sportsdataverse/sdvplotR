# GitHub Copilot Instructions -- sdvplotR

These instructions tell GitHub Copilot (and other AI coding assistants) how to
write code that fits this repository. The fuller guide is
[CLAUDE.md](../CLAUDE.md); [CONTRIBUTING.md](../CONTRIBUTING.md) covers the
workflow.

`sdvplotR` is a ggplot2 / gt / reactable extension for team logos, wordmarks,
player headshots and team colors across eight leagues, built on
[`ggpath`](https://github.com/mrcaseb/ggpath).

## Golden rules

1. Never re-implement ggpath rendering: geoms delegate to
   `ggpath::GeomFromPath$draw_panel()`; theme elements go through
   `sdv_element_to_path_grob()`, which builds a real `ggpath::element_path()`
   (an S7 object -- never `structure()` a list with that class).
2. Resolve every team key through `clean_team_abbrs()` and the resolvers in
   `R/utils.R` (`logo_from_team()`, `wordmark_from_team()`,
   `headshot_from_id()`, `resolve_logo_url()`). Do not duplicate URL logic.
3. Every team-aware function takes `sport`, validated with
   `rlang::arg_match0(sport, supported_sports())`. The generic `gt` table
   toolkit ported from gtUtils (themes, legends, save/crop) works on any
   table and takes no `sport`.
4. Team data changes go in `data-raw/generate_logo_ref.R` or
   `R/historical_teams.R`, then regenerate `R/sysdata.rda`. Never hand-edit
   `NAMESPACE`, `man/`, `README.md` or the `.rda`.
5. Tests run offline and assert on URLs / HTML; image rendering tests use
   `skip_on_cran()` + `skip_if_offline()`.
6. Never add AI assistants as commit co-authors.

## After changing code

- `devtools::document()`, `devtools::test()`, `devtools::check(args = "--as-cran")`.
- Add new exported topics to `_pkgdown.yml` `reference:`.
- Update `NEWS.md` for user-visible changes; re-render `README.Rmd` if edited.
- Commit with Conventional Commits (`feat(geom):`, `fix(gt):`, `data(nfl):`, ...).
