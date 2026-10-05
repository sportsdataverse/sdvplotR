# NFL Weekly Leaderboard

On this page

**Updated 2026-10-05:** the 2026 season through week 4 (63 games).

This page is rebuilt every week with the site. It finds the latest NFL
season with play-by-play, ranks every team by EPA (expected points
added) per play, plots offense against defense, and lists the most
efficient quarterbacks with their headshots: the season to date while
games are being played, the last full regular season in the offseason.
Data: nflverse play-by-play and schedules, read with
[nflreadr](https://nflreadr.nflverse.com).

## Picking the season

The season starts in September, so before then the calendar points at
last season. nflverse publishes a season’s play-by-play file with its
first games; until then
[`nflreadr::load_pbp()`](https://nflreadr.nflverse.com/reference/load_pbp.html)
errors, and the page steps back one season instead of failing. The
status line above comes from the schedule: games still to play mean the
season to date, a played Super Bowl means the offseason.

``` r

library(sdvplotR)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(gt)

today <- Sys.Date()
# The season starts in September, so before then the calendar points at last season
current <- as.integer(format(today, "%Y")) - (format(today, "%m") < "09")

# A season's regular-season plays, or NULL when nflverse has not published any:
# load_pbp() errors for a season past nflreadr::most_recent_season()
regular_season <- function(season) {
  pbp <- tryCatch(nflreadr::load_pbp(season), error = function(e) NULL)
  if (is.null(pbp)) {
    return(NULL)
  }
  pbp <- filter(pbp, season_type == "REG")
  if (nrow(pbp) == 0) NULL else pbp
}

season <- current
pbp <- regular_season(season)
if (is.null(pbp)) {
  season <- current - 1
  pbp <- regular_season(season)
}
stopifnot(!is.null(pbp))

schedule <- nflreadr::load_schedules(season)
week <- max(pbp$week)
n_games <- n_distinct(pbp$game_id)
unplayed <- sum(schedule$game_type == "REG" & is.na(schedule$result))
super_bowl <- any(schedule$game_type == "SB" & !is.na(schedule$result))
through <- if (unplayed > 0) paste("through week", week) else "final regular season"
status <- if (unplayed > 0) {
  sprintf("the %d season through week %d (%d games).", season, week, n_games)
} else if (!super_bowl) {
  sprintf("the final %d regular season; the playoffs are under way.", season)
} else {
  sprintf(
    "the offseason, so this is the final %d regular season. The %d season starts in September.",
    season, season + 1
  )
}
```

## 1. Power table

Every team’s record and point differential from the schedule, and its
EPA per pass or run play on offense and allowed on defense, from the
play-by-play. Net EPA per play is offense minus defense; the trend
compares each team’s last three games with its season.
[`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
stacks the record under the nickname in team colors,
[`gt_delta()`](https://sdvplotR.sportsdataverse.org/reference/gt_delta.md)
computes the trend, and
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns the nflverse abbreviations into logos.

``` r

plays <- pbp |>
  filter(pass == 1 | rush == 1, !is.na(epa), !is.na(posteam))
offense <- plays |>
  group_by(game_id, week, team = posteam) |>
  summarise(off = sum(epa), off_n = n(), .groups = "drop")
defense <- plays |>
  group_by(game_id, team = defteam) |>
  summarise(dfn = sum(epa), dfn_n = n(), .groups = "drop")
# a fixed row order: every sum below adds up in the same order each week
per_game <- inner_join(offense, defense, by = c("game_id", "team")) |>
  arrange(team, week)

per_play <- function(games) {
  games |>
    group_by(team) |>
    summarise(
      off_epa = sum(off) / sum(off_n),
      def_epa = sum(dfn) / sum(dfn_n),
      .groups = "drop"
    ) |>
    mutate(net = off_epa - def_epa)
}
last3 <- per_game |>
  group_by(team) |>
  slice_tail(n = 3) |>
  ungroup() |>
  per_play() |>
  select(team, last3 = net)

games <- filter(schedule, game_type == "REG", game_id %in% pbp$game_id)
record <- bind_rows(
  transmute(games, team = home_team, pf = home_score, pa = away_score),
  transmute(games, team = away_team, pf = away_score, pa = home_score)
) |>
  group_by(team) |>
  summarise(
    w = sum(pf > pa), l = sum(pf < pa), t = sum(pf == pa), diff = sum(pf - pa),
    .groups = "drop"
  ) |>
  mutate(record = if_else(t > 0, paste(w, l, t, sep = "-"), paste(w, l, sep = "-")))

nicknames <- nflreadr::load_teams() |>
  select(team = team_abbr, name = team_nick)

power <- per_play(per_game) |>
  inner_join(last3, by = "team") |>
  inner_join(record, by = "team") |>
  inner_join(nicknames, by = "team") |>
  arrange(desc(net), team) |> # the team breaks a tie, so an unchanged week renders the same
  mutate(rank = row_number()) |>
  select(rank, team, name, record, diff, off_epa, def_epa, net, last3)
head(power)
#> # A tibble: 6 × 9
#>    rank team  name    record  diff off_epa  def_epa   net  last3
#>   <int> <chr> <chr>   <chr>  <int>   <dbl>    <dbl> <dbl>  <dbl>
#> 1     1 SF    49ers   4-0       58  0.274   0.00682 0.267 0.234 
#> 2     2 JAX   Jaguars 3-1       51  0.137  -0.0634  0.201 0.112 
#> 3     3 KC    Chiefs  4-0       41  0.157  -0.0314  0.188 0.122 
#> 4     4 CHI   Bears   3-1       47  0.116  -0.0657  0.182 0.202 
#> 5     5 BAL   Ravens  3-1       20  0.160   0.00827 0.152 0.0737
#> 6     6 LV    Raiders 3-1       31  0.0301 -0.122   0.152 0.137
```

``` r

good_bad <- c("#c84630", "#f7f7f7", "#2e8b57")
reach <- max(abs(c(power$off_epa, power$def_epa))) # one symmetric scale for both sides

power |>
  gt(id = "nfl-power") |> # a fixed id: gt draws a random one otherwise
  tab_header(
    title = paste("NFL power table,", season),
    subtitle = paste("Ranked by net EPA per play,", through)
  ) |>
  fmt_number(c(off_epa, def_epa, net, last3), decimals = 3, force_sign = TRUE) |>
  fmt_number(diff, decimals = 0, force_sign = TRUE) |>
  data_color(off_epa, palette = good_bad, domain = c(-reach, reach)) |>
  data_color(def_epa, palette = rev(good_bad), domain = c(-reach, reach)) |>
  data_color(net, palette = good_bad, domain = c(-1, 1) * max(abs(power$net))) |>
  tab_spanner("EPA per play", c(off_epa, def_epa, net, last3)) |>
  cols_label(
    rank = "", team = "", name = "Team", diff = "Pt diff",
    off_epa = "Offense", def_epa = "Defense", net = "Net", last3 = "Last 3"
  ) |>
  tab_source_note(paste(
    "Data: nflverse play-by-play via nflreadr. Pass and run plays;",
    "defense is EPA allowed (lower is better). Viz: sdvplotR"
  )) |>
  gt_merge_stack_team_color(name, record, team, sport = "nfl") |>
  gt_delta(net, last3, column_label = "Trend", decimals = 3, arrows = TRUE) |>
  gt_sdv_logos(columns = team, sport = "nfl", height = 26) |>
  gt_theme_athletic()
```

[TABLE]

`gt_save_crop(table, "nfl-power.png")` renders the same table to a
trimmed PNG, ready to post; see [Saving and Posting
Tables](https://sdvplotR.sportsdataverse.org/articles/saving_tables.md).

## 2. Offense against defense

The same EPA per play as a scatter, one logo per team. The y axis is
reversed so the better defenses sit higher: the top-right corner is
where good teams live. The faint diagonals are lines of equal net EPA
per play, 0.1 apart.

``` r

ggplot(power, aes(x = off_epa, y = def_epa)) +
  geom_abline(slope = 1, intercept = seq(-0.6, 0.6, by = 0.1), colour = "grey88", linewidth = 0.3) +
  geom_hline(yintercept = mean(power$def_epa), linetype = "dashed", colour = "grey55") +
  geom_vline(xintercept = mean(power$off_epa), linetype = "dashed", colour = "grey55") +
  geom_sdv_logos(aes(team = team), sport = "nfl", width = 0.06, alpha = 0.9) +
  # logos do not widen the limits, so leave room for the outermost ones
  scale_x_continuous(expand = expansion(mult = 0.07)) +
  scale_y_reverse(expand = expansion(mult = 0.07)) +
  labs(
    title = paste("NFL offense and defense,", season),
    subtitle = paste("EPA per pass or run play,", through),
    x = "Offense: EPA per play",
    y = "Defense: EPA allowed per play (reversed)",
    caption = "Data: nflverse via nflreadr | Viz: sdvplotR"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

![Every NFL team's logo placed by offensive EPA per play (horizontal)
and defensive EPA allowed per play (vertical, reversed so better
defenses sit higher), with dashed league-average lines and faint
diagonals of equal net
EPA.](leaderboard-nfl-weekly_files/figure-html/off-def-1.png)

## 3. Quarterback leaderboard

EPA per dropback (passes, sacks and scrambles) for quarterbacks with at
least 15 dropbacks per team game, with completion percentage over
expected (CPOE). The play-by-play’s `id` column is the passer’s GSIS id,
which is what
[`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md)
takes for the NFL; the season’s rosters, keyed by the same id, give the
full names.

``` r

team_games <- max(count(per_game, team)$n)
qbs <- pbp |>
  filter(qb_dropback == 1, !is.na(qb_epa), !is.na(id)) |>
  arrange(game_id, play_id) |>
  group_by(id) |>
  summarise(
    name = last(name),
    team = last(posteam),
    dropbacks = n(),
    epa = mean(qb_epa),
    cpoe = mean(cpoe, na.rm = TRUE),
    success = mean(success, na.rm = TRUE),
    td = sum(pass_touchdown, na.rm = TRUE),
    int = sum(interception, na.rm = TRUE),
    .groups = "drop"
  ) |>
  filter(dropbacks >= 15 * team_games) |>
  arrange(desc(epa), id) |>
  mutate(rank = row_number(), headshot = id)
full_names <- nflreadr::load_rosters(season) |>
  distinct(id = gsis_id, full_name) |>
  filter(!is.na(id), !duplicated(id))
qbs <- qbs |>
  left_join(full_names, by = "id") |>
  mutate(name = coalesce(full_name, name))
nrow(qbs)
#> [1] 31
```

``` r

qbs |>
  slice_head(n = 16) |>
  select(rank, headshot, name, team, dropbacks, epa, cpoe, success, td, int) |>
  gt(id = "nfl-qbs") |>
  tab_header(
    title = paste("NFL quarterbacks by EPA per dropback,", season),
    subtitle = paste0("Minimum ", 15 * team_games, " dropbacks, ", through)
  ) |>
  fmt_number(epa, decimals = 3, force_sign = TRUE) |>
  fmt_number(cpoe, decimals = 1, force_sign = TRUE) |>
  fmt_percent(success, decimals = 1) |>
  cols_label(
    rank = "", headshot = "", name = "Quarterback", team = "", dropbacks = "Dropbacks",
    epa = "EPA/db", cpoe = "CPOE", success = "Success", td = "TD", int = "INT"
  ) |>
  tab_source_note("Data: nflverse play-by-play via nflreadr | Viz: sdvplotR") |>
  gt_color_pills(
    epa,
    palette = good_bad, domain = c(-1, 1) * max(abs(qbs$epa)), digits = 3, pill_height = 22
  ) |>
  gt_sdv_headshots(columns = headshot, sport = "nfl", height = 34) |>
  gt_sdv_logos(columns = team, sport = "nfl", height = 22) |>
  gt_theme_sdv()
```

| NFL quarterbacks by EPA per dropback, 2026 |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|
| Minimum 60 dropbacks, through week 4 |  |  |  |  |  |  |  |  |  |
|  |  | Quarterback |  | Dropbacks | EPA/db | CPOE | Success | TD | INT |
| 1 | ![Player 00-0037834 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/xs2fyj1sqdgwvt9ihbri.png) | Brock Purdy | ![San Francisco 49ers](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | 122 | 0.566 | +4.5 | 62.3% | 11 | 1 |
| 2 | ![Player 00-0039918 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/h4qs11kutwiw7whekmyt.png) | Caleb Williams | ![Chicago Bears](https://a.espncdn.com/i/teamlogos/nfl/500/chi.png) | 70 | 0.381 | +6.2 | 48.6% | 2 | 1 |
| 3 | ![Player 00-0034796 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/eno6s5qzl9grbfbfwhoa.png) | Lamar Jackson | ![Baltimore Ravens](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) | 111 | 0.375 | +8.1 | 57.7% | 6 | 1 |
| 4 | ![Player 00-0034857 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/mjwbioajzldkq1vzoz2d.png) | Josh Allen | ![Buffalo Bills](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | 138 | 0.318 | +6.0 | 44.2% | 6 | 3 |
| 5 | ![Player 00-0033077 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/yvscmqq1qki8zfsemmcd.png) | Dak Prescott | ![Dallas Cowboys](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | 168 | 0.292 | +5.4 | 50.0% | 8 | 1 |
| 6 | ![Player 00-0036971 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/k9uzdernqkx7oquy7dkg.png) | Trevor Lawrence | ![Jacksonville Jaguars](https://a.espncdn.com/i/teamlogos/nfl/500/jax.png) | 114 | 0.274 | +9.5 | 51.8% | 8 | 2 |
| 7 | ![Player 00-0033106 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/kaicbot8qhzrvddilbtp.png) | Jared Goff | ![Detroit Lions](https://a.espncdn.com/i/teamlogos/nfl/500/det.png) | 174 | 0.272 | +1.5 | 51.1% | 9 | 0 |
| 8 | ![Player 00-0039150 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/vcvhmxvxw2a3armle0af.png) | Bryce Young | ![Carolina Panthers](https://a.espncdn.com/i/teamlogos/nfl/500/car.png) | 175 | 0.254 | +5.7 | 46.3% | 9 | 2 |
| 9 | ![Player 00-0033873 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png) | Patrick Mahomes | ![Kansas City Chiefs](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | 143 | 0.205 | +0.8 | 49.0% | 9 | 2 |
| 10 | ![Player 00-0033537 headshot](https://static.www.nfl.com/image/private/t_headshot_desktop/f_auto/league/otfs2docj6eahaebo5xn.png) | Deshaun Watson | ![Cleveland Browns](https://a.espncdn.com/i/teamlogos/nfl/500/cle.png) | 140 | 0.180 | +1.3 | 50.0% | 6 | 2 |
| 11 | ![Player 00-0039910 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/gfz8k5onuqjrche9ogqc.png) | Jayden Daniels | ![Washington Commanders](https://a.espncdn.com/i/teamlogos/nfl/500/wsh.png) | 62 | 0.180 | −1.0 | 43.5% | 3 | 0 |
| 12 | ![Player 00-0029604 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/za7cynvpwlsro1tsaijk.png) | Kirk Cousins | ![Las Vegas Raiders](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | 152 | 0.164 | +1.6 | 49.3% | 11 | 4 |
| 13 | ![Player 00-0030565 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/zppfqqcyjfma14jjif3a.png) | Geno Smith | ![New York Jets](https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png) | 138 | 0.138 | +7.9 | 47.1% | 5 | 0 |
| 14 | ![Player 00-0036442 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/gnnvcgui1cijybukk2w7.png) | Joe Burrow | ![Cincinnati Bengals](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | 171 | 0.120 | +5.6 | 48.0% | 7 | 3 |
| 15 | ![Player 00-0039163 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/tt4zrtxlhifaljhj0rn7.png) | C.J. Stroud | ![Houston Texans](https://a.espncdn.com/i/teamlogos/nfl/500/hou.png) | 166 | 0.091 | +0.7 | 47.6% | 5 | 0 |
| 16 | ![Player 00-0026498 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/jwpkjfrkzufdyh8u1mg7.png) | Matthew Stafford | ![Los Angeles Rams](https://a.espncdn.com/i/teamlogos/nfl/500/lar.png) | 169 | 0.087 | −0.1 | 46.7% | 6 | 6 |
| Data: nflverse play-by-play via nflreadr \| Viz: sdvplotR |  |  |  |  |  |  |  |  |  |

The same quarterbacks on the two axes, each drawn as his headshot. Up
and to the right is efficient and accurate.

``` r

ggplot(qbs, aes(x = cpoe, y = epa)) +
  geom_hline(yintercept = mean(qbs$epa), linetype = "dashed", colour = "grey55") +
  geom_vline(xintercept = mean(qbs$cpoe), linetype = "dashed", colour = "grey55") +
  geom_sdv_headshots(aes(player_id = id), sport = "nfl", height = 0.08) +
  ggrepel::geom_text_repel(
    aes(label = sub("^\\S+\\s+", "", name)), # the last name
    size = 3, colour = "grey25", point.size = 13, box.padding = 0.35,
    min.segment.length = 0, segment.colour = "grey70", max.overlaps = Inf,
    seed = 2026 # a seed: the same layout each week
  ) +
  labs(
    title = paste("NFL quarterbacks,", season),
    subtitle = paste0("EPA per dropback against CPOE, minimum ", 15 * team_games, " dropbacks, ", through),
    x = "Completion percentage over expected",
    y = "EPA per dropback",
    caption = "Data: nflverse via nflreadr | Viz: sdvplotR"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

![Every qualifying NFL quarterback's headshot placed by completion
percentage over expected (horizontal) and EPA per dropback (vertical),
with dashed lines at the averages of the
group.](leaderboard-nfl-weekly_files/figure-html/qb-chart-1.png)

## Related

- [Leaderboard
  Dashboards](https://sdvplotR.sportsdataverse.org/articles/leaderboard-dashboards.md)
  for layout patterns.
- [College football
  weekly](https://sdvplotR.sportsdataverse.org/articles/leaderboard-cfb-weekly.md),
  and the
  [NBA](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nba.md),
  [WNBA](https://sdvplotR.sportsdataverse.org/articles/leaderboard-wnba.md),
  [MLB](https://sdvplotR.sportsdataverse.org/articles/leaderboard-mlb.md)
  and
  [NHL](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nhl.md)
  leaderboards.
- [Social graphics,
  automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.md)
  posts tables like these on a schedule.
