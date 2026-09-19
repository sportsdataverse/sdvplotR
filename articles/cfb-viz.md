# CFB Visualizations with cfbfastR, cfbseedR, and sdvplotR

## Introduction

This vignette demonstrates how to create rich CFB (College Football)
visualizations by combining
[cfbfastR](https://cfbfastR.sportsdataverse.org) for play-by-play data,
[cfbseedR](https://cfbseedR.sportsdataverse.org) for playoff/tournament
analysis, and [sdvplotR](https://sdvplotr.sportsdataverse.org) for team
logos, colors, and gt tables.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(cfbfastR)
library(cfbseedR)
library(dplyr)
library(gt)

# Get valid CFB team abbreviations
cfb_teams <- valid_team_names("cfb")
length(cfb_teams)  # ~130 FBS teams
head(cfb_teams)
```

## Loading CFB Data

Use `cfbfastR` to load play-by-play data:

``` r

# Load recent season play-by-play
pbp <- cfbfastR::load_cfb_pbp(
  seasons = cfbfastR::most_recent_cfb_season(),
  epa_wpa = TRUE
)

# Filter to pass plays
pass_plays <- pbp |>
  filter(
    !is.na(EPA),
    pass == 1,
    !is.na(posteam)
  )
```

## Conference Standings with Logos

Create a conference standings table with team logos:

``` r

# Get team info with conferences
team_info <- cfbfastR::cfb_team_info() |>
  filter(conference %in% c("SEC", "Big Ten", "ACC", "Big 12", "Pac-12"))

# Calculate team performance
team_perf <- pass_plays |>
  group_by(posteam) |>
  summarise(
    mean_epa = mean(EPA, na.rm = TRUE),
    n_plays = n(),
    .groups = "drop"
  ) |>
  filter(n_plays >= 100) |>
  inner_join(
    team_info |> select(school = school, conference),
    by = c("posteam" = "school")
  )

# Show SEC teams
sec_teams <- team_perf |>
  filter(conference == "SEC") |>
  arrange(desc(mean_epa))

ggplot(sec_teams, aes(x = reorder(posteam, mean_epa), y = mean_epa)) +
  geom_col(aes(fill = posteam), width = 0.7) +
  scale_fill_sdv(sport = "cfb", alpha = 0.8) +
  labs(
    title = "SEC Teams by Pass EPA per Play",
    subtitle = paste("Season", cfbfastR::most_recent_cfb_season()),
    x = NULL,
    y = "Mean EPA per Play"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )
```

## Playoff Bracket with cfbseedR

Use `cfbseedR` to simulate College Football Playoff brackets:

``` r

# Get current CFP rankings (requires API key)
# rankings <- cfbseedR::cfb_rankings(year = cfbfastR::most_recent_cfb_season())

# Simulate playoff bracket
# bracket_sim <- cfbseedR::cfb_simulate(
#   rankings = rankings,
#   n_sims = 1000
# )

# For demonstration, create sample bracket data
bracket_data <- data.frame(
  seed = 1:12,
  team = c("UGA", "MICH", "WASH", "FSU", "OSU", "TEX",
           "ALA", "ORE", "PSU", "MIZ", "AZ", "LSU")
)

ggplot(bracket_data, aes(x = seed, y = 1)) +
  geom_sdv_logos(
    aes(team = team),
    sport = "cfb",
    width = 0.075
  ) +
  scale_x_continuous(breaks = 1:12) +
  labs(
    title = "College Football Playoff Seeds",
    subtitle = paste("Season", cfbfastR::most_recent_cfb_season()),
    x = "Seed",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )
```

## CFB Team Tiers

Create a tier plot for top CFB teams:

``` r

# Top 25 teams by EPA
top_25 <- team_perf |>
  top_n(25, wt = mean_epa) |>
  mutate(
    tier_no = case_when(
      mean_epa > 0.3 ~ 1,
      mean_epa > 0.2 ~ 2,
      mean_epa > 0.1 ~ 3,
      mean_epa > 0.0 ~ 4,
      TRUE ~ 5
    )
  ) |>
  select(tier_no, team = posteam)

sdv_team_tiers(
  top_25,
  sport = "cfb",
  title = "CFB Power Rankings",
  subtitle = paste("Week", ceiling(runif(1, 1, 15)), "of", cfbfastR::most_recent_cfb_season()),
  tier_desc = c(
    "1" = "Elite",
    "2" = "Playoff Contenders",
    "3" = "Top 25",
    "4" = "Bowl Teams",
    "5" = "Rebuilding"
  ),
  presort = TRUE
)
```

## Conference Map

Visualize all FBS teams by conference:

``` r

# Get conference assignments
conference_map <- team_info |>
  filter(!is.na(conference)) |>
  select(team = school, conference) |>
  mutate(
    conference_num = as.numeric(factor(conference)),
    team_rank = row_number(),
    .by = conference
  ) |>
  arrange(conference_num, team_rank)

ggplot(conference_map, aes(x = conference_num, y = team_rank)) +
  geom_sdv_logos(
    aes(team = team),
    sport = "cfb",
    width = 0.05
  ) +
  scale_x_continuous(
    breaks = 1:length(unique(conference_map$conference)),
    labels = unique(conference_map$conference)
  ) +
  labs(
    title = "FBS Teams by Conference",
    x = "Conference",
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )
```

## CFB Standings Table with Logos

Create a gt table with team logos:

``` r

standings_table <- team_perf |>
  top_n(15, wt = mean_epa) |>
  arrange(desc(mean_epa)) |>
  mutate(
    logo = posteam,
    rank = row_number()
  ) |>
  select(rank, logo, posteam, conference, mean_epa, n_plays)

standings_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "cfb", height = 30) |>
  fmt_number(columns = "mean_epa", decimals = 3) |>
  fmt_number(columns = "n_plays", decimals = 0) |>
  cols_label(
    rank = "#",
    logo = "Team",
    posteam = "School",
    conference = "Conf",
    mean_epa = "EPA/Play",
    n_plays = "Plays"
  ) |>
  tab_header(
    title = "CFB Top 15 by Pass EPA",
    subtitle = paste("Season", cfbfastR::most_recent_cfb_season())
  )
```

## Rivalry Matchups

Visualize rivalry games with both team logos:

``` r

# Define rivalries
rivalries <- data.frame(
  team1 = c("BAMA", "AUB", "OSU", "MICH", "UGA", "UF"),
  team2 = c("AUB", "BAMA", "MICH", "OSU", "UF", "UGA"),
  rivalry = c("Iron Bowl", "Iron Bowl", "The Game", "The Game",
              "World's Largest Outdoor Cocktail Party",
              "World's Largest Outdoor Cocktail Party")
) |>
  distinct(rivalry, .keep_all = TRUE)

ggplot(rivalries, aes(x = 1, y = row_number())) +
  geom_sdv_logos(
    aes(team = team1),
    sport = "cfb",
    width = 0.075,
    hjust = 0
  ) +
  geom_sdv_logos(
    aes(team = team2),
    sport = "cfb",
    width = 0.075,
    hjust = 1
  ) +
  geom_label(
    aes(label = rivalry),
    nudge_y = -0.3,
    alpha = 0.5
  ) +
  scale_x_continuous(limits = c(0.5, 1.5)) +
  labs(
    title = "College Football Rivalries",
    x = NULL,
    y = NULL
  ) +
  theme_void()
```

## Axis Labels with Logos

Replace axis labels with team logos:

``` r

top_10 <- team_perf |>
  top_n(10, wt = mean_epa) |>
  arrange(desc(mean_epa)) |>
  mutate(posteam = factor(posteam, levels = posteam))

ggplot(top_10, aes(x = posteam, y = mean_epa)) +
  geom_col(aes(fill = posteam), width = 0.6) +
  scale_fill_sdv(sport = "cfb", alpha = 0.7) +
  scale_x_sdv(sport = "cfb") +
  theme_x_sdv() +
  theme_minimal() +
  labs(
    title = "Top 10 CFB Teams by Pass EPA",
    x = NULL,
    y = "Mean EPA per Play"
  ) +
  theme(legend.position = "none")
```

## Next Steps

- Explore [cfbfastR
  documentation](https://cfbfastR.sportsdataverse.org/)
- Try [cfbseedR](https://cfbseedR.sportsdataverse.org) for tournament
  simulations
- Combine with [oddsapiR](https://oddsapiR.sportsdataverse.org) for
  betting lines

## Related Vignettes

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
- [Leaderboard
  Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.md)
