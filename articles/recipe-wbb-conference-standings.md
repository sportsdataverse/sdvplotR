# WBB Conference Standings

On this page

**The brief:** the conference-recap newsletter wants the final SEC
women’s basketball standings as an image, 1200 px wide, plus a 4:5
portrait cut (1080 x 1350) for Instagram, where a tall table fills the
screen better than a square. Every team’s conference season should be
visible at a glance, along with how its season ended in March. The games
are ESPN’s through wehoop, and the table is gt with sdvplotR’s logos,
team colors, theme and export helpers.

``` r

library(sdvplotR)
library(gt)
library(dplyr, warn.conflicts = FALSE)

season <- 2026 # the 2025-26 season, named by the year it ends
conference <- "SEC"
out_dir <- tempfile("sdvplotR-recipe-") # where the exports go; use your own folder
dir.create(out_dir)
```

## 1. Get the data

The schedule has one row per game; stacking the home and away sides
gives one row per team per game. Conference membership comes from
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md),
which lists each team’s ESPN id and conference. The ids are integers on
both sides, checked before they are matched.

``` r

schedule <- wehoop::load_wbb_schedule(season) |>
  filter(status_type_completed)
members <- team_reference("wbb") |>
  filter(conference == !!conference) |>
  select(team_id = espn_team_id, team_abbr)
stopifnot(is.integer(schedule$home_id), is.integer(members$team_id))

side <- function(me, opp) {
  transmute(
    schedule,
    game_date,
    conf_flag = conference_competition,
    notes = coalesce(notes_headline, ""),
    team_id = .data[[paste0(me, "_id")]],
    team = .data[[paste0(me, "_location")]],
    opponent = .data[[paste0(opp, "_location")]],
    pf = .data[[paste0(me, "_score")]],
    pa = .data[[paste0(opp, "_score")]]
  )
}
games <- bind_rows(side("home", "away"), side("away", "home")) |>
  inner_join(members, by = "team_id") |>
  arrange(game_date) |>
  mutate(won = pf > pa)

games |>
  filter(conf_flag) |>
  count(notes)
#> # A tibble: 9 × 2
#>   notes                                         n
#>   <chr>                                     <int>
#> 1 ""                                          216
#> 2 "Play4Kay"                                   20
#> 3 "Players Era Championship - Championship"     2
#> 4 "SEC Tournament - 1st Round"                  8
#> 5 "SEC Tournament - 2nd Round"                  8
#> 6 "SEC Tournament - Final"                      2
#> 7 "SEC Tournament - Quarterfinal"               8
#> 8 "SEC Tournament - Semifinal"                  4
#> 9 "We Back Pat"                                20
```

ESPN’s `conference_competition` flag is `TRUE` for any game between two
conference members, and the notes show what that sweeps in: the
conference tournament, and an early-season neutral-site final in which
two SEC teams met. The themed games (Play4Kay, We Back Pat) are real
conference games. Dropping every game whose note names a tournament or a
championship leaves each team’s conference schedule, which the check
confirms is the same length for everyone.

``` r

games <- games |>
  mutate(is_conf = conf_flag & !grepl("Tournament|Championship", notes))
stopifnot(n_distinct(count(filter(games, is_conf), team)$n) == 1)

round_name <- function(notes) {
  round <- sub(".* - ", "", notes)
  if_else(round == "National Championship", "final", round)
}

standings <- games |>
  group_by(team_abbr, team) |>
  summarise(
    conf_results = list(as.integer(won[is_conf])), # in date order, for the strip
    conf_w = sum(won & is_conf),
    conf_l = sum(!won & is_conf),
    w = sum(won),
    l = sum(!won),
    last_notes = last(notes),
    last_result = paste0(
      if_else(last(won), "W ", "L "), max(last(pf), last(pa)), "-", min(last(pf), last(pa)), " vs ", last(opponent)
    ),
    .groups = "drop"
  ) |>
  mutate(
    march = case_when(
      startsWith(last_notes, "NCAA") ~ paste0("NCAA ", round_name(last_notes), ": ", last_result),
      startsWith(last_notes, "WBIT") ~ paste0("WBIT ", round_name(last_notes), ": ", last_result),
      grepl("Tournament", last_notes) ~ paste0(conference, " Tournament: ", last_result),
      .default = ""
    )
  ) |>
  arrange(desc(conf_w), conf_l, desc(w), team) # team breaks a full tie the same way every run
standings |>
  select(team, conf_w, conf_l, w, l, march)
#> # A tibble: 16 × 6
#>    team              conf_w conf_l     w     l march                            
#>    <chr>              <int>  <int> <int> <int> <chr>                            
#>  1 South Carolina        15      1    36     4 NCAA final: L 79-51 vs UCLA      
#>  2 Texas                 13      3    35     4 NCAA Final Four: L 51-44 vs UCLA 
#>  3 Vanderbilt            13      3    29     5 NCAA Sweet 16: L 67-64 vs Notre …
#>  4 LSU                   12      4    29     6 NCAA Sweet 16: L 87-85 vs Duke   
#>  5 Oklahoma              11      5    26     8 NCAA Sweet 16: L 94-68 vs South …
#>  6 Kentucky               8      8    25    11 NCAA Sweet 16: L 76-54 vs Texas  
#>  7 Ole Miss               8      8    24    12 NCAA 2nd Round: L 65-63 vs Minne…
#>  8 Georgia                8      8    22    10 NCAA 1st Round: L 82-73 vs Virgi…
#>  9 Tennessee              8      8    16    14 NCAA 1st Round: L 76-61 vs NC St…
#> 10 Alabama                7      9    24    11 NCAA 2nd Round: L 69-68 vs Louis…
#> 11 Texas A&M              7      9    14    13 WBIT 1st Round: L 68-48 vs McNee…
#> 12 Florida                5     11    18    15 SEC Tournament: L 82-64 vs Oklah…
#> 13 Mississippi State      5     11    18    13 SEC Tournament: L 86-68 vs Flori…
#> 14 Missouri               4     12    17    17 WBIT 2nd Round: L 93-75 vs BYU   
#> 15 Auburn                 3     13    15    17 SEC Tournament: L 73-57 vs Ole M…
#> 16 Arkansas               1     15    12    20 SEC Tournament: L 94-64 vs Kentu…
```

