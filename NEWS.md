# sdvplotR 0.1.0

Initial release: team logos, wordmarks, player headshots and team colours for
ggplot2, gt and reactable, and for interactive plotly, ggiraph and leaflet
charts, across the 28 leagues of the SportsDataverse team index
(`sdv_leagues()`), built on 'ggpath'. It shares its team index, logo
archive and argument names with the Python package sdvplot and the
JavaScript packages `@sportsdataverse/sdvplot` and `@sportsdataverse/sdvtables`.

## Teams and identifiers

* `sdv_resolve()` turns team identifiers from any of 19 id systems (ESPN,
  nflverse, MLB Stats, nba_api, NHL, HockeyTech, CFBD, NCAA, PFF, Sports
  Reference, FanGraphs, names, ...) into canonical team ids, using `season`
  for codes reused across eras; `sdv_suggest()` proposes candidates for a
  value that does not resolve. The helpers that take a team take `league` and
  `id_system`. Those that draw team marks or colours also take `season`
  (the `geom_sdv_*` layers read it as an aesthetic or a constant).
  `strict` (raise instead of warn when a value does not resolve) is taken by
  `sdv_resolve()`, `sdv_logo_url()`, `sdv_team_colors()`,
  `sdv_color_palette()`, `sdv_team_tiers()` and the logo, wordmark, label and
  colour-bar helpers (`geom_sdv_logos()`, `geom_sdv_wordmarks()`,
  `add_sdv_logos()`, `add_sdv_wordmarks()`, `addSdvLogoMarkers()`,
  `sdv_axis_logos()` and the `gt_sdv_*` and `reactable_sdv_*` helpers that draw
  them), but not by `sdv_marks()`, `element_sdv_logo()`,
  `element_sdv_wordmark()`, `scale_x_sdv()`, `scale_y_sdv()`, `sdv_colorway()`
  or `sdv_team_factor()`. Headshot helpers take no `season`;
  `ggtitle_image()`, `scale_colour_sdv()`, `scale_color_sdv()` and
  `scale_fill_sdv()` take neither `season` nor `id_system`; `sdv_surface()`
  takes `league` and `season` but no `id_system`.
* `sdv_teams()`, `sdv_leagues()`, `sdv_team_colors()`, `sdv_color_palette()`
  and `sdv_team_factor()` list and colour teams.
* The team index and the logo manifest are read from the SportsDataverse CDN
  and cached for a day (`sdv_versions()`, `sdv_clear_cache()`); a copy is
  bundled for offline use (`options(sdvplotR.offline = TRUE)`).

## Logos, wordmarks and headshots

* `sdv_logo_url()` and `sdv_marks()` choose a team's archived mark by
  variant (`"default"`, `"dark"`, or a named variant) and season.
* `sdv_headshot_url()` and the headshot helpers read ESPN athlete ids in
  every league by default; `id_system = "gsis"` reads nflverse NFL ids and
  `id_system = "league"` the league's own player ids.

## Interactive plots and maps

* plotly: `add_sdv_logos()`, `add_sdv_wordmarks()`, `add_sdv_headshots()`,
  `sdv_axis_logos()` and `sdv_colorway()`.
* ggiraph: `geom_sdv_logos_interactive()`, `geom_sdv_wordmarks_interactive()`
  and `geom_sdv_headshots_interactive()`, which embed images at most `max_px`
  (160) pixels a side, so 32 logos add about half a megabyte to the page.
* leaflet: `addSdvLogoMarkers()`.

## Plots, surfaces and tables

* `geom_sdv_logos()`, `geom_sdv_wordmarks()` and `geom_sdv_headshots()`
  draw images at x / y positions; `geom_sdv_logos()` takes a `season`
  aesthetic, so a team is drawn with the mark it wore that season.
* `element_sdv_logo()`, `element_sdv_wordmark()` and
  `element_sdv_headshot()` replace axis text with images; `scale_x_sdv()`,
  `scale_y_sdv()` and the headshot variants do the same through
  `ggtext::element_markdown()` with `theme_x_sdv()` / `theme_y_sdv()`. Both
  draw a copy of each image at most four times its drawn size (sharp in a
  300 dpi export, and a few KB a logo in an SVG or ggiraph widget). All of
  them work after a complete theme such as `theme_minimal()` on 'ggplot2' 4,
  which sdvplotR requires.
* `gt_theme_source()` and `reactable_theme_sdv()` apply any of 122 surveyed
  table styles, named for their source (`"datagolf"`, `"wikipedia"`, `"nejm"`,
  ...); `sdv_table_themes()` lists them and `table_theme_spec()` resolves one.
  The registry is shared with sdvplot and sdvtables. Twenty shortcuts such as
  `gt_theme_datagolf()` and `gt_theme_wikipedia()` name the most useful.
* `scale_color_sdv()` and `scale_fill_sdv()` map teams to their primary or
  secondary colours.
* Conference rows (the college conferences, and the AFC, NFC and NFL) have
  logos and colours: `sdv_teams(include_conferences = TRUE)` lists them and the
  image helpers draw them from their short keys (`"SEC"`, `"Big Ten"`,
  `"Pac-12"`) or their other names (`"Southeastern Conference"`, `"B1G"`).
  A team's code wins over a conference's: cfb's `"MAC"` is Macalester.
