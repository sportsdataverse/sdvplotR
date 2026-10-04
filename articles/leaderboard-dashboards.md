# Leaderboard Dashboards with sdvplotR, gt, and Quarto

On this page

## Introduction

This vignette demonstrates how to create interactive leaderboard
dashboards using sdvplotR, gt tables, and Quarto. These patterns are
perfect for tracking standings, player stats, and team performance in
real-time.

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

## Basic Leaderboard with Logos

Create a simple leaderboard table with team logos:

``` r

# Sample standings data
standings <- data.frame(
  team = c("KC", "BUF", "SF", "PHI", "DAL", "MIA", "CIN", "BAL"),
  wins = c(9, 8, 8, 7, 7, 6, 6, 6),
  losses = c(2, 3, 3, 4, 4, 5, 5, 5),
  ties = c(0, 0, 0, 0, 0, 0, 0, 0),
  pct = c(0.818, 0.727, 0.727, 0.636, 0.636, 0.545, 0.545, 0.545)
) |>
  mutate(
    logo = team,
    rank = row_number()
  ) |>
  select(rank, logo, team, wins, losses, ties, pct)

standings |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team = "Abbrev",
    wins = "W",
    losses = "L",
    ties = "T",
    pct = "Win %"
  ) |>
  tab_header(
    title = "NFL Standings",
    subtitle = "Example data"
  ) |>
  tab_footnote(
    footnote = "Data: nflfastR | Viz: sdvplotR",
    locations = cells_title(groups = "title")
  )
```

