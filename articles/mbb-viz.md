# Men's College Basketball Visualizations with hoopR and sdvplotR

On this page

Division I men’s basketball has more than 360 teams in 31 conferences,
and the conferences change from one season to the next. These ten
examples chart the 2025-26 season: matching ESPN team ids and names to
sdvplotR, keeping a 360-team chart legible, ranking the top 25 with
logos on the axis, the power conferences in small multiples, a
season-by-season realignment table with conference logos, a conference
standings table, March as a tier list, a headshot leaderboard, a shot
chart on a college court and the AP poll as a bump chart. The data are
[hoopR](https://hoopR.sportsdataverse.org)’s ESPN release files on
GitHub (`load_mbb_*()`): box scores, standings, schedules, shots and the
adjusted team ratings. Nothing here calls stats.ncaa.org.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(dplyr)
library(tidyr)
library(gt)

season <- 2026 # the 2025-26 season: hoopR names a season by the year it ends
label <- "2025-26"
source_note <- "Data: hoopR (ESPN) | Viz: sdvplotR"

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      plot.title.position = "plot",
      plot.caption = element_text(color = "grey40", size = 8),
      plot.caption.position = "plot",
      panel.grid.minor = element_blank()
    )
)
```

## 1. ESPN team ids, names and what doesn’t resolve

`team_reference("mbb")` lists every Division I program sdvplotR knows,
one row per team, with its ESPN team id. sdvplotR’s own key is the ESPN
abbreviation, and full names, short names and the names other providers
use (NCAA.com, KenPom, Torvik) resolve to it too:

``` r

mbb_teams <- team_reference("mbb")
nrow(mbb_teams)
#> [1] 366

clean_team_abbrs(
  c("Michigan", "Michigan Wolverines", "Connecticut", "Saint Mary's", "St. Mary's", "130", "American", "American Conference"),
  sport = "mbb",
  keep_non_matches = FALSE
)
#> [1] "MICH" "MICH" "CONN" "SMC"  NA     NA     "AMER" "AAC"
```

Three things in that output matter for real data. “St. Mary’s” matches
nothing: short forms that no provider uses come back `NA`. `"130"`,
Michigan’s ESPN id, is not a key either; ids can’t be told apart from
other numbers, so join on `espn_team_id` instead. And `"American"` is
American University, a Patriot League team: the American Conference is
`"American Conference"` (`"AAC"`). Conferences are rows too, listed with
`team_reference("mbb", include_conferences = TRUE)`.

hoopR’s adjusted ratings store the ESPN id as text while
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
stores it as an integer, so cast before the join. The ratings also rate
every non-Division I opponent a Division I team played; the inner join
keeps the Division I teams. Each team’s 2025-26 conference comes from
that season’s standings, not from
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md),
whose `conference` is today’s (the College Basketball Crown is a
postseason event filed as a group, so it is dropped).

``` r

standings <- hoopR::load_mbb_standings(seasons = season)
conferences <- standings |>
  filter(group_abbreviation != "CBC") |>
  distinct(team_id, conference = group_short_name)
stopifnot(!anyDuplicated(conferences$team_id))

ratings <- hoopR::load_mbb_ratings(seasons = season) |>
  mutate(team_id = as.integer(team_id))
nrow(ratings)
#> [1] 727

ratings <- ratings |>
  inner_join(select(mbb_teams, team_id = espn_team_id, team = team_abbr, team_name), by = "team_id") |>
  left_join(conferences, by = "team_id") |>
  arrange(desc(adj_em), team)
nrow(ratings)
#> [1] 365
```

## 2. Tempo against efficiency: 360 teams, 25 logos

With 360 teams, a logo for everyone is a smear. Draw every team as a
grey point and give logos only to the top 25 by adjusted efficiency
margin (points scored minus allowed per 100 possessions, adjusted for
the opponents).

``` r

top25 <- head(ratings, 25)

