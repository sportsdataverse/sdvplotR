# sdvplotR 0.1.0

Initial release: one plotting package for team logos, wordmarks, player
headshots and team colors across eight leagues (NFL, NBA, WNBA, MLB, NHL,
college football, men's and women's college basketball), built on 'ggpath'
and following the conventions of 'nflplotR', 'cfbplotR', 'nbaplotR' and
'mlbplotR'.

* Team reference data covers every current franchise in the five pro
  leagues plus all FBS and FCS football programs and all Division I
  basketball programs, with ESPN ids, primary / dark logo variants, official
  colors and conference / division. NFL rows carry nflverse wordmarks.
* `clean_team_abbrs()` maps full team names, alternate provider
  abbreviations (`"WSH"` / `"WAS"`, `"GSW"` / `"GS"`, ...) and historical
  abbreviations of relocated franchises to one canonical key per sport;
  `resolve_historical_abbr()` exposes the relocation table.
* `geom_sdv_logos()`, `geom_sdv_wordmarks()` and `geom_sdv_headshots()`
  draw images at x / y positions.
* `element_sdv_logo()`, `element_sdv_wordmark()` and
  `element_sdv_headshot()` replace axis text with images; `scale_x_sdv()`,
  `scale_y_sdv()` and the headshot variants do the same through
  `ggtext::element_markdown()` with `theme_x_sdv()` / `theme_y_sdv()`.
* `scale_color_sdv()` and `scale_fill_sdv()` map teams to their primary or
  secondary colors; `sdv_team_colors()`, `sdv_color_palette()` and
  `sdv_team_factor()` expose the same data outside ggplot2.
* `gt_sdv_logos()`, `gt_sdv_wordmarks()`, `gt_sdv_headshots()`,
  `gt_sdv_cols_label()` and `gt_merge_stack_team_color()` render images and
  team-colored text inside 'gt' tables.
* `reactable_sdv_logos()`, `reactable_sdv_wordmarks()`,
  `reactable_sdv_headshots()`, `reactable_sdv_cols_label()`,
  `reactable_sdv_team_color_bar()` and `reactable_sdv_team_color_bg()` do the
  same for 'reactable' tables.
* The 'gtUtils' table toolkit by Andrew Weatherman ships in sdvplotR: 18
  `gt_theme_*()` table themes plus `gt_theme_preview()`, continuous and
  discrete color legends, `gt_cutline()`, `gt_significance()`,
  `gt_outliers()`, color pills / ranks / results, percentile bars, border
  bars, `gt_grid()`, `gt_snake()` and `gt_stack_tables()` layouts,
  `gt_save_crop()`, `gt_save_batch()` and `gt_social_crop()`, and the
  `theme_bg` background lookup. The eight gtUtils articles are on the
  website as "gt Table Cookbooks".
* `gt_theme_sdv()` is the SportsDataverse house table theme, in light and
  `style = "dark"`, and `gt_theme_sdv_team()` dresses a table in one team's
  colors from `sdv_team_colors()`, picking title text and line colors by
  contrast.
* `gt_grid()` and `gt_stack_tables()` scroll inside their own box instead of
  overflowing the page when they are wider than the screen.
* Two articles walk through what the gt side adds and why: "SportsDataverse
  Table Themes" (the house theme, dark style, team colors and their contrast
  rules, density, overrides, saving) and "Team Tables with the gt Toolkit" (a
  2023 playoff-picture table built from logos, a cut line, rank colors,
  captions and a two-conference grid).
* Every example runs: examples that only build tables run as plain examples,
  and those that save images through a headless Chrome are `\donttest{}`
  blocks that run when `webshot2` and Chrome are available.
* `sdv_team_tiers()` builds tier charts, and `ggtitle_image()` places a logo
  next to a plot title.
* `valid_team_names()`, `team_reference()` and `supported_sports()` expose
  the reference data.