## 2. The first draft

Hand the frame to gt as it is.

``` r

gt(standings)
```

| team_abbr | team | conf_results | conf_w | conf_l | w | l | last_notes | last_result | march |
|----|----|----|----|----|----|----|----|----|----|
| SC | South Carolina | 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 | 15 | 1 | 36 | 4 | NCAA Women's Basketball Championship - National Championship | L 79-51 vs UCLA | NCAA final: L 79-51 vs UCLA |
| TEX | Texas | 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1 | 13 | 3 | 35 | 4 | NCAA Women's Basketball Championship - Final Four | L 51-44 vs UCLA | NCAA Final Four: L 51-44 vs UCLA |
| VAN | Vanderbilt | 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1 | 13 | 3 | 29 | 5 | NCAA Women's Basketball Championship - Regional 1 in Fort Worth - Sweet 16 | L 67-64 vs Notre Dame | NCAA Sweet 16: L 67-64 vs Notre Dame |
| LSU | LSU | 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1 | 12 | 4 | 29 | 6 | NCAA Women's Basketball Championship - Regional 2 in Sacramento - Sweet 16 | L 87-85 vs Duke | NCAA Sweet 16: L 87-85 vs Duke |
| OU | Oklahoma | 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1 | 11 | 5 | 26 | 8 | NCAA Women's Basketball Championship - Regional 4 in Sacramento - Sweet 16 | L 94-68 vs South Carolina | NCAA Sweet 16: L 94-68 vs South Carolina |
| UK | Kentucky | 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0 | 8 | 8 | 25 | 11 | NCAA Women's Basketball Championship - Regional 3 in Fort Worth - Sweet 16 | L 76-54 vs Texas | NCAA Sweet 16: L 76-54 vs Texas |
| MISS | Ole Miss | 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0 | 8 | 8 | 24 | 12 | NCAA Women's Basketball Championship - Regional 2 in Sacramento - 2nd Round | L 65-63 vs Minnesota | NCAA 2nd Round: L 65-63 vs Minnesota |
| UGA | Georgia | 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1 | 8 | 8 | 22 | 10 | NCAA Women's Basketball Championship - Regional 4 in Sacramento - 1st Round | L 82-73 vs Virginia | NCAA 1st Round: L 82-73 vs Virginia |
| TENN | Tennessee | 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0 | 8 | 8 | 16 | 14 | NCAA Women's Basketball Championship - Regional 3 in Fort Worth - 1st Round | L 76-61 vs NC State | NCAA 1st Round: L 76-61 vs NC State |
| ALA | Alabama | 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 | 7 | 9 | 24 | 11 | NCAA Women's Basketball Championship - Regional 3 in Fort Worth - 2nd Round | L 69-68 vs Louisville | NCAA 2nd Round: L 69-68 vs Louisville |
| TA&M | Texas A&M | 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1 | 7 | 9 | 14 | 13 | WBIT - 1st Round | L 68-48 vs McNeese | WBIT 1st Round: L 68-48 vs McNeese |
| FLA | Florida | 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0 | 5 | 11 | 18 | 15 | SEC Tournament - 2nd Round | L 82-64 vs Oklahoma | SEC Tournament: L 82-64 vs Oklahoma |
| MSST | Mississippi State | 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0 | 5 | 11 | 18 | 13 | SEC Tournament - 1st Round | L 86-68 vs Florida | SEC Tournament: L 86-68 vs Florida |
| MIZ | Missouri | 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0 | 4 | 12 | 17 | 17 | WBIT - 2nd Round | L 93-75 vs BYU | WBIT 2nd Round: L 93-75 vs BYU |
| AUB | Auburn | 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0 | 3 | 13 | 15 | 17 | SEC Tournament - 2nd Round | L 73-57 vs Ole Miss | SEC Tournament: L 73-57 vs Ole Miss |
| ARK | Arkansas | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1 | 1 | 15 | 12 | 20 | SEC Tournament - 1st Round | L 94-64 vs Kentucky | SEC Tournament: L 94-64 vs Kentucky |

