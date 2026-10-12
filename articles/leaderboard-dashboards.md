# Leaderboard Dashboards with sdvplotR, gt, and Quarto

On this page

## Introduction

This article demonstrates how to create interactive leaderboard
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
nfl_teams <- sdv_teams("nfl")$abbr
nba_teams <- sdv_teams("nba")$abbr
cfb_teams <- sdv_teams("cfb")$abbr
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
  gt_sdv_logos(columns = "logo", league = "nfl", height = 35) |>
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
    footnote = "Example data | Viz: sdvplotR",
    locations = cells_title(groups = "title")
  )
```

| NFL Standings¹ |  |  |  |  |  |  |
|----|----|----|----|----|----|----|
| Example data |  |  |  |  |  |  |
| \# | Team | Abbrev | W | L | T | Win % |
| 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | KC | 9 | 2 | 0 | 0.818 |
| 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | BUF | 8 | 3 | 0 | 0.727 |
| 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | SF | 8 | 3 | 0 | 0.727 |
| 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | PHI | 7 | 4 | 0 | 0.636 |
| 5 | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | DAL | 7 | 4 | 0 | 0.636 |
| 6 | ![Miami Dolphins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b9/b9631269a82abda39bd748afc82390679ca67bfc167bc3581665e237407de8e0.png) | MIA | 6 | 5 | 0 | 0.545 |
| 7 | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | CIN | 6 | 5 | 0 | 0.545 |
| 8 | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | BAL | 6 | 5 | 0 | 0.545 |
| ¹ Example data \| Viz: sdvplotR |  |  |  |  |  |  |

## Advanced Leaderboard with Team Colors

Create a leaderboard with team-colored rows:

``` r

# Add team colors to standings
standings_colored <- standings |>
  mutate(
    primary_color = sdv_team_colors("nfl", team, which = "primary"),
    secondary_color = sdv_team_colors("nfl", team, which = "secondary")
  )

standings_colored |>
  gt() |>
  gt_sdv_logos(columns = "logo", league = "nfl", height = 35) |>
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
| 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | KC | 9 | 2 | 0 | 0.818 | \#e31837 | \#ffb612 |
| 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | BUF | 8 | 3 | 0 | 0.727 | \#00338d | \#c60c30 |
| 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | SF | 8 | 3 | 0 | 0.727 | \#aa0000 | \#b3995d |
| 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | PHI | 7 | 4 | 0 | 0.636 | \#004c54 | \#a5acaf |
| 5 | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | DAL | 7 | 4 | 0 | 0.636 | \#002244 | \#b0b7bc |
| 6 | ![Miami Dolphins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b9/b9631269a82abda39bd748afc82390679ca67bfc167bc3581665e237407de8e0.png) | MIA | 6 | 5 | 0 | 0.545 | \#008e97 | \#f58220 |
| 7 | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | CIN | 6 | 5 | 0 | 0.545 | \#fb4f14 | \#000000 |
| 8 | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | BAL | 6 | 5 | 0 | 0.545 | \#241773 | \#9e7c0c |

## Multi-Sport Leaderboard

Create leaderboards for multiple sports in one table:

