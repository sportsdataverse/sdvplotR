# Social Posting Patterns with sdvplotR

## Introduction

This vignette demonstrates best practices for creating shareable sports
graphics using sdvplotR. These patterns are optimized for social media
platforms like Twitter/X, Instagram, and Facebook.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(dplyr)
library(gt)

# Get valid team abbreviations
nfl_teams <- valid_team_names("nfl")
nba_teams <- valid_team_names("nba")
cfb_teams <- valid_team_names("cfb")
```

## Weekly Win-Probability Charts

Create win-probability charts for weekly recaps:

``` r

# Sample game data (replace with real data)
game_data <- data.frame(
  quarter = rep(1:4, each = 10),
  time_left = rep(seq(900, 0, length.out = 10), 4),
  win_prob_home = c(seq(0.5, 0.3, length.out = 10),
                    seq(0.3, 0.6, length.out = 10),
                    seq(0.6, 0.4, length.out = 10),
                    seq(0.4, 0.8, length.out = 10)),
  win_prob_away = c(seq(0.5, 0.7, length.out = 10),
                    seq(0.7, 0.4, length.out = 10),
                    seq(0.4, 0.6, length.out = 10),
                    seq(0.6, 0.2, length.out = 10))
)

ggplot(game_data, aes(x = time_left)) +
  geom_area(aes(y = win_prob_home), fill = "#E31837", alpha = 0.6) +
  geom_area(aes(y = win_prob_away), fill = "#003594", alpha = 0.6) +
  geom_sdv_logos(
    data = data.frame(x = 450, y = 0.5, team = "KC"),
    aes(x = x, y = y, team = team),
    sport = "nfl",
    width = 0.05,
    inherit.aes = FALSE
  ) +
  geom_sdv_logos(
    data = data.frame(x = 450, y = 0.5, team = "BUF"),
    aes(x = x, y = y, team = team),
    sport = "nfl",
    width = 0.05,
    inherit.aes = FALSE
  ) +
  scale_x_reverse() +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Win Probability: KC vs BUF",
    subtitle = "Week 10 Recap",
    x = "Time Remaining",
    y = "Win Probability",
    caption = "Data: nflfastR | Viz: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "grey40", size = 12),
    plot.caption = element_text(color = "grey60", size = 9)
  )
```

## Logo-Rich Scatter Plots

Create eye-catching scatter plots with team logos:

``` r

# Sample EPA data
epa_data <- data.frame(
  team = sample(nfl_teams, 16),
  offensive_epa = runif(16, -0.2, 0.3),
  defensive_epa = runif(16, -0.3, 0.2)
)