ggplot(ratings, aes(adj_tempo, adj_em)) +
  geom_hline(yintercept = 0, color = "grey60", linewidth = 0.4) +
  geom_point(color = "grey75", size = 1.6) +
  geom_sdv_logos(aes(team = team), data = top25, sport = "mbb", width = 0.035) +
  labs(
    title = paste("Tempo vs efficiency, Division I men's basketball,", label),
    subtitle = paste(nrow(ratings), "teams; logos for the top 25 by adjusted efficiency margin"),
    x = "Adjusted tempo (possessions per 40 minutes)",
    y = "Adjusted efficiency margin (per 100 possessions)",
    caption = source_note
  )
```

![Scatter plot of every Division I men's basketball team in 2025-26 by
adjusted tempo (horizontal) and adjusted efficiency margin (vertical):
grey points for all teams and logos for the top
25.](mbb-viz_files/figure-html/team-performance-1.png)

## 3. A ranked top 25 with logos on the axis

[`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
swaps a discrete axis of abbreviations for logos, so the bars keep their
order and the labels stay short. A thin black edge keeps pale team
colors visible.

``` r

top25 |>
  mutate(team = factor(team, levels = rev(team))) |>
  ggplot(aes(adj_em, team, fill = team)) +
  geom_col(width = 0.75, color = "black", linewidth = 0.2) +
  geom_text(aes(label = sprintf("%.1f", adj_em)), hjust = -0.15, size = 3.3) +
  scale_fill_sdv(sport = "mbb") +
  scale_y_sdv(sport = "mbb", size = 16) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(
    title = paste("The top 25 by adjusted efficiency margin,", label),
    x = "Adjusted efficiency margin (per 100 possessions)",
    y = NULL,
    caption = source_note
  ) +
  theme_y_sdv() +
  theme(legend.position = "none", panel.grid.major.y = element_blank())
```

![Horizontal bar chart of the top 25 Division I men's basketball teams
of 2025-26 by adjusted efficiency margin, each bar in the team's color
with its logo on the vertical axis and its margin at the end of the
bar.](mbb-viz_files/figure-html/top-25-1.png)

## 4. Offense vs defense in the power conferences

