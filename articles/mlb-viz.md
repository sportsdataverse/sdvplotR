# MLB Visualizations with baseballr and sdvplotR

## Introduction

This vignette demonstrates how to create rich MLB visualizations by
combining [baseballr](https://billpettitt.github.io/baseballr/) for
player and team data with
[sdvplotR](https://sdvplotr.sportsdataverse.org) for team logos,
headshots, colors, and gt tables.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(baseballr)
library(dplyr)
library(gt)

# Get valid MLB team abbreviations
mlb_teams <- valid_team_names("mlb")
head(mlb_teams)
```

## Loading MLB Data

Use `baseballr` to load MLB player and team statistics:

``` r

# Load MLB team stats
team_stats <- baseballr::get_team_stats(
  season = baseballr::most_recent_mlb_season(),
  team_id = NULL  # All teams
)

# Load MLB player stats
player_stats <- baseballr::get_batter_stats(
  season = baseballr::most_recent_mlb_season(),
  player_id = NULL
)
```

## MLB Team Performance

Visualize team performance with team logos:

``` r

# Calculate team metrics
team_perf <- team_stats |>
  filter(!is.na(team_abbreviation)) |>
  group_by(team_abbreviation) |>
  summarise(
    avg_runs = mean(runs, na.rm = TRUE),
    avg_home_runs = mean(home_runs, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 10)

ggplot(team_perf, aes(x = avg_runs, y = avg_home_runs)) +
  geom_sdv_logos(
    aes(team = team_abbreviation),
    sport = "mlb",
    width = 0.075
  ) +
  labs(
    title = "MLB Team Performance",
    subtitle = paste("Season", baseballr::most_recent_mlb_season()),
    x = "Average Runs per Game",
    y = "Average Home Runs per Game",
    caption = "Data: baseballr | Viz: sdvplotR"
  ) +
  theme_minimal()
```

## MLB Team Colors

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
  head(20)

ggplot(team_wins, aes(x = reorder(team_abbreviation, win_pct), y = win_pct)) +
  geom_col(aes(fill = team_abbreviation), width = 0.7) +
  scale_fill_sdv(sport = "mlb", alpha = 0.8) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Top 20 MLB Teams by Win Percentage",
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

# Top home run hitters
top_hr <- player_stats |>
  filter(!is.na(player_id)) |>
  group_by(player_id, player_name) |>
  summarise(
    total_hr = sum(home_runs, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 50) |>
  arrange(desc(total_hr)) |>
  head(8)

ggplot(top_hr, aes(x = games, y = total_hr)) +
  geom_sdv_headshots(
    aes(player_id = player_id),
    sport = "mlb",
    height = 0.15
  ) +
  geom_label(
    aes(label = player_name),
    nudge_y = -3,
    size = 3,
    alpha = 0.7
  ) +
  labs(
    title = "Top 8 MLB Home Run Hitters",
    subtitle = paste("Season", baseballr::most_recent_mlb_season()),
    x = "Games Played",
    y = "Total Home Runs"
  ) +
  theme_minimal()
```

## MLB Team Tiers

Create a tier plot ranking MLB teams:

``` r

# Sample tier assignments
tier_data <- data.frame(
  tier_no = c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5),
  team = c("LAD", "ATL", "HOU", "BAL", "TB", "NYY",
           "PHI", "TEX", "TOR",
           "SEA", "SF", "CHC",
           "BOS", "STL", "CIN")
)

sdv_team_tiers(
  tier_data,
  sport = "mlb",
  title = "MLB Power Rankings",
  subtitle = paste("As of", Sys.Date()),
  tier_desc = c(
    "1" = "World Series Favorites",
    "2" = "Contenders",
    "3" = "Playoff Teams",
    "4" = "Bubble Teams",
    "5" = "Rebuilding"
  )
)
```

## MLB Division Map

Visualize teams grouped by division:

``` r

# Get team info with divisions
mlb_info <- baseballr::get_teams() |>
  select(team_abbreviation, team_name, division_name)

division_map <- mlb_info |>
  filter(!is.na(division_name)) |>
  mutate(
    division_num = as.numeric(factor(division_name))
  ) |>
  arrange(division_num, team_name) |>
  mutate(
    team_rank = row_number(),
    .by = division_num
  )

ggplot(division_map, aes(x = division_num, y = team_rank)) +
  geom_sdv_logos(
    aes(team = team_abbreviation),
    sport = "mlb",
    width = 0.075
  ) +
  scale_x_continuous(
    breaks = 1:length(unique(division_map$division_name)),
    labels = unique(division_map$division_name)
  ) +
  labs(
    title = "MLB Teams by Division",
    x = "Division",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )
```

## MLB Standings Table with Logos

Create a gt table with team logos:

``` r

standings_table <- team_wins |>
  head(15) |>
  mutate(
    logo = team_abbreviation,
    rank = row_number()
  ) |>
  select(rank, logo, team_abbreviation, wins, games, win_pct)

standings_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "mlb", height = 35) |>
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
    title = "MLB Top 15",
    subtitle = paste("Season", baseballr::most_recent_mlb_season())
  )
```

## Player Performance Comparison

Compare top players using headshots:

``` r

# Top 5 home run hitters and batting average leaders
top_5_hr <- top_hr |> head(5)
top_5_avg <- player_stats |>
  filter(!is.na(player_id)) |>
  group_by(player_id, player_name) |>
  summarise(
    avg = mean(batting_average, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 50) |>
  arrange(desc(avg)) |>
  head(5)

# Combine for comparison
comparison <- bind_rows(
  top_5_hr |> mutate(category = "Top HR"),
  top_5_avg |> mutate(category = "Top Avg")
)

ggplot(comparison, aes(x = category, y = total_hr)) +
  geom_sdv_headshots(
    aes(player_id = player_id),
    sport = "mlb",
    width = 0.1
  ) +
  facet_wrap(~ category, scales = "free_y") +
  labs(
    title = "MLB Top Performers",
    subtitle = paste("Season", baseballr::most_recent_mlb_season()),
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
  scale_fill_sdv(sport = "mlb", alpha = 0.7) +
  scale_x_sdv(sport = "mlb") +
  theme_x_sdv() +
  theme_minimal() +
  labs(
    title = "Top 8 MLB Teams by Win %",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme(legend.position = "none")
```

## Next Steps

- Explore [baseballr
  documentation](https://billpettitt.github.io/baseballr/)
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
