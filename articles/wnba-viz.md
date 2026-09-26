# WNBA Visualizations with wehoop and sdvplotR

## Introduction

This vignette demonstrates how to create rich WNBA visualizations by
combining [wehoop](https://wehoop.sportsdataverse.org) for player and
team data with [sdvplotR](https://sdvplotr.sportsdataverse.org) for team
logos, headshots, colors, and gt tables.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(wehoop)
library(dplyr)
library(gt)

# Get valid WNBA team abbreviations
wnba_teams <- valid_team_names("wnba")
head(wnba_teams)
```

## Loading WNBA Data

Use `wehoop` to load WNBA player and team statistics:

``` r

# Load WNBA team stats
team_stats <- wehoop::load_wnba_team_stats(
  seasons = wehoop::most_recent_wnba_season(),
  level = "team"
)

# Load WNBA player stats
player_stats <- wehoop::load_wnba_player_stats(
  seasons = wehoop::most_recent_wnba_season(),
  season_type = "Regular Season"
)
```

## WNBA Team Performance

Visualize team performance with team logos:

``` r

# Calculate team metrics
team_perf <- team_stats |>
  filter(!is.na(team_abbreviation)) |>
  group_by(team_abbreviation) |>
  summarise(
    avg_points = mean(points, na.rm = TRUE),
    avg_rebounds = mean(total_rebounds, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 10)

ggplot(team_perf, aes(x = avg_points, y = avg_rebounds)) +
  geom_sdv_logos(
    aes(team = team_abbreviation),
    sport = "wnba",
    width = 0.075
  ) +
  labs(
    title = "WNBA Team Performance",
    subtitle = paste("Season", wehoop::most_recent_wnba_season()),
    x = "Average Points per Game",
    y = "Average Rebounds per Game",
    caption = "Data: wehoop | Viz: sdvplotR"
  ) +
  theme_minimal()
```

## WNBA Team Colors

Use team colors to visualize win percentages:

``` r

# Calculate win percentage
team_wins <- team_stats |>
  filter(!is.na(team_abbreviation)) |>
  group_by(team_abbreviation) |>
  summarise(
    wins = sum(win == 1, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 10) |>
  mutate(win_pct = wins / games) |>
  arrange(desc(win_pct)) |>
  head(12)

ggplot(team_wins, aes(x = reorder(team_abbreviation, win_pct), y = win_pct)) +
  geom_col(aes(fill = team_abbreviation), width = 0.7) +
  scale_fill_sdv(sport = "wnba", alpha = 0.8) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "WNBA Teams by Win Percentage",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )
```

## Player Headshots

Visualize top performers with player headshots:

``` r

# Top scorers
top_scorers <- player_stats |>
  filter(!is.na(athlete_id)) |>
  group_by(athlete_id, athlete_display_name) |>
  summarise(
    avg_points = mean(points, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 15) |>
  arrange(desc(avg_points)) |>
  head(8)

ggplot(top_scorers, aes(x = games, y = avg_points)) +
  geom_sdv_headshots(
    aes(player_id = athlete_id),
    sport = "wnba",
    height = 0.15
  ) +
  geom_label(
    aes(label = athlete_display_name),
    nudge_y = -1.0,
    size = 3,
    alpha = 0.7
  ) +
  labs(
    title = "Top 8 WNBA Scorers",
    subtitle = paste("Season", wehoop::most_recent_wnba_season()),
    x = "Games Played",
    y = "Average Points per Game"
  ) +
  theme_minimal()
```

### WNBA Stats player IDs

The headshots above use ESPN athlete IDs, the `athlete_id` in wehoop’s
`load_wnba_*()` data. wehoop’s `wnba_*()` functions read stats.wnba.com,
which numbers players differently (`PLAYER_ID`). Pass
`id_type = "league"` to draw those from the WNBA’s own image CDN. Both
are plain numbers, so without it a WNBA Stats ID is read as an ESPN ID
and draws someone else or nothing.

``` r

leaders <- wehoop::wnba_leagueleaders()$LeagueLeaders |>
  mutate(across(c(GP, PTS), as.numeric)) |>
  head(8)

ggplot(leaders, aes(x = GP, y = PTS)) +
  geom_sdv_headshots(
    aes(player_id = PLAYER_ID),
    sport = "wnba",
    id_type = "league",
    height = 0.15
  ) +
  labs(title = "WNBA scoring leaders", x = "Games Played", y = "Points")
```

`id_type` works the same in
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
[`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
the headshot axis scales and
[`element_sdv_headshot()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md).
The WNBA’s image CDN refuses requests from datacenter IPs, so a plot
rendered on CI or a server can come back without these headshots; tables
are unaffected, because the reader’s browser loads the images.

## WNBA Team Tiers

Create a tier plot ranking WNBA teams:

``` r

# Sample tier assignments
tier_data <- data.frame(
  tier_no = c(1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5),
  team = c("LV", "NY", "WAS", "DAL", "MIN",
           "SEA", "CHI", "ATL",
           "PHX", "LA", "CON",
           "IND")
)

sdv_team_tiers(
  tier_data,
  sport = "wnba",
  title = "WNBA Power Rankings",
  subtitle = paste("As of", Sys.Date()),
  tier_desc = c(
    "1" = "Championship Favorites",
    "2" = "Contenders",
    "3" = "Playoff Teams",
    "4" = "Bubble Teams",
    "5" = "Developing"
  )
)
```

## WNBA Conference Standings

Visualize teams by conference:

``` r

# Get team info with conferences
wnba_info <- wehoop::wnba_teams() |>
  select(team_abbreviation, team_name, conference)

conference_standings <- team_wins |>
  inner_join(wnba_info, by = "team_abbreviation") |>
  arrange(conference, desc(win_pct)) |>
  mutate(
    conference_num = as.numeric(factor(conference)),
    team_rank = row_number(),
    .by = conference_num
  )

ggplot(conference_standings, aes(x = conference_num, y = team_rank)) +
  geom_sdv_logos(
    aes(team = team_abbreviation),
    sport = "wnba",
    width = 0.075
  ) +
  scale_x_continuous(
    breaks = 1:length(unique(conference_standings$conference)),
    labels = unique(conference_standings$conference)
  ) +
  labs(
    title = "WNBA Teams by Conference",
    x = "Conference",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )
```

## WNBA Standings Table with Logos

Create a gt table with team logos:

``` r

standings_table <- team_wins |>
  mutate(
    logo = team_abbreviation,
    rank = row_number()
  ) |>
  select(rank, logo, team_abbreviation, wins, games, win_pct)

standings_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "wnba", height = 35) |>
  fmt_number(columns = "win_pct", decimals = 3) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team_abbreviation = "Abbrev",
    wins = "Wins",
    games = "Games",
    win_pct = "Win %"
  ) |>
  tab_header(
    title = "WNBA Standings",
    subtitle = paste("Season", wehoop::most_recent_wnba_season())
  )
```

## Player Performance Comparison

Compare top players using headshots:

``` r

# Top 5 scorers and assist leaders
top_5_scorers <- top_scorers |> head(5)
top_5_assists <- player_stats |>
  filter(!is.na(athlete_id)) |>
  group_by(athlete_id, athlete_display_name) |>
  summarise(
    avg_assists = mean(assists, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 15) |>
  arrange(desc(avg_assists)) |>
  head(5)

# Combine for comparison
comparison <- bind_rows(
  top_5_scorers |> mutate(category = "Top Scorers"),
  top_5_assists |> mutate(category = "Top Assists")
)

ggplot(comparison, aes(x = category, y = avg_points)) +
  geom_sdv_headshots(
    aes(player_id = athlete_id),
    sport = "wnba",
    width = 0.1
  ) +
  facet_wrap(~ category, scales = "free_y") +
  labs(
    title = "WNBA Top Performers",
    subtitle = paste("Season", wehoop::most_recent_wnba_season()),
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    panel.grid = element_blank()
  )
```

## Axis Labels with Logos

Replace axis labels with team logos:

``` r

top_8 <- team_wins |>
  head(8) |>
  mutate(team_abbreviation = factor(team_abbreviation, levels = team_abbreviation))

ggplot(top_8, aes(x = team_abbreviation, y = win_pct)) +
  geom_col(aes(fill = team_abbreviation), width = 0.6) +
  scale_fill_sdv(sport = "wnba", alpha = 0.7) +
  scale_x_sdv(sport = "wnba") +
  theme_x_sdv() +
  theme_minimal() +
  labs(
    title = "Top 8 WNBA Teams by Win %",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme(legend.position = "none")
```

## Next Steps

- Explore [wehoop documentation](https://wehoop.sportsdataverse.org/)
- Try combining with [oddsapiR](https://oddsapiR.sportsdataverse.org)
  for betting lines
- Build weekly dashboard with [Quarto](https://quarto.org/)

## Related Vignettes

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
- [Leaderboard
  Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.md)
