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
* `sdv_court_coords()` converts stats.nba.com / stats.wnba.com legacy shot
  locations (`x_legacy`/`y_legacy`, or `LOC_X`/`LOC_Y` from the
  `Shot_Chart_Detail` element of `hoopR::nba_shotchartdetail()`) into the
  `sportyR::geom_basketball("nba")` court frame; the converted points also
  fit sportyR's `"wnba"` and `"ncaa"` courts.
* The 'gtUtils' table toolkit by Andrew Weatherman ships in sdvplotR: 18
  `gt_theme_*()` table themes plus `gt_theme_preview()`, continuous and
  discrete color legends, `gt_cutline()`, `gt_significance()`,
  `gt_outliers()`, color pills / ranks / results, percentile bars, border
  bars, `gt_grid()`, `gt_snake()` and `gt_stack_tables()` layouts,
  `gt_save_crop()`, `gt_save_batch()` and `gt_social_crop()`, and the
  `theme_bg` background lookup. The eight gtUtils articles are on the
  website as "gt Table Cookbooks".
* `gt_color_pills()`, `gt_percentile_bar()`, `gt_fmt_tally()`,
  `gt_significance()` and `gt_merge_stack_team_color()` decorate each cell
  from its own row when row groups reorder the table. gt hands
  `text_transform()` the cells in display order, so values computed in data
  order landed on the wrong rows: pill colors that didn't match their numbers,
  bars, tallies and stacked names from other rows, and significance stars on
  the wrong estimates. They now go through `gt::fmt()`, which gt applies in
  data order (stars, which follow the formatted estimate, take one
  `text_transform()` per distinct mark). `gt_merge_stack_team_color()` also
  escapes the lower line's text.
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
  blocks that run in an interactive session with `webshot2` and Chrome
  available (checks skip them). `gt_save_batch()`
  now needs an explicit `dir` rather than writing to the working directory.
