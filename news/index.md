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
- [`sdv_court_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_court_coords.md)
  converts stats.nba.com / stats.wnba.com legacy shot locations
  (`x_legacy`/`y_legacy`, or `LOC_X`/`LOC_Y` from the
  `Shot_Chart_Detail` element of
  [`hoopR::nba_shotchartdetail()`](https://hoopR.sportsdataverse.org/reference/nba_shotchartdetail.html))
  into the `sportyR::geom_basketball("nba")` court frame; the converted
  points also fit sportyR’s `"wnba"` and `"ncaa"` courts.
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
- [`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md),
  [`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md),
  [`gt_fmt_tally()`](https://sdvplotR.sportsdataverse.org/reference/gt_fmt_tally.md),
  [`gt_significance()`](https://sdvplotR.sportsdataverse.org/reference/gt_significance.md)
  and
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  decorate each cell from its own row when row groups reorder the table.
  gt hands
  [`text_transform()`](https://gt.rstudio.com/reference/text_transform.html)
  the cells in display order, so values computed in data order landed on
  the wrong rows: pill colors that didn’t match their numbers, bars,
  tallies and stacked names from other rows, and significance stars on
  the wrong estimates. They now go through
  [`gt::fmt()`](https://gt.rstudio.com/reference/fmt.html), which gt
  applies in data order (stars, which follow the formatted estimate,
  take one
  [`text_transform()`](https://gt.rstudio.com/reference/text_transform.html)
  per distinct mark).
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  also escapes the lower line’s text.
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
  (hoopR’s `nba_*()`, wehoop’s `wnba_*()`), MLBAM (baseballr, Baseball
  Savant) and NHL API player IDs (fastRhockey’s `nhl_*()` and
  `load_nhl_*()`). `"espn"` reads ESPN athlete IDs in any sport,
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
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  matches team names regardless of accents, which providers write
  inconsistently: the NHL API’s “Montréal Canadiens” now resolves, as
  does an unaccented “San Jose State” against ESPN’s “San José State”.
- Conference logos, which cbbplotR drew and sdvplotR lacked: every
  college conference ESPN has a logo for resolves like a team, so the
  geoms, theme elements, gt, reactable and color scales draw `"SEC"`,
  `"Big Ten"` or `"A-10"` with no new functions, and `"AFC"`, `"NFC"`
  and `"NFL"` do too, as in nflplotR. Conference colors come from
  cbbplotR.
  [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md),
  [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md)
  and
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
  list them only with `include_conferences = TRUE` (nflplotR lists AFC /
  NFC / NFL by default), so code that loops over teams still sees only
  teams;
  [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
  gains a `type` column (`"team"`, `"conference"`, `"league"`). Team
  rows’ `conference` changes in three places: ESPN’s API labels the MAAC
  as the old “Metro Conference”, so its teams read `"Metro"` and now
  read `"MAAC"`; the AAC reads `"AAC"` instead of `"American"` (American
  University’s name), and football’s SoCon reads `"SoCon"` instead of
  `"Southern"` (Southern University’s).
- A conference’s former names resolve to its logo: `"Pac-10"`, `"Pac-8"`
  and `"AAWU"` draw the Pac-12, `"Mid-Continent Conference"` the Summit
  League, `"Midwestern Collegiate Conference"` the Horizon League,
  `"Gateway"` the MVFC and `"Colonial League"` the Patriot League. The
  names come from the sportsdataverse-data `cfb_groups`, `mbb_groups`
  and `wbb_groups` releases, which follow each conference through its
  renames. A name two conferences have used (`"South"`, football’s
  `"Western"`), or one a team already goes by (South Alabama’s `"USA"`),
  is left out, and conferences sdvplotR has no logo for (football’s Big
  West and Big East) resolve to nothing, as before.
- The WAC, which ESPN no longer draws (football’s WAC ended after 2022,
  and ESPN labels the basketball WAC with the name it took for 2026-27,
  the United Athletic Conference), is a conference row in all three
  college sports with ESPN’s archived WAC mark, so `"WAC"`,
  `"Western Athletic Conference"` and football’s `"Western Athletic"`
  draw it. `"UAC"` and `"United Athletic Conference"` stay unmatched:
  the WAC mark stands for the seasons through 2025-26 only.
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  and every helper built on it take the school names NCAA.com /
  stats.ncaa.org, KenPom and Bart Torvik use for college teams
  (`"Iowa St."`, `"St. John's (NY)"`, `"Saint Mary's (CA)"`,
  `"Miami (OH)"`), from sportsdataverse-py’s NCAA / ESPN crosswalks and
  hoopR’s team crosswalk, so their tables plot without a lookup table.
  ESPN’s own names still win wherever they overlap.
- Sports Reference’s college names resolve too: its whole 2025-26
  Division I list, men’s and women’s (`"Brigham Young"`,
  `"Virginia Commonwealth"`, `"Loyola (IL)"`), and the same schools’
  football teams. The headshot docs name the hoopR, wehoop and cfbfastR
  roster functions that return ESPN athlete ids (what cbbplotR’s
  `get_espn_players()` fetched).
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  folds typographic dashes and curly apostrophes, so Sports Reference’s
  UNLV (`"Nevada-Las Vegas"` with an en dash) and a curly
  `"Saint Mary's"` resolve.
- `gt_sdv_logos(include_name = TRUE)` keeps the cell’s text after the
  logo, the logo-and-name cell cbbplotR’s `gt_cbb_teams()` built, for
  any sport.
  [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
  and
  [`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md)
  also resolve names with an ampersand (“Texas A&M”, “William & Mary”):
  gt passes them HTML-escaped, so they used to fall back to text.