``` r

# Sample multi-sport data
multi_sport_standings <- data.frame(
  league = c(rep("NFL", 4), rep("NBA", 4), rep("MLB", 4)),
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
  select(league, rank, team, wins, losses, pct)

multi_sport_standings |>
  gt() |>
  gt_sdv_logos(columns = "team", league = "nfl", height = 30, locations = cells_body(columns = team, rows = league == "NFL")) |>
  gt_sdv_logos(columns = "team", league = "nba", height = 30, locations = cells_body(columns = team, rows = league == "NBA")) |>
  gt_sdv_logos(columns = "team", league = "mlb", height = 30, locations = cells_body(columns = team, rows = league == "MLB")) |>
  fmt_number(columns = "pct", decimals = 3) |>
  cols_label(
    league = "Sport",
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
| NFL | 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | 9 | 2 | 0.818 |
| NFL | 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | 8 | 3 | 0.727 |
| NFL | 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | 8 | 3 | 0.727 |
| NFL | 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | 7 | 4 | 0.636 |
| NBA | 5 | ![Boston Celtics](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0d/0d0d6b85971b1d18428ba1161772b8c2f7e3ee103846ec4b4763bf0cc849ece0.png) | 25 | 8 | 0.758 |
| NBA | 6 | ![Denver Nuggets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/33/33f295fabf1bc3ddb60dfcbefb35ab9a3a91c865752e4539778495aab27f535d.png) | 23 | 10 | 0.697 |
| NBA | 7 | ![Milwaukee Bucks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/84/84fbddec67f59fa143f4fde9c2745ca15f3ad03594da4e677a4a1034aefa6f33.png) | 22 | 11 | 0.667 |
| NBA | 8 | ![Phoenix Suns](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/5f/5f8932efdb7595069610b11ec2f417d78a9213691c2ba21e2bd491c172397ead.png) | 20 | 13 | 0.606 |
| MLB | 9 | ![Los Angeles Dodgers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/aa/aab854c59098d4f465c1c6f31b580f2a38d2ed4f5c0c03df2da76f62f5378dc4.png) | 95 | 67 | 0.586 |
| MLB | 10 | ![Atlanta Braves](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1c/1c36c62410bbed29624672b006173af58bcdfbb066ae9d6f7c4cb99205e861d2.png) | 90 | 72 | 0.556 |
| MLB | 11 | ![Houston Astros](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b7e6858d9d11fe9fade351624bfbab74ec12451749feef37bd1f083d59eb4f7b.png) | 88 | 74 | 0.543 |
| MLB | 12 | ![Baltimore Orioles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e9/e96827050e6079674fa20221f5b8b8acbd4f80843f861dbb4d0261b309741472.png) | 85 | 77 | 0.525 |

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
  gt_sdv_headshots(columns = "player_id", league = "nfl", id_system = "gsis", height = 40) |>
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
| 1 | ![Player 00-0033873 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png) | P. Mahomes | KC | 4,200.00 | 32.00 | 8.00 |
| 2 | ![Player 00-0026498 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/jwpkjfrkzufdyh8u1mg7.png) | M. Stafford | LAR | 3,800.00 | 28.00 | 12.00 |
| 3 | ![Player 00-0035228 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/btfruyf33adgnjzpcuen.png) | K. Murray | ARI | 3,500.00 | 25.00 | 10.00 |
| 4 | ![Player 00-0033869 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/yxs7ix2pmcfv5k1qn1sk.png) | J. Allen | BUF | 4,100.00 | 30.00 | 9.00 |

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
  gt_sdv_logos(columns = "logo", league = "nfl", height = 35) |>
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
| 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | BUF | 8 | 3 | 0 | 0.727 | Q2 (Good) |
| 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | SF | 8 | 3 | 0 | 0.727 | Q2 (Good) |
| 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | PHI | 7 | 4 | 0 | 0.636 | Q2 (Good) |
| 5 | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | DAL | 7 | 4 | 0 | 0.636 | Q2 (Good) |
| 6 | ![Miami Dolphins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b9/b9631269a82abda39bd748afc82390679ca67bfc167bc3581665e237407de8e0.png) | MIA | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| 7 | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | CIN | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| 8 | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | BAL | 6 | 5 | 0 | 0.545 | Q2 (Good) |
| Elite Teams |  |  |  |  |  |  |  |
| 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | KC | 9 | 2 | 0 | 0.818 | Q1 (Elite) |

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
#   gt_sdv_logos(columns = "logo", league = "nfl")
# ```

# ## Team Performance

# ```{r}
# ggplot(standings, aes(x = reorder(team, pct), y = pct)) +
#   geom_col(aes(fill = team), width = 0.7) +
#   scale_fill_sdv(league = "nfl") +
#   theme_minimal()
# ```
```

## Real-Time Leaderboard Updates

Create a leaderboard that updates automatically:

``` r

