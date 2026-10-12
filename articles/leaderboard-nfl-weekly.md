# NFL Weekly Leaderboard

On this page

**Updated 2026-10-12:** the 2026 season through week 5 (78 games).

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
#>    rank team  name    record  diff  off_epa  def_epa   net  last3
#>   <int> <chr> <chr>   <chr>  <int>    <dbl>    <dbl> <dbl>  <dbl>
#> 1     1 SF    49ers   5-0       61  0.187   -0.0723  0.260 0.176 
#> 2     2 KC    Chiefs  4-0       41  0.157   -0.0314  0.188 0.122 
#> 3     3 JAX   Jaguars 4-1       53  0.105   -0.0732  0.178 0.194 
#> 4     4 MIN   Vikings 5-0       45 -0.0999  -0.235   0.135 0.145 
#> 5     5 BAL   Ravens  4-1       27  0.132    0.00232 0.129 0.0973
#> 6     6 LA    Rams    2-2        2  0.00599 -0.0977  0.104 0.266
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
| Minimum 75 dropbacks, through week 5 |  |  |  |  |  |  |  |  |  |
|  |  | Quarterback |  | Dropbacks | EPA/db | CPOE | Success | TD | INT |
| 1 | ![Player 00-0037834 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/xs2fyj1sqdgwvt9ihbri.png) | Brock Purdy | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | 157 | 0.417 | +4.7 | 57.3% | 13 | 2 |
| 2 | ![Player 00-0034796 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/eno6s5qzl9grbfbfwhoa.png) | Lamar Jackson | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) | 111 | 0.375 | +8.1 | 57.7% | 6 | 1 |
| 3 | ![Player 00-0034857 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/mjwbioajzldkq1vzoz2d.png) | Josh Allen | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | 138 | 0.318 | +6.0 | 44.2% | 6 | 3 |
| 4 | ![Player 00-0039917 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/mip4kogkqxwkkya6mvmh.png) | Michael Penix Jr. | ![Atlanta Falcons](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/fe/fe566e9da6f7986b2bac321571bd751247ff93af15c51ae555486fb1bee90c91.png) | 84 | 0.311 | +1.1 | 52.4% | 3 | 1 |
| 5 | ![Player 00-0033106 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/kaicbot8qhzrvddilbtp.png) | Jared Goff | ![Detroit Lions](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/97/9776b567ebab0bd3640165e915d948d8e736e35967dfc19ce62b967cfe7b4eb1.png) | 207 | 0.308 | +1.3 | 50.2% | 12 | 0 |
| 6 | ![Player 00-0036971 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/k9uzdernqkx7oquy7dkg.png) | Trevor Lawrence | ![Jacksonville Jaguars](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/15/15cb9a1c77ebfaea885d0d3a34f33dabc4e6a00eb7d5462148fceed641d49397.png) | 158 | 0.269 | +5.9 | 49.4% | 10 | 3 |
| 7 | ![Player 00-0039150 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/vcvhmxvxw2a3armle0af.png) | Bryce Young | ![Carolina Panthers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2c/2cebc1bbdcfd89f28c1578b397f440d229d93fa9a30bfa1193cc286482c82298.png) | 175 | 0.254 | +5.7 | 46.3% | 9 | 2 |
| 8 | ![Player 00-0033077 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/yvscmqq1qki8zfsemmcd.png) | Dak Prescott | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | 211 | 0.217 | +1.9 | 50.2% | 9 | 3 |
| 9 | ![Player 00-0033873 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p.png) | Patrick Mahomes | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | 143 | 0.205 | +0.8 | 49.0% | 9 | 2 |
| 10 | ![Player 00-0039851 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/s1nmoon2xnrc3bnyulv4.png) | Drake Maye | ![New England Patriots](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/da/dac19aa9a573dcf9075e2422bee3e35a4955b9ab494bb3191ab3bacfd3609729.png) | 180 | 0.204 | +6.7 | 52.8% | 8 | 7 |
| 11 | ![Player 00-0039910 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/gfz8k5onuqjrche9ogqc.png) | Jayden Daniels | ![Washington Commanders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2f/2f67805ef9e385a4c67adb0a9320706bd481a52e3aa0e0faea995dad2b501112.png) | 100 | 0.189 | +2.1 | 45.0% | 3 | 0 |
| 12 | ![Player 00-0029604 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/za7cynvpwlsro1tsaijk.png) | Kirk Cousins | ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | 183 | 0.186 | +1.4 | 48.6% | 12 | 4 |
| 13 | ![Player 00-0036442 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/gnnvcgui1cijybukk2w7.png) | Joe Burrow | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | 204 | 0.173 | +6.0 | 50.0% | 11 | 3 |
| 14 | ![Player 00-0039163 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/tt4zrtxlhifaljhj0rn7.png) | C.J. Stroud | ![Houston Texans](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/54b0fe559761860e4953851c197d995b2f9c0c4e278164edda7b608ffd64f39b.png) | 202 | 0.127 | +2.5 | 48.5% | 6 | 0 |
| 15 | ![Player 00-0036264 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/thz8stjkbjwddxqnozi5.png) | Jordan Love | ![Green Bay Packers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7e/7ea8154cdbff5db84d248f235c1f1c78a1a8b4cb8c14335b5886ec10ee20b00e.png) | 197 | 0.111 | −3.1 | 43.1% | 10 | 3 |
| 16 | ![Player 00-0026498 headshot](https://static.www.nfl.com/image/upload/t_headshot_desktop/f_auto/league/jwpkjfrkzufdyh8u1mg7.png) | Matthew Stafford | ![Los Angeles Rams](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e2/e289b738a5e1259cccea921bee02eec881d35b4241761a8c4e12fe5964cab75c.png) | 169 | 0.087 | −0.1 | 46.7% | 6 | 6 |
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