ggplot(epa_data, aes(x = offensive_epa, y = defensive_epa)) +
  geom_sdv_logos(
    aes(team = team),
    sport = "nfl",
    width = 0.075
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  labs(
    title = "NFL Team EPA Analysis",
    subtitle = "Offensive vs Defensive Performance",
    x = "Offensive EPA per Play",
    y = "Defensive EPA per Play",
    caption = "Data: nflfastR | Viz: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "grey40", size = 12),
    plot.caption = element_text(color = "grey60", size = 9)
  )
```

## Instagram-Style Square Exports

Create square graphics optimized for Instagram:

``` r

# Top 9 teams by win percentage
top_9 <- data.frame(
  team = sample(nfl_teams, 9),
  win_pct = sort(runif(9, 0.5, 0.9), decreasing = TRUE),
  x = rep(1:3, each = 3),
  y = rep(3:1, 3)
)

ggplot(top_9, aes(x = x, y = y)) +
  geom_sdv_logos(
    aes(team = team),
    sport = "nfl",
    width = 0.15
  ) +
  geom_label(
    aes(label = paste0(round(win_pct * 100, 1), "%")),
    nudge_y = -0.3,
    size = 4,
    alpha = 0.8
  ) +
  coord_equal() +
  labs(
    title = "Top 9 NFL Teams by Win %",
    caption = "Data: nflfastR | Viz: sdvplotR"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.caption = element_text(color = "grey60", size = 10, hjust = 0.5)
  )
```

## Twitter/X Optimized Graphics

Create graphics optimized for Twitter/X (16:9 aspect ratio):

``` r

# Weekly power rankings
power_rankings <- data.frame(
  rank = 1:10,
  team = sample(nfl_teams, 10),
  points = sort(runif(10, 50, 100), decreasing = TRUE)
)

ggplot(power_rankings, aes(x = rank, y = points)) +
  geom_col(aes(fill = team), width = 0.7) +
  geom_sdv_logos(
    aes(team = team),
    sport = "nfl",
    width = 0.05
  ) +
  scale_fill_sdv(sport = "nfl", alpha = 0.8) +
  scale_y_continuous(limits = c(0, 120)) +
  labs(
    title = "Week 10 Power Rankings",
    subtitle = "Top 10 NFL Teams",
    x = "Rank",
    y = "Power Rating",
    caption = "Data: nflfastR | Viz: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 18),
    plot.subtitle = element_text(color = "grey40", size = 14),
    plot.caption = element_text(color = "grey60", size = 10),
    legend.position = "none"
  )
```

## ggsave Best Practices

Export graphics with optimal settings for social media:

``` r

# Save for Twitter (16:9, high DPI)
# ggsave("twitter_graphic.png",
#        width = 16, height = 9, dpi = 300,
#        bg = "white")

# Save for Instagram (1:1 square)
# ggsave("instagram_square.png",
#        width = 10, height = 10, dpi = 300,
#        bg = "white")

# Save for Instagram Stories (9:16)
# ggsave("instagram_story.png",
#        width = 9, height = 16, dpi = 300,
#        bg = "white")

# Save for Facebook (varies, but 1200x630 is common)
# ggsave("facebook_post.png",
#        width = 12, height = 6.3, dpi = 300,
#        bg = "white")
```

## Branding and Watermarks

Add consistent branding to your graphics:

``` r

# Create a branded footer function
add_branding <- function(plot, username = "@YourHandle") {
  plot +
    labs(caption = paste0("Data: nflfastR | Viz: sdvplotR | ", username)) +
    theme(
      plot.caption = element_text(
        color = "grey60",
        size = 9,
        hjust = 1
      )
    )
}

# Apply branding to a plot
sample_plot <- ggplot(data.frame(x = 1:5, y = 1:5), aes(x, y)) +
  geom_point() +
  theme_minimal()

add_branding(sample_plot, "@SportsDataverse")
```

## Multi-Sport Weekly Recap

Create a multi-sport recap graphic:

``` r

# Sample data for multiple sports
multi_sport_data <- data.frame(
  sport = c("NFL", "NBA", "MLB", "NHL", "CFB"),
  team = c("KC", "BOS", "LAD", "COL", "UGA"),
  record = c("8-2", "12-3", "95-67", "45-12-5", "11-1"),
  rank = 1:5
)

ggplot(multi_sport_data, aes(x = rank, y = 1)) +
  geom_sdv_logos(
    data = multi_sport_data[1, ],
    aes(x = rank, y = 1, team = team),
    sport = "nfl",
    width = 0.075,
    inherit.aes = FALSE
  ) +
  geom_sdv_logos(
    data = multi_sport_data[2, ],
    aes(x = rank, y = 1, team = team),
    sport = "nba",
    width = 0.075,
    inherit.aes = FALSE
  ) +
  geom_sdv_logos(
    data = multi_sport_data[3, ],
    aes(x = rank, y = 1, team = team),
    sport = "mlb",
    width = 0.075,
    inherit.aes = FALSE
  ) +
  geom_sdv_logos(
    data = multi_sport_data[4, ],
    aes(x = rank, y = 1, team = team),
    sport = "nhl",
    width = 0.075,
    inherit.aes = FALSE
  ) +
  geom_sdv_logos(
    data = multi_sport_data[5, ],
    aes(x = rank, y = 1, team = team),
    sport = "cfb",
    width = 0.075,
    inherit.aes = FALSE
  ) +
  geom_label(
    aes(label = sport),
    nudge_y = -0.3,
    size = 3,
    alpha = 0.8
  ) +
  geom_label(
    aes(label = record),
    nudge_y = -0.6,
    size = 3,
    alpha = 0.8
  ) +
  scale_x_continuous(breaks = 1:5) +
  labs(
    title = "Weekly Power Rankings",
    subtitle = "Top Teams Across All Sports",
    caption = "Data: SportsDataverse | Viz: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "grey40", size = 12)
  )
```

## Color Palette Showcases

Create graphics showcasing team color palettes:

``` r

# Get team colors for top teams
color_data <- data.frame(
  team = c("KC", "BUF", "SF", "PHI", "DAL"),
  x = 1:5,
  y = 1
)

ggplot(color_data, aes(x = x, y = y)) +
  geom_col(aes(fill = team), width = 0.8) +
  scale_fill_sdv(sport = "nfl", alpha = 1) +
  labs(
    title = "NFL Team Color Palettes",
    subtitle = "Primary Colors",
    caption = "Data: sdvplotR"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(color = "grey40", size = 12)
  )
```

## Tips for Social Media Success

1.  **Aspect Ratios**: Use platform-specific aspect ratios (16:9 for
    Twitter, 1:1 for Instagram posts, 9:16 for Stories)

2.  **Text Size**: Use large, readable fonts (minimum 14pt for titles)

3.  **High DPI**: Export at 300 DPI for crisp images

4.  **Branding**: Include consistent watermarks and handles

5.  **Accessibility**: Use high-contrast colors and alt text

6.  **Consistency**: Post at regular intervals with consistent styling

## Related Vignettes

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Leaderboard
  Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.md)
- [Workflows](https://sdvplotR.sportsdataverse.org/articles/workflows.md)