# Function to fetch and display standings
update_standings <- function(league = "nfl", week = NULL) {
  # In a real implementation, this would fetch live data
  # For demonstration, we'll use sample data

  message(paste("Updating", toupper(league), "standings..."))

  # Sample standings (replace with real data fetch)
  standings <- data.frame(
    team = sample(sdv_teams(league)$abbr, 10),
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
    gt_sdv_logos(columns = "logo", league = league, height = 30) |>
    fmt_number(columns = "pct", decimals = 3)
}

# Update standings
update_standings("nfl")
```

| team | wins | losses | pct | logo | rank |
|----|----|----|----|----|----|
| MIN | 16 | 0 | 1.000 | ![Minnesota Vikings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/72/72759956b149bc1c9496ea6ebb9a6ae34093dfed371cc6abb425c13f14f53448.png) | 4 |
| IND | 7 | 2 | 0.778 | ![Indianapolis Colts](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f1/f1f5222a876f810956aa8d4e75d4e6b47bcb3a6d11f876642b674010233c8a97.png) | 6 |
| ARI | 15 | 6 | 0.714 | ![Arizona Cardinals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f8/f870b58b43585a5b7717d578dd433b0b1e0c462d64ef4bea2aeb8c03f4ae7854.png) | 7 |
| DAL | 8 | 5 | 0.615 | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | 1 |
| CHI | 11 | 9 | 0.550 | ![Chicago Bears](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/fd/fd7b5a207b9ad443f950b384d43dba6cb367c5737ad50a51a15e3893fa31753b.png) | 9 |
| BAL | 14 | 13 | 0.519 | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | 8 |
| KC | 5 | 7 | 0.417 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | 2 |
| TB | 2 | 3 | 0.400 | ![Tampa Bay Buccaneers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bc/bcc5d267024650938c9f35558077fe00a31913b89c61768d4ebb63d1ea31fbfd.png) | 10 |
| LAC | 3 | 16 | 0.158 | ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | 3 |
| NE | 0 | 11 | 0.000 | ![New England Patriots](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/da/dac19aa9a573dcf9075e2422bee3e35a4955b9ab494bb3191ab3bacfd3609729.png) | 5 |

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
  gt_sdv_logos(columns = "logo", league = "nfl", height = 35) |>
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
| 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | KC | 9 | 2 | 0 | 0.818 | 🔥 Hot |
| 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | BUF | 8 | 3 | 0 | 0.727 | ✅ Good |
| 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | SF | 8 | 3 | 0 | 0.727 | ✅ Good |
| 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | PHI | 7 | 4 | 0 | 0.636 | ✅ Good |
| 5 | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | DAL | 7 | 4 | 0 | 0.636 | ✅ Good |
| 6 | ![Miami Dolphins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b9/b9631269a82abda39bd748afc82390679ca67bfc167bc3581665e237407de8e0.png) | MIA | 6 | 5 | 0 | 0.545 | ✅ Good |
| 7 | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | CIN | 6 | 5 | 0 | 0.545 | ✅ Good |
| 8 | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | BAL | 6 | 5 | 0 | 0.545 | ✅ Good |

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
  gt_sdv_logos(columns = "logo", league = "nfl", height = 35) |>
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
| 1 | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | KC | 9 | 2 | 0 | 0.8 | −7.5 | −350 | 48.5 |
| 2 | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | BUF | 8 | 3 | 0 | 0.7 | −3.5 | −180 | 51.5 |
| 3 | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | SF | 8 | 3 | 0 | 0.7 | −6.5 | −280 | 47.5 |
| 4 | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) | PHI | 7 | 4 | 0 | 0.6 | −10.5 | −550 | 45.5 |

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

## Related Articles

- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)
- [Social Posting
  Patterns](https://sdvplotR.sportsdataverse.org/articles/social-posting.md)
- [Workflows](https://sdvplotR.sportsdataverse.org/articles/workflows.md)

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
