# Percentile Bars and Cut Lines

On this page

A table of numbers tells you the values. It does not tell you which ones
stand out, where the line falls between one group and the next, or how
far a row has moved. Three functions handle those jobs, and this article
builds one table with each:

1.  **Percentile bars**: the 2025 NFL season’s busiest quarterbacks,
    each one’s EPA per dropback and completion percentage over expected
    drawn against every qualified passer with
    [`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md).
2.  **Cut lines**: the NBA’s 2025-26 Western Conference standings, with
    [`gt_cutline()`](https://sdvplotR.sportsdataverse.org/reference/gt_cutline.md)
    marking where the playoff seeds end and where the play-in ends.
3.  **Rank changes**: the final 2025 college football AP Top 25 with
    each team’s move since the preseason poll, computed and colored by
    [`gt_delta()`](https://sdvplotR.sportsdataverse.org/reference/gt_delta.md).

The quarterbacks come from nflverse’s player stats via
[`nflreadr`](https://nflreadr.nflverse.com), the standings from ESPN via
[`hoopR`](https://hoopR.sportsdataverse.org) and the polls from
CollegeFootballData.com via
[`cfbfastR`](https://cfbfastR.sportsdataverse.org) (which needs a free
API key). The three functions come from Andrew Weatherman’s
[gtUtils](https://github.com/andreweatherman/gtUtils), and the first two
sections follow his delay-table example.

``` r

library(sdvplotR)
library(gt)
library(gtExtras)
library(dplyr)
```

## 1. Percentile bars

We take every quarterback with at least 250 dropbacks (pass attempts
plus sacks) in the 2025 regular season and compute two rates: EPA per
dropback and completion percentage over expected (CPOE). Each gets a
percentile among all the qualified passers, so the fifteen busiest can
be read against the whole group, not just against each other.

``` r

qbs <- nflreadr::load_player_stats(2025, summary_level = "reg") |>
  filter(position == "QB") |>
  mutate(dropbacks = attempts + sacks_suffered, epa_db = passing_epa / dropbacks) |>
  filter(dropbacks >= 250) |>
  mutate(
    epa_ptile = cume_dist(epa_db),
    cpoe_ptile = cume_dist(passing_cpoe)
  ) |>
  arrange(desc(dropbacks), player_id) |>
  slice_head(n = 15) |>
  select(player_id, player_display_name, recent_team, dropbacks, epa_db, epa_ptile, passing_cpoe, cpoe_ptile)
```

[`cume_dist()`](https://dplyr.tidyverse.org/reference/percent_rank.html)
gives each value’s percentile, on a 0-1 scale, which matters in a
moment. Sorting on `player_id` after `dropbacks` breaks any tie the same
way on every rebuild.

[`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md)
turns each percentile column into a filled track with a numbered marker
at the tip.
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md)
turns the GSIS ids into NFL.com headshots and
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
the team abbreviations into logos.

``` r

qbs |>
  gt(id = "qb-bars") |>
  gt_theme_almanac() |>
  gt_sdv_headshots(player_id, sport = "nfl", height = 34) |>
  gt_sdv_logos(recent_team, sport = "nfl", height = 24) |>
  gt_percentile_bar(c(epa_ptile, cpoe_ptile), full_track = FALSE, width = 150) |>
  fmt_number(epa_db, decimals = 2, force_sign = TRUE) |>
  fmt_number(passing_cpoe, decimals = 1, force_sign = TRUE) |>
  tab_spanner(columns = c(epa_db, epa_ptile), "EPA per dropback") |>
  tab_spanner(columns = c(passing_cpoe, cpoe_ptile), "CPOE") |>
  cols_align(columns = -player_display_name, "center") |>
  gt_add_divider(dropbacks, color = "black", weight = px(1.5), include_labels = FALSE) |>
  cols_label(
    player_id = "", player_display_name = "Quarterback", recent_team = "",
    dropbacks = "Dropbacks", epa_db = "Value", epa_ptile = "Percentile",
    passing_cpoe = "Value", cpoe_ptile = "Percentile"
  ) |>
  tab_footnote(
    locations = cells_column_spanners(),
    footnote = "Percentile among every quarterback with at least 250 dropbacks in the 2025 regular season"
  ) |>
  tab_header(
    "The NFL's busiest passers, 2025",
    "The 15 quarterbacks with the most dropbacks, regular season"
  ) |>
  tab_source_note("Data: nflverse player stats via nflreadr")
```