Every number is there, but the reader gets ids, a list printed as text,
two columns for every record and a raw ESPN note.

## 3. Shape it for a reader

Records read as “13-3”, not two columns, and sit under spanners. The raw
note and the list go (the list comes back as a chart in the next step),
and the March column gets a real label.

``` r

table <- standings |>
  mutate(
    conf = paste0(conf_w, "-", conf_l),
    overall = paste0(w, "-", l)
  ) |>
  select(team_abbr, team, conf, conf_results, overall, march)

draft <- gt(table) |>
  cols_hide(c(team_abbr, conf_results)) |>
  cols_label(team = "Team", conf = "W-L", overall = "W-L", march = "How the season ended") |>
  tab_spanner("Conference", conf) |>
  tab_spanner("Overall", overall) |>
  cols_align("center", c(conf, overall))
draft
```

[TABLE]

## 4. Logos, team colors and the conference season

Three helpers carry the team layer.
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns the abbreviation column into logos.
[`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
stacks each team’s name over its overall record, the record in the
team’s own color, so the logo, name and record read as one block. And
gtExtras’
[`gt_plt_winloss()`](https://jthomasmock.github.io/gtExtras/reference/gt_plt_winloss.html)
draws the list of conference results as a strip of pills, one per game
in date order: a team’s conference season, wins up and losses down, in
one glance.

``` r

with_teams <- draft |>
  cols_unhide(c(team_abbr, conf_results)) |>
  gt_sdv_logos(team_abbr, sport = "wbb", height = 28) |>
  gt_merge_stack_team_color(team, overall, team_abbr, sport = "wbb") |>
  gtExtras::gt_plt_winloss(
    conf_results,
    max_wins = max(lengths(table$conf_results)),
    palette = c("#2e8540", "#c0392b", "grey70"),
    width = 45 # mm: wide enough for 16 readable pills
  ) |>
  cols_label(team_abbr = "", team = "Team", conf_results = "Game by game") |>
  rm_spanners("Conference") |> # widen the spanner over the new column
  tab_spanner("Conference", c(conf, conf_results))
with_teams
```

[TABLE]

## 5. Dress it in the champion’s colors

[`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
is the SportsDataverse table theme in one team’s colors: the title block
takes the team’s primary color and the rule under the column labels its
secondary. Here it is the regular-season champion’s. The title states
the result, the subtitle how to read the strip, and the source note
credits the data; a footnote owns up to the ordering, which is by
conference record and not the conference’s tiebreaker.

``` r

leaders <- filter(standings, conf_w == max(conf_w), conf_l == min(conf_l))
champ <- leaders[1, ]
title <- if (nrow(leaders) == 1) {
  sprintf("%s won the %s at %d-%d", champ$team, conference, champ$conf_w, champ$conf_l)
} else {
  sprintf("%s shared the %s title at %d-%d", paste(leaders$team, collapse = " and "), conference, champ$conf_w, champ$conf_l)
}

final <- with_teams |>
  tab_header(
    title = title,
    subtitle = paste0(
      "Final ", season - 1, "-", season %% 100, " ", conference,
      " standings. Each pill is a conference game, in date order: up for a win, down for a loss."
    )
  ) |>
  tab_source_note("Data: ESPN via wehoop  |  Table: sdvplotR + gt + gtExtras") |>
  tab_footnote(
    "Ordered by conference record, then overall record; not the conference's tiebreaker.",
    locations = cells_column_labels(columns = conf)
  ) |>
  gt_theme_sdv_team(team = champ$team_abbr, sport = "wbb")
final
```

[TABLE]

## 6. Export for the newsletter and Instagram

[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
renders the table in headless Chrome, trims it with an even border and
scales it to 1200 px.
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md)
centers the same table on a canvas of any shape without cropping it;
`aspect_ratio = "4:5"` with `width = 1080` gives Instagram’s 1080 x 1350
portrait post.

``` r

newsletter <- gt_save_crop(final, file.path(out_dir, "sec_wbb_1200.png"), width = 1200)
portrait <- gt_social_crop(
  final, file.path(out_dir, "sec_wbb_1080x1350.png"),
  aspect_ratio = "4:5", width = 1080
)
magick::image_info(magick::image_read(c(newsletter, portrait)))[c("width", "height")]
#> # A tibble: 2 × 2
#>   width height
#>   <int>  <int>
#> 1  1200   1602
#> 2  1080   1350
magick::image_read(newsletter)
```

![The finished SEC women's basketball standings table exported 1200
pixels wide for the
newsletter.](recipe-wbb-conference-standings_files/figure-html/export-1.png)

The 4:5 portrait cut for Instagram:

``` r

magick::image_read(portrait)
```

![The same table centered on a 1080 by 1350 pixel portrait canvas for
Instagram.](recipe-wbb-conference-standings_files/figure-html/export-portrait-1.png)