* The reference examples run on real SportsDataverse data instead of the
  gtUtils demo tables (`mtcars`, `iris`, `airquality`) and made-up frames:
  `sdv_example_standings` holds the final 2025 NFL and 2025-26 NBA
  regular-season standings (records, points, conference ranks, playoff wins,
  the previous season's wins, ESPN ids), built by
  `data-raw/sdv_examples.R` from the nflreadr / nflseedR and hoopR release
  loaders.
* The package ships no vignettes. Every article, "Getting Started" included,
  is on the pkgdown site only (<https://sdvplotR.sportsdataverse.org/articles/>),
  at the same address as before; knitr and rmarkdown are no longer suggested.
* NFL player headshots work again. GSIS ids (`"00-0033873"`) resolve through a
  headshot map read at run time, the way nflplotR reads its own: sdvplotR
  builds it from nflverse rosters back to 1999 and publishes it, with a player
  id crosswalk (GSIS, ESPN, PFR, PFF, Sportradar, Sleeper, ...), to the
  `sdvplotr_infrastructure` release, refreshed weekly. Each id resolves to the
  player's NFL.com image, or ESPN's where NFL.com has none. They previously
  pointed at a URL built from the GSIS digits that returned 404 for every
  player, in the geom, the gt and reactable helpers, and the headshot axis
  scales. `sdvplotR_clear_cache()` now also clears the memoised map.
* Every headshot helper takes `id_type`, so player IDs from sources other than
  ESPN draw the right player. `"league"` reads the league's own ID from its
  image CDN: NBA Stats and WNBA Stats `PERSON_ID` (hoopR's `nba_*()`, wehoop's
  `wnba_*()`), MLBAM (baseballr, Baseball Savant) and NHL API player IDs
  (fastRhockey's `nhl_*()` and `load_nhl_*()`). `"espn"` reads ESPN
  athlete IDs in any sport, including the NFL. By default, IDs are read as
  before: GSIS for the NFL, ESPN elsewhere. The ID systems overlap: without
  `id_type`, Dirk Nowitzki's NBA Stats ID drew ESPN's Jared Jeffries.
* `clean_team_abbrs()` resolves the MLB Stats API's `"AZ"` (baseballr, Baseball
  Savant) and FanGraphs' `"WSN"`, so Arizona's and Washington's logos draw from
  that data.
* `scale_color_sdv()` and `scale_fill_sdv()` color every key the rest of the
  package accepts (provider aliases such as `"AZ"` or `"GSW"`, full names,
  historical abbreviations), not only canonical abbreviations, which drew
  grey.
* `theme_x_sdv()` and `theme_y_sdv()` work after a complete theme such as
  `theme_minimal()` on 'ggplot2' 4, which sets the position-specific axis text
  elements itself; axis logos drew as raw HTML there.
* `clean_team_abbrs()` matches team names regardless of accents, which
  providers write inconsistently: the NHL API's "Montréal Canadiens" now
  resolves, as does an unaccented "San Jose State" against ESPN's
  "San José State".
* Conference logos, which cbbplotR drew and sdvplotR lacked: every college
  conference ESPN has a logo for resolves like a team, so the geoms, theme
  elements, gt, reactable and color scales draw `"SEC"`, `"Big Ten"` or
  `"A-10"` with no new functions, and `"AFC"`, `"NFC"` and `"NFL"` do too, as
  in nflplotR. Conference colors come from cbbplotR. `team_reference()`,
  `valid_team_names()` and `sdv_team_colors()` list them only with
  `include_conferences = TRUE` (nflplotR lists AFC / NFC / NFL by default), so
  code that loops over teams still sees only teams; `team_reference()` gains a
  `type` column (`"team"`, `"conference"`, `"league"`). Team rows'
  `conference` changes in three places: ESPN's API labels the MAAC as the old
  "Metro Conference", so its teams read `"Metro"` and now read `"MAAC"`; the
  AAC reads `"AAC"` instead of `"American"` (American University's name), and
  football's SoCon reads `"SoCon"` instead of `"Southern"` (Southern
  University's).
* A conference's former names resolve to its logo: `"Pac-10"`, `"Pac-8"` and
  `"AAWU"` draw the Pac-12, `"Mid-Continent Conference"` the Summit League,
  `"Midwestern Collegiate Conference"` the Horizon League, `"Gateway"` the
  MVFC and `"Colonial League"` the Patriot League. The names come from the
  sportsdataverse-data `cfb_groups`, `mbb_groups` and `wbb_groups` releases,
  which follow each conference through its renames. A name two conferences
  have used (`"South"`, football's `"Western"`), or one a team already goes by
  (South Alabama's `"USA"`), is left out, and conferences sdvplotR has no logo
  for (football's Big West and Big East) resolve to nothing, as before.
* The WAC, which ESPN no longer draws (football's WAC ended after 2022, and
  ESPN labels the basketball WAC with the name it took for 2026-27, the
  United Athletic Conference), is a conference row in all three college
  sports with ESPN's archived WAC mark, so `"WAC"`, `"Western Athletic
  Conference"` and football's `"Western Athletic"` draw it. `"UAC"` and
  `"United Athletic Conference"` stay unmatched: the WAC mark stands for the
  seasons through 2025-26 only.
* `clean_team_abbrs()` and every helper built on it take the school names
  NCAA.com / stats.ncaa.org, KenPom and Bart Torvik use for college teams
  (`"Iowa St."`, `"St. John's (NY)"`, `"Saint Mary's (CA)"`, `"Miami (OH)"`),
  from sportsdataverse-py's NCAA / ESPN crosswalks and hoopR's team crosswalk,
  so their tables plot without a lookup table. ESPN's own names still win
  wherever they overlap.
* Sports Reference's college names resolve too: its whole 2025-26 Division I
  list, men's and women's (`"Brigham Young"`, `"Virginia Commonwealth"`,
  `"Loyola (IL)"`), and the same schools' football teams. The headshot docs
  name the hoopR, wehoop and cfbfastR roster functions that return ESPN
  athlete ids (what cbbplotR's `get_espn_players()` fetched).
* `clean_team_abbrs()` folds typographic dashes and curly apostrophes, so
  Sports Reference's UNLV (`"Nevada-Las Vegas"` with an en dash) and a curly
  `"Saint Mary's"` resolve.
* `gt_sdv_logos(include_name = TRUE)` keeps the cell's text after the logo,
  the logo-and-name cell cbbplotR's `gt_cbb_teams()` built, for any sport.
  `gt_sdv_logos()` and `gt_sdv_wordmarks()` also resolve names with an
  ampersand ("Texas A&M", "William & Mary"): gt passes them HTML-escaped, so
  they used to fall back to text.
* The college basketball articles (tier list, border bars, grid tables,
  window wins) no longer use cbbdata or cbbplotR: their data comes from
  hoopR, the NCAA's NET page and Sports Reference, and their logos from
  sdvplotR.
* College team data covers every Division I program. ESPN's teams list leaves
  some out (Lindenwood, Queens, Southern Indiana, Mercyhurst, Saint Francis,
  UT Rio Grande Valley football), so they drew no logo; they are now fetched
  one by one. Programs that just left a division stay available for the season
  they played. ESPN box scores' `"BUT"` (Butler) and `"UNO"` (New Orleans) and
  ESPN FPI's `"BUFF"` (Buffalo) and `"AFA"` (Air Force) resolve.
* `sdv_team_tiers()` builds tier charts, and `ggtitle_image()` places a logo
  next to a plot title.
* `sdv_surface()` draws a court, field or rink for any of the eight leagues
  through 'sportyR' (now in Suggests), as a ggplot to plot data on. Given a
  team, a few features take its colors (basketball paint and apron, football
  end zones, hockey center line, center circle and boards; a baseball infield
  keeps its own), and `center_logo = TRUE` puts its logo at center court,
  center ice or midfield. These are stylized surfaces built from team colors,
  not the teams' real floor, field or rink designs.
* `valid_team_names()`, `team_reference()` and `supported_sports()` expose
  the reference data.
* `geom_sdv_logos()` takes a `season` aesthetic and `gt_sdv_logos()` a
  `season` argument (one season for the whole table): a team is drawn with the
  mark it wore that season. The NHL has every club identity's primary and dark
  marks since 1917-18, from the NHL's logo catalog, keyed by the identity's
  triCode (`"QUE"`, `"HFD"`, `"ATL"`, `"TBL"`, and `"TB"` for the current
  club); the NFL and WNBA have their relocated and defunct identities (the St.
  Louis Rams, San Diego Chargers, Houston Comets, Sacramento Monarchs,
  Charlotte Sting, Detroit and Tulsa Shock, San Antonio Silver Stars and
  Stars). Other teams and seasons keep today's logo. The images are
  content-addressed copies in the SportsDataverse asset archive, so they
  don't change when ESPN reuses a file name; the NHL's are SVG files, read
  with the 'rsvg' package (now in Suggests).
* A "Visual recipes" article group rebuilds SportsDataverse web visuals as
  static tables and plots on real data. "Neighbour Ranks" shows one college
  football team with the five teams ranked above and below it on three
  metrics, from `cfbfastR::load_espn_cfb_team_summaries()`. "Shot Grid"
  colors one NBA player's half court, in 3 ft squares, by his field goal
  percentage minus the league's from the same square, from
  `hoopR::load_nba_shots()`, with the court drawn in plain 'ggplot2'.
  "Rolling Form" lists the college football teams whose last 150 offensive
  plays rose or fell most against the 150 before, from the
  `cfb_rolling_windows` release, with `gt_delta()` and `gt_percentile_bar()`.
  "Signature Ribbon" draws one NBA shooter's attempts by shot distance as a
  ribbon whose thickness is his share of attempts and whose fill is his field
  goal percentage minus the league's, from the `nba_stats_metric_curves`
  release.
* Every `gt_theme_*()` keeps its own row colors on a Bootstrap page (pkgdown,
  Quarto) in either color mode. Before, the page's table variables painted
  the cells, so a light theme was unreadable on a dark page and a dark theme
  on a light one.
* `gt_grid()` and `gt_stack_tables()` request Google fonts by discrete
  weights. The `wght@100..900` range they asked for is rejected for most
  families, so the font silently never loaded.
* `element_sdv_logo()`, `element_sdv_wordmark()` and `element_sdv_headshot()`
  set on `axis.text.x` / `axis.text.y` draw after `theme_minimal()` on
  'ggplot2' 4. That theme sets `axis.text.x.bottom` / `axis.text.y.left`
  itself, and the plain child shadowed the image element, inheriting its
  `colour = NA` and `size = 0.5`: the axis drew no labels at all. The elements
  are now subclasses of `ggpath::element_path()`, which ggplot2 lets replace a
  plain child (keeping the child's spacing). sdvplotR now imports 'S7' and
  requires 'ggplot2' 4.0.0, which 'ggpath' 1.1.0 already did.
* `resolve_historical_abbr()` returns the package's canonical keys, the ones
  `clean_team_abbrs()` returns: `"STL"` gives the Rams' `"LA"` (was `"LAR"`),
  `"NOH"` / `"NOK"` the Pelicans' `"NO"` (was `"NOP"`) and `"WSB"` the
  Wizards' `"WSH"` (was `"WAS"`).
* A relocation key follows the franchise in both `clean_team_abbrs()` and
  `resolve_historical_abbr()`, even where a provider alias used the same code:
  `"WIN"` is the original Winnipeg Jets (1979-96) and gives `"UTAH"`;
  `clean_team_abbrs()` returned today's Jets (`"WPG"`).
* `ggtitle_image()` with `theme_title_image()` centers the image on the title
  text. 'gridtext' draws an inline image on the text baseline and ignores CSS
  `vertical-align`, so a logo taller than the text rose above the title. Style
  the title through `theme_title_image(...)` (`size`, `face`, `hjust`): a later
  `theme(plot.title = ggtext::element_markdown(...))`, which the old example
  used, replaces the centering element and the image drops to the baseline.
* `sdv_team_tiers()` takes `theme = "light"`, a white background with dark
  labels and lines, for dark logos (Toronto, Iowa, West Virginia) that nearly
  vanish on the default dark theme. 'sdvplot' (Python) has the same option.
* `gt_merge_stack_team_color()` keeps the team-colored text readable: a
  primary color under 4.5:1 contrast against the cell background gives way to
  the secondary color, or is darkened until it passes, so Missouri's gold no
  longer vanishes on a white table and stays gold on `gt_theme_midnight()`.
  The new `background` argument defaults to the table's own background color
  (white when unset); a theme applied after this function isn't seen.
* `gt_tiers()` gives each image its own alt text, so a screen reader can tell
  the entries apart (they all read "Tier list entry"). A logo or wordmark from
  `team_reference()`, or a season logo, takes the team's name; any other image
  its file name. The new `alt` argument takes a function of the image URLs for
  your own text.
