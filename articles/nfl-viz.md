# NFL Visualizations with nflfastR and sdvplotR

## Introduction

This vignette demonstrates how to create rich NFL visualizations by
combining [nflfastR](https://www.nflfastr.com/) for data ingestion with
[sdvplotR](https://sdvplotr.sportsdataverse.org) for team logos,
headshots, colors, and gt tables.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(nflfastR)
library(dplyr)
library(gt)

# Get valid NFL team abbreviations
nfl_teams <- valid_team_names("nfl")
head(nfl_teams)
```

## Loading NFL Data

Use `nflfastR` to load a season of play-by-play data:

``` r

# The last completed regular season (NFL seasons are named for the year they
# start, and the regular season ends in early January)
season <- as.integer(format(Sys.Date(), "%Y")) - 1 -
  (format(Sys.Date(), "%m-%d") < "01-15")

pbp <- nflfastR::load_pbp(seasons = season, file_type = "rds")

# Filter to pass plays only for EPA analysis
pass_plays <- pbp |>
  filter(
    !is.na(epa),
    pass == 1,
    !is.na(posteam)
  )
```

## EPA by Team with Logos

Create a scatter plot showing team EPA (Expected Points Added) per play,
with team logos replacing the data points:

``` r

team_epa <- pass_plays |>
  group_by(posteam) |>
  summarise(
    mean_epa = mean(epa, na.rm = TRUE),
    n_plays = n(),
    .groups = "drop"
  ) |>
  filter(n_plays >= 100)

ggplot(team_epa, aes(x = n_plays, y = mean_epa)) +
  geom_sdv_logos(
    aes(team = posteam),
    sport = "nfl",
    width = 0.075
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "NFL Team Pass EPA per Play",
    subtitle = paste("Season", season),
    x = "Number of Pass Plays",
    y = "Mean EPA per Play",
    caption = "Data: nflfastR | Viz: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey40")
  )
```

## Team Standings with Colors

Use team colors to visualize win-loss records:

``` r

# Regular-season records from the schedule, one row per team per game
standings <- nflreadr::load_schedules(season) |>
  filter(game_type == "REG", !is.na(result)) |>
  nflreadr::clean_homeaway() |>
  group_by(team) |>
  summarise(
    wins = sum(team_score > opponent_score) + 0.5 * sum(team_score == opponent_score),
    games = n(),
    .groups = "drop"
  ) |>
  mutate(win_pct = wins / games) |>
  arrange(desc(win_pct))

ggplot(head(standings, 16), aes(x = reorder(team, win_pct), y = win_pct)) +
  geom_col(aes(fill = team), width = 0.7) +
  scale_fill_sdv(sport = "nfl", alpha = 0.8) +
  labs(
    title = "Top 16 NFL Teams by Win Percentage",
    subtitle = paste("Season", season),
    x = NULL,
    y = "Win Percentage"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )
```

## Quarterback Headshots

Visualize quarterback performance with player headshots:

``` r

# Top QBs by EPA
qb_epa <- pass_plays |>
  filter(pass == 1, !is.na(passer_player_id)) |>
  group_by(passer_player_id, passer) |>
  summarise(
    mean_epa = mean(epa, na.rm = TRUE),
    n_passes = n(),
    .groups = "drop"
  ) |>
  filter(n_passes >= 200) |>
  arrange(desc(mean_epa)) |>
  head(8)

ggplot(qb_epa, aes(x = n_passes, y = mean_epa)) +
  geom_sdv_headshots(
    aes(player_id = passer_player_id),
    sport = "nfl",
    height = 0.15
  ) +
  geom_label(
    aes(label = passer),
    nudge_y = -0.02,
    size = 3,
    alpha = 0.7
  ) +
  labs(
    title = "Top 8 Quarterbacks by EPA per Pass",
    x = "Number of Passes",
    y = "Mean EPA per Pass"
  ) +
  theme_minimal()
```

## NFL Team Tiers

Create a tier plot ranking NFL teams:

``` r

# Sample tier assignments (replace with your own rankings)
tier_data <- data.frame(
  tier_no = c(1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4),
  team = c("KC", "BUF", "SF", "PHI", "DAL", "MIA", "CIN",
           "BAL", "DET", "JAX", "CLE", "GB",
           "LAR", "MIN", "PIT", "TEN")
)

sdv_team_tiers(
  tier_data,
  sport = "nfl",
  title = "NFL Power Rankings",
  subtitle = paste("Example tiers,", season, "season"),
  tier_desc = c(
    "1" = "Elite",
    "2" = "Contenders",
    "3" = "Playoff Bubble",
    "4" = "Rebuilding"
  )
)
```

## NFL Standings Table with Logos

Create a gt table with team logos:

``` r

standings_table <- standings |>
  head(10) |>
  mutate(
    logo = team,
    team_name = nflfastR::teams_colors_logos$team_nick[
      match(team, nflfastR::teams_colors_logos$team_abbr)
    ]
  ) |>
  select(logo, team_name, wins, games, win_pct)

standings_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = "win_pct", decimals = 3) |>
  cols_label(
    logo = "Team",
    team_name = "Name",
    wins = "Wins",
    games = "Games",
    win_pct = "Win %"
  ) |>
  tab_header(
    title = "NFL Standings",
    subtitle = paste("Season", season)
  )
```

## NFL Division Map with Logos

Visualize teams grouped by division:

``` r

# Each team's division, from the reference data sdvplotR keeps for every team
divisions <- team_reference("nfl") |>
  arrange(division, team_name) |>
  group_by(division) |>
  mutate(y = row_number()) |>
  ungroup() |>
  mutate(x = as.numeric(factor(division)))

ggplot(divisions, aes(x = x, y = y)) +
  geom_sdv_logos(
    aes(team = team_abbr),
    sport = "nfl",
    width = 0.075
  ) +
  scale_x_continuous(
    breaks = seq_along(levels(factor(divisions$division))),
    labels = levels(factor(divisions$division))
  ) +
  scale_y_reverse() +
  labs(
    title = "NFL Teams by Division",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )
```

## Axis Labels with Logos

Replace axis labels with team logos using
[`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md):

``` r

top_8 <- standings |>
  head(8) |>
  mutate(team = factor(team, levels = team))

ggplot(top_8, aes(x = team, y = win_pct)) +
  geom_col(aes(fill = team), width = 0.6) +
  scale_fill_sdv(sport = "nfl", alpha = 0.7) +
  scale_x_sdv(sport = "nfl") +
  theme_minimal() +
  theme_x_sdv() +
  labs(
    title = "Top 8 NFL Teams",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme(legend.position = "none")
```

## Next Steps

- Explore [nflfastR documentation](https://www.nflfastr.com/)
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