A conference is the natural small multiple: its 11 to 18 logos fit in
one panel.
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
maps the team as an aesthetic, so it follows
[`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html),
and
[`geom_mean_lines()`](https://mrcaseb.github.io/ggpath/reference/geom_lines.html)
draws each conference’s own averages. Defense is points allowed, so its
axis is reversed to put good defenses on top.

``` r

power <- ratings |>
  filter(conference %in% c("ACC", "Big 12", "Big East", "Big Ten", "SEC"))

ggplot(power, aes(adj_o, adj_d)) +
  geom_mean_lines(aes(x0 = adj_o, y0 = adj_d), color = "grey60", linewidth = 0.4) +
  geom_sdv_logos(aes(team = team), sport = "mbb", width = 0.085) +
  facet_wrap(~conference, ncol = 3) +
  scale_y_reverse() +
  labs(
    title = paste("Offense vs defense in the power conferences,", label),
    x = "Adjusted offensive efficiency (points per 100 possessions)",
    y = "Adjusted defensive efficiency (allowed per 100)",
    caption = source_note
  ) +
  theme(strip.text = element_text(face = "bold", size = 11))
```

![Five panels, one per power conference (ACC, Big 12, Big East, Big Ten,
SEC), placing each team's logo by adjusted offensive efficiency
(horizontal) and adjusted defensive efficiency (vertical, reversed),
with each conference's average
lines.](mbb-viz_files/figure-html/power-conferences-1.png)

## 5. Conference realignment, season by season

A past season’s conference comes from that season’s data. Load three
seasons of standings and follow the twelve teams of the 2023-24 Pac-12:
ten left for the ACC, Big 12 and Big Ten in 2024, and Oregon State and
Washington State spent two seasons in the West Coast Conference. The
last column is
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)’s
conference, today’s, where those two anchor the rebuilt Pac-12.
Conference names resolve to conference logos, so
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
draws every column; `include_name = TRUE` keeps the name beside the
mark.

``` r

history <- hoopR::load_mbb_standings(seasons = (season - 2):season) |>
  filter(group_abbreviation != "CBC") |>
  distinct(season, team_id, conference = group_short_name)

pac12 <- history |>
  filter(season == !!season - 2, conference == "Pac-12") |>
  pull(team_id)

history |>
  filter(team_id %in% pac12) |>
  pivot_wider(names_from = season, values_from = conference, names_prefix = "s") |>
  inner_join(
    select(mbb_teams, team_id = espn_team_id, team = team_abbr, team_name, today = conference),
    by = "team_id"
  ) |>
  arrange(s2026, team_name) |>
  select(team, team_name, s2024, s2025, s2026, today) |>
  gt() |>
  tab_header(
    title = "Where the 2023-24 Pac-12 went",
    subtitle = "Each season's conference, from that season's ESPN standings"
  ) |>
  cols_label(
    team = "", team_name = "Team", s2024 = "2023-24", s2025 = "2024-25",
    s2026 = "2025-26", today = "Today"
  ) |>
  tab_source_note(source_note) |>
  gt_sdv_logos(columns = team, sport = "mbb", height = 28) |>
  gt_sdv_logos(columns = c(s2024, s2025, s2026, today), sport = "mbb", height = 22, include_name = TRUE) |>
  gt_theme_sdv()
```

| Where the 2023-24 Pac-12 went |  |  |  |  |  |
|----|----|----|----|----|----|
| Each season's conference, from that season's ESPN standings |  |  |  |  |  |
|  | Team | 2023-24 | 2024-25 | 2025-26 | Today |
| ![California Golden Bears](https://a.espncdn.com/i/teamlogos/ncaa/500/25.png) | California Golden Bears | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC |
| ![Stanford Cardinal](https://a.espncdn.com/i/teamlogos/ncaa/500/24.png) | Stanford Cardinal | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/acc.png)ACC |
| ![Arizona State Sun Devils](https://a.espncdn.com/i/teamlogos/ncaa/500/9.png) | Arizona State Sun Devils | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 |
| ![Arizona Wildcats](https://a.espncdn.com/i/teamlogos/ncaa/500/12.png) | Arizona Wildcats | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 |
| ![Colorado Buffaloes](https://a.espncdn.com/i/teamlogos/ncaa/500/38.png) | Colorado Buffaloes | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 |
| ![Utah Utes](https://a.espncdn.com/i/teamlogos/ncaa/500/254.png) | Utah Utes | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_12.png)Big 12 |
| ![Oregon Ducks](https://a.espncdn.com/i/teamlogos/ncaa/500/2483.png) | Oregon Ducks | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten |
| ![UCLA Bruins](https://a.espncdn.com/i/teamlogos/ncaa/500/26.png) | UCLA Bruins | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten |
| ![USC Trojans](https://a.espncdn.com/i/teamlogos/ncaa/500/30.png) | USC Trojans | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten |
| ![Washington Huskies](https://a.espncdn.com/i/teamlogos/ncaa/500/264.png) | Washington Huskies | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/big_ten.png)Big Ten |
| ![Oregon State Beavers](https://a.espncdn.com/i/teamlogos/ncaa/500/204.png) | Oregon State Beavers | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/west_coast.png)WCC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/west_coast.png)WCC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 |
| ![Washington State Cougars](https://a.espncdn.com/i/teamlogos/ncaa/500/265.png) | Washington State Cougars | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/west_coast.png)WCC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/west_coast.png)WCC | ![](https://a.espncdn.com/i/teamlogos/ncaa_conf/500/pac_12.png)Pac-12 |
| Data: hoopR (ESPN) \| Viz: sdvplotR |  |  |  |  |  |

## 6. A conference standings table

The Big Ten’s 2025-26 standings: the conference and overall records,
home and road, the scoring margin and the adjusted efficiency margin, in
ESPN’s standings order (`playoffseed`). The standings frame is long, one
row per team and stat, and college standings repeat each stat for every
split (home, road, conference, against ranked teams), so the unique key
is `stat_type`, not `stat_name`.
[`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
puts each overall record under the team name in the team’s color, and
[`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md)
colors the rating.

``` r

standings |>
  filter(group_short_name == "Big Ten") |>
  select(team_id, stat_type, display_value) |>
  pivot_wider(names_from = stat_type, values_from = display_value) |>
  inner_join(select(ratings, team_id, team, team_name, adj_em), by = "team_id") |>
  mutate(
    seed = as.integer(playoffseed),
    logo = team,
    margin = as.numeric(avgpointsfor) - as.numeric(avgpointsagainst)
  ) |>
  arrange(seed, team) |>
  select(seed, logo, team_name, total, team, vsconf, home, road, margin, adj_em) |>
  gt() |>
  tab_header(
    title = paste("Big Ten standings,", label),
    subtitle = "Overall record under each team; conference, home and road records beside it"
  ) |>
  cols_label(
    seed = "", logo = "", team_name = "Team", vsconf = "Conf", home = "Home",
    road = "Road", margin = "Margin", adj_em = "Adj. EM"
  ) |>
  fmt_number(margin, decimals = 1, force_sign = TRUE) |>
  tab_source_note(source_note) |>
  gt_merge_stack_team_color(team_name, total, team, sport = "mbb") |>
  gt_sdv_logos(columns = logo, sport = "mbb", height = 28) |>
  gt_color_pills(adj_em, digits = 1, domain = c(-10, 50)) |>
  gt_theme_athletic() |>
  cols_hide(team)
```

[TABLE]

## 7. March as a tier list

The schedule’s `notes_headline` names each NCAA tournament game’s round,
so each team’s last round is how far it went, and the title game’s
winner is the champion.
[`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
turns that into a tier list of the Sweet 16, best adjusted efficiency
margin first within each tier.

``` r

rounds <- c(
  "First Four" = 0, "1st Round" = 1, "2nd Round" = 2, "Sweet 16" = 3,
  "Elite 8" = 4, "Final Four" = 5, "National Championship" = 6
)

ncaa <- hoopR::load_mbb_schedule(seasons = season) |>
  filter(grepl("^NCAA Men's Basketball Championship", notes_headline)) |>
  mutate(round = rounds[sub(".* - ", "", notes_headline)])
stopifnot(!anyNA(ncaa$round))

runs <- bind_rows(
  ncaa |> transmute(team_id = home_id, round, won = home_winner),
  ncaa |> transmute(team_id = away_id, round, won = away_winner)
) |>
  group_by(team_id) |>
  summarise(last_round = max(round), champion = any(round == 6 & won)) |>
  inner_join(select(ratings, team_id, team, adj_em), by = "team_id")

tiers <- runs |>
  filter(last_round >= 3) |>
  mutate(tier_no = if_else(champion, 1L, as.integer(8 - last_round))) |>
  arrange(tier_no, desc(adj_em)) |>
  select(tier_no, team)

sdv_team_tiers(
  tiers,
  sport = "mbb",
  title = paste("The", season, "NCAA tournament, by how far each team went"),
  subtitle = "The Sweet 16; best adjusted efficiency margin first within each tier",
  caption = source_note,
  tier_desc = c(
    "1" = "Champion", "2" = "Runner-up", "3" = "Final Four",
    "4" = "Elite Eight", "5" = "Sweet 16"
  ),
  alpha = 1,
  theme = "light" # Iowa's black hawkeye vanishes on the default dark background
)
```

![The 16 teams of the 2026 men's NCAA tournament Sweet 16 as logos in
five tiers by how far they went: Champion, Runner-up, Final Four, Elite
Eight and Sweet 16.](mbb-viz_files/figure-html/team-tiers-1.png)

## 8. Scoring leaders with headshots

Player box scores carry ESPN athlete ids, which
[`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
draws for college players too. Only Division I teams count, and a
player’s team is the one he played for last. Leaders need at least 20
games.

``` r

players <- hoopR::load_mbb_player_box(seasons = season) |>
  filter(season_type == 2, !did_not_play, team_id %in% mbb_teams$espn_team_id)

scorers <- players |>
  arrange(game_date) |>
  group_by(athlete_id, athlete_display_name) |>
  summarise(games = n(), team_id = last(team_id), ppg = mean(points, na.rm = TRUE), .groups = "drop") |>
  filter(games >= 20) |>
  arrange(desc(ppg), athlete_id) |>
  head(10) |>
  inner_join(select(ratings, team_id, team), by = "team_id") |>
  mutate(athlete_display_name = factor(athlete_display_name, levels = rev(athlete_display_name)))

ggplot(scorers, aes(ppg, athlete_display_name)) +
  geom_col(aes(fill = team), width = 0.7, color = "black", linewidth = 0.2) +
  geom_sdv_logos(aes(x = ppg + 1.3, team = team), sport = "mbb", height = 0.075) +
  geom_sdv_headshots(aes(x = ppg + 3.8, player_id = athlete_id), sport = "mbb", height = 0.09) +
  geom_text(aes(x = ppg + 6.2, label = sprintf("%.1f", ppg)), fontface = "bold", hjust = 0) +
  scale_fill_sdv(sport = "mbb") +
  scale_x_continuous(limits = c(0, max(scorers$ppg) + 9), expand = expansion(0)) +
  labs(
    title = paste("Division I scoring leaders,", label),
    subtitle = "Points per game, regular season, 20 or more games",
    x = "Points per game",
    y = NULL,
    caption = source_note
  ) +
  theme(legend.position = "none", panel.grid.major.y = element_blank())
```

![Horizontal bar chart of the ten Division I men's basketball scoring
leaders of 2025-26 (20 or more games), each bar in the team's color,
followed by the team logo, the player's headshot and his points per
game.](mbb-viz_files/figure-html/player-headshots-1.png)

## 9. A shot chart on a college court

`load_mbb_shots()` holds ESPN’s shot locations, which hoopR already
converts to feet on a center-court frame, the frame
[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)’s
sportyR court uses, so they need no conversion
([`sdv_court_coords()`](https://sdvplotR.sportsdataverse.org/reference/sdv_court_coords.md)
is only for the stats.nba.com legacy frame). Two cleanups first: free
throws are placed at the rim, so drop them, and a shot with no location
carries a placeholder of about ±215 million, so keep only points on the
floor. Then fold the right-basket shots onto the left one. The player is
the national champion’s leading scorer.

``` r

champion_id <- filter(runs, champion)$team_id
star <- players |>
  filter(team_id == champion_id) |>
  group_by(athlete_id, athlete_display_name) |>
  summarise(games = n(), points = sum(points, na.rm = TRUE), .groups = "drop") |>
  slice_max(points, n = 1, with_ties = FALSE)
star_team <- filter(ratings, team_id == champion_id)$team

shots <- hoopR::load_mbb_shots(seasons = season) |>
  filter(
    athlete_id_1 == star$athlete_id,
    !grepl("FreeThrow", type_text),
    abs(coordinate_x) <= 47, abs(coordinate_y) <= 25
  ) |>
  mutate(
    right = coordinate_x > 0,
    x = if_else(right, -coordinate_x, coordinate_x),
    y = if_else(right, -coordinate_y, coordinate_y)
  )

sdv_surface("mbb", star_team, display_range = "defense") +
  geom_point(
    aes(x, y),
    data = filter(shots, !scoring_play),
    shape = 4, color = "grey25", size = 1.6, alpha = 0.65
  ) +
  geom_point(
    aes(x, y),
    data = filter(shots, scoring_play),
    shape = 21, fill = sdv_team_colors(star_team, sport = "mbb", type = "secondary"),
    color = "black", stroke = 0.3, size = 2
  ) +
  labs(
    title = paste0(star$athlete_display_name, ": every field goal attempt, ", label),
    subtitle = sprintf(
      "%d made (filled), %d missed (crosses): %.1f%% from the field, all games",
      sum(shots$scoring_play), sum(!shots$scoring_play), 100 * mean(shots$scoring_play)
    ),
    caption = source_note
  ) +
  theme(plot.title = element_text(face = "bold"))
```

![Half-court shot chart of the 2026 national champion's leading scorer
on a college court painted in his team's colors: made shots as filled
circles, missed shots as grey
crosses.](mbb-viz_files/figure-html/shot-chart-1.png)

## 10. The AP poll, week by week

Each schedule row carries both teams’ AP rank that week (99 means
unranked), so the schedule holds the whole poll. Take each ranked team’s
rank per week, keep the top 10 of the last regular-season poll, and draw
a bump chart in team colors with the logos at the finish. A week a team
spent unranked leaves a gap in its line.

``` r

games <- hoopR::load_mbb_schedule(seasons = season) |>
  filter(season_type == 2) |>
  mutate(week = as.Date(cut(game_date, "week", start.on.monday = TRUE)))
weekly_rank <- bind_rows(
  games |> transmute(week, team_id = home_id, rank = home_current_rank),
  games |> transmute(week, team_id = away_id, rank = away_current_rank)
) |>
  group_by(team_id, week) |>
  summarise(rank = min(rank), .groups = "drop")
```

A team that didn’t play in a week (most of them over Christmas) has no
row for it, so carry its last rank forward; a team that played unranked
keeps its 99 and drops out of the chart until it is ranked again. The
final week of conference tournaments has too few ranked teams playing,
so the chart ends with the last week in which at least 20 of the 25
played.

``` r

full_weeks <- weekly_rank |>
  filter(rank <= 25) |>
  count(week) |>
  filter(n >= 20) |>
  pull(week)
final_week <- max(full_weeks)

poll <- weekly_rank |>
  complete(team_id, week) |>
  arrange(team_id, week) |>
  group_by(team_id) |>
  fill(rank) |>
  ungroup() |>
  filter(week <= final_week) |>
  mutate(rank = if_else(rank <= 25, rank, NA)) |>
  inner_join(select(ratings, team_id, team), by = "team_id")

top_final <- poll |>
  filter(week == final_week, !is.na(rank)) |>
  arrange(rank, team) |>
  head(8)
poll_top <- filter(poll, team_id %in% top_final$team_id)

ggplot(poll_top, aes(week, rank)) +
  geom_line(aes(group = team), color = "black", linewidth = 1.5, na.rm = TRUE) +
  geom_line(aes(color = team), linewidth = 0.9, na.rm = TRUE) +
  geom_sdv_logos(aes(x = week + 5, team = team), data = top_final, sport = "mbb", width = 0.04) +
  scale_color_sdv(sport = "mbb") +
  scale_y_reverse(breaks = c(1, 5, 10, 15, 20, 25)) +
  scale_x_date(date_labels = "%b %d", expand = expansion(add = c(2, 9))) +
  labs(
    title = paste("The AP poll,", label),
    subtitle = "Weekly rank of the last full poll's top 8; a gap is a week unranked",
    x = NULL,
    y = "AP rank",
    caption = source_note
  ) +
  theme(legend.position = "none")
```

![Bump chart of the AP poll rank by week through the 2025-26 regular
season for the eight teams ranked highest in the last full poll, one
line per team in its color with its logo at its final
rank.](mbb-viz_files/figure-html/ap-poll-1.png)

## Related articles

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Women’s College Basketball
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/wbb-viz.md)
- [NBA
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/nba-viz.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
