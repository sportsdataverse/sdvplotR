# Changelog

## sdvplotR 0.3.0

First CRAN release. Earlier development builds were published only on
r-universe, every one of them numbered 0.1.0 (no 0.1.0 or 0.2.0 was
released to CRAN or tagged), so this section describes the whole
package.

### sportyR 2.4.5 and the CRAN submission

- [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  needs ‘sportyR’ 2.4.5 or later, which is on CRAN
  (`install.packages("sportyR")`); `Suggests` declares the floor and
  [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  checks it with
  [`rlang::check_installed()`](https://rlang.r-lib.org/reference/is_installed.html).
  It reads a field’s parameters through
  [`sportyR::get_surface_dimensions()`](https://sportyR.sportsdataverse.org/reference/get_surface_dimensions.html)
  and no longer reads anything internal to ‘sportyR’.
- Surfaces follow sportyR 2.4.5’s geometry. Feature positions and the
  display range scale with the unit arguments, so a surface drawn in
  meters and its center logo agree. NFL, college and NFHS football
  fields have a white border outline (change it with
  `color_updates = list(field_border_outline = ...)`); a team’s end
  zones are painted inside it. The lacrosse markings (neutral zones,
  penalty boxes, goal fans, goal mouths, face-off markers) and the
  `nhl92` hockey goal crease are drawn correctly.
- The installed package is smaller: the bundled team-data snapshot is
  stored xz-compressed and the help-page figures are palette PNGs at
  most 1000 px wide. The code no longer declares global variables for R
  CMD check.

### Overview

Team logos, wordmarks, player headshots and team colours for ggplot2, gt
and reactable, and for interactive plotly, ggiraph and leaflet charts,
across the 28 leagues of the SportsDataverse team index
([`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md)),
built on ‘ggpath’. It shares its team index, logo archive and argument
names with the Python package sdvplot and the JavaScript packages
`@sportsdataverse/sdvplot` and `@sportsdataverse/sdvtables`.

### Teams and identifiers

- [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  turns team identifiers from any of 18 id systems (ESPN, nflverse, MLB
  Stats, nba_api, NHL, HockeyTech, CFBD, NCAA, PFF, Sports Reference,
  FanGraphs, names, …) into canonical team ids, using `season` for codes
  reused across eras;
  [`sdv_suggest()`](https://sdvplotR.sportsdataverse.org/reference/sdv_suggest.md)
  proposes candidates for a value that does not resolve. The helpers
  that take a team take `league` and `id_system`. Those that draw team
  marks or colours also take `season` (the `geom_sdv_*` layers read it
  as an aesthetic or a constant). `strict` (raise instead of warn when a
  value does not resolve) is taken by
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md),
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md),
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  [`sdv_color_palette()`](https://sdvplotR.sportsdataverse.org/reference/sdv_color_palette.md),
  [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  and the logo, wordmark, label and colour-bar helpers
  ([`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
  [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md),
  [`add_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
  [`add_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
  [`addSdvLogoMarkers()`](https://sdvplotR.sportsdataverse.org/reference/addSdvLogoMarkers.md),
  [`sdv_axis_logos()`](https://sdvplotR.sportsdataverse.org/reference/sdv_axis_logos.md)
  and the `gt_sdv_*` and `reactable_sdv_*` helpers that draw them), but
  not by
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md),
  [`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md),
  [`element_sdv_wordmark()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md),
  [`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md),
  [`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md),
  [`sdv_colorway()`](https://sdvplotR.sportsdataverse.org/reference/sdv_colorway.md)
  or
  [`sdv_team_factor()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_factor.md).
  Headshot helpers take no `season`;
  [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md),
  [`scale_colour_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md),
  [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  and
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  take neither `season` nor `id_system`;
  [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  takes `league` and `season` but no `id_system`.
- [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md),
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md),
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  [`sdv_color_palette()`](https://sdvplotR.sportsdataverse.org/reference/sdv_color_palette.md)
  and
  [`sdv_team_factor()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_factor.md)
  list and colour teams.
- The team index and the logo manifest are read from the SportsDataverse
  CDN and cached for a day
  ([`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md),
  [`sdv_clear_cache()`](https://sdvplotR.sportsdataverse.org/reference/sdv_clear_cache.md));
  a copy is bundled for offline use
  (`options(sdvplotR.offline = TRUE)`).

### Logos, wordmarks and headshots

- [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)
  and
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  choose a team’s archived mark by variant (`"default"`, `"dark"`, or a
  named variant) and season.
- [`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md)
  and the headshot helpers read ESPN athlete ids in every league by
  default; `id_system = "gsis"` reads nflverse NFL ids and
  `id_system = "league"` the league’s own player ids.

### Interactive plots and maps

- plotly:
  [`add_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
  [`add_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
  [`add_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/add_sdv_logos.md),
  [`sdv_axis_logos()`](https://sdvplotR.sportsdataverse.org/reference/sdv_axis_logos.md)
  and
  [`sdv_colorway()`](https://sdvplotR.sportsdataverse.org/reference/sdv_colorway.md).
- ggiraph:
  [`geom_sdv_logos_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos_interactive.md),
  [`geom_sdv_wordmarks_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos_interactive.md)
  and
  [`geom_sdv_headshots_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos_interactive.md),
  which embed images at most `max_px`
  160. pixels a side, so 32 logos add about half a megabyte to the page.
- leaflet:
  [`addSdvLogoMarkers()`](https://sdvplotR.sportsdataverse.org/reference/addSdvLogoMarkers.md).

### Plots, surfaces and tables

- [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
  [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md)
  and
  [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
  draw images at x / y positions;
  [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
  takes a `season` aesthetic, so a team is drawn with the mark it wore
  that season.
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
  Both draw a copy of each image at most four times its drawn size
  (sharp in a 300 dpi export, and a few KB a logo in an SVG or ggiraph
  widget). All of them work after a complete theme such as
  [`theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
  on ‘ggplot2’ 4, which sdvplotR requires.
- [`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md)
  and
  [`reactable_sdv_theme()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_theme.md)
  apply any of 122 surveyed table styles, named for their source
  (`"datagolf"`, `"wikipedia"`, `"nejm"`, …);
  [`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md)
  lists them and
  [`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md)
  resolves one. The registry is shared with sdvplot and sdvtables.
  Twenty shortcuts such as
  [`gt_theme_datagolf()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_datagolf.md)
  and
  [`gt_theme_wikipedia()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_wikipedia.md)
  name the most useful.
- [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  and
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  map teams to their primary or secondary colours.
- Conference rows (the college conferences, and the AFC, NFC and NFL)
  have logos and colours: `sdv_teams(include_conferences = TRUE)` lists
  them and the image helpers draw them from their short keys (`"SEC"`,
  `"Big Ten"`, `"Pac-12"`) or their other names
  (`"Southeastern Conference"`, `"B1G"`). A team’s code wins over a
  conference’s: cfb’s `"MAC"` is Macalester.
- [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  builds tier charts, with dark marks on its dark theme
  (`variant = "auto"`) and a `theme = "light"` option;
  [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  with
  [`theme_title_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  places a logo next to a plot title.
- [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  draws a court, field, rink, pitch or sheet through ‘sportyR’ for 59
  surface keys (the table sdvplot-js uses; sdvplot, the Python package,
  is moving to it), as a ggplot to plot data on: every sport ‘sportyR’
  draws (basketball, football, baseball, softball, hockey, soccer,
  lacrosse, tennis, volleyball, curling) and its leagues, from the NFL
  to NFHS, Little League, the ATP and the WCF. Leagues without a surface
  of their own use their sport’s (the WHL, for one, uses the NHL rink);
  the PWHL draws its own rink. Given a team, a few features take its
  colours, and `center_logo = TRUE` puts its logo at the center; on a
  baseball or softball field, whose origin is home plate, it goes in
  shallow center field instead, midway between second base and the
  center-field fence and 0.15 x the center-field distance across (it
  used to warn and draw no logo). These are stylized surfaces built from
  team colours, not the teams’ real floor, field or rink designs. Keys
  that are not team leagues (`"fiba"`, `"atp"`, `"nll"`, `"epl"`, …)
  take no `team`. `"ncaa_softball"` is both a team league and a surface.
- [`sdv_court_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_court_coords.md)
  converts stats.nba.com / stats.wnba.com legacy shot locations
  (`x_legacy`/`y_legacy`, or `LOC_X`/`LOC_Y` from the
  `Shot_Chart_Detail` element of
  [`hoopR::nba_shotchartdetail()`](https://hoopR.sportsdataverse.org/reference/nba_shotchartdetail.html))
  into the `sportyR::geom_basketball("nba")` court frame; the converted
  points also fit sportyR’s `"wnba"` and `"ncaa"` courts.
  `sdv_court_coords(provider = "euroleague")` converts the Euroleague
  shot frame of hoopR’s `euroleague_game_points()` (`coord_x`/`coord_y`:
  integer centimeters, hoop at the origin, both teams on one basket,
  free throws as `-1,-1`) onto the FIBA court `sdv_surface("fiba")`
  draws, in meters, with the `-1,-1` free throws as `NA`.
- [`sdv_pitch_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_pitch_coords.md)
  converts soccer event coordinates from Opta / Stats Perform, Wyscout,
  StatsBomb, UEFA, Impect, ESPN and the tracking providers (Tracab,
  SkillCorner, Second Spectrum, Metrica) to one regulation 105 x 68 m
  frame, piecewise-linearly between pitch landmarks.
- [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
  [`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
  [`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
  [`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)
  and
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  render images and team-coloured text inside ‘gt’ tables.
  `gt_sdv_logos(include_name = TRUE)` keeps the cell’s text after the
  logo.
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  keeps its text readable: a primary colour under 4.5:1 contrast against
  the cell background gives way to the secondary colour, or is darkened
  until it passes.
- [`reactable_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_cols_label.md),
  [`reactable_sdv_team_color_bar()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  and
  [`reactable_sdv_team_color_bg()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  do the same for ‘reactable’ tables; a logo or wordmark swaps to the
  default image in the browser if a variant fails to load.
- [`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
  is the SportsDataverse house table theme, in light and
  `style = "dark"`, and
  [`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
  dresses a table in one team’s colours from
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  picking title text and line colours by contrast.
- The ‘gtUtils’ table toolkit by Andrew Weatherman ships in sdvplotR: 18
  `gt_theme_*()` table themes plus
  [`gt_theme_preview()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_preview.md),
  continuous and discrete colour legends,
  [`gt_cutline()`](https://sdvplotR.sportsdataverse.org/reference/gt_cutline.md),
  [`gt_significance()`](https://sdvplotR.sportsdataverse.org/reference/gt_significance.md),
  [`gt_outliers()`](https://sdvplotR.sportsdataverse.org/reference/gt_outliers.md),
  colour pills / ranks / results, percentile bars, border bars,
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
  on the website under “Tables cookbook”.
- Every `gt_theme_*()` keeps its own row colours on a Bootstrap page
  (pkgdown, Quarto) in either colour mode.
  [`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md),
  [`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md),
  [`gt_fmt_tally()`](https://sdvplotR.sportsdataverse.org/reference/gt_fmt_tally.md),
  [`gt_significance()`](https://sdvplotR.sportsdataverse.org/reference/gt_significance.md)
  and
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  decorate each cell from its own row when row groups reorder the table.
  [`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
  and
  [`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
  scroll inside their own box when they are wider than the screen.
- [`gt_spotlight()`](https://sdvplotR.sportsdataverse.org/reference/gt_spotlight.md)
  dims the other rows to a readable tone: with `dim_color = "auto"` it
  blends the table’s text toward its background until it sits just above
  4.5:1 contrast.
  [`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
  gives each image its own alt text, and takes an `alt` argument for
  your own text.
- Saving a table to an image
  ([`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md),
  [`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md),
  [`gt_save_batch()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_batch.md),
  [`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md),
  [`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md))
  gives headless Chrome 60 seconds to start; a longer
  `options(chromote.timeout = )` of your own is kept.
  [`gt_save_batch()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_batch.md)
  needs an explicit `dir`.
- Every example runs: examples that only build tables run as plain
  examples, and those that save images through a headless Chrome are
  `\donttest{}` blocks that run in an interactive session with
  `webshot2` and Chrome available. The reference examples use real
  SportsDataverse data: `sdv_example_standings` holds the final 2025 NFL
  and 2025-26 NBA regular-season standings, built by
  `data-raw/sdv_examples.R` from the nflreadr / nflseedR and hoopR
  release loaders.
- The package ships no vignettes. Every article, “Getting Started”
  included, is on the pkgdown site
  (<https://sdvplotR.sportsdataverse.org/articles/>), among them
  “SportsDataverse Table Themes”, “Team Tables with the gt Toolkit” and
  a “Recipes” group that rebuilds SportsDataverse web visuals as static
  tables and plots on real data.

## sdvplotR 0.1.0

Development version number of the builds published on r-universe before
the first CRAN release; never released to CRAN or tagged. Its changes
are described under 0.3.0.
