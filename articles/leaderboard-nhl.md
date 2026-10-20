# NHL Leaderboard

On this page

**Updated 2026-10-20:** the 2026-27 season, 6-10 games in per team.
Early-season tables move a lot from week to week.

This page is rebuilt every week with the site. It builds the standings,
charts goal differential with logos and ranks the points leaders with
their headshots, for the latest NHL season with games: the season to
date from October to April, the final regular season once it is over.
Data: [fastRhockey](https://fastRhockey.sportsdataverse.org)’s box-score
releases and the NHL’s api-web.nhle.com standings.

## Picking the season

NHL seasons are named by the year they end (2025-26 is `2026`) and start
in the fall, so until September the calendar points at the season that
ended in June. For a season with no file yet
[`fastRhockey::load_nhl_team_box()`](https://fastRhockey.sportsdataverse.org/reference/load_nhl_team_box.html)
warns and returns no rows, and a new season’s file holds only preseason
games at first, so the helper treats “no regular-season games” as “not
published” and the page steps back one season. A game id’s fifth and
sixth digits are its type: 02 is the regular season, 03 the playoffs.
During the season the standings come from api-web.nhle.com as of today;
once the regular season is over, as of its last day. That call goes
through `live()`: if the API does not answer, the page shows a note in
place of the standings and the goal-differential chart for that week
instead of failing the site build.

``` r

library(sdvplotR)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(gt)

today <- Sys.Date()
day_label <- function(day, month = "%b") sub(" 0", " ", format(as.Date(day), paste(month, "%d"))) # "Oct 5"
# fastRhockey names a season by the year it ends (2025-26 is 2026); it starts in
# the fall, so until September the calendar points at the season that ended in June
current <- as.integer(format(today, "%Y")) + (format(today, "%m") >= "09")
label <- function(season) sprintf("%d-%02d", season - 1, season %% 100)
# an NHL game id's fifth and sixth digits are its type: 01 preseason, 02 regular season, 03 playoffs
game_type <- function(game_id) (as.numeric(game_id) %/% 10000) %% 100

# A season's team box scores, or NULL when it has no regular-season games yet:
# load_nhl_team_box() warns and returns no rows for a season it has no file for,
# and a new season's file holds only preseason games at first
team_games <- function(season) {
  box <- tryCatch(suppressWarnings(fastRhockey::load_nhl_team_box(seasons = season)), error = function(e) NULL)
  if (NROW(box) == 0 || !any(game_type(box$game_id) == 2)) NULL else box
}

season <- current
box <- team_games(season)
if (is.null(box)) {
  season <- current - 1
  box <- team_games(season)
}
stopifnot(!is.null(box))

box <- mutate(box, game_date = as.Date(game_date), type = game_type(game_id))
last_regular <- max(box$game_date[box$type == 2])
playoffs <- filter(box, type == 3)
in_season <- season == current && nrow(playoffs) == 0
# games per team from the release file (they differ early on)
games_in <- paste(unique(range(table(box$team_abbrev[box$type == 2]))), collapse = "-")

# A live API call, or NULL when the API does not answer: one bad week then shows
# a note in place of a table instead of failing the whole site build
live <- function(expr) tryCatch(expr, error = function(e) NULL)
unavailable <- function(what, ok) {
  if (ok) "" else sprintf("*%s were unavailable when this page was built on %s; they return next week.*", what, today)
}
# api-web.nhle.com standings: as of today in season, as of the last regular-season day after it
standings <- live(fastRhockey::nhl_standings(date = if (in_season) NULL else format(last_regular)))
standings_ok <- NROW(standings) > 0
if (in_season) {
  status <- sprintf(
    "the %s season, %s games in per team. Early-season tables move a lot from week to week.",
    label(season), games_in
  )
  through <- sprintf("through %s (%s games in)", day_label(last_regular), games_in)
} else if (season < current) {
  status <- sprintf(
    "the offseason, so this is the final %s regular season; the %s season has no regular-season games yet.",
    label(season), label(current)
  )
  through <- "final regular season"
} else if (as.numeric(today - max(playoffs$game_date)) <= 10) {
  status <- sprintf("the final %s regular season; the playoffs are under way.", label(season))
  through <- "final regular season"
} else {
  status <- sprintf("the offseason, so this is the final %s regular season.", label(season))
  through <- "final regular season"
}
```

## 1. Standings

Grouped by division in the NHL’s own order.
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
reads the NHL’s three-letter team codes (`LAK`, `NJD`, `TBL`) through
sdvplotR’s aliases, so nothing is mapped by hand.

``` r

standings |>
  arrange(division_name, division_sequence) |>
  transmute(
    division = division_name,
    logo = team_abbr,
    team = team_common_name,
    gp = games_played, w = wins, l = losses, otl = ot_losses,
    pts = points, pts_pct = point_pctg,
    gf = goals_for, ga = goals_against, diff = goal_differential,
    l10 = paste(l10_wins, l10_losses, l10_ot_losses, sep = "-"),
    streak = paste0(streak_code, streak_count)
  ) |>
  gt(groupname_col = "division", id = "nhl-standings") |>
  tab_header(
    title = paste("NHL standings,", label(season)),
    subtitle = paste0(toupper(substr(through, 1, 1)), substring(through, 2))
  ) |>
  fmt_number(pts_pct, decimals = 3) |>
  fmt_number(diff, decimals = 0, force_sign = TRUE) |>
  cols_label(
    logo = "", team = "Team", gp = "GP", w = "W", l = "L", otl = "OTL", pts = "PTS",
    pts_pct = "PTS%", gf = "GF", ga = "GA", diff = "DIFF", l10 = "Last 10", streak = "Streak"
  ) |>
  tab_source_note("Data: api-web.nhle.com via fastRhockey | Viz: sdvplotR") |>
  gt_sdv_logos(columns = logo, league = "nhl", height = 24) |>
  gt_theme_swiss()
```

| NHL standings, 2026-27 |  |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| Through Oct 18 (6-10 games in) |  |  |  |  |  |  |  |  |  |  |  |  |
|  | Team | GP | W | L | OTL | PTS | PTS% | GF | GA | DIFF | Last 10 | Streak |
| Atlantic |  |  |  |  |  |  |  |  |  |  |  |  |
| ![Boston Bruins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/70/70f79a2352abcf9ea24bcab9e4863ddfcf1a4d329c9edecb3b64bfbda24409ed.png) | Bruins | 9 | 7 | 2 | 0 | 14 | 0.778 | 34 | 19 | +15 | 7-2-0 | W5 |
| ![Tampa Bay Lightning](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3f/3f46ba7991bb86ecd35112b65136b507325d023fc43d42e3d8015354363a62b3.png) | Lightning | 8 | 6 | 2 | 0 | 12 | 0.750 | 25 | 21 | +4 | 6-2-0 | W2 |
| ![Ottawa Senators](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/05/05bddfd77b0f30e13cd4a81708e41cc72cfad5b9d136a11f35eb01016b27c849.png) | Senators | 9 | 6 | 3 | 0 | 12 | 0.667 | 24 | 23 | +1 | 6-3-0 | L1 |
| ![Florida Panthers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/68/68f45d7aa38031ec83bd985058f943d54274ad890ebf112f4971388ad87d1d4f.png) | Panthers | 9 | 5 | 2 | 2 | 12 | 0.667 | 30 | 25 | +5 | 5-2-2 | W3 |
| ![Buffalo Sabres](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c5/c5ff4ae23f112f73eca9569801e9f5b82366fafaa9f1f3dae535f9cafd673148.png) | Sabres | 9 | 4 | 3 | 2 | 10 | 0.556 | 27 | 34 | −7 | 4-3-2 | OT1 |
| ![Toronto Maple Leafs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2c/2c7646270d2e07f5ea16b277d9ebf916ee8ee0718f3049d123402e38f930e9ba.png) | Maple Leafs | 10 | 4 | 4 | 2 | 10 | 0.500 | 32 | 33 | −1 | 4-4-2 | W1 |
| ![Montreal Canadiens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2a/2ab02cb9e6c668e8b981f2b23174be1eb94554b8c3a86dfc5df4f6fb377a8560.png) | Canadiens | 8 | 4 | 3 | 1 | 9 | 0.562 | 27 | 30 | −3 | 4-3-1 | W1 |
| ![Detroit Red Wings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/a6/a634a4fcd294b2a439ccb16ab4e554227ec57aac2dfc198014f9f112a612c12d.png) | Red Wings | 8 | 3 | 3 | 2 | 8 | 0.500 | 20 | 24 | −4 | 3-3-2 | W2 |
| Central |  |  |  |  |  |  |  |  |  |  |  |  |
| ![Minnesota Wild](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b1/b1d7a8e3e887381d590649665080184cacfc50050f767c0723fcc6524ef95188.png) | Wild | 9 | 6 | 2 | 1 | 13 | 0.722 | 28 | 21 | +7 | 6-2-1 | W2 |
| ![Utah Mammoth](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/26/260a50b0164256131df4675b558f03a748525f8c0b138c23f54f37f63c0958d8.png) | Mammoth | 9 | 6 | 3 | 0 | 12 | 0.667 | 33 | 27 | +6 | 6-3-0 | L1 |
| ![Colorado Avalanche](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/01/01dcc259d7d40935c487a1db0b464d933ebc120db6808bf3d845a2e902d55059.png) | Avalanche | 9 | 5 | 3 | 1 | 11 | 0.611 | 38 | 27 | +11 | 5-3-1 | L1 |
| ![Winnipeg Jets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/45/45d1d6176f1753f419671c1a45bf832042e339a8e47163abfff06337933ded8f.png) | Jets | 8 | 4 | 2 | 2 | 10 | 0.625 | 23 | 24 | −1 | 4-2-2 | L1 |
| ![Dallas Stars](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/58/58fcc157a3b553bd10c7231118623b1e8ef5303e6b93e490e357ab7f5ca6690d.png) | Stars | 8 | 4 | 3 | 1 | 9 | 0.562 | 20 | 13 | +7 | 4-3-1 | W2 |
| ![Nashville Predators](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/4d/4d2e7def5af8332185bcfeb59fc9633f4fb30417262aa05e68095d93e4e12c2d.png) | Predators | 8 | 3 | 2 | 3 | 9 | 0.562 | 23 | 24 | −1 | 3-2-3 | W1 |
| ![St. Louis Blues](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/af/af4f35bdd196d566c9caa33e42dc0cd5284053631cb4a8ef190fb107f9e071b8.png) | Blues | 8 | 3 | 4 | 1 | 7 | 0.438 | 27 | 28 | −1 | 3-4-1 | L2 |
| ![Chicago Blackhawks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/4e/4e3260f13d674c1ec71e6ac7c08f9c6d4680fe4052a087814b66466ddaca15d9.png) | Blackhawks | 9 | 3 | 6 | 0 | 6 | 0.333 | 21 | 36 | −15 | 3-6-0 | L1 |
| Metropolitan |  |  |  |  |  |  |  |  |  |  |  |  |
| ![Carolina Hurricanes](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8b/8b28b34fbd7b4953c550fc9fde1656f68f1f402088f3d86922e3c6ba514330a0.png) | Hurricanes | 10 | 7 | 2 | 1 | 15 | 0.750 | 36 | 24 | +12 | 7-2-1 | L1 |
| ![New York Rangers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7a/7a43515a4551cc0708140f89d2f54d57259dde1498001c29ec28cc5b1d96fa7f.png) | Rangers | 11 | 7 | 3 | 1 | 15 | 0.682 | 33 | 24 | +9 | 7-2-1 | W1 |
| ![Washington Capitals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/59/5987a4f5511e6bd443042757522b040d1b7a258a4bc488693a250b658cf43a6d.png) | Capitals | 8 | 5 | 3 | 0 | 10 | 0.625 | 28 | 24 | +4 | 5-3-0 | W2 |
| ![New York Islanders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e6/e6bfc0d1b6d437d6fa09028ac465691ac64154cf396584f1d174bbe32be17921.png) | Islanders | 8 | 4 | 3 | 1 | 9 | 0.562 | 24 | 18 | +6 | 4-3-1 | W1 |
| ![New Jersey Devils](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/9a/9a10cdba30197130eb999bd19e9f40fb34be153599f09e98e6c7f472e41ef242.png) | Devils | 8 | 4 | 4 | 0 | 8 | 0.500 | 25 | 27 | −2 | 4-4-0 | L1 |
| ![Pittsburgh Penguins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1b/1b4dc90de4cb2eef301c0d2f9ffefd5cef2e0de1a8ad7d863e96ef686986e00f.png) | Penguins | 9 | 3 | 5 | 1 | 7 | 0.389 | 29 | 33 | −4 | 3-5-1 | L3 |
| ![Philadelphia Flyers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/04/0411764d10618e764c58e5c9b7e88d9b0dc7c77ebe9813095c338cd485e2dd04.png) | Flyers | 11 | 2 | 6 | 3 | 7 | 0.318 | 17 | 36 | −19 | 2-5-3 | W2 |
| ![Columbus Blue Jackets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/a1/a140e93fa031bae0464306c52fa24aef3821fa9d17e92cf66939efb6b0d2a957.png) | Blue Jackets | 7 | 3 | 4 | 0 | 6 | 0.429 | 18 | 23 | −5 | 3-4-0 | L1 |
| Pacific |  |  |  |  |  |  |  |  |  |  |  |  |
| ![Vegas Golden Knights](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/91/913da521af36370b9b9a3df6ca6b869c915b54732cc166d369865fbc24197e44.png) | Golden Knights | 10 | 8 | 2 | 0 | 16 | 0.800 | 42 | 24 | +18 | 8-2-0 | W3 |
| ![Edmonton Oilers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f8/f8e95d487f02c85aeb65a200f226b795e7a8de95604df49664962ad473d57666.png) | Oilers | 8 | 6 | 1 | 1 | 13 | 0.812 | 37 | 24 | +13 | 6-1-1 | W1 |
| ![Seattle Kraken](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/35/35208c3044f129338b22b3b4de0ca0bf384a2919468fe4077183ef5bcca87fcf.png) | Kraken | 9 | 5 | 3 | 1 | 11 | 0.611 | 35 | 31 | +4 | 5-3-1 | L1 |
| ![San Jose Sharks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/23/23c8bb973fc6e9e57c9f63b74fbf7b1a4e325515371e952579d0e0df13d33a5b.png) | Sharks | 9 | 4 | 4 | 1 | 9 | 0.500 | 23 | 32 | −9 | 4-4-1 | L1 |
| ![Anaheim Ducks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3b/3b94f09309431a7fbaee2947bf07b99df9c0aac8d61eaba3634e2078a13c5cdc.png) | Ducks | 8 | 4 | 4 | 0 | 8 | 0.500 | 24 | 26 | −2 | 4-4-0 | L3 |
| ![Vancouver Canucks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/30/306e860f33a92794782c0a365006627d12a73b750e1350afb24592a60b36506c.png) | Canucks | 10 | 2 | 7 | 1 | 5 | 0.250 | 30 | 45 | −15 | 2-7-1 | L1 |
| ![Calgary Flames](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e1638154eaae178588702673410e00938831f0a9b05512a0c8727c6e45e76a6.png) | Flames | 8 | 2 | 6 | 0 | 4 | 0.250 | 17 | 37 | −20 | 2-6-0 | W1 |
| ![Los Angeles Kings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/92/92c3b54fa5e296730885fb0ed63a5a8c062d50c827ae3ab1733c9529974733ff.png) | Kings | 6 | 0 | 4 | 2 | 2 | 0.167 | 12 | 25 | −13 | 0-4-2 | L2 |
| Data: api-web.nhle.com via fastRhockey \| Viz: sdvplotR |  |  |  |  |  |  |  |  |  |  |  |  |

## 2. Goal differential

Goals for minus goals against, all 32 teams, in team colors;
[`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
and
[`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
swap the team codes on the x axis for logos.

``` r

gd <- standings |>
  mutate(team = sdv_resolve(team_abbr, league = "nhl")) |>
  arrange(desc(goal_differential), team) # the team breaks a tie, so an unchanged week renders the same

ggplot(gd, aes(x = factor(team, levels = team), y = goal_differential, fill = team)) +
  geom_col(width = 0.75) +
  geom_hline(yintercept = 0, colour = "grey20", linewidth = 0.4) +
  scale_fill_sdv(league = "nhl", guide = "none") +
  scale_x_sdv(league = "nhl", size = 20) +
  labs(
    title = paste("NHL goal differential,", label(season), through),
    subtitle = "Goals for minus goals against",
    x = NULL, y = "Goal differential",
    caption = "Data: api-web.nhle.com via fastRhockey | Viz: sdvplotR"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  theme_x_sdv()
```

![Bar chart of every NHL team's goal differential, best to worst, each
bar in the team's primary color with the team's logo under it on the
horizontal
axis.](leaderboard-nhl_files/figure-html/goal-differential-1.png)

## 3. Points leaders with headshots

Goals and assists from the regular-season skater box scores, stacked
into points. The box scores carry NHL API player ids, which
`geom_sdv_headshots(id_system = "league")` turns into the NHL’s own
headshots; the game rosters give the full names.

``` r

skaters <- fastRhockey::load_nhl_player_box(seasons = season) |>
  filter(game_type(game_id) == 2)
full_names <- fastRhockey::load_nhl_game_rosters(seasons = season) |>
  distinct(player_id, full_name) |>
  filter(!duplicated(player_id))
stopifnot(identical(class(skaters$player_id), class(full_names$player_id)))

leaders <- skaters |>
  arrange(game_date, game_id) |>
  group_by(player_id) |>
  summarise(
    team = last(team_abbrev), gp = n(),
    goals = sum(goals), assists = sum(assists), points = sum(points),
    .groups = "drop"
  ) |>
  arrange(desc(points), desc(goals), player_id) |>
  slice_head(n = 10) |>
  left_join(full_names, by = "player_id") |>
  mutate(full_name = factor(full_name, levels = rev(full_name)))
top <- max(leaders$points)

bars <- tidyr::pivot_longer(leaders, c(goals, assists), names_to = "part", values_to = "n") |>
  mutate(part = factor(part, levels = c("assists", "goals"), labels = c("Assists", "Goals")))

ggplot(leaders, aes(y = full_name)) +
  geom_col(data = bars, aes(x = n, fill = part), width = 0.7) +
  geom_sdv_headshots(
    aes(x = -0.07 * top, player_id = player_id),
    league = "nhl", id_system = "league", height = 0.085
  ) +
  geom_sdv_logos(aes(x = points + 0.06 * top, team = team), league = "nhl", height = 0.06) +
  geom_text(aes(x = points + 0.12 * top, label = points), hjust = 0, fontface = "bold", size = 3.8) +
  scale_fill_manual(values = c(Goals = "#1f3b73", Assists = "#9fb4d8"), breaks = c("Goals", "Assists")) +
  scale_x_continuous(limits = c(-0.14 * top, 1.22 * top), expand = c(0, 0)) +
  labs(
    title = paste("NHL points leaders,", label(season)),
    # the box-score release can trail the live standings by a day or two
    subtitle = paste0(
      "Goals and assists, regular season",
      if (in_season) paste(", games through", day_label(max(skaters$game_date))) else ""
    ),
    x = "Points", y = NULL, fill = NULL,
    caption = "Data: fastRhockey box scores | Viz: sdvplotR"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top", legend.justification = "left"
  )
```

![Stacked horizontal bar chart of the ten NHL points leaders, goals in
dark blue and assists in light blue, with each player's headshot at the
left of the bar, the team logo at its end and the points total beside
it.](leaderboard-nhl_files/figure-html/points-leaders-1.png)

## 4. Interactive version

The goal differential bars from section 2 as a plotly chart: hover a bar
for the team’s record and its goals for and against. plotly draws no
logos on its own, so
[`sdv_axis_logos()`](https://sdvplotR.sportsdataverse.org/reference/sdv_axis_logos.md)
hides the team codes and puts a logo under each bar.

``` r

plotly::plot_ly(
  gd, x = ~factor(team, levels = team), y = ~goal_differential, type = "bar",
  marker = list(color = unname(sdv_team_colors("nhl", gd$team))),
  hoverinfo = "text", textposition = "none",
  text = ~sprintf(
    "%s, %d-%d-%d<br>%d goals for, %d against (%+d)",
    team_common_name, wins, losses, ot_losses, goals_for, goals_against, goal_differential
  )
) |>
  plotly::layout(
    title = list(text = paste("NHL goal differential,", label(season)), x = 0.02),
    xaxis = list(title = ""), yaxis = list(title = "Goal differential"),
    margin = list(b = 50, t = 50)
  ) |>
  sdv_axis_logos(gd$team, "nhl")
```

More recipes like this one, in plotly, ggiraph, leaflet and reactable,
are in [Interactive
charts](https://sdvplotR.sportsdataverse.org/articles/cookbook-interactive.md).

## Related

- [NHL](https://sdvplotR.sportsdataverse.org/articles/nhl-viz.md) walks
  through fastRhockey and sdvplotR more broadly.
- [MLB](https://sdvplotR.sportsdataverse.org/articles/leaderboard-mlb.md)
  builds the same three views for baseball.
- [Social graphics,
  automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.md)
  posts leaderboards like these on a schedule.

## **Our Authors**

- [Saiem Gilani](https://x.com/saiemgilani)  
  [![@saiemgilani](https://img.shields.io/twitter/follow/saiemgilani?color=blue&label=%40saiemgilani&logo=x&style=for-the-badge)](https://x.com/saiemgilani)
  [![@saiemgilani](https://img.shields.io/github/followers/saiemgilani?color=eee&logo=Github&style=for-the-badge)](https://github.com/saiemgilani)
- [Sebastian Carl](https://x.com/mrcaseb)  
  [![@mrcaseb](https://img.shields.io/twitter/follow/mrcaseb?color=blue&label=%40mrcaseb&logo=x&style=for-the-badge)](https://x.com/mrcaseb)
  [![@mrcaseb](https://img.shields.io/github/followers/mrcaseb?color=eee&logo=Github&style=for-the-badge)](https://github.com/mrcaseb)
- [Jared Lee](https://github.com/Kazink36)  
  [![@Kazink36](https://img.shields.io/github/followers/Kazink36?color=eee&logo=Github&style=for-the-badge)](https://github.com/Kazink36)
- [Camden Kay](https://x.com/camdenkay)  
  [![@camdenkay](https://img.shields.io/twitter/follow/camdenkay?color=blue&label=%40camdenkay&logo=x&style=for-the-badge)](https://x.com/camdenkay)
  [![@camdenk](https://img.shields.io/github/followers/camdenk?color=eee&logo=Github&style=for-the-badge)](https://github.com/camdenk)
- [Andrew Weatherman](https://github.com/andreweatherman) (gtUtils)  
  [![@andreweatherman](https://img.shields.io/github/followers/andreweatherman?color=eee&logo=Github&style=for-the-badge)](https://github.com/andreweatherman)

## **Citation**

To cite the [**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) R
package in publications, use:

BibTeX Citation

``` bibtex
@misc{gilani_carl_lee_kay_weatherman_sdvplotR,
  author = {Gilani, Saiem and Carl, Sebastian and Lee, Jared and Kay, Camden and Weatherman, Andrew},
  title = {sdvplotR: The SportsDataverse's R Package for Multi-League Sports Plotting.},
  url = {https://sdvplotR.sportsdataverse.org},
  year = {2026}
}
```

## **Related SportsDataverse packages**

- [**sdvplot**](https://sdvplot.sportsdataverse.org/) - the Python
  plotting package
- [**sdvplot-js**](https://plot.sportsdataverse.org/) - the JavaScript /
  TypeScript plotting packages
- [**cfbfastR**](https://cfbfastR.sportsdataverse.org/) - college
  football
- [**hoopR**](https://hoopR.sportsdataverse.org/) - men’s basketball
- [**wehoop**](https://wehoop.sportsdataverse.org/) - women’s basketball
- [**baseballr**](https://baseballr.sportsdataverse.org/) - baseball
- [**fastRhockey**](https://fastRhockey.sportsdataverse.org/) - hockey
- [**oddsapiR**](https://oddsapiR.sportsdataverse.org/) - betting odds
- [**sportyR**](https://sportyR.sportsdataverse.org/) - playing surfaces
- [**sportsdataverse-py**](https://py.sportsdataverse.org/) - the Python
  package
- [**sportsdataverse-R**](https://r.sportsdataverse.org/) - the R
  meta-package
