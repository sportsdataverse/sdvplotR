# College Football Visualizations with cfbfastR and sdvplotR

On this page

Ten charts and tables from the 2025 college football season: all 136 FBS
teams on one scatter, conference small multiples, conference logos on an
axis, a conference standings table, the national champion’s season with
a logo in the title, the College Football Playoff bracket, a rivalry
across two decades, a quarterback leaderboard with headshots, a ranked
bar chart with logos on the y axis and a tier list.

College football is the league where sdvplotR’s name matching earns its
keep: the data names schools (`"Ohio State"`, `"San José State"`), and
sdvplotR resolves every FBS and FCS program, plus each conference, from
those names, so the code below never builds a lookup table.

## Setup

The play-by-play comes from the SportsDataverse releases through
[cfbfastR](https://cfbfastR.sportsdataverse.org) and needs no key. The
schedule, ratings and series history come from the
[CollegeFootballData.com](https://collegefootballdata.com) API, which
needs a free key. Get one at <https://collegefootballdata.com/key> and
register it before running the chunks that call `cfbd_*()` or
`load_cfb_schedules()`:

``` r

Sys.setenv(CFBD_API_KEY = "YOUR-API-KEY-HERE")
# to keep it across sessions, add CFBD_API_KEY=YOUR-API-KEY-HERE to
# ~/.Renviron (usethis::edit_r_environ()); see ?cfbfastR::register_cfbd
```

``` r

library(sdvplotR)
library(ggplot2)
library(dplyr, warn.conflicts = FALSE)
library(gt)

season <- 2025
caption <- "Data: cfbfastR | 2025 season"

pbp <- cfbfastR::load_cfb_pbp(season)
schedule <- cfbfastR::load_cfb_schedules(season)

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      plot.title.position = "plot",
      plot.caption = element_text(color = "grey45", size = 8)
    )
)
```

The schedule carries each team’s division and its conference **that
season**.
[`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
turns the school names into sdvplotR’s abbreviations:

``` r

fbs <- bind_rows(
  select(schedule, team = home_team, conference = home_conference, division = home_division),
  select(schedule, team = away_team, conference = away_conference, division = away_division)
) |>
  filter(division == "fbs") |>
  distinct(team, conference) |>
  mutate(abbr = clean_team_abbrs(team, sport = "cfb"))

nrow(fbs)
#> [1] 136
count(fbs, conference, sort = TRUE)
#> # A tibble: 11 × 2
#>    conference            n
#>    <chr>             <int>
#>  1 Big Ten              18
#>  2 ACC                  17
#>  3 Big 12               16
#>  4 SEC                  16
#>  5 American Athletic    14
#>  6 Sun Belt             14
#>  7 Mid-American         13
#>  8 Conference USA       12
#>  9 Mountain West        12
#> 10 FBS Independents      2
#> 11 Pac-12                2
```

Conference names resolve too: `"American Athletic"` is the `AAC` key and
`"Conference USA"` the `CUSA` key. That makes it easy to check the
season’s conferences against
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md),
which holds each school’s conference **today**. A tutorial on a past
season should take conferences from that season’s data:

``` r

fbs |>
  mutate(conf_2025 = clean_team_abbrs(conference, sport = "cfb")) |>
  inner_join(
    select(team_reference("cfb"), abbr = team_abbr, conf_today = conference),
    by = "abbr"
  ) |>
  filter(conf_2025 != conf_today) |>
  arrange(conf_today, team) |>
  select(team, conf_2025, conf_today)
#> # A tibble: 9 × 3
#>   team              conf_2025     conf_today   
#>   <chr>             <chr>         <chr>        
#> 1 Northern Illinois MAC           Mountain West
#> 2 UTEP              CUSA          Mountain West
#> 3 Boise State       Mountain West Pac-12       
#> 4 Colorado State    Mountain West Pac-12       
#> 5 Fresno State      Mountain West Pac-12       
#> 6 San Diego State   Mountain West Pac-12       
#> 7 Texas State       Sun Belt      Pac-12       
#> 8 Utah State        Mountain West Pac-12       
#> 9 Louisiana Tech    CUSA          Sun Belt
```

## 1. All 136 FBS teams on one chart

Offensive EPA per play against defensive EPA per play allowed, for every
FBS team, over the full season. With this many teams the logos have to
be small: `width = 0.032` makes each one 3.2% of the panel’s width.
[`geom_mean_lines()`](https://mrcaseb.github.io/ggpath/reference/geom_lines.html)
marks the FBS averages, and the defense axis is reversed so the best
teams sit top right.

``` r

scrimmage <- pbp |>
  filter(pass == 1 | rush == 1, !is.na(EPA))

offense <- scrimmage |>
  group_by(team = pos_team) |>
  summarise(off_epa = mean(EPA), off_sr = mean(epa_success), .groups = "drop")
defense <- scrimmage |>
  group_by(team = def_pos_team) |>
  summarise(def_epa = mean(EPA), .groups = "drop")

ratings <- fbs |>
  inner_join(offense, by = "team") |>
  inner_join(defense, by = "team") |>
  mutate(net_epa = off_epa - def_epa)

ggplot(ratings, aes(x = off_epa, y = def_epa)) +
  geom_mean_lines(aes(x0 = off_epa, y0 = def_epa), color = "grey50", linewidth = 0.4) +
  geom_sdv_logos(aes(team = abbr), sport = "cfb", width = 0.032) +
  scale_y_reverse() +
  labs(
    title = "Every FBS offense and defense, 2025",
    x = "Offense EPA per play",
    y = "Defense EPA per play allowed (better is up)",
    caption = caption
  )
```

![Scatter plot of all 136 FBS teams in the 2025 season, each drawn as a
small logo, with offensive EPA per play on the horizontal axis and
defensive EPA per play allowed on the vertical axis, reversed so better
defenses sit higher, and dashed lines at the
averages.](cfb-viz_files/figure-html/fbs-scatter-1.png)

## 2. Conference small multiples

The same data, one panel per conference: every FBS team as a grey dot
behind, the conference’s own teams as logos. The grey layer gets a copy
of the data without the `conference` column, so
[`facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html)
repeats it in every panel.

``` r

ggplot(ratings, aes(x = off_epa, y = def_epa)) +
  geom_point(data = select(ratings, -conference), color = "grey85", size = 1) +
  geom_sdv_logos(aes(team = abbr), sport = "cfb", width = 0.1) +
  scale_y_reverse() +
  facet_wrap(~conference, ncol = 4) +
  labs(
    title = "FBS offense and defense by conference, 2025",
    x = "Offense EPA per play",
    y = "Defense EPA per play allowed (better is up)",
    caption = caption
  ) +
  theme(panel.grid.minor = element_blank())
```

![Eleven small scatter plots, one per FBS conference in 2025, of
offensive against defensive EPA per play, with the conference's teams
drawn as logos over grey dots for every other FBS
team.](cfb-viz_files/figure-html/conference-facets-1.png)

## 3. Conference logos on an axis

How strong is each conference top to bottom? Each team’s SP+ rating
([`cfbfastR::cfbd_ratings_sp()`](https://cfbfastR.sportsdataverse.org/reference/cfbd_ratings_sp.html))
is a logo on its conference’s row, with a line at the conference median.
The rows are labelled with the conference names, and
[`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
with
[`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
draws those names as conference logos: sdvplotR keeps the conferences’
marks alongside the teams’.

``` r

sp <- cfbfastR::cfbd_ratings_sp(year = season) |>
  select(team, sp = rating, sp_rank = ranking)

by_conf <- ratings |>
  inner_join(sp, by = "team") |>
  group_by(conference) |>
  mutate(median_sp = median(sp)) |>
  # three staggered rows per conference, so neighboring logos overlap less
  arrange(sp, team, .by_group = TRUE) |>
  mutate(offset = (row_number() %% 3 - 1) * 0.22) |>
  ungroup() |>
  mutate(conference = reorder(conference, median_sp))

medians <- distinct(by_conf, conference, median_sp)

ggplot(by_conf, aes(x = sp, y = conference)) +
  # the discrete layer that sets the rows; the layers below place logos and
  # medians between them in numbers (row 1, row 2, ...)
  geom_blank() +
  geom_vline(xintercept = 0, color = "grey70", linewidth = 0.3) +
  geom_segment(
    aes(x = median_sp, xend = median_sp, y = as.numeric(conference) - 0.4, yend = as.numeric(conference) + 0.4),
    data = medians, color = "grey30", linewidth = 0.6
  ) +
  geom_sdv_logos(aes(y = as.numeric(conference) + offset, team = abbr), sport = "cfb", height = 0.03) +
  scale_y_sdv(sport = "cfb", size = 28) +
  labs(
    title = "Conference strength by SP+, 2025",
    subtitle = "Each FBS team's SP+ rating; the line is the conference median",
    x = "SP+ rating (points better than an average team)",
    y = NULL,
    caption = "Data: CollegeFootballData.com via cfbfastR | 2025 final SP+"
  ) +
  theme_y_sdv() +
  theme(panel.grid.major.y = element_blank(), panel.grid.minor = element_blank())
#> Warning in png::readPNG(get_file(path), native = TRUE): libpng warning: iCCP:
#> known incorrect sRGB profile
```

![Strip chart of the 2025 SP+ rating of every FBS team, one row per
conference with the conference's logo as the row label, rows sorted by
median rating with the SEC and Big Ten at the top, each team drawn as a
small logo and a vertical line at each conference
median.](cfb-viz_files/figure-html/conference-strength-1.png)

## 4. A conference standings table

SEC records built from the schedule: conference games and all
regular-season games, before the title game and bowls.
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns the abbreviation column into logos,
[`gt_fmt_tally()`](https://sdvplotR.sportsdataverse.org/reference/gt_fmt_tally.md)
writes each pair of win and loss columns as one record, and
[`gt_theme_athletic()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_athletic.md)
styles the table. The last column is each team’s real postseason: the
bowl or playoff round from the schedule’s `notes`.

``` r

regular <- schedule |>
  filter(completed, season_type == "regular", week <= 14)

sides <- bind_rows(
  regular |> transmute(team = home_team, conf = home_conference, conference_game, pf = home_points, pa = away_points),
  regular |> transmute(team = away_team, conf = away_conference, conference_game, pf = away_points, pa = home_points)
) |>
  mutate(win = pf > pa)

# Title games and bowls, one row per team per game, in date order
late <- schedule |>
  filter(completed, season_type == "postseason" | week > 14) |>
  arrange(start_date)
postseason <- bind_rows(
  transmute(late, start_date, team = home_team, won = home_points > away_points, notes),
  transmute(late, start_date, team = away_team, won = away_points > home_points, notes)
) |>
  arrange(start_date) |>
  mutate(
    # "College Football Playoff Quarterfinal at the Allstate Sugar Bowl" -> "CFP Quarterfinal"
    game = sub("^College Football Playoff (.*?)( Game| at the .*| Presented by .*)?$", "CFP \\1", notes, perl = TRUE),
    game = paste(if_else(won, "W", "L"), coalesce(game, "conference title game"))
  ) |>
  group_by(team) |>
  summarise(postseason = paste(game, collapse = ", "), .groups = "drop")

sec <- sides |>
  filter(conf == "SEC") |>
  group_by(team) |>
  summarise(
    conf_w = sum(win & conference_game),
    conf_l = sum(!win & conference_game),
    w = sum(win),
    l = sum(!win),
    pf = sum(pf),
    pa = sum(pa),
    .groups = "drop"
  ) |>
  left_join(sp, by = "team") |>
  left_join(postseason, by = "team") |>
  # conference record, then overall record: not the SEC's tiebreakers
  arrange(desc(conf_w), desc(w), desc(sp), team) |>
  mutate(logo = clean_team_abbrs(team, sport = "cfb")) |>
  select(logo, team, conf_w, conf_l, w, l, pf, pa, sp, postseason)

sec |>
  gt() |>
  gt_sdv_logos(columns = "logo", sport = "cfb", height = 24) |>
  gt_fmt_tally(columns = c(conf_w, conf_l), label = "SEC") |>
  gt_fmt_tally(columns = c(w, l), label = "Overall") |>
  fmt_number(columns = "sp", decimals = 1) |>
  sub_missing(columns = "postseason", missing_text = "") |>
  cols_align(align = "left", columns = "postseason") |>
  data_color(columns = "sp", palette = c("#f7f7f7", "#1b7837")) |>
  cols_label(logo = "", team = "", pf = "PF", pa = "PA", sp = "SP+", postseason = "Postseason") |>
  tab_header(title = "SEC standings, 2025", subtitle = "Regular season, before the SEC title game") |>
  tab_source_note("Data: CollegeFootballData.com via cfbfastR") |>
  gt_theme_athletic(density = "compact")
```

[TABLE]

## 5. The national champion’s season, with a logo in the title

Indiana won every game. Each bar is one game’s margin in Indiana’s
primary color, the opponent’s logo above it, and
[`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
puts the Indiana logo beside the title. The shaded games are the Big Ten
title game and the playoff.

``` r

champion <- schedule |>
  filter(grepl("National Championship", notes)) |>
  mutate(winner = if_else(home_points > away_points, home_team, away_team)) |>
  pull(winner)

games <- schedule |>
  filter(completed, home_team == champion | away_team == champion) |>
  arrange(start_date) |>
  mutate(
    game = row_number(),
    home = home_team == champion,
    opponent = if_else(home, away_team, home_team),
    margin = if_else(home, home_points - away_points, away_points - home_points),
    title_run = season_type == "postseason" | week > 14
  )

record <- sprintf("%d-%d", sum(games$margin > 0), sum(games$margin < 0))
run_start <- min(games$game[games$title_run])

ggplot(games, aes(x = game, y = margin)) +
  annotate(
    "rect", xmin = run_start - 0.5, xmax = max(games$game) + 0.5, ymin = -Inf, ymax = Inf,
    fill = "grey93"
  ) +
  annotate(
    "text", x = (run_start + max(games$game)) / 2, y = max(games$margin) + 16,
    label = "Big Ten title game and playoff", size = 3.2, color = "grey40"
  ) +
  geom_col(fill = sdv_team_colors("cfb", champion), width = 0.7) +
  geom_sdv_logos(aes(y = margin + 6, team = opponent), sport = "cfb", height = 0.085) +
  scale_x_continuous(breaks = games$game) +
  scale_y_continuous(limits = c(0, max(games$margin) + 18), expand = c(0, 0)) +
  ggtitle_image(
    title_image = champion,
    title = sprintf("%s's %s national title season", champion, record),
    subtitle = "Margin of victory in every game, opponents' logos above the bars",
    image_height = 30,
    sport = "cfb"
  ) +
  labs(x = "Game", y = "Margin of victory", caption = "Data: CollegeFootballData.com via cfbfastR") +
  theme_title_image(size = 15, face = "bold") +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor = element_blank())
```

![Bar chart of Indiana's margin of victory in each of its 16 games of
the 2025 season in Indiana crimson, with each opponent's logo above its
bar, the Big Ten title game and three playoff games shaded, and the
Indiana logo beside the
title.](cfb-viz_files/figure-html/champion-season-1.png)

## 6. The College Football Playoff bracket

The 11 playoff games, from the schedule’s `notes`, drawn as a bracket.
Each column is a round; the team that advanced is drawn solid and the
team that lost faded, with the score where the two meet. Teams with a
first-round bye enter in the quarterfinal column. The layout walks back
from the champion: a team’s slot in one round sits between the two teams
of the game it won the round before.

``` r

rounds <- c("First round", "Quarterfinals", "Semifinals", "Final", "Champion")

cfp <- schedule |>
  filter(grepl("College Football Playoff", notes)) |>
  mutate(
    round = case_when(
      grepl("First Round", notes) ~ 1,
      grepl("Quarterfinal", notes) ~ 2,
      grepl("Semifinal", notes) ~ 3,
      grepl("Championship", notes) ~ 4
    ),
    winner = if_else(home_points > away_points, home_team, away_team),
    loser = if_else(home_points > away_points, away_team, home_team),
    score = paste0(pmax(home_points, away_points), "-", pmin(home_points, away_points))
  )

# A team's slot in round r: a leaf if it played no game in round r - 1 (a
# bye, or the first round), otherwise centered on that game's two teams
slots <- data.frame()
edges <- data.frame()
leaf <- 0
place <- function(team, r) {
  prev <- cfp[cfp$round == r - 1 & cfp$winner == team, ]
  if (nrow(prev) == 0) {
    leaf <<- leaf + 1
    y <- leaf
  } else {
    ys <- c(place(prev$winner, r - 1), place(prev$loser, r - 1))
    y <- mean(ys)
    edges <<- rbind(edges, data.frame(x = r - 1, y1 = ys[1], y2 = ys[2], y = y, score = prev$score))
  }
  lost <- any(cfp$round == r & cfp$loser == team)
  slots <<- rbind(slots, data.frame(team = team, x = r, y = y, lost = lost))
  y
}
invisible(place(cfp$winner[cfp$round == 4], 5))
slots$abbr <- clean_team_abbrs(slots$team, sport = "cfb")

ggplot() +
  # each game: from both teams to the round's midline, then on to the winner
  geom_segment(aes(x = x + 0.22, xend = x + 0.5, y = y1, yend = y1), data = edges, color = "grey60") +
  geom_segment(aes(x = x + 0.22, xend = x + 0.5, y = y2, yend = y2), data = edges, color = "grey60") +
  geom_segment(aes(x = x + 0.5, xend = x + 0.5, y = y1, yend = y2), data = edges, color = "grey60") +
  geom_segment(aes(x = x + 0.5, xend = x + 0.78, y = y, yend = y), data = edges, color = "grey60") +
  geom_label(
    aes(x = x + 0.5, y = y, label = score),
    data = edges, size = 3, linewidth = 0, fill = "white", color = "grey25"
  ) +
  geom_sdv_logos(
    aes(x = x, y = y, team = abbr, alpha = if_else(lost, 0.3, 1)),
    data = slots, sport = "cfb", height = 0.075
  ) +
  scale_alpha_identity() +
  scale_x_continuous(breaks = 1:5, labels = rounds, position = "top", limits = c(0.6, 5.4)) +
  scale_y_reverse() +
  labs(
    title = "The 2025-26 College Football Playoff",
    x = NULL,
    y = NULL,
    caption = "Data: CollegeFootballData.com via cfbfastR"
  ) +
  theme(panel.grid = element_blank(), axis.text.y = element_blank(), axis.text.x = element_text(face = "bold"))
```

![The 2025-26 College Football Playoff bracket drawn with team logos,
rounds from left to right: first round, quarterfinals, semifinals, final
and champion. Winners are solid, losers faded, each game's score is
printed where the two teams meet, and Indiana is the champion on the
right.](cfb-viz_files/figure-html/playoff-bracket-1.png)

## 7. A rivalry, season by season

Ohio State against Michigan since 2004, from one CFBD call
([`cfbfastR::cfbd_team_matchup()`](https://cfbfastR.sportsdataverse.org/reference/cfbd_team_matchup.html)).
Each bar is the margin from Ohio State’s side, colored for the winner,
with the winner’s logo at the end of the bar. There was no game in 2020.

``` r

series <- cfbfastR::cfbd_team_matchup("Ohio State", "Michigan", min_year = 2004, max_year = season) |>
  filter(!is.na(home_score)) |>
  mutate(
    osu_margin = if_else(home_team == "Ohio State", home_score - away_score, away_score - home_score),
    winner_abbr = clean_team_abbrs(winner, sport = "cfb"),
    tip = osu_margin + if_else(osu_margin > 0, 6, -6)
  )

ggplot(series, aes(x = season, y = osu_margin)) +
  geom_col(aes(fill = winner_abbr), width = 0.75) +
  geom_hline(yintercept = 0, color = "grey30") +
  geom_sdv_logos(aes(y = tip, team = winner_abbr), sport = "cfb", height = 0.075) +
  annotate("text", x = 2020, y = 2, label = "no game", angle = 90, hjust = 0, size = 3, color = "grey45") +
  scale_fill_sdv(sport = "cfb") +
  scale_x_continuous(breaks = seq(2004, season, 3)) +
  scale_y_continuous(limits = c(-35, 50)) +
  labs(
    title = sprintf("The Game: Ohio State vs Michigan, 2004-%d", season),
    subtitle = sprintf(
      "Ohio State %d wins, Michigan %d",
      sum(series$osu_margin > 0), sum(series$osu_margin < 0)
    ),
    x = NULL,
    y = "Ohio State margin",
    caption = "Data: CollegeFootballData.com via cfbfastR"
  ) +
  theme(legend.position = "none", panel.grid.minor = element_blank())
```

![Bar chart of Ohio State's margin against Michigan in each season from
2004 to 2025, bars above zero in Ohio State scarlet and below zero in
Michigan blue, each with the winner's logo at the end of the bar and a
note that there was no game in
2020.](cfb-viz_files/figure-html/rivalry-1.png)

## 8. A quarterback leaderboard with headshots

cfbfastR’s play-by-play names the passer on each dropback by role
(`completion_player_id`, `incompletion_player_id`, …); the first that is
set is the quarterback’s ESPN athlete id, which is what
[`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
takes for college players. FBS quarterbacks only, 300 or more dropbacks,
all games.

``` r

qbs <- pbp |>
  filter(pass == 1, !is.na(EPA)) |>
  mutate(
    qb_id = coalesce(completion_player_id, incompletion_player_id, interception_thrown_player_id, sack_taken_player_id),
    qb = coalesce(completion_player, incompletion_player, interception_thrown_player, sack_taken_player)
  ) |>
  filter(!is.na(qb_id), pos_team %in% fbs$team) |>
  arrange(game_id, id_play) |>
  group_by(qb_id) |>
  summarise(
    qb = last(qb),
    team = last(pos_team),
    dropbacks = n(),
    epa = mean(EPA),
    .groups = "drop"
  ) |>
  filter(dropbacks >= 300) |>
  arrange(desc(epa), qb_id) |>
  head(15) |>
  mutate(abbr = clean_team_abbrs(team, sport = "cfb"), qb_id = as.character(qb_id))

ggplot(qbs, aes(x = epa, y = reorder(qb, epa))) +
  geom_col(aes(fill = abbr), width = 0.75) +
  geom_sdv_logos(aes(x = -0.016, team = abbr), sport = "cfb", height = 0.05) +
  geom_sdv_headshots(aes(x = epa + 0.022, player_id = qb_id), sport = "cfb", height = 0.06) +
  scale_fill_sdv(sport = "cfb") +
  scale_x_continuous(breaks = seq(0, 0.4, 0.1), expand = expansion(mult = c(0.02, 0.08))) +
  labs(
    title = "Top 15 FBS quarterbacks by EPA per dropback, 2025",
    subtitle = "300+ dropbacks, all games",
    x = "EPA per dropback",
    y = NULL,
    caption = caption
  ) +
  theme(legend.position = "none", panel.grid.major.y = element_blank())
```

![Horizontal bar chart of the 15 FBS quarterbacks with the highest EPA
per dropback in the 2025 season (300 or more dropbacks), each bar in the
team's color with the team's logo before it and the quarterback's
headshot at its end.](cfb-viz_files/figure-html/qb-headshots-1.png)

## 9. A ranked bar chart with logos on the y axis

The final SP+ top 25. The bars use the teams’ colors, and with the team
abbreviations on the y axis,
[`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
plus
[`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
replaces each with its logo.

``` r

top25 <- sp |>
  inner_join(fbs, by = "team") |>
  arrange(sp_rank, team) |>
  head(25) |>
  mutate(abbr = factor(abbr, levels = rev(abbr)))

ggplot(top25, aes(x = sp, y = abbr)) +
  geom_col(aes(fill = abbr), width = 0.75) +
  geom_text(aes(label = sprintf("%.1f", sp)), hjust = -0.2, size = 3) +
  scale_fill_sdv(sport = "cfb") +
  scale_y_sdv(sport = "cfb", size = 18) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(
    title = "Final SP+ top 25, 2025",
    x = "SP+ rating",
    y = NULL,
    caption = "Data: CollegeFootballData.com via cfbfastR"
  ) +
  theme_y_sdv() +
  theme(legend.position = "none", panel.grid.major.y = element_blank())
```

![Horizontal bar chart of the top 25 teams in the final 2025 SP+
ratings, bars in team colors with each team's logo in place of its name
on the vertical axis and the rating printed at the end of each
bar.](cfb-viz_files/figure-html/axis-logos-1.png)

## 10. Tiers of a ranking you compute

A composite ranking: the average of each FBS team’s rank in three
systems, SP+, ESPN’s FPI
([`cfbfastR::espn_ratings_fpi()`](https://cfbfastR.sportsdataverse.org/reference/espn_ratings_fpi.html))
and the Simple Rating System
([`cfbfastR::cfbd_ratings_srs()`](https://cfbfastR.sportsdataverse.org/reference/cfbd_ratings_srs.html)).
The top 32 go into five tiers with
[`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md).
FPI comes keyed by ESPN abbreviation, which is already sdvplotR’s key.

``` r

fpi <- cfbfastR::espn_ratings_fpi(year = season) |>
  transmute(abbr = team_abbreviation, fpi = as.numeric(fpi))
srs <- cfbfastR::cfbd_ratings_srs(year = season) |>
  select(team, srs = rating)

composite <- fbs |>
  inner_join(sp, by = "team") |>
  inner_join(srs, by = "team") |>
  inner_join(fpi, by = "abbr") |>
  mutate(score = (rank(-sp) + rank(-fpi) + rank(-srs)) / 3) |>
  arrange(score, abbr) |>
  head(32)

sizes <- c(4, 6, 7, 7, 8) # teams per tier, top to bottom
composite$tier_no <- rep(seq_along(sizes), sizes)

sdv_team_tiers(
  select(composite, tier_no, team = abbr),
  sport = "cfb",
  title = "College football tiers, 2025",
  subtitle = "Average rank in SP+, FPI and SRS among FBS teams",
  caption = "Data: CollegeFootballData.com and ESPN via cfbfastR",
  alpha = 1,
  tier_desc = c(
    "1" = "Elite",
    "2" = "Contenders",
    "3" = "Very good",
    "4" = "Good",
    "5" = "Solid"
  )
)
```

![College football team logos in five labeled tiers, from Elite to
Solid, for the 32 best FBS teams of 2025 by their average rank in SP+,
FPI and SRS, best first within each
tier.](cfb-viz_files/figure-html/team-tiers-1.png)

## Next steps

- [cfbfastR](https://cfbfastR.sportsdataverse.org/) documents the
  play-by-play columns and every `cfbd_*()` endpoint used here.
- `sdv_surface("cfb", team)` draws a college field in a team’s colors;
  the [NFL
  tutorial](https://sdvplotR.sportsdataverse.org/articles/nfl-viz.md)
  puts plays on one.
- [cfbseedR](https://cfbseedR.sportsdataverse.org) applies conference
  tiebreakers and simulates the playoff field.
