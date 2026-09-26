# Changelog

## sdvplotR 0.1.0

Initial release: one plotting package for team logos, wordmarks, player
headshots and team colors across eight leagues (NFL, NBA, WNBA, MLB,
NHL, college football, men’s and women’s college basketball), built on
‘ggpath’ and following the conventions of ‘nflplotR’, ‘cfbplotR’,
‘nbaplotR’ and ‘mlbplotR’.

- Team reference data covers every current franchise in the five pro
  leagues plus all FBS and FCS football programs and all Division I
  basketball programs, with ESPN ids, primary / dark logo variants,
  official colors and conference / division. NFL rows carry nflverse
  wordmarks.
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  maps full team names, alternate provider abbreviations (`"WSH"` /
  `"WAS"`, `"GSW"` / `"GS"`, …) and historical abbreviations of
  relocated franchises to one canonical key per sport;
  [`resolve_historical_abbr()`](https://sdvplotR.sportsdataverse.org/reference/resolve_historical_abbr.md)
  exposes the relocation table.
- [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
  [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md)
  and
  [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
  draw images at x / y positions.
- [`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md),
  [`element_sdv_wordmark()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  and
  [`element_sdv_headshot()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  replace axis text with images;
  [`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md),
  [`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  and the headshot variants do the same through
  [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
  with
  [`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  /
  [`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md).
- [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  and
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  map teams to their primary or secondary colors;
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  [`sdv_color_palette()`](https://sdvplotR.sportsdataverse.org/reference/sdv_color_palette.md)
  and
  [`sdv_team_factor()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_factor.md)
  expose the same data outside ggplot2.
- [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
  [`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
  [`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
  [`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)
  and
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  render images and team-colored text inside ‘gt’ tables.
- [`reactable_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_cols_label.md),
  [`reactable_sdv_team_color_bar()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  and
  [`reactable_sdv_team_color_bg()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  do the same for ‘reactable’ tables.
- The ‘gtUtils’ table toolkit by Andrew Weatherman ships in sdvplotR: 18
  `gt_theme_*()` table themes plus
  [`gt_theme_preview()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_preview.md),
  continuous and discrete color legends,
  [`gt_cutline()`](https://sdvplotR.sportsdataverse.org/reference/gt_cutline.md),
  [`gt_significance()`](https://sdvplotR.sportsdataverse.org/reference/gt_significance.md),
  [`gt_outliers()`](https://sdvplotR.sportsdataverse.org/reference/gt_outliers.md),
  color pills / ranks / results, percentile bars, border bars,
  [`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md),
  [`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
  and
  [`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
  layouts,
  [`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md),
  [`gt_save_batch()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_batch.md)
  and
  [`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md),
  and the `theme_bg` background lookup. The eight gtUtils articles are
  on the website as “gt Table Cookbooks”.
- [`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
  is the SportsDataverse house table theme, in light and
  `style = "dark"`, and
  [`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
  dresses a table in one team’s colors from
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  picking title text and line colors by contrast.
- [`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
  and
  [`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
  scroll inside their own box instead of overflowing the page when they
  are wider than the screen.
- Two articles walk through what the gt side adds and why:
  “SportsDataverse Table Themes” (the house theme, dark style, team
  colors and their contrast rules, density, overrides, saving) and “Team
  Tables with the gt Toolkit” (a 2023 playoff-picture table built from
  logos, a cut line, rank colors, captions and a two-conference grid).
- Every example runs: examples that only build tables run as plain
  examples, and those that save images through a headless Chrome are
  `\donttest{}` blocks that run in an interactive session with
  `webshot2` and Chrome available (checks skip them).
  [`gt_save_batch()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_batch.md)
  now needs an explicit `dir` rather than writing to the working
  directory.
- NFL player headshots work again. GSIS ids (`"00-0033873"`) resolve
  through a headshot map read at run time, the way nflplotR reads its
  own: sdvplotR builds it from nflverse rosters back to 1999 and
  publishes it, with a player id crosswalk (GSIS, ESPN, PFR, PFF,
  Sportradar, Sleeper, …), to the `sdvplotr_infrastructure` release,
  refreshed weekly. Each id resolves to the player’s NFL.com image, or
  ESPN’s where NFL.com has none. They previously pointed at a URL built
  from the GSIS digits that returned 404 for every player, in the geom,
  the gt and reactable helpers, and the headshot axis scales.
  [`sdvplotR_clear_cache()`](https://sdvplotR.sportsdataverse.org/reference/sdvplotR_clear_cache.md)
  now also clears the memoised map.
- Every headshot helper takes `id_type`, so player IDs from sources
  other than ESPN draw the right player. `"league"` reads the league’s
  own ID from its image CDN: NBA Stats and WNBA Stats `PERSON_ID`
  (hoopR’s `nba_*()`, wehoop’s `wnba_*()`) and MLBAM (baseballr,
  Baseball Savant). `"espn"` reads ESPN athlete IDs in any sport,
  including the NFL. By default, IDs are read as before: GSIS for the
  NFL, ESPN elsewhere. The ID systems overlap: without `id_type`, Dirk
  Nowitzki’s NBA Stats ID drew ESPN’s Jared Jeffries.
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  resolves the MLB Stats API’s `"AZ"` (baseballr, Baseball Savant) and
  FanGraphs’ `"WSN"`, so Arizona’s and Washington’s logos draw from that
  data.
- [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  and
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  color every key the rest of the package accepts (provider aliases such
  as `"AZ"` or `"GSW"`, full names, historical abbreviations), not only
  canonical abbreviations, which drew grey.
- [`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  and
  [`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  work after a complete theme such as
  [`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  on ‘ggplot2’ 4, which sets the position-specific axis text elements
  itself; axis logos drew as raw HTML there.
- [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  builds tier charts, and
  [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  places a logo next to a plot title.
- [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md),
  [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
  and
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md)
  expose the reference data.
