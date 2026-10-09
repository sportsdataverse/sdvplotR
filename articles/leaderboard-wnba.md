# WNBA Leaderboard

On this page

**Updated 2026-10-09:** the final 2026 regular season; the playoffs are
under way.

This page is rebuilt every week with the site. It builds the standings
with offensive, defensive and net ratings, plots offense against defense
and lists the scoring leaders with their headshots, for the latest WNBA
season with games: the season to date from May to September, the final
regular season once it is over. Data:
[wehoop](https://wehoop.sportsdataverse.org)’s ESPN box scores, read
from release files (no stats.wnba.com calls).

## Picking the season

The WNBA season tips off in May, so until then the calendar points at
last season.
[`wehoop::load_wnba_team_box()`](https://wehoop.sportsdataverse.org/reference/load_wnba_draft.html)
errors for a season past wehoop’s most recent one, and a new season’s
file can hold only preseason games at first, so the helper treats “no
regular-season games” as “not published” and the page steps back one
season. The status line says what the numbers cover.

``` r

library(sdvplotR)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(gt)

today <- Sys.Date()
day_label <- function(day, month = "%b") sub(" 0", " ", format(as.Date(day), paste(month, "%d"))) # "Oct 5"
# The season tips off in May, so until then the calendar points at last season
current <- as.integer(format(today, "%Y")) - (format(today, "%m") < "05")

# A season's team box scores, or NULL when it has no regular-season games yet:
# load_wnba_team_box() errors for a season past wehoop's most recent one, and a
# new season's file can hold only preseason games at first
team_games <- function(season) {
  box <- tryCatch(suppressWarnings(wehoop::load_wnba_team_box(seasons = season)), error = function(e) NULL)
  if (NROW(box) == 0 || !any(box$season_type == 2)) NULL else box
}

season <- current
box <- team_games(season)
if (is.null(box)) {
  season <- current - 1
  box <- team_games(season)
}
stopifnot(!is.null(box))

last_game <- max(box$game_date)
playoffs <- filter(box, season_type == 3)
if (season < current) {
  status <- sprintf(
    "the offseason, so this is the final %d regular season; the %d season has no games yet.",
    season, current
  )
  through <- "final regular season"
} else if (nrow(playoffs) == 0) {
  status <- sprintf("the %d season through %s.", season, day_label(last_game, "%B"))
  through <- paste("through", day_label(last_game))
} else if (as.numeric(today - max(playoffs$game_date)) <= 10) {
  status <- sprintf("the final %d regular season; the playoffs are under way.", season)
  through <- "final regular season"
} else {
  status <- sprintf("the offseason, so this is the final %d regular season.", season)
  through <- "final regular season"
}
```

ESPN files the All-Star Game and the Commissioner’s Cup final as
regular-season games, though neither counts in the standings; the
schedule marks them in `type_abbreviation` (`ALLSTAR`, `CC`), so keep
the standard games (`STD`) only. That also drops the All-Star teams,
whose abbreviations are not franchises.

``` r

standard <- wehoop::load_wnba_schedule(seasons = season) |>
  filter(season_type == 2, type_abbreviation == "STD")
stopifnot(identical(class(box$game_id), class(standard$game_id)))

games <- box |>
  filter(season_type == 2, game_id %in% standard$game_id) |>
  mutate(poss = field_goals_attempted - offensive_rebounds + total_turnovers +
    0.44 * free_throws_attempted) |>
  group_by(game_id) |>
  mutate(poss = mean(poss, na.rm = TRUE)) |> # one side's box can miss a count; the other covers it
  ungroup()

teams <- team_reference("wnba") |>
  select(team = team_abbr, name = team_short_name, conference)
ratings <- games |>
  arrange(game_date, game_id) |>
  group_by(team = team_abbreviation) |>
  summarise(
    w = sum(team_winner), l = sum(!team_winner),
    l10 = sum(tail(team_winner, 10)),
    ortg = 100 * sum(team_score) / sum(poss),
    drtg = 100 * sum(opponent_team_score) / sum(poss),
    .groups = "drop"
  ) |>
  mutate(pct = w / (w + l), net = ortg - drtg) |>
  inner_join(teams, by = "team") |>
  arrange(desc(pct), desc(net), team) # the team breaks a tie, so an unchanged week renders the same
nrow(ratings)
#> [1] 15
```

## 1. Standings with net rating

One table for the league, ordered by winning percentage (the WNBA seeds
its playoffs league-wide), with the conference beside each team and its
points scored and allowed per 100 possessions.
[`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md)
draws net rating on a scale centred at zero.

``` r

standings <- ratings |>
  mutate(
    seed = row_number(),
    record = paste(w, l, sep = "-"),
    last10 = paste(l10, pmin(10, w + l) - l10, sep = "-"),
    logo = team
  ) |>
  select(seed, logo, name, conference, record, pct, last10, ortg, drtg, net)

standings |>
  gt(id = "wnba-standings") |>
  tab_header(
    title = paste("WNBA standings and ratings,", season),
    subtitle = paste0(toupper(substr(through, 1, 1)), substring(through, 2))
  ) |>
  fmt_number(pct, decimals = 3) |>
  fmt_number(c(ortg, drtg), decimals = 1) |>
  tab_spanner("Per 100 possessions", c(ortg, drtg, net)) |>
  cols_label(
    seed = "", logo = "", name = "Team", conference = "Conf", record = "W-L",
    pct = "Pct", last10 = "Last 10", ortg = "Off", drtg = "Def", net = "Net"
  ) |>
  tab_source_note(paste(
    "Data: wehoop (ESPN box scores). Possessions estimated from the box score;",
    "ties ordered by net rating. Viz: sdvplotR"
  )) |>
  gt_color_pills(
    net,
    palette = c("#c84630", "#f7f7f7", "#2e8b57"),
    domain = c(-1, 1) * max(abs(standings$net)), digits = 1, pill_height = 22
  ) |>
  gt_sdv_logos(columns = logo, sport = "wnba", height = 26) |>
  gt_theme_pl()
```

[TABLE]

## 2. Offense against defense

Points scored per 100 possessions against points allowed, one logo per
team. The y axis is reversed so the better defenses sit higher, and the
faint diagonals are lines of equal net rating, five points apart.

``` r

ggplot(ratings, aes(x = ortg, y = drtg)) +
  geom_abline(slope = 1, intercept = seq(-30, 30, by = 5), colour = "grey88", linewidth = 0.3) +
  geom_hline(yintercept = mean(ratings$drtg), linetype = "dashed", colour = "grey55") +
  geom_vline(xintercept = mean(ratings$ortg), linetype = "dashed", colour = "grey55") +
  geom_sdv_logos(aes(team = team), sport = "wnba", width = 0.065) +
  # logos do not widen the limits, so leave room for the outermost ones
  scale_x_continuous(expand = expansion(mult = 0.08)) +
  scale_y_reverse(expand = expansion(mult = 0.12)) +
  labs(
    title = paste("WNBA offense and defense,", season),
    subtitle = paste("Points per 100 possessions,", through),
    x = "Offensive rating (points scored per 100 possessions)",
    y = "Defensive rating (points allowed, reversed)",
    caption = "Data: wehoop (ESPN box scores) | Viz: sdvplotR"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

![Every WNBA team's logo placed by offensive rating (horizontal) and
defensive rating (vertical, reversed so better defenses sit higher),
with dashed lines at the league averages and faint diagonals of equal
net rating.](leaderboard-wnba_files/figure-html/off-def-1.png)

## 3. Scoring leaders with headshots

Points per game from the player box scores (standard games only), for
players who appeared in at least half of the most games any team has
played. ESPN athlete ids are sdvplotR’s default id for WNBA headshots,
and the table is dressed in the scoring leader’s team colors by
[`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md).

``` r

players <- wehoop::load_wnba_player_box(seasons = season) |>
  filter(season_type == 2, !did_not_play, !is.na(minutes), game_id %in% standard$game_id)
most_games <- max(count(distinct(players, team_abbreviation, game_id), team_abbreviation)$n)

leaders <- players |>
  arrange(game_date, game_id) |>
  group_by(athlete_id) |>
  summarise(
    name = last(athlete_display_name), team = last(team_abbreviation), gp = n(),
    ppg = mean(points), rpg = mean(rebounds), apg = mean(assists),
    fg_pct = sum(field_goals_made) / sum(field_goals_attempted),
    .groups = "drop"
  ) |>
  filter(gp >= most_games / 2) |>
  arrange(desc(ppg), athlete_id) |>
  slice_head(n = 10) |>
  mutate(rank = row_number(), headshot = athlete_id, logo = team)
head(leaders)
#> # A tibble: 6 × 11
#>   athlete_id name      team     gp   ppg   rpg   apg fg_pct  rank headshot logo 
#>        <int> <chr>     <chr> <int> <dbl> <dbl> <dbl>  <dbl> <int>    <int> <chr>
#> 1    3149391 A'ja Wil… LV       41  26.2  9.37  3.22  0.527     1  3149391 LV   
#> 2    3142191 Kelsey M… IND      44  24.7  1.70  2.75  0.509     2  3142191 IND  
#> 3    4433403 Caitlin … IND      40  22.3  3.95  8.32  0.445     3  4433403 IND  
#> 4    2998938 Kahleah … PHX      40  21.5  3.68  1.88  0.449     4  2998938 PHX  
#> 5    4433730 Paige Bu… DAL      42  20.9  4.14  5.88  0.512     5  4433730 DAL  
#> 6    3904576 Marina M… TOR      32  20.8  3.28  3.69  0.441     6  3904576 TOR
```

``` r

leaders |>
  select(rank, headshot, name, logo, gp, ppg, rpg, apg, fg_pct) |>
  gt(id = "wnba-leaders") |>
  tab_header(
    title = paste("WNBA scoring leaders,", season),
    subtitle = paste0(
      "Points per game, minimum ", ceiling(most_games / 2), " games, ", through
    )
  ) |>
  fmt_number(c(ppg, rpg, apg), decimals = 1) |>
  fmt_percent(fg_pct, decimals = 1) |>
  cols_label(
    rank = "", headshot = "", name = "Player", logo = "", gp = "GP",
    ppg = "PTS", rpg = "REB", apg = "AST", fg_pct = "FG%"
  ) |>
  tab_source_note("Data: wehoop (ESPN box scores) | Viz: sdvplotR") |>
  gt_sdv_headshots(columns = headshot, sport = "wnba", height = 40) |>
  gt_sdv_logos(columns = logo, sport = "wnba", height = 26) |>
  gt_theme_sdv_team(team = leaders$team[1], sport = "wnba")
```

| WNBA scoring leaders, 2026 |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Points per game, minimum 22 games, final regular season |  |  |  |  |  |  |  |  |
|  |  | Player |  | GP | PTS | REB | AST | FG% |
| 1 | ![Player 3149391 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/3149391.png) | A'ja Wilson | ![Las Vegas Aces](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d3/d3057fc57ddcd581b22821cab1d5fcc21a6e7b9e9bc7a0dcc57c3ef4e8284523.png) | 41 | 26.2 | 9.4 | 3.2 | 52.7% |
| 2 | ![Player 3142191 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/3142191.png) | Kelsey Mitchell | ![Indiana Fever](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/54229f470dabb4795f3e09f979805041d0bc60e859ba94f8bc3d3c2939e8a1bd.png) | 44 | 24.7 | 1.7 | 2.8 | 50.9% |
| 3 | ![Player 4433403 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/4433403.png) | Caitlin Clark | ![Indiana Fever](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/54229f470dabb4795f3e09f979805041d0bc60e859ba94f8bc3d3c2939e8a1bd.png) | 40 | 22.3 | 4.0 | 8.3 | 44.5% |
| 4 | ![Player 2998938 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/2998938.png) | Kahleah Copper | ![Phoenix Mercury](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ca/cabf18c9af751e07c8df012fde18e326da8047d789bc10298be48bfe6f0f3ab7.png) | 40 | 21.5 | 3.7 | 1.9 | 44.9% |
| 5 | ![Player 4433730 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/4433730.png) | Paige Bueckers | ![Dallas Wings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/a5/a5137a5545b847a96f798bb8ec059f4a908acf898d4cda371fb17b00e2333b65.png) | 42 | 20.9 | 4.1 | 5.9 | 51.2% |
| 6 | ![Player 3904576 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/3904576.png) | Marina Mabrey | ![Toronto Tempo](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/22/2268104ab5df4d3276b4469b89559f488d61464091755f2df8ce84d42ccca5e8.png) | 32 | 20.8 | 3.3 | 3.7 | 44.1% |
| 7 | ![Player 2998928 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/2998928.png) | Breanna Stewart | ![New York Liberty](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/88/88aaa89584094c04a6b37ce67693565feae3fb04728da508830daba1b61d343c.png) | 42 | 20.8 | 8.3 | 3.3 | 47.4% |
| 8 | ![Player 4433791 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/4433791.png) | Olivia Miles | ![Minnesota Lynx](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/74/7400d6af343a3f6c725c70d1967050a0c63686f51abb40cd4161f7b84f629c76.png) | 40 | 19.8 | 4.7 | 6.0 | 49.2% |
| 9 | ![Player 3058901 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/3058901.png) | Allisha Gray | ![Atlanta Dream](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e1/e102207a9739a4c4f036a7448ec130a10329adc71730d954ec23c9f7f68a83f0.png) | 44 | 19.0 | 3.5 | 2.6 | 46.2% |
| 10 | ![Player 4065870 headshot](https://a.espncdn.com/combiner/i?img=/i/headshots/wnba/players/full/4065870.png) | Jackie Young | ![Las Vegas Aces](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d3/d3057fc57ddcd581b22821cab1d5fcc21a6e7b9e9bc7a0dcc57c3ef4e8284523.png) | 43 | 18.9 | 4.4 | 6.8 | 48.8% |
| Data: wehoop (ESPN box scores) \| Viz: sdvplotR |  |  |  |  |  |  |  |  |

## Related

- [WNBA](https://sdvplotR.sportsdataverse.org/articles/wnba-viz.md)
  walks through wehoop and sdvplotR more broadly.
- [NBA](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nba.md)
  builds the same standings from hoopR.
- [Social graphics,
  automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.md)
  posts leaderboards like these on a schedule.