- The college basketball articles (tier list, border bars, grid tables,
  window wins) no longer use cbbdata or cbbplotR: their data comes from
  hoopR, the NCAA’s NET page and Sports Reference, and their logos from
  sdvplotR.
- College team data covers every Division I program. ESPN’s teams list
  leaves some out (Lindenwood, Queens, Southern Indiana, Mercyhurst,
  Saint Francis, UT Rio Grande Valley football), so they drew no logo;
  they are now fetched one by one. Programs that just left a division
  stay available for the season they played. ESPN box scores’ `"BUT"`
  (Butler) and `"UNO"` (New Orleans) and ESPN FPI’s `"BUFF"` (Buffalo)
  and `"AFA"` (Air Force) resolve.
- [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  builds tier charts, and
  [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  places a logo next to a plot title.
- [`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
  draws a court, field or rink for any of the eight leagues through
  ‘sportyR’ (now in Suggests), as a ggplot to plot data on. Given a
  team, a few features take its colors (basketball paint and apron,
  football end zones, hockey center line, center circle and boards; a
  baseball infield keeps its own), and `center_logo = TRUE` puts its
  logo at center court, center ice or midfield. These are stylized
  surfaces built from team colors, not the teams’ real floor, field or
  rink designs.
- [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md),
  [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
  and
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md)
  expose the reference data.
- [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
  takes a `season` aesthetic and
  [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
  a `season` argument (one season for the whole table): a team is drawn
  with the mark it wore that season. The NHL has every club identity’s
  primary and dark marks since 1917-18, from the NHL’s logo catalog,
  keyed by the identity’s triCode (`"QUE"`, `"HFD"`, `"ATL"`, `"TBL"`,
  and `"TB"` for the current club); the NFL and WNBA have their
  relocated and defunct identities (the St. Louis Rams, San Diego
  Chargers, Houston Comets, Sacramento Monarchs, Charlotte Sting,
  Detroit and Tulsa Shock, San Antonio Silver Stars and Stars). Other
  teams and seasons keep today’s logo. The images are content-addressed
  copies in the SportsDataverse asset archive, so they don’t change when
  ESPN reuses a file name; the NHL’s are SVG files, read with the ‘rsvg’
  package (now in Suggests).
- A “Visual recipes” article group rebuilds SportsDataverse web visuals
  as static tables and plots on real data. “Neighbour Ranks” shows one
  college football team with the five teams ranked above and below it on
  three metrics, from
  [`cfbfastR::load_espn_cfb_team_summaries()`](https://cfbfastR.sportsdataverse.org/reference/load_espn_cfb_team_summaries.html).
  “Shot Grid” colors one NBA player’s half court, in 3 ft squares, by
  his field goal percentage minus the league’s from the same square,
  from
  [`hoopR::load_nba_shots()`](https://hoopR.sportsdataverse.org/reference/load_nba_pbp.html),
  with the court drawn in plain ‘ggplot2’. “Rolling Form” lists the
  college football teams whose last 150 offensive plays rose or fell
  most against the 150 before, from the `cfb_rolling_windows` release,
  with
  [`gt_delta()`](https://sdvplotR.sportsdataverse.org/reference/gt_delta.md)
  and
  [`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md).
