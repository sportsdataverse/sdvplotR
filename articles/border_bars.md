# Border Bars

On this page

[`gt_border_bars_top()`](https://sdvplotR.sportsdataverse.org/reference/gt_border_bars_top.md)
and
[`gt_border_bars_bottom()`](https://sdvplotR.sportsdataverse.org/reference/gt_border_bars_bottom.md)
place colored bars above or below a table. Stack as many bars as you
like, or use a single bar to carry an image and a line of text: a team’s
logo over its season recap, or a publisher’s mark under a leaderboard.
This article builds three tables with them:

1.  **A team report card**: the 2026 men’s college basketball champion’s
    four-factor percentiles at home and on the road, under a bar in the
    team’s color with its logo.
2.  **A branded footer**: the WNBA’s 2026 scoring leaders with a footer
    bar that carries the sdvplotR mark and the data source.
3.  **Team-color stripes**: the 2025 Super Bowl champion’s game log,
    topped with its wordmark and finished with stripes in its colors.

The basketball comes from [`hoopR`](https://hoopR.sportsdataverse.org)
and [`wehoop`](https://wehoop.sportsdataverse.org)’s ESPN box scores,
the football from nflverse via
[`nflreadr`](https://nflreadr.nflverse.com). The border bars, like the
other `gt_*` table functions, come from Andrew Weatherman’s
[gtUtils](https://github.com/andreweatherman/gtUtils), whose border-bars
article this one follows.

``` r

library(sdvplotR)
library(gt)
library(dplyr)
library(tidyr)
```

## 1. A team report card

The team is whoever won the season’s last game, the national
championship, so nothing about it is typed in. We plot national
percentiles on a home/away split for a set of efficiency, four-factor
and shooting numbers. The efficiency numbers are raw points per 100
possessions, not adjusted for opponents.

``` r

higher_better <- c(
  "off_eff", "tempo", "efg", "ftr", "oreb_rate", "dreb_rate", "def_tov_rate",
  "two_pt_pct", "three_pt_pct", "ft_pct"
)
```

The box scores hold one row per team per game, so joining each row to
its opponent’s row puts both ends of the floor side by side. Possessions
are estimated from the box score.

``` r

box <- hoopR::load_mbb_team_box(seasons = 2026) |>
  mutate(poss = field_goals_attempted - offensive_rebounds + total_turnovers + 0.475 * free_throws_attempted)

champion <- box |>
  filter(season_type == 3) |>
  slice_max(game_date_time, n = 1, with_ties = TRUE) |>
  filter(team_winner) |>
  pull(team_id)

games <- box |>
  # Division I teams only; the box scores also hold their games against other divisions
  filter(team_id %in% team_reference("mbb")$espn_team_id) |>
  inner_join(
    select(box, game_id,
      opponent_team_id = team_id, opp_score = team_score, opp_poss = poss,
      opp_fgm = field_goals_made, opp_fga = field_goals_attempted,
      opp_3pm = three_point_field_goals_made, opp_3pa = three_point_field_goals_attempted,
      opp_ftm = free_throws_made, opp_fta = free_throws_attempted,
      opp_oreb = offensive_rebounds, opp_dreb = defensive_rebounds, opp_tov = total_turnovers
    ),
    by = c("game_id", "opponent_team_id")
  )

team_factors <- function(data) {
  data |>
    summarise(
      off_eff = 100 * sum(team_score) / sum(poss),
      def_eff = 100 * sum(opp_score) / sum(opp_poss),
      tempo = mean((poss + opp_poss) / 2),
      efg = (sum(field_goals_made) + 0.5 * sum(three_point_field_goals_made)) / sum(field_goals_attempted),
      def_efg = (sum(opp_fgm) + 0.5 * sum(opp_3pm)) / sum(opp_fga),
      ftr = sum(free_throws_attempted) / sum(field_goals_attempted),
      def_ftr = sum(opp_fta) / sum(opp_fga),
      oreb_rate = sum(offensive_rebounds) / sum(offensive_rebounds + opp_dreb),
      dreb_rate = sum(defensive_rebounds) / sum(defensive_rebounds + opp_oreb),
      tov_rate = sum(total_turnovers) / sum(poss),
      def_tov_rate = sum(opp_tov) / sum(opp_poss),
      two_pt_pct = sum(field_goals_made - three_point_field_goals_made) /
        sum(field_goals_attempted - three_point_field_goals_attempted),
      three_pt_pct = sum(three_point_field_goals_made) / sum(three_point_field_goals_attempted),
      ft_pct = sum(free_throws_made) / sum(free_throws_attempted),
      def_two_pt_pct = sum(opp_fgm - opp_3pm) / sum(opp_fga - opp_3pa),
      def_three_pt_pct = sum(opp_3pm) / sum(opp_3pa),
      def_ft_pct = sum(opp_ftm) / sum(opp_fta),
      .by = team_id
    )
}
```

Percentiles come from
[`percent_rank()`](https://dplyr.tidyverse.org/reference/percent_rank.html)
across every Division I team on each split, with the sign flipped where
a lower number is better, so 100% is always the best mark in the
country.

``` r

percentiles <- function(data, location) {
  data |>
    mutate(
      across(all_of(higher_better), percent_rank),
      across(-c(team_id, all_of(higher_better)), ~ percent_rank(-.x))
    ) |>
    pivot_longer(-team_id, names_to = "stat", values_to = "percentile") |>
    mutate(location = location)
}

# ESPN labels every game home or away, neutral sites included
splits <- bind_rows(
  percentiles(team_factors(filter(games, team_home_away == "home")), "home"),
  percentiles(team_factors(filter(games, team_home_away == "away")), "away")
) |>
  pivot_wider(names_from = location, values_from = percentile)
```

The last step names each stat and groups them, so the table reads in
sections.

``` r

labels <- c(
  off_eff = "Off. efficiency", def_eff = "Def. efficiency", tempo = "Tempo",
  efg = "Eff. FG%", ftr = "FTA per FGA", oreb_rate = "Off. rebound rate", tov_rate = "Turnover rate",
  def_efg = "Eff. FG%", def_ftr = "FTA per FGA", dreb_rate = "Def. rebound rate",
  def_tov_rate = "Turnover rate", two_pt_pct = "2FG%", three_pt_pct = "3FG%", ft_pct = "FT%",
  def_two_pt_pct = "2FG%", def_three_pt_pct = "3FG%", def_ft_pct = "FT%"
)

report <- splits |>
  filter(team_id == champion) |>
  mutate(
    group = case_when(
      stat %in% c("off_eff", "def_eff", "tempo") ~ "Efficiency",
      stat %in% c("efg", "ftr", "oreb_rate", "tov_rate") ~ "Offensive four factors",
      stat %in% c("def_efg", "def_ftr", "dreb_rate", "def_tov_rate") ~ "Defensive four factors",
      stat %in% c("two_pt_pct", "three_pt_pct", "ft_pct") ~ "Offensive shooting",
      TRUE ~ "Defensive shooting"
    ),
    stat = labels[stat]
  ) |>
  select(group, stat, home, away)
```

[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
holds the champion’s name, its dark-mode logo (made for a colored
ground) and, through
[`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
its primary color for the bar.

``` r

team <- filter(team_reference("mbb"), espn_team_id == champion)
team_color <- unname(sdv_team_colors("mbb", team$team_abbr, "primary"))
team_logo <- coalesce(team$logo_dark_url, team$logo_url)
```

Now the table.
[`gt_theme_savant()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_savant.md)
gives a clean base,
[`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md)
fills the two percentile columns over a fixed `[0, 1]` domain, and
[`gt_border_bars_top()`](https://sdvplotR.sportsdataverse.org/reference/gt_border_bars_top.md)
adds the header bar. With an image in the bar, `bar_height` has to be
tall enough to hold it; the text picks up the font the theme uses for
its headers unless you set it, and `text_padding`, `text_align` and
`img_align` move the two around.

``` r

report |>
  group_by(group) |>
  gt() |>
  gt_theme_savant() |>
  gt_color_pills(home,
    domain = c(0, 1), format_type = "percent", digits = 0,
    palette = "ggsci::green_material"
  ) |>
  gt_color_pills(away,
    domain = c(0, 1), format_type = "percent", digits = 0,
    palette = "ggsci::green_material"
  ) |>
  cols_width(home:away ~ px(90)) |>
  cols_label(stat = "", home = "At home", away = "On the road") |>
  cols_align(columns = -stat, "center") |>
  tab_options(column_labels.border.top.style = "none") |>
  gt_538_caption(
    "National percentile among Division I teams on each split; 100% is the best mark.",
    "Data: ESPN box scores via hoopR"
  ) |>
  gt_border_bars_top(
    colors = team_color,
    img = team_logo,
    text = paste("2025-26 recap:", team$team_location),
    text_padding = 10,
    text_size = 20,
    img_width = 44,
    img_height = 44,
    bar_height = 62
  )
```

| ¹ | At home¹ | On the road¹ |
|----|----|----|
| Efficiency |  |  |
| Off. efficiency | 93% | 96% |
| Def. efficiency | 90% | 95% |
| Tempo | 89% | 62% |
| Offensive four factors |  |  |
| Eff. FG% | 97% | 95% |
| FTA per FGA | 72% | 61% |
| Off. rebound rate | 61% | 96% |
| Turnover rate | 56% | 43% |
| Defensive four factors |  |  |
| Eff. FG% | 95% | 100% |
| FTA per FGA | 87% | 98% |
| Def. rebound rate | 84% | 28% |
| Turnover rate | 16% | 33% |
| Offensive shooting |  |  |
| 2FG% | 99% | 84% |
| 3FG% | 72% | 95% |
| FT% | 55% | 95% |
| Defensive shooting |  |  |
| 2FG% | 97% | 99% |
| 3FG% | 79% | 94% |
| FT% | 49% | 1% |
| ¹ National percentile among Division I teams on each split; 100% is the best mark. |  |  |
| Data: ESPN box scores via hoopR |  |  |

2025-26 recap:
Michigan![](https://a.espncdn.com/i/teamlogos/ncaa/500-dark/130.png)
{.table .gt_table style="table-layout:fixed;"
quarto-disable-processing="false" quarto-bootstrap="false"}

## 2. A branded footer

A footer bar is the place for a publisher’s mark. The table is the
WNBA’s top ten scorers of the 2026 regular season among players who
appeared in at least 30 games, each with a headshot and team logo.

``` r

scorers <- wehoop::load_wnba_player_box(2026) |>
  filter(season_type == 2, !did_not_play) |>
  summarise(
    player = last(athlete_display_name, order_by = game_date),
    team = last(team_abbreviation, order_by = game_date),
    gp = n(),
    ppg = mean(points),
    fg_pct = sum(field_goals_made) / sum(field_goals_attempted),
    .by = athlete_id
  ) |>
  filter(gp >= 30) |>
  arrange(desc(ppg), player) |>
  slice_head(n = 10) |>
  mutate(rank = row_number(), photo = athlete_id) |>
  select(rank, photo, player, team, gp, ppg, fg_pct)
```

[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md)
turns ESPN athlete ids into photos and
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns the team abbreviations into logos. The footer bar holds the
sdvplotR hex mark, drawn 32px wide and 37px tall to keep its shape, and
the source line, on the SportsDataverse blue, where the dark hex stands
out; a thin bar of the same color on top frames the table.

``` r

scorers |>
  gt() |>
  gt_theme_sofa() |>
  gt_sdv_headshots(photo, sport = "wnba", height = 36) |>
  gt_sdv_logos(team, sport = "wnba", height = 26) |>
  fmt_number(ppg, decimals = 1) |>
  fmt_percent(fg_pct, decimals = 1) |>
  cols_label(rank = "", photo = "", player = "Player", team = "", gp = "GP", ppg = "PPG", fg_pct = "FG%") |>
  cols_align(columns = -player, "center") |>
  opt_row_striping() |>
  tab_header(
    title = "The WNBA's top scorers, 2026",
    subtitle = "Points per game, regular season, 30 or more games"
  ) |>
  gt_border_bars_bottom("#2680E4",
    bar_height = 46,
    img = "https://raw.githubusercontent.com/sportsdataverse/sdvplotR/main/man/figures/logo.png",
    img_width = 32, img_height = 37,
    text = "Data: ESPN box scores via wehoop", text_size = 12, text_weight = "normal"
  ) |>
  gt_border_bars_top("#2680E4", bar_height = 6)
```

[TABLE]

## 3. Team-color stripes

With no text or image, the bars are pure decoration, and you can have as
many as you like at equal heights, drawn in order from the first color
down. Here the 2025 Super Bowl champion’s game log gets its wordmark in
a white top bar and a stripe in each of its two colors at the bottom.

The champion is the winner of the season’s Super Bowl, and its games are
one filter on the schedule after `clean_homeaway()` turns it into one
row per team.

``` r

schedule <- nflreadr::load_schedules(2025)

sb <- filter(schedule, game_type == "SB")
champ <- if_else(sb$home_score > sb$away_score, sb$home_team, sb$away_team)

game_log <- schedule |>
  select(week, game_type, home_team, away_team, home_score, away_score) |>
  nflreadr::clean_homeaway() |>
  filter(team == champ, !is.na(team_score)) |>
  arrange(week) |>
  transmute(
    week = if_else(game_type == "REG", as.character(week), game_type),
    where = if_else(location == "home", "vs", "@"),
    opponent,
    result = if_else(team_score > opponent_score, "W", if_else(team_score < opponent_score, "L", "T")),
    score = paste0(team_score, "-", opponent_score)
  )
```

`sdv_team_colors(type = "all")` returns a team’s colors as one
comma-separated string, which splits into the stripe colors;
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
holds the wordmark.

``` r

stripes <- strsplit(unname(sdv_team_colors("nfl", champ, "all")), ", ")[[1]]
wordmark <- team_reference("nfl")$wordmark_url[team_reference("nfl")$team_abbr == champ]

game_log |>
  gt() |>
  gt_theme_sdv() |>
  gt_sdv_logos(opponent, sport = "nfl", height = 24) |>
  gt_highlight_cells(result, condition = ~ .x == "W", fill = "#E3F1E7", bold = TRUE) |>
  cols_label(week = "Week", where = "", opponent = "Opponent", result = "", score = "Score") |>
  cols_align(columns = everything(), "center") |>
  tab_source_note("Data: nflverse schedules via nflreadr") |>
  gt_border_bars_top("#FFFFFF", bar_height = 56, img = wordmark, img_width = 168, img_height = 46) |>
  gt_border_bars_bottom(stripes, bar_height = 8)
```

[TABLE]

![](https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/SEA.png)
{.table .gt_table quarto-disable-processing="false"
quarto-bootstrap="false"}

The wordmark bar is white because a team’s wordmark is drawn in the
team’s own colors, which would disappear on a bar of the same color. Put
a logo on a colored bar (the report card above) and a wordmark on a
light one.