* `sdv_team_tiers()` builds tier charts, with dark marks on its dark theme
  (`variant = "auto"`) and a `theme = "light"` option; `ggtitle_image()` with
  `theme_title_image()` places a logo next to a plot title.
* `sdv_surface()` draws a court, field, rink or pitch through 'sportyR' for 27
  leagues and FIBA courts, as a ggplot to plot data on. Leagues without a
  surface of their own use their sport's (the WHL, for one, uses the NHL rink).
  Given a team, a few features take its colours, and `center_logo = TRUE` puts
  its logo at the center. These are stylized surfaces built from team colours,
  not the teams' real floor, field or rink designs.
* `sdv_court_coords()` converts stats.nba.com / stats.wnba.com legacy shot
  locations (`x_legacy`/`y_legacy`, or `LOC_X`/`LOC_Y` from the
  `Shot_Chart_Detail` element of `hoopR::nba_shotchartdetail()`) into the
  `sportyR::geom_basketball("nba")` court frame; the converted points also
  fit sportyR's `"wnba"` and `"ncaa"` courts.
  `sdv_court_coords(provider = "euroleague")` converts the Euroleague shot
  frame of hoopR's `euroleague_game_points()` (`coord_x`/`coord_y`: integer
  centimeters, hoop at the origin, both teams on one basket, free throws as
  `-1,-1`) onto the FIBA court `sdv_surface("fiba")` draws, in meters, with
  the `-1,-1` free throws as `NA`.
* `sdv_pitch_coords()` converts soccer event coordinates from Opta /
  Stats Perform, Wyscout, StatsBomb, UEFA, Impect, ESPN and the tracking
  providers (Tracab, SkillCorner, Second Spectrum, Metrica) to one
  regulation 105 x 68 m frame, piecewise-linearly between pitch landmarks.
* `gt_sdv_logos()`, `gt_sdv_wordmarks()`, `gt_sdv_headshots()`,
  `gt_sdv_cols_label()` and `gt_merge_stack_team_color()` render images and
  team-coloured text inside 'gt' tables. `gt_sdv_logos(include_name = TRUE)`
  keeps the cell's text after the logo. `gt_merge_stack_team_color()` keeps
  its text readable: a primary colour under 4.5:1 contrast against the cell
  background gives way to the secondary colour, or is darkened until it
  passes.
* `reactable_sdv_logos()`, `reactable_sdv_wordmarks()`,
  `reactable_sdv_headshots()`, `reactable_sdv_cols_label()`,
  `reactable_sdv_team_color_bar()` and `reactable_sdv_team_color_bg()` do the
  same for 'reactable' tables; a logo or wordmark swaps to the default image in
  the browser if a variant fails to load.
* `gt_theme_sdv()` is the SportsDataverse house table theme, in light and
  `style = "dark"`, and `gt_theme_sdv_team()` dresses a table in one team's
  colours from `sdv_team_colors()`, picking title text and line colours by
  contrast.
* The 'gtUtils' table toolkit by Andrew Weatherman ships in sdvplotR: 18
  `gt_theme_*()` table themes plus `gt_theme_preview()`, continuous and
  discrete colour legends, `gt_cutline()`, `gt_significance()`,
  `gt_outliers()`, colour pills / ranks / results, percentile bars, border
  bars, `gt_grid()`, `gt_snake()` and `gt_stack_tables()` layouts,
  `gt_save_crop()`, `gt_save_batch()` and `gt_social_crop()`, and the
  `theme_bg` background lookup. The eight gtUtils articles are on the
  website as "gt Table Cookbooks".
* Every `gt_theme_*()` keeps its own row colours on a Bootstrap page (pkgdown,
  Quarto) in either colour mode. `gt_color_pills()`, `gt_percentile_bar()`,
  `gt_fmt_tally()`, `gt_significance()` and `gt_merge_stack_team_color()`
  decorate each cell from its own row when row groups reorder the table.
  `gt_grid()` and `gt_stack_tables()` scroll inside their own box when they
  are wider than the screen.
* `gt_spotlight()` dims the other rows to a readable tone: with
  `dim_color = "auto"` it blends the table's text toward its background until
  it sits just above 4.5:1 contrast. `gt_tiers()` gives each image its own
  alt text, and takes an `alt` argument for your own text.
* Saving a table to an image (`gt_save_crop()`, `gt_social_crop()`,
  `gt_save_batch()`, `gt_grid()`, `gt_stack_tables()`) gives headless Chrome
  60 seconds to start; a longer `options(chromote.timeout = )` of your own is
  kept. `gt_save_batch()` needs an explicit `dir`.
* Every example runs: examples that only build tables run as plain examples,
  and those that save images through a headless Chrome are `\donttest{}`
  blocks that run in an interactive session with `webshot2` and Chrome
  available. The reference examples use real SportsDataverse data:
  `sdv_example_standings` holds the final 2025 NFL and 2025-26 NBA
  regular-season standings, built by `data-raw/sdv_examples.R` from the
  nflreadr / nflseedR and hoopR release loaders.
* The package ships no vignettes. Every article, "Getting Started" included,
  is on the pkgdown site (<https://sdvplotR.sportsdataverse.org/articles/>),
  among them "SportsDataverse Table Themes", "Team Tables with the gt
  Toolkit" and a "Visual recipes" group that rebuilds SportsDataverse web
  visuals as static tables and plots on real data.
