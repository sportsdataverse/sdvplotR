# MBB Visualizations with hoopR and sdvplotR

On this page

## Introduction

This vignette demonstrates how to create rich MBB (Men’s College
Basketball) visualizations by combining
[hoopR](https://hoopR.sportsdataverse.org) for player and team data and
[sdvplotR](https://sdvplotr.sportsdataverse.org) for team logos,
headshots, colors, and gt tables.

## Setup

``` r

library(sdvplotR)
library(ggplot2)
library(hoopR)
library(dplyr)
library(gt)

# Get valid MBB team abbreviations
mbb_teams <- valid_team_names("mbb")
length(mbb_teams)  # ~350+ D1 teams
#> [1] 366
head(mbb_teams)
#> [1] "AAMU" "ACU"  "AF"   "AKR"  "ALA"  "ALCN"
```

## Loading MBB Data

Use `hoopR` to load this season’s ESPN team and player box scores:

``` r

# The last completed regular season (hoopR names a season for the year it
# ends; the regular season ends in mid-March)
season <- as.integer(format(Sys.Date(), "%Y")) -
  (format(Sys.Date(), "%m-%d") < "03-20")

# One row per team per game (ESPN box scores), regular season only; Division I
# teams only (the box scores also hold their games against other divisions)
team_stats <- hoopR::load_mbb_team_box(seasons = season) |>
  filter(season_type == 2, team_abbreviation %in% team_reference("mbb")$team_abbr)

# One row per player per game, with ESPN athlete IDs; players who did not
# play are dropped so games played counts real games
player_stats <- hoopR::load_mbb_player_box(seasons = season) |>
  filter(season_type == 2, !did_not_play)
```

## MBB Team Performance

Visualize team performance with team logos:

``` r

# Calculate team metrics
team_perf <- team_stats |>
  filter(!is.na(team_abbreviation)) |>
  group_by(team_id, team_abbreviation) |>
  summarise(
    avg_points = mean(team_score, na.rm = TRUE),
    avg_rebounds = mean(total_rebounds, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 10)

ggplot(team_perf, aes(x = avg_points, y = avg_rebounds)) +
  geom_sdv_logos(
    aes(team = team_abbreviation),
    sport = "mbb",
    width = 0.075
  ) +
  labs(
    title = "MBB Team Performance",
    subtitle = paste("Season", season),
    x = "Average Points per Game",
    y = "Average Rebounds per Game",
    caption = "Data: hoopR | Viz: sdvplotR"
  ) +
  theme_minimal()
```

![Men's college basketball teams in the latest completed season, each
drawn as its logo, placed by average points (horizontal) and average
rebounds (vertical) per
game.](mbb-viz_files/figure-html/team-performance-1.png)

## MBB Team Colors

Use team colors to visualize win percentages:

``` r

# Calculate win percentage
team_wins <- team_stats |>
  filter(!is.na(team_abbreviation)) |>
  group_by(team_id, team_abbreviation) |>
  summarise(
    wins = sum(team_winner, na.rm = TRUE),
    games = n(),
    .groups = "drop"
  ) |>
  filter(games >= 10) |>
  mutate(win_pct = wins / games) |>
  arrange(desc(win_pct)) |>
  head(25)

ggplot(team_wins, aes(x = reorder(team_abbreviation, win_pct), y = win_pct)) +
  geom_col(aes(fill = team_abbreviation), width = 0.7) +
  scale_fill_sdv(sport = "mbb", alpha = 0.8) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Top 25 MBB Teams by Win Percentage",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )
```

![Bar chart of the 25 men's college basketball teams with the best win
percentage in the latest completed season, each bar filled in the team's
color.](mbb-viz_files/figure-html/team-colors-1.png)

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
    sport = "mbb",
    height = 0.1
  ) +
  # Labels sit a fixed share of the y range below their face; ggrepel moves
  # the ones that would collide and draws a connector back to the player
  ggrepel::geom_label_repel(
    aes(label = athlete_display_name),
    nudge_y = -0.22 * diff(range(top_scorers$avg_points)),
    size = 3,
    alpha = 0.7,
    box.padding = 0.5,
    point.size = 12,
    min.segment.length = 0,
    seed = 1
  ) +
  scale_x_continuous(expand = expansion(mult = 0.15)) +
  scale_y_continuous(expand = expansion(mult = c(0.35, 0.2))) +
  labs(
    title = "Top 8 MBB Scorers",
    subtitle = paste("Season", season),
    x = "Games Played",
    y = "Average Points per Game"
  ) +
  theme_minimal()
```

![Men's college basketball points per game leaders of the latest
completed season, each drawn as a headshot placed by games played
(horizontal) and points per game (vertical), with a name label under
each.](mbb-viz_files/figure-html/player-headshots-1.png)

## Tournament Seeds with Logos

Plot a set of tournament seeds with team logos. These seeds are an
example; swap in the real bracket once it is announced:

``` r

# For demonstration, create sample bracket data
bracket_data <- data.frame(
  seed = 1:16,
  team = c("HOU", "UCLA", "KANSAS", "PURDUE", "GONZAGA", "BAYLOR",
           "ARIZONA", "DUKE", "CREIGHTON", "MARQUETTE", "TEXAS",
           "AUBURN", "MSU", "TENN", "SDSU", "TCU")
)

ggplot(bracket_data, aes(x = seed, y = 1)) +
  geom_sdv_logos(
    aes(team = team),
    sport = "mbb",
    width = 0.042
  ) +
  scale_x_continuous(breaks = 1:16) +
  labs(
    title = "Example NCAA Tournament Seeds",
    subtitle = "Example seeds for illustration, not a real bracket",
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

![Example NCAA tournament seeds, each team drawn as its logo in seed
order; the seeds are for illustration, not a real
bracket.](mbb-viz_files/figure-html/march-madness-1.png)

## MBB Team Tiers

Create a tier plot ranking MBB teams:

``` r

# Top 25 teams by win percentage
top_25 <- team_wins |>
  mutate(
    tier_no = case_when(
      win_pct > 0.85 ~ 1,
      win_pct > 0.75 ~ 2,
      win_pct > 0.65 ~ 3,
      win_pct > 0.55 ~ 4,
      TRUE ~ 5
    )
  ) |>
  select(tier_no, team = team_abbreviation)

sdv_team_tiers(
  top_25,
  sport = "mbb",
  title = "MBB Team Tiers",
  subtitle = paste("Example tiers,", season, "season"),
  tier_desc = c(
    "1" = "Elite",
    "2" = "Championship Contenders",
    "3" = "Top 25",
    "4" = "Bubble Teams",
    "5" = "Rebuilding"
  ),
  presort = TRUE
)
```

![Men's college basketball team logos grouped into labeled tiers, from
the top tier to the bottom. The tiers are
examples.](mbb-viz_files/figure-html/team-tiers-1.png)

## MBB Conference Map

Show each major conference’s teams in a column:

``` r

# The five major conferences, from the conferences sdvplotR keeps for every team
conference_map <- team_reference("mbb") |>
  filter(conference %in% c("ACC", "Big 12", "Big East", "Big Ten", "SEC")) |>
  arrange(conference, team_location) |>
  group_by(conference) |>
  mutate(team_rank = row_number()) |>
  ungroup() |>
  mutate(conference_num = as.numeric(factor(conference)))

ggplot(conference_map, aes(x = conference_num, y = team_rank)) +
  geom_sdv_logos(
    aes(team = team_abbr),
    sport = "mbb",
    width = 0.05
  ) +
  scale_x_continuous(
    breaks = seq_along(levels(factor(conference_map$conference))),
    labels = levels(factor(conference_map$conference))
  ) +
  scale_y_reverse() +
  labs(
    title = "MBB Teams in the Major Conferences",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_blank(),
    panel.grid = element_blank()
  )
```

![Grid of men's college basketball team logos, one column per major
conference, so each team sits under its major
conference.](mbb-viz_files/figure-html/conference-map-1.png)

## MBB Standings Table with Logos

Create a gt table with team logos:

``` r

standings_table <- team_wins |>
  head(20) |>
  mutate(
    logo = team_abbreviation,
    rank = row_number()
  ) |>
  select(rank, logo, team_abbreviation, wins, games, win_pct)

standings_table |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "mbb", height = 30) |>
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
    title = "MBB Top 20",
    subtitle = paste("Season", season)
  )
```

| MBB Top 20 |  |  |  |  |  |
|----|----|----|----|----|----|
| Season 2026 |  |  |  |  |  |
| \# | Team | Abbrev | Wins | Games | Win % |
| 1 | ![Miami (OH) RedHawks](https://a.espncdn.com/i/teamlogos/ncaa/500/193.png) | M-OH | 31 | 32 | 0.969 |
| 2 | ![Arizona Wildcats](https://a.espncdn.com/i/teamlogos/ncaa/500/12.png) | ARIZ | 32 | 34 | 0.941 |
| 3 | ![Duke Blue Devils](https://a.espncdn.com/i/teamlogos/ncaa/500/150.png) | DUKE | 32 | 34 | 0.941 |
| 4 | ![Michigan Wolverines](https://a.espncdn.com/i/teamlogos/ncaa/500/130.png) | MICH | 31 | 34 | 0.912 |
| 5 | ![Gonzaga Bulldogs](https://a.espncdn.com/i/teamlogos/ncaa/500/2250.png) | GONZ | 30 | 33 | 0.909 |
| 6 | ![High Point Panthers](https://a.espncdn.com/i/teamlogos/ncaa/500/2272.png) | HPU | 30 | 34 | 0.882 |
| 7 | ![UConn Huskies](https://a.espncdn.com/i/teamlogos/ncaa/500/41.png) | CONN | 29 | 34 | 0.853 |
| 8 | ![Virginia Cavaliers](https://a.espncdn.com/i/teamlogos/ncaa/500/258.png) | UVA | 29 | 34 | 0.853 |
| 9 | ![Akron Zips](https://a.espncdn.com/i/teamlogos/ncaa/500/2006.png) | AKR | 29 | 34 | 0.853 |
| 10 | ![Saint Louis Billikens](https://a.espncdn.com/i/teamlogos/ncaa/500/139.png) | SLU | 28 | 33 | 0.848 |
| 11 | ![McNeese Cowboys](https://a.espncdn.com/i/teamlogos/ncaa/500/2377.png) | MCN | 28 | 33 | 0.848 |
| 12 | ![Stephen F. Austin Lumberjacks](https://a.espncdn.com/i/teamlogos/ncaa/500/2617.png) | SFA | 28 | 33 | 0.848 |
| 13 | ![Saint Mary's Gaels](https://a.espncdn.com/i/teamlogos/ncaa/500/2608.png) | SMC | 27 | 32 | 0.844 |
| 14 | ![Houston Cougars](https://a.espncdn.com/i/teamlogos/ncaa/500/248.png) | HOU | 28 | 34 | 0.824 |
| 15 | ![Utah State Aggies](https://a.espncdn.com/i/teamlogos/ncaa/500/328.png) | USU | 28 | 34 | 0.824 |
| 16 | ![St. John's Red Storm](https://a.espncdn.com/i/teamlogos/ncaa/500/2599.png) | SJU | 28 | 34 | 0.824 |
| 17 | ![Nebraska Cornhuskers](https://a.espncdn.com/i/teamlogos/ncaa/500/158.png) | NEB | 26 | 32 | 0.812 |
| 18 | ![UNC Wilmington Seahawks](https://a.espncdn.com/i/teamlogos/ncaa/500/350.png) | UNCW | 26 | 32 | 0.812 |
| 19 | ![Belmont Bruins](https://a.espncdn.com/i/teamlogos/ncaa/500/2057.png) | BEL | 26 | 32 | 0.812 |
| 20 | ![Yale Bulldogs](https://a.espncdn.com/i/teamlogos/ncaa/500/43.png) | YALE | 24 | 30 | 0.800 |

## Axis Labels with Logos

Replace axis labels with team logos:

``` r

top_8 <- team_wins |>
  head(8) |>
  mutate(team_abbreviation = factor(team_abbreviation, levels = team_abbreviation))

ggplot(top_8, aes(x = team_abbreviation, y = win_pct)) +
  geom_col(aes(fill = team_abbreviation), width = 0.6) +
  scale_fill_sdv(sport = "mbb", alpha = 0.7) +
  scale_x_sdv(sport = "mbb") +
  theme_minimal() +
  theme_x_sdv() +
  labs(
    title = "Top 8 MBB Teams by Win %",
    x = NULL,
    y = "Win Percentage"
  ) +
  theme(legend.position = "none")
```

![Bar chart of the top 8 men's college basketball teams by win
percentage, with each team's logo in place of its name on the horizontal
axis and bars in team
colors.](mbb-viz_files/figure-html/axis-logos-1.png)

## Next Steps

- Explore [hoopR documentation](https://hoopR.sportsdataverse.org/)
- Combine with [oddsapiR](https://oddsapiR.sportsdataverse.org) for
  betting lines

## Related Vignettes

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
- [Leaderboard
  Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.md)