[TABLE]

The percentile columns are stored on a 0-1 scale, but the markers read
as whole numbers out of 100. That is
[`gt_percentile_bar()`](https://sdvplotR.sportsdataverse.org/reference/gt_percentile_bar.md)’s
`scale` argument, which defaults to `"auto"`: a column whose values all
fall in `[0, 1]` is treated as a proportion and mapped onto the 0-100
axis, so a raw `0.71` prints as `71`. A column already on a 0-100 scale
is left alone, so the same code works either way. Set `scale = "none"`
to turn that off.

The other arguments cover the look:

- `domain`: the value range the bar spans, `c(0, 100)` by default.
- `palette`: colors mapped across the domain, used for both the fill and
  the marker. The default runs blue at the low end through grey to red
  at the high end.
- `full_track`: whether the unfilled track runs the full width or stops
  at the marker. We set it to `FALSE` so each bar ends at its own value.
- `width`, `marker_size`, `track_height`, `text_color`, `decimals`: the
  column width, the marker, the thickness of the track, the color of the
  number inside the marker, and its decimal places.
- `na_label`: what to show for a missing percentile. It defaults to an
  em dash and draws a broken track, so an empty row cannot be misread as
  a percentile of zero.

The whole bar is CSS, not an image, so it stays sharp at any export
size.

## 2. Cut lines

The second table asks where the lines fall in a standings table. In the
NBA, seeds 1-6 in each conference go straight to the playoffs, seeds
7-10 play in for the last two places, and the rest go to the lottery.
ESPN’s standings carry each team’s final seed, tiebreakers and the
play-in applied, so the 7 and 8 seeds are the two play-in winners and
the 8 seed can hold the better record.

``` r

nba_teams <- team_reference("nba")

west <- hoopR::espn_nba_standings(year = 2026) |>
  mutate(
    team_id = as.character(team_id),
    conference = nba_teams$conference[match(team_id, nba_teams$espn_team_id)],
    abbr = nba_teams$team_abbr[match(team_id, nba_teams$espn_team_id)]
  ) |>
  filter(conference == "Western") |>
  arrange(playoffseed) |>
  transmute(
    seed = playoffseed, team = abbr, wins, losses,
    pct = winpercent, diff = as.numeric(differential), last_ten = lasttengames
  )
```

[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
gives each ESPN team id its conference and abbreviation; ESPN’s
standings leave the conference out.

``` r

west |>
  gt(id = "west") |>
  gt_theme_almanac(accent = "#1D428A") |>
  gt_sdv_logos(team, sport = "nba", height = 24) |>
  gt_cutline(after = 0, "Playoffs", color = "#1D428A") |>
  gt_cutline(after = 6, "Play-in", color = "#C8102E", gap = c(12, 0)) |>
  gt_cutline(after = 10, "Lottery", color = "#5A5A5A", gap = c(12, 0)) |>
  opt_row_striping(FALSE) |>
  fmt(pct, fns = function(x) sub("^0", "", sprintf("%.3f", x))) |>
  fmt_number(diff, decimals = 1, force_sign = TRUE) |>
  cols_label(
    seed = "Seed", team = "", wins = "W", losses = "L", pct = "Pct",
    diff = "Diff", last_ten = "Last 10"
  ) |>
  cols_align(columns = everything(), "center") |>
  tab_style(locations = cells_body(), style = cell_text(size = px(14))) |>
  tab_header(
    "Western Conference standings, 2025-26",
    "Regular-season records; final seeds, after the play-in. Diff is the average scoring margin."
  ) |>
  gt_538_caption(
    "Seeds 1-6 reach the playoffs; seeds 7-10 meet in the play-in for the last two places.",
    "Data: ESPN standings via hoopR"
  )
```

| Western Conference standings, 2025-26 |  |  |  |  |  |  |
|----|----|----|----|----|----|----|
| Regular-season records; final seeds, after the play-in. Diff is the average scoring margin. |  |  |  |  |  |  |
| Seed¹ | ¹ | W¹ | L¹ | Pct¹ | Diff¹ | Last 10¹ |
| 1 | ![Oklahoma City Thunder](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/6b/6b4801ae99c7dac7240d3b6ab3fbd4249a371473fc06517384e891834164a76e.png) | 64 | 18 | .780 | +11.1 | 7-3 |
| 2 | ![San Antonio Spurs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/cc/cc3d33fa8faf34874258b10a8e0377d70b80c7900b4d90698f35edba9952fa1c.png) | 62 | 20 | .756 | +8.3 | 8-2 |
| 3 | ![Denver Nuggets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/33/33f295fabf1bc3ddb60dfcbefb35ab9a3a91c865752e4539778495aab27f535d.png) | 54 | 28 | .659 | +5.2 | 10-0 |
| 4 | ![Los Angeles Lakers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82fda3df51058c5aad8a52123868f43959017be0c39c886e9aefbb77e6c69c89.png) | 53 | 29 | .646 | +1.7 | 7-3 |
| 5 | ![Houston Rockets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/72/720e35c0d3b39af8d57ae66f00ae1058bd0f32b41fba1137f779af5bc439e011.png) | 52 | 30 | .634 | +5.2 | 9-1 |
| 6 | ![Minnesota Timberwolves](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ff/ff53859dd29fb795e2f9c0a7fbaf808548731526d3fbcbb2fdfb842224c36979.png) | 49 | 33 | .598 | +3.4 | 5-5 |
| 7 | ![Portland Trail Blazers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/63/635515bc924cef7432e9b362da558c41032daf6f4c41be2e1dc80a34360b6f18.png) | 42 | 40 | .512 | −0.3 | 7-3 |
| 8 | ![Phoenix Suns](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/5f/5f8932efdb7595069610b11ec2f417d78a9213691c2ba21e2bd491c172397ead.png) | 45 | 37 | .549 | +1.5 | 5-5 |
| 9 | ![LA Clippers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d4/d43253c0630f0d3d3a4c3c50ce92c9dbe8d5bf21e3bfd5326920c9487b26dbec.png) | 42 | 40 | .512 | +1.2 | 6-4 |
| 10 | ![Golden State Warriors](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b6/b623681ece167224ad4f51aef1ffa5a6f9e072af1cf1d6a6c158fd796e8d33ab.png) | 37 | 45 | .451 | −0.6 | 3-7 |
| 11 | ![New Orleans Pelicans](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2c/2c2bf09a59358e024c442d80f16707cd8b705863df9b6aa0ee478346561dc18a.png) | 26 | 56 | .317 | −4.5 | 1-9 |
| 12 | ![Dallas Mavericks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d0/d0d526f5400b7266883476071df0d24cdea0655a1641f0e5a2ea212e6c1b2b09.png) | 26 | 56 | .317 | −5.5 | 3-7 |
| 13 | ![Memphis Grizzlies](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/eb/eb3f14246f67bccd4d8dd44be2f431992115beac8837c4b1be51d098b0a388bd.png) | 25 | 57 | .305 | −6.0 | 1-9 |
| 14 | ![Sacramento Kings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/38/38728eaaf98d73d00363ee570601d64a4caa7fe2590fb0df5afb1b9129d6e20b.png) | 22 | 60 | .268 | −10.0 | 3-7 |
| 15 | ![Utah Jazz](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/eb/eb20ed36a17b49f65fa30627a2ab2aae5c6e3ee31ab9f03983c15c05270016e1.png) | 22 | 60 | .268 | −8.4 | 1-9 |
| ¹ Seeds 1-6 reach the playoffs; seeds 7-10 meet in the play-in for the last two places. |  |  |  |  |  |  |
| Data: ESPN standings via hoopR |  |  |  |  |  |  |

There are three cut lines, one per group. `gt_cutline(after = 6, ...)`
draws the rule between rows 6 and 7, where the playoff seeds give way to
the play-in, and `after = 10` does the same where the play-in ends. Each
label sits on its line, rendered in uppercase.

The first call, `gt_cutline(after = 0, ...)`, is the useful trick:
`after = 0` draws a line above the very first row, which labels the top
section the same way the others are labelled.

A few arguments shape the lines:

- `color`, `weight`, `style`: the color, thickness, and line style
  (`"dashed"`, `"solid"`, or `"dotted"`).
- `label`, `label_position`, `label_size`, `label_color`: the text on
  the line, whether it sits above or below, and how it looks.
- `gap`: extra space around the line, in pixels. A single number pads
  both sides; a length-2 vector `c(above, below)` sets them separately.
  Here `gap = c(12, 0)` opens room above each lower line without pushing
  the row below it down.

Note `cell_text(size = px(14))` on the body: the `gt_theme_*` functions
set their font sizes per cell, so `tab_options(table.font.size = ...)`
will not move them. Restyle the body cells directly instead.

Cut lines are positional, not data-driven.
[`gt::tab_row_group()`](https://gt.rstudio.com/reference/tab_row_group.html)
splits a table on a value in the data and adds heading rows; a cut line
leaves the table flowing and marks a fixed row number, which is what a
standings table wants.

## 3. Rank changes

The last table puts a final ranking next to where each team started. The
preseason AP poll is week 1 of the regular season in
CollegeFootballData.com’s rankings, and the final poll is the only poll
of the postseason.

``` r

ap_poll <- function(...) {
  cfbfastR::cfbd_rankings(year = 2025, ...) |>
    filter(poll == "AP Top 25") |>
    select(school, conference, rank)
}

preseason <- ap_poll(week = 1, season_type = "regular")
final <- ap_poll(season_type = "postseason")

moves <- final |>
  left_join(select(preseason, school, preseason = rank), by = "school") |>
  arrange(rank) |>
  select(rank, school, conference, preseason)
```

`gt_delta(from, to)` adds a column holding `to - from`, signed and
colored by direction. For a ranking, a lower number is better, so
passing the final rank as `from` and the preseason rank as `to` gives
the places a team climbed: positive when it rose. A team that was
unranked in the preseason has no starting rank, so its change is left
blank and its preseason cell reads `NR`.

``` r

moves |>
  gt(id = "ap-moves") |>
  gt_theme_almanac(accent = "#9E1B32") |>
  gt_sdv_logos(school, sport = "cfb", height = 22, include_name = TRUE) |>
  gt_delta(rank, preseason, column_label = "Places climbed", decimals = 0, arrows = TRUE) |>
  sub_missing(preseason, missing_text = "NR") |>
  cols_label(rank = "Final", school = "Team", conference = "Conference", preseason = "Preseason") |>
  cols_align(columns = -c(school, conference), "center") |>
  tab_style(locations = cells_body(), style = cell_text(size = px(14))) |>
  tab_header(
    "The final 2025 AP Top 25, and where each team started",
    "Final poll after the national championship, against the preseason poll"
  ) |>
  tab_source_note("Data: CollegeFootballData.com via cfbfastR")
```

| The final 2025 AP Top 25, and where each team started |  |  |  |  |
|----|----|----|----|----|
| Final poll after the national championship, against the preseason poll |  |  |  |  |
| Final | Team | Conference | Preseason | Places climbed |
| 1 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0d/0dfc3e06f6e158d96df2b9729de6b1cd6a5a5756ec365cd0b998aa6ecb45aa66.png)Indiana | Big Ten | 20 | ▲ 19 |
| 2 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/55/55800e4867c87bf38281043628d2c0dfadd0bf44632b27a9ab20af27a9a728fb.png)Miami | ACC | 10 | ▲ 8 |
| 3 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/61/61988dd6fb46c4c5dad612e7ef14eeee56b63ada3a0758b30ccf418213ecd826.png)Ole Miss | SEC | 21 | ▲ 18 |
| 4 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/57/57dca8a00b01bebcfb1e0c7ceafe0b046e175c47ec7225713b3930e7fcb7cd05.png)Oregon | Big Ten | 7 | ▲ 3 |
| 5 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/6d/6dbe512c1b9b4e8c0ebcfcb4b3620b6229a05619e8bf70b3051a8e6c4964240d.png)Ohio State | Big Ten | 3 | ▼ 2 |
| 6 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/fa/fa5c7fb14d5ffa38eaddfeb80161835e60a3d496b57db5e0ebda5e6475226d8a.png)Georgia | SEC | 5 | ▼ 1 |
| 7 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/be/be16f2f868f97ef01961fe3332252aa767be3a860438b9f0da054bf7205b66e4.png)Texas Tech | Big 12 | 23 | ▲ 16 |
| 8 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0d/0da7ac07d04adcd38707b88a4198e988b830ed49a0ab6c9378cfb4cfb980aa08.png)Texas A&M | SEC | 19 | ▲ 11 |
| 9 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bb/bb55649cd4257a7d13b58db3f6cc85af8672b43f6eb215b6e729c7916ba5e4b8.png)Alabama | SEC | 8 | ▼ 1 |
| 10 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/5c/5c0412f57d3fdf05789d255595ce014bbed36c6468f8ec3d8471450efe5f9f10.png)Notre Dame | FBS Independents | 6 | ▼ 4 |
| 11 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/4c/4c49b759151574b979556fb10f1e245ec8cb03b4b3b80d4d352b5f909293976d.png)BYU | Big 12 | NR |  |
| 12 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/12/12d69bb78c3443bdbcc5a7659f288840a7a3862d70043eda3d8868a229eb7696.png)Texas | SEC | 1 | ▼ 11 |
| 13 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/19/19f8f9a3254b9c85ffacf42de7b4d00e1186fbb0b55effdabe9c6d0a3f487ddf.png)Oklahoma | SEC | 18 | ▲ 5 |
| 14 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/54d1837e37240cb37dcbea2b2dfd518bdf8531344e5f5397ff02a1d2111b5b43.png)Utah | Big 12 | NR |  |
| 15 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/cd/cdb3df344d224cae8b03a9f23f6e15424267095644cc211e0e0278c6e53986c4.png)Vanderbilt | SEC | NR |  |
| 16 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d3/d35c8362ad7a6f03b32e30bc0745cb481da320da96010c7327f3c78359ac9fe5.png)Virginia | ACC | NR |  |
| 17 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/86/865b23c1e68385b0c0f2bbdd69a662382db1e9aa66310d3af5110b246b2ec472.png)Iowa | Big Ten | NR |  |
| 18 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/35/35db0df8ce98e8180a3d6cffa1c2924f863874b3a4226d6b76192216fbfb4808.png)Tulane | American Athletic | NR |  |
| 19 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/58/585459126d87e56750ae902d78b198f63e44b8a6cac5c25b1a6c9483366229f5.png)James Madison | Sun Belt | NR |  |
| 20 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ab/abd4a69d1efca7bd1c944acf8a5a77b5bce41602da970e9779f0bf6079489c1a.png)USC | Big Ten | NR |  |
| 21 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/91/910dbf467c9b442f1b493280bbc027ba5a1f91e2ce314fae099d637aade7d42b.png)Michigan | Big Ten | 14 | ▼ 7 |
| 22 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d8/d8984a3cc57ea50d3002bb08515942af2be523c4fa404a670515da041261980d.png)Houston | Big 12 | NR |  |
| 23 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82eb45dc0f8186430a637f42fc3746ae07fff74ca04fe6ea2099da720864f51d.png)Navy | American Athletic | NR |  |
| 24 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/59/5953d0a7dd1e44d82402467043f2cd63003d74a0dc3bff754cb467ab93104436.png)North Texas | American Athletic | NR |  |
| 25 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/86/864561cb4ebf372171438c038fcf52eac3342a2c1d751e605901e144c70afda0.png)TCU | Big 12 | NR |  |
| Data: CollegeFootballData.com via cfbfastR |  |  |  |  |

`arrows = TRUE` leads each value with a triangle in place of a sign, so
a fall reads as a down triangle in front of a positive number. With
`percent = TRUE` the change is shown as a percent of `from` instead,
which suits values such as points or yards better than ranks.