| NFL Standings¹ |  |  |  |  |  |  |
|----|----|----|----|----|----|----|
| Example data |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | T | Win % |
| 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | KC | 9 | 2 | 0 | 0.818 |
| 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | BUF | 8 | 3 | 0 | 0.727 |
| 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | SF | 8 | 3 | 0 | 0.727 |
| 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | PHI | 7 | 4 | 0 | 0.636 |
| 5 | ![The DAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | DAL | 7 | 4 | 0 | 0.636 |
| 6 | ![The MIA logo](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | MIA | 6 | 5 | 0 | 0.545 |
| 7 | ![The CIN logo](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | CIN | 6 | 5 | 0 | 0.545 |
| 8 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | BAL | 6 | 5 | 0 | 0.545 |
| ¹ Data: nflfastR \| Viz: sdvplotR |  |  |  |  |  |  |

## Advanced Leaderboard with Team Colors

Create a leaderboard with team-colored rows:

``` r

# Add team colors to standings
standings_colored <- standings |>
  mutate(
    primary_color = sdv_team_colors("nfl", team, type = "primary"),
    secondary_color = sdv_team_colors("nfl", team, type = "secondary")
  )

standings_colored |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team = "Abbrev",
    wins = "W",
    losses = "L",
    ties = "T",
    pct = "Win %"
  ) |>
  tab_header(
    title = "NFL Standings",
    subtitle = "Example data"
  ) |>
  data_color(
    columns = "pct",
    palette = c("lightblue", "darkblue"),
    # pick black or white text by WCAG contrast (gt's default, APCA, put white text on
    # mid-blue cells at 3.1:1)
    contrast_algo = "wcag"
  )
```

| NFL Standings |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Example data |  |  |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | T | Win % | primary_color | secondary_color |
| 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | KC | 9 | 2 | 0 | 0.818 | \#E31837 | \#FFB612 |
| 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | BUF | 8 | 3 | 0 | 0.727 | \#00338D | \#C60C30 |
| 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | SF | 8 | 3 | 0 | 0.727 | \#AA0000 | \#B3995D |
| 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | PHI | 7 | 4 | 0 | 0.636 | \#004C54 | \#A5ACAF |
| 5 | ![The DAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | DAL | 7 | 4 | 0 | 0.636 | \#002244 | \#B0B7BC |
| 6 | ![The MIA logo](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | MIA | 6 | 5 | 0 | 0.545 | \#008E97 | \#F58220 |
| 7 | ![The CIN logo](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | CIN | 6 | 5 | 0 | 0.545 | \#FB4F14 | \#000000 |
| 8 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | BAL | 6 | 5 | 0 | 0.545 | \#241773 | \#9E7C0C |

## Multi-Sport Leaderboard

Create leaderboards for multiple sports in one table:

``` r

# Sample multi-sport data
multi_sport_standings <- data.frame(
  sport = c(rep("NFL", 4), rep("NBA", 4), rep("MLB", 4)),
  team = c("KC", "BUF", "SF", "PHI",
           "BOS", "DEN", "MIL", "PHX",
           "LAD", "ATL", "HOU", "BAL"),
  wins = c(9, 8, 8, 7, 25, 23, 22, 20, 95, 90, 88, 85),
  losses = c(2, 3, 3, 4, 8, 10, 11, 13, 67, 72, 74, 77)
) |>
  mutate(
    pct = wins / (wins + losses),
    rank = row_number()
  ) |>
  select(sport, rank, team, wins, losses, pct)

multi_sport_standings |>
  gt() |>
  gt_sdv_logos(columns = "team", sport = "nfl", height = 30) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    sport = "Sport",
    rank = "#",
    team = "Team",
    wins = "W",
    losses = "L",
    pct = "Win %"
  ) |>
  tab_header(
    title = "Multi-Sport Leaderboard",
    subtitle = "Top Teams Across Sports"
  )
```

| Multi-Sport Leaderboard |  |  |  |  |  |
|----|----|----|----|----|----|
| Top Teams Across Sports |  |  |  |  |  |
| Sport | \# | Team | W | L | Win % |
| NFL | 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | 9 | 2 | 0.818 |
| NFL | 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | 8 | 3 | 0.727 |
| NFL | 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | 8 | 3 | 0.727 |
| NFL | 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | 7 | 4 | 0.636 |
| NBA | 5 | BOS | 25 | 8 | 0.758 |
| NBA | 6 | ![The DEN logo](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | 23 | 10 | 0.697 |
| NBA | 7 | MIL | 22 | 11 | 0.667 |
| NBA | 8 | PHX | 20 | 13 | 0.606 |
| MLB | 9 | LAD | 95 | 67 | 0.586 |
| MLB | 10 | ![The ATL logo](https://a.espncdn.com/i/teamlogos/nfl/500/atl.png) | 90 | 72 | 0.556 |
| MLB | 11 | ![The HOU logo](https://a.espncdn.com/i/teamlogos/nfl/500/hou.png) | 88 | 74 | 0.543 |
| MLB | 12 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | 85 | 77 | 0.525 |

## Player Leaderboard with Headshots

Create a player stats table with headshots:

``` r

# Sample player data
player_stats <- data.frame(
  player_id = c("00-0033873", "00-0026498", "00-0035228", "00-0033869"),
  player_name = c("P. Mahomes", "M. Stafford", "K. Murray", "J. Allen"),
  team = c("KC", "LAR", "ARI", "BUF"),
  pass_yds = c(4200, 3800, 3500, 4100),
  pass_td = c(32, 28, 25, 30),
  pass_int = c(8, 12, 10, 9)
) |>
  mutate(
    rank = row_number()
  ) |>
  select(rank, player_id, player_name, team, pass_yds, pass_td, pass_int)

player_stats |>
  gt() |>
  gt_sdv_headshots(columns = "player_id", sport = "nfl", height = 40) |>
  fmt_number(columns = c("pass_yds", "pass_td", "pass_int")) |>
  cols_label(
    rank = "#",
    player_id = "Player",
    player_name = "Name",
    team = "Team",
    pass_yds = "Yards",
    pass_td = "TD",
    pass_int = "INT"
  ) |>
  tab_header(
    title = "NFL Quarterback Leaderboard",
    subtitle = "Top Passers by Yards"
  )
```

| NFL Quarterback Leaderboard |  |  |  |  |  |  |
|----|----|----|----|----|----|----|
| Top Passers by Yards |  |  |  |  |  |  |
| \# | Player | Name | Team | Yards | TD | INT |
| 1 | ![](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png) | P. Mahomes | KC | 4,200.00 | 32.00 | 8.00 |
| 2 | ![](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/jwpkjfrkzufdyh8u1mg7.png) | M. Stafford | LAR | 3,800.00 | 28.00 | 12.00 |
| 3 | ![](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/btfruyf33adgnjzpcuen.png) | K. Murray | ARI | 3,500.00 | 25.00 | 10.00 |
| 4 | ![](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/yxs7ix2pmcfv5k1qn1sk.png) | J. Allen | BUF | 4,100.00 | 30.00 | 9.00 |

## Quartile-Based Leaderboard

Create a leaderboard with quartile indicators:

``` r

# Add quartile information
standings_quartile <- standings |>
  mutate(
    quartile = case_when(
      pct >= 0.75 ~ "Q1 (Elite)",
      pct >= 0.50 ~ "Q2 (Good)",
      pct >= 0.25 ~ "Q3 (Average)",
      TRUE ~ "Q4 (Struggling)"
    )
  )

standings_quartile |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team = "Abbrev",
    wins = "W",
    losses = "L",
    ties = "T",
    pct = "Win %",
    quartile = "Quartile"
  ) |>
  tab_header(
    title = "NFL Standings by Quartile",
    subtitle = "Example data"
  ) |>
  tab_row_group(
    label = "Elite Teams",
    rows = pct >= 0.75
  ) |>
  tab_row_group(
    label = "Playoff Teams",
    rows = pct >= 0.50 & pct < 0.75
  )
```

| NFL Standings by Quartile |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| Example data |  |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | T | Win % | Quartile |
| Playoff Teams |  |  |  |  |  |  |  |
| 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | BUF | 8 | 3 | 0 | 0.727 | Q2 (Good) |
| 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | SF | 8 | 3 | 0 | 0.727 | Q2 (Good) |
| 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | PHI | 7 | 4 | 0 | 0.636 | Q2 (Good) |
| 5 | ![The DAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | DAL | 7 | 4 | 0 | 0.636 | Q2 (Good) |
| 6 | ![The MIA logo](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | MIA | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| 7 | ![The CIN logo](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | CIN | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| 8 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | BAL | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| Elite Teams |  |  |  |  |  |  |  |
| 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | KC | 9 | 2 | 0 | 0.818 | Q1 (Elite) |

## Quarto Dashboard Integration

Create a Quarto dashboard with sdvplotR visualizations:

``` r

# In a Quarto document (.qmd), use this structure:

# ---
# title: "NFL Dashboard"
# format: dashboard
# ---

# ## Standings

# ```{r}
# standings |>
#   gt() |>
#   gt_sdv_logos(columns = "logo", sport = "nfl")
# ```

# ## Team Performance

# ```{r}
# ggplot(standings, aes(x = reorder(team, pct), y = pct)) +
#   geom_col(aes(fill = team), width = 0.7) +
#   scale_fill_sdv(sport = "nfl") +
#   theme_minimal()
# ```
```

## Real-Time Leaderboard Updates

Create a leaderboard that updates automatically:

``` r

# Function to fetch and display standings
update_standings <- function(sport = "nfl", week = NULL) {
  # In a real implementation, this would fetch live data
  # For demonstration, we'll use sample data

  message(paste("Updating", toupper(sport), "standings..."))

  # Sample standings (replace with real data fetch)
  standings <- data.frame(
    team = sample(valid_team_names(sport), 10),
    wins = sample(0:16, 10),
    losses = sample(0:16, 10)
  ) |>
    mutate(
      pct = wins / (wins + losses),
      logo = team,
      rank = row_number()
    ) |>
    arrange(desc(pct)) |>
    head(10)

  standings |>
    gt() |>
    gt_sdv_logos(columns = "logo", sport = sport, height = 30) |>
    fmt_number(columns = "pct", decimals = 3)
}

# Update standings
update_standings("nfl")
```

| team | wins | losses | pct | logo | rank |
|----|----|----|----|----|----|
| CLE | 16 | 0 | 1.000 | ![The CLE logo](https://a.espncdn.com/i/teamlogos/nfl/500/cle.png) | 4 |
| BAL | 7 | 2 | 0.778 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | 6 |
| JAX | 15 | 6 | 0.714 | ![The JAX logo](https://a.espncdn.com/i/teamlogos/nfl/500/jax.png) | 7 |
| SF | 8 | 5 | 0.615 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | 1 |
| NO | 11 | 9 | 0.550 | ![The NO logo](https://a.espncdn.com/i/teamlogos/nfl/500/no.png) | 9 |
| NYJ | 14 | 13 | 0.519 | ![The NYJ logo](https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png) | 8 |
| BUF | 5 | 7 | 0.417 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | 2 |
| MIA | 2 | 3 | 0.400 | ![The MIA logo](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | 10 |
| LA | 3 | 16 | 0.158 | ![The LA logo](https://a.espncdn.com/i/teamlogos/nfl/500/lar.png) | 3 |
| DAL | 0 | 11 | 0.000 | ![The DAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | 5 |

## Conditional Formatting

Apply conditional formatting based on performance:

``` r

# Add performance indicators
standings_conditional <- standings |>
  mutate(
    performance = case_when(
      pct >= 0.75 ~ "🔥 Hot",
      pct >= 0.50 ~ "✅ Good",
      pct >= 0.25 ~ "⚠️ Average",
      TRUE ~ "❌ Struggling"
    )
  )

standings_conditional |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team = "Abbrev",
    wins = "W",
    losses = "L",
    ties = "T",
    pct = "Win %",
    performance = "Status"
  ) |>
  tab_header(
    title = "NFL Standings with Status",
    subtitle = "Example data"
  )
```

| NFL Standings with Status |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| Example data |  |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | T | Win % | Status |
| 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | KC | 9 | 2 | 0 | 0.818 | 🔥 Hot |
| 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | BUF | 8 | 3 | 0 | 0.727 | ✅ Good |
| 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | SF | 8 | 3 | 0 | 0.727 | ✅ Good |
| 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | PHI | 7 | 4 | 0 | 0.636 | ✅ Good |
| 5 | ![The DAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | DAL | 7 | 4 | 0 | 0.636 | ✅ Good |
| 6 | ![The MIA logo](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | MIA | 6 | 5 | 0 | 0.545 | ✅ Good |
| 7 | ![The CIN logo](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | CIN | 6 | 5 | 0 | 0.545 | ✅ Good |
| 8 | ![The BAL logo](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | BAL | 6 | 5 | 0 | 0.545 | ✅ Good |

## Integrating with oddsapiR

Combine standings with betting odds:

``` r

# Sample odds data (replace with real oddsapiR data)
odds_data <- data.frame(
  team = c("KC", "BUF", "SF", "PHI"),
  spread = c(-7.5, -3.5, -6.5, -10.5),
  moneyline = c(-350, -180, -280, -550),
  total = c(48.5, 51.5, 47.5, 45.5)
)

# Merge with standings
standings_with_odds <- standings |>
  filter(team %in% odds_data$team) |>
  left_join(odds_data, by = "team") |>
  mutate(logo = team)

standings_with_odds |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "nfl", height = 35) |>
  fmt_number(columns = c("pct", "spread", "total"), decimals = 1) |>
  fmt_number(columns = "moneyline", decimals = 0) |>
  cols_label(
    rank = "#",
    logo = "Team",
    team = "Abbrev",
    wins = "W",
    losses = "L",
    pct = "Win %",
    spread = "Spread",
    moneyline = "ML",
    total = "O/U"
  ) |>
  tab_header(
    title = "NFL Standings with Betting Odds",
    subtitle = "Combining Performance and Odds"
  )
```

| NFL Standings with Betting Odds |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|
| Combining Performance and Odds |  |  |  |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | ties | Win % | Spread | ML | O/U |
| 1 | ![The KC logo](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | KC | 9 | 2 | 0 | 0.8 | −7.5 | −350 | 48.5 |
| 2 | ![The BUF logo](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | BUF | 8 | 3 | 0 | 0.7 | −3.5 | −180 | 51.5 |
| 3 | ![The SF logo](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | SF | 8 | 3 | 0 | 0.7 | −6.5 | −280 | 47.5 |
| 4 | ![The PHI logo](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) | PHI | 7 | 4 | 0 | 0.6 | −10.5 | −550 | 45.5 |

## Best Practices for Dashboards

1.  **Keep it Simple**: Focus on key metrics that matter to your
    audience

2.  **Use Consistent Branding**: Apply the same colors, fonts, and logos
    across all visualizations

3.  **Make it Interactive**: Use Quarto dashboards for interactive
    exploration

4.  **Update Regularly**: Set up automated updates to keep data fresh

5.  **Optimize for Mobile**: Ensure dashboards work on mobile devices

6.  **Add Context**: Include captions, footnotes, and data sources

## Related Vignettes

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
- [Workflows](https://sdvplotR.sportsdataverse.org/articles/workflows.md)
