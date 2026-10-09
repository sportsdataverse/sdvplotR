# MLB Leaderboard

On this page

**Updated 2026-10-09:** the final 2026 regular season; the postseason is
under way.

This page is rebuilt every week with the site. It builds the division
standings, charts run differential with logos and lists the league
leaders with their headshots, for the latest MLB season with games: the
season to date from opening day to the end of September, the final
regular season after that. Data: the MLB Stats API through
[baseballr](https://BillPetti.github.io/baseballr/); no key needed.

## Picking the season

The season runs inside one calendar year, but before opening day the
Stats API standings for the new season come back empty, or with every
team on zero games. The helper turns both into “not published” and the
page steps back one season. Every Stats API call goes through `live()`:
if the API does not answer, the page shows a note in place of each table
and chart for that week instead of failing the site build. The Stats
API’s season calendar (`mlb_seasons()`) says whether the regular season
is still being played, so the status line can say what the numbers
cover.

``` r

library(sdvplotR)
library(dplyr, warn.conflicts = FALSE)
library(ggplot2)
library(gt)

today <- Sys.Date()
current <- as.integer(format(today, "%Y")) # the season runs inside one calendar year

# A live API call, or NULL when the API does not answer: one bad week then shows
# a note in place of a table instead of failing the whole site build
live <- function(expr) tryCatch(expr, error = function(e) NULL)
unavailable <- function(what, ok) {
  if (ok) "" else sprintf("*%s were unavailable when this page was built on %s; they return next week.*", what, today)
}

# A season's standings from the MLB Stats API, or NULL before opening day: the
# API answers with no rows for a season it has no standings for, or with every
# team on zero games
standings_for <- function(season) {
  table <- live(baseballr::mlb_standings(season = season, league_id = "103,104"))
  if (NROW(table) == 0 || max(table$team_records_games_played) == 0) NULL else table
}

season <- current
raw_standings <- standings_for(season)
if (is.null(raw_standings)) {
  season <- current - 1
  raw_standings <- standings_for(season)
}
# last season always has standings, so none for either season means the API did not answer
available <- !is.null(raw_standings)
leaders_ok <- FALSE

# The Stats API's calendar for the current season: when its regular season and
# postseason end
calendar <- live(baseballr::mlb_seasons(sport_id = 1))
regular_end <- as.Date(as.character(calendar$regular_season_end_date[calendar$season_id == current]))
post_end <- as.Date(as.character(calendar$post_season_end_date[calendar$season_id == current]))
games_per_team <- if (available) round(median(raw_standings$team_records_games_played)) else NA
if (!available) {
  status <- "the MLB Stats API did not answer when this page was built, so this week's tables and chart are missing; they return next week."
  through <- ""
} else if (season < current) {
  status <- sprintf(
    "the offseason, so this is the final %d regular season; the %d season has no games yet.",
    season, current
  )
  through <- "final regular season"
} else if (length(regular_end) == 1 && today <= regular_end) {
  status <- sprintf("the %d season to date, about %d games per team.", season, games_per_team)
  through <- paste("through", games_per_team, "games")
} else if (length(post_end) == 1 && today <= post_end) {
  status <- sprintf("the final %d regular season; the postseason is under way.", season)
  through <- "final regular season"
} else {
  status <- sprintf("the offseason, so this is the final %d regular season.", season)
  through <- "final regular season"
}
```

The standings name each club by its nickname; `mlb_teams()` adds its
abbreviation, full name and division, joined on the Stats API team id.

``` r

clubs <- live(baseballr::mlb_teams(season = season, sport_ids = 1))
available <- NROW(clubs) > 0 # mlb_teams(), like mlb_standings(), answers with no rows when the API is down
```

``` r

clubs <- select(clubs, team_id, abbreviation = team_abbreviation, team_name = team_full_name, division = division_name)
standings <- raw_standings |>
  transmute(
    team_id = team_records_team_id,
    rank = as.integer(team_records_division_rank),
    w = team_records_wins,
    l = team_records_losses,
    pct = as.numeric(team_records_winning_percentage),
    gb = team_records_division_games_back,
    rs = team_records_runs_scored,
    ra = team_records_runs_allowed,
    diff = team_records_run_differential,
    streak = team_records_streak_streak_code
  )
stopifnot(identical(class(standings$team_id), class(clubs$team_id)))
standings <- inner_join(standings, clubs, by = "team_id") |>
  arrange(division, rank)
nrow(standings)
#> [1] 30
```

## 1. Division standings

Six tables in one, grouped by division.
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns the Stats API abbreviations into logos (sdvplotR maps its `AZ` and
`CWS` to ESPN’s `ARI` and `CHW`), and
[`gt_color_pills()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_pills.md)
draws the run differential on a scale centred at zero.

``` r

reach <- max(abs(standings$diff))
standings |>
  mutate(logo = abbreviation) |>
  select(division, logo, team_name, w, l, pct, gb, rs, ra, diff, streak) |>
  gt(groupname_col = "division", id = "mlb-standings") |>
  tab_header(
    title = paste("MLB standings,", season),
    subtitle = paste("By division,", through)
  ) |>
  fmt_number(pct, decimals = 3) |>
  cols_label(
    logo = "", team_name = "Team", w = "W", l = "L", pct = "Pct", gb = "GB",
    rs = "RS", ra = "RA", diff = "Diff", streak = "Streak"
  ) |>
  tab_source_note("Data: MLB Stats API via baseballr | Viz: sdvplotR") |>
  gt_color_pills(
    diff,
    palette = c("#c84630", "#f7f7f7", "#2a7ab9"), domain = c(-reach, reach),
    digits = 0, pill_height = 22
  ) |>
  gt_sdv_logos(columns = logo, sport = "mlb", height = 24) |>
  gt_theme_broadsheet()
```

| MLB standings, 2026 |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|
| By division, final regular season |  |  |  |  |  |  |  |  |  |
|  | Team | W | L | Pct | GB | RS | RA | Diff | Streak |
| American League Central |  |  |  |  |  |  |  |  |  |
| ![Cleveland Guardians](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/88/8883a4e8b7c6bb75f308f1fb27a39eb7cf81ce431ba781edbc4afe082164410f.png) | Cleveland Guardians | 85 | 77 | 0.525 | \- | 678 | 667 | 11 | L1 |
| ![Chicago White Sox](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f9/f92f9c32cea65d9e697a254d09a8ae16326889796f380649b2fee64396cc4640.png) | Chicago White Sox | 84 | 78 | 0.519 | 1.0 | 776 | 720 | 56 | W1 |
| ![Minnesota Twins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3f/3fbce769013cd44f2370505f8982d732c58c511eac9ede4e4d9bbe1b24ad4d39.png) | Minnesota Twins | 77 | 85 | 0.475 | 8.0 | 739 | 797 | -58 | W1 |
| ![Detroit Tigers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/00/0037b82f8f714da9f40b6a2ac036c5086f06ccb139473891135c3321a7a08750.png) | Detroit Tigers | 76 | 86 | 0.469 | 9.0 | 723 | 652 | 71 | L1 |
| ![Kansas City Royals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95188fdcf6d74b4e5437549ad33e20548ce8f3e696621765680354da25a0207b.png) | Kansas City Royals | 69 | 93 | 0.426 | 16.0 | 690 | 810 | -120 | W1 |
| American League East |  |  |  |  |  |  |  |  |  |
| ![Tampa Bay Rays](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3f/3f16f721cfdbb929fac08c9e1d8f9e1ab410be8b409eed5dac9b5f5c9a7af5ae.png) | Tampa Bay Rays | 98 | 64 | 0.605 | \- | 736 | 650 | 86 | L1 |
| ![New York Yankees](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d9/d98856c36bc8d3b0fb0bab5fabd79d2ae057619164365845cbc817b04ae74a26.png) | New York Yankees | 93 | 68 | 0.578 | 4.5 | 739 | 601 | 138 | W1 |
| ![Boston Red Sox](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/47/471966c3b3f4ab7b567b9cd29e7eefc138963182e98b31c01c922335ad265597.png) | Boston Red Sox | 87 | 75 | 0.537 | 11.0 | 689 | 611 | 78 | L1 |
| ![Baltimore Orioles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e9/e96827050e6079674fa20221f5b8b8acbd4f80843f861dbb4d0261b309741472.png) | Baltimore Orioles | 79 | 82 | 0.491 | 18.5 | 718 | 739 | -21 | L1 |
| ![Toronto Blue Jays](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/af/af6d5454549834ea4b8cd6687618a76f936209ecf39eabdb17deaf76d21dd989.png) | Toronto Blue Jays | 79 | 83 | 0.488 | 19.0 | 648 | 694 | -46 | W1 |
| American League West |  |  |  |  |  |  |  |  |  |
| ![Houston Astros](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b7e6858d9d11fe9fade351624bfbab74ec12451749feef37bd1f083d59eb4f7b.png) | Houston Astros | 81 | 81 | 0.500 | \- | 734 | 766 | -32 | W2 |
| ![Texas Rangers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b1/b19ee28a151164ed231d98cafbcebe471faaa876a202e9c558b925be3ac3dac9.png) | Texas Rangers | 80 | 82 | 0.494 | 1.0 | 673 | 719 | -46 | L1 |
| ![Seattle Mariners](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/92/9273d78e456969b14ef9031f39fc0511d8e875a919d887daa6b0898b1ff52226.png) | Seattle Mariners | 76 | 86 | 0.469 | 5.0 | 664 | 722 | -58 | W2 |
| ![Athletics](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f430543a6db8d652e4fb1a81c4ac99ee32022ae587834234a029830a9653b8d2.png) | Athletics | 64 | 98 | 0.395 | 17.0 | 699 | 937 | -238 | L2 |
| ![Los Angeles Angels](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/71/712a4a6f37cac63156de1d17a170532fd6bbbf3a9690b276fec2a6aac751809f.png) | Los Angeles Angels | 62 | 100 | 0.383 | 19.0 | 655 | 752 | -97 | L2 |
| National League Central |  |  |  |  |  |  |  |  |  |
| ![Milwaukee Brewers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d4/d4f8fe1b5be4b266a7cb1520a46a863973467361a1d3fd528502e223cbe35490.png) | Milwaukee Brewers | 103 | 59 | 0.636 | \- | 832 | 618 | 214 | W5 |
| ![Chicago Cubs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/39/39a2b071f52778bbaa9f7d58432db3dcf638bb9a25eb17a901d3551d5d859086.png) | Chicago Cubs | 89 | 73 | 0.549 | 14.0 | 850 | 703 | 147 | W1 |
| ![Pittsburgh Pirates](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0a/0af791c91bc01b4c654a65c90c983c3f907bf2605c67cfaaed731985efff34a1.png) | Pittsburgh Pirates | 82 | 80 | 0.506 | 21.0 | 767 | 739 | 28 | W1 |
| ![St. Louis Cardinals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b738c8aaac9b726336cfa3e42745a4ddcc4c8d9537a9dc0b6abba02c5952e417.png) | St. Louis Cardinals | 77 | 85 | 0.475 | 26.0 | 720 | 749 | -29 | L4 |
| ![Cincinnati Reds](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/57/57f685ca691ba291d8ed31378e489a44b71648b310bfb7ceb8017bd21373f23c.png) | Cincinnati Reds | 75 | 87 | 0.463 | 28.0 | 666 | 826 | -160 | L1 |
| National League East |  |  |  |  |  |  |  |  |  |
| ![Atlanta Braves](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1c/1c36c62410bbed29624672b006173af58bcdfbb066ae9d6f7c4cb99205e861d2.png) | Atlanta Braves | 94 | 68 | 0.580 | \- | 742 | 626 | 116 | L1 |
| ![Philadelphia Phillies](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95997c9aaac40ec5d718b667c374561b782e5cb88665d69daf3178a16401d683.png) | Philadelphia Phillies | 88 | 74 | 0.543 | 6.0 | 713 | 698 | 15 | W1 |
| ![Miami Marlins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ef/ef37342904a50d2807c45432909de83c62c6795e9e54ebe42ac85fdd5e24c91f.png) | Miami Marlins | 80 | 82 | 0.494 | 14.0 | 715 | 712 | 3 | W1 |
| ![Washington Nationals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1d/1d65931fe979aec3fe59a60b2d9df900e3f84da0eca81eb1646d0ea3a93fc810.png) | Washington Nationals | 77 | 85 | 0.475 | 17.0 | 821 | 815 | 6 | W1 |
| ![New York Mets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/94/94c334280d388936cb193fca6c3b620d2ed6abb7b932f352fa575630ce6243bd.png) | New York Mets | 74 | 88 | 0.457 | 20.0 | 699 | 731 | -32 | L1 |
| National League West |  |  |  |  |  |  |  |  |  |
| ![Los Angeles Dodgers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/aa/aab854c59098d4f465c1c6f31b580f2a38d2ed4f5c0c03df2da76f62f5378dc4.png) | Los Angeles Dodgers | 100 | 62 | 0.617 | \- | 801 | 600 | 201 | W3 |
| ![San Diego Padres](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8b/8bb012967768a5f476ff427f433e89960149217777c6371d80eafb8725c2f175.png) | San Diego Padres | 91 | 71 | 0.562 | 9.0 | 722 | 681 | 41 | W2 |
| ![Arizona Diamondbacks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b0/b060f0fcc21d64b978be260f0c24880c50094f0ec8e640d14896dc5045bf0b21.png) | Arizona Diamondbacks | 86 | 76 | 0.531 | 14.0 | 739 | 730 | 9 | L2 |
| ![San Francisco Giants](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/da/dad3e0a51931bb8281ebb0215624849e0fd6cbec81aafc6a12d2260f583c04e5.png) | San Francisco Giants | 65 | 97 | 0.401 | 35.0 | 669 | 760 | -91 | L5 |
| ![Colorado Rockies](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bd/bd21e7588f021af3b44cc0aeab2b281ddc515b7d6b6a68e4c823086ed585ea75.png) | Colorado Rockies | 58 | 104 | 0.358 | 42.0 | 752 | 944 | -192 | L1 |
| Data: MLB Stats API via baseballr \| Viz: sdvplotR |  |  |  |  |  |  |  |  |  |

## 2. Run differential

Every club’s run differential as a bar in its primary color, best at the
top, with its logo at the end of the bar.

``` r

if (available) {
  rd <- standings |>
    arrange(diff, desc(team_name)) |> # the name breaks a tie, so an unchanged week renders the same
    mutate(
      label = sprintf("%s (%+d)", team_name, diff),
      label = factor(label, levels = label),
      end = diff + sign(diff) * 0.06 * reach
    )

  ggplot(rd, aes(y = label)) +
    geom_col(aes(x = diff, fill = abbreviation), width = 0.72) +
    geom_vline(xintercept = 0, colour = "grey20", linewidth = 0.4) +
    geom_sdv_logos(aes(x = end, team = abbreviation), sport = "mlb", height = 0.028) +
    scale_fill_sdv(sport = "mlb", guide = "none") +
    scale_x_continuous(limits = c(-1.15, 1.15) * reach) +
    labs(
      title = paste("MLB run differential,", season, through),
      subtitle = "Runs scored minus runs allowed",
      x = "Run differential", y = NULL,
      caption = "Data: MLB Stats API via baseballr | Viz: sdvplotR"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank()
    )
} else {
  # the Stats API did not answer: a stand-in keeps this figure, which the gallery shows
  ggplot() +
    annotate("text", x = 0, y = 0, size = 5, label = paste0(
      "MLB standings were unavailable when this page was built on ", today, ".\nThey return next week."
    )) +
    theme_void()
}
```

![Horizontal bar chart of every MLB club's run differential, best at the
top, each bar in the club's primary color with its logo at the end of
the bar.](leaderboard-mlb_files/figure-html/run-differential-1.png)

## 3. League leaders with headshots

The Stats API’s leaderboards, one category at a time
(`mlb_stats_leaders()`; the rate stats list qualified players only). Its
player ids are MLBAM ids, which `gt_sdv_headshots(id_type = "league")`
turns into MLB’s own headshots. Ties share a rank, so a category can
show more than three players.

``` r

categories <- tibble::tribble(
  ~category, ~stat, ~group, ~digits,
  "Home runs", "homeRuns", "hitting", 0,
  "Batting average", "battingAverage", "hitting", 3,
  "OPS", "onBasePlusSlugging", "hitting", 3,
  "Stolen bases", "stolenBases", "hitting", 0,
  "ERA", "earnedRunAverage", "pitching", 2,
  "Strikeouts", "strikeouts", "pitching", 0
)
top3 <- function(i) {
  x <- live(baseballr::mlb_stats_leaders(
    leader_categories = categories$stat[i], season = season, sport_id = 1,
    leader_game_types = "R", limit = 3
  ))
  if (NROW(x) == 0) {
    return(NULL) # the API did not answer for this category
  }
  x |>
    filter(stat_group == categories$group[i], rank <= 3) |>
    transmute(
      category = categories$category[i], rank, person_id, player = person_full_name, team_id,
      value = formatC(as.numeric(value), format = "f", digits = categories$digits[i])
    )
}
leaders <- bind_rows(lapply(seq_len(nrow(categories)), top3))
leaders_ok <- nrow(leaders) > 0
if (leaders_ok) {
  leaders <- leaders |>
    left_join(select(clubs, team_id, abbreviation), by = "team_id") |>
    mutate(
      value = sub("^0\\.", ".", value), # .312, not 0.312, as baseball writes it
      headshot = person_id
    )
}
head(leaders)
#> # A tibble: 6 × 8
#>   category         rank person_id player     team_id value abbreviation headshot
#>   <chr>           <int>     <int> <chr>        <int> <chr> <chr>           <int>
#> 1 Home runs           1    691718 Pete Crow…     112 45    CHC            691718
#> 2 Home runs           1    656941 Kyle Schw…     143 45    PHI            656941
#> 3 Home runs           3    624413 Pete Alon…     110 43    BAL            624413
#> 4 Batting average     1    670541 Yordan Al…     117 .316  HOU            670541
#> 5 Batting average     2    672515 Gabriel M…     109 .311  AZ             672515
#> 6 Batting average     3    650333 Luis Arra…     143 .310  PHI            650333
```

``` r

leaders |>
  select(category, rank, headshot, player, abbreviation, value) |>
  gt(groupname_col = "category", id = "mlb-leaders") |>
  tab_header(
    title = paste("MLB leaders,", season),
    subtitle = paste0("Top three, ", through)
  ) |>
  cols_label(rank = "", headshot = "", player = "Player", abbreviation = "", value = "") |>
  cols_align("right", value) |>
  tab_source_note("Data: MLB Stats API via baseballr | Viz: sdvplotR") |>
  gt_sdv_headshots(columns = headshot, sport = "mlb", id_type = "league", height = 36) |>
  gt_sdv_logos(columns = abbreviation, sport = "mlb", height = 22) |>
  gt_theme_savant()
```

| MLB leaders, 2026 |  |  |  |  |
|----|----|----|----|----|
| Top three, final regular season |  |  |  |  |
|  |  | Player |  |  |
| Home runs |  |  |  |  |
| 1 | ![Player 691718 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/691718/headshot/67/current.png) | Pete Crow-Armstrong | ![Chicago Cubs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/39/39a2b071f52778bbaa9f7d58432db3dcf638bb9a25eb17a901d3551d5d859086.png) | 45 |
| 1 | ![Player 656941 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/656941/headshot/67/current.png) | Kyle Schwarber | ![Philadelphia Phillies](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95997c9aaac40ec5d718b667c374561b782e5cb88665d69daf3178a16401d683.png) | 45 |
| 3 | ![Player 624413 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/624413/headshot/67/current.png) | Pete Alonso | ![Baltimore Orioles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e9/e96827050e6079674fa20221f5b8b8acbd4f80843f861dbb4d0261b309741472.png) | 43 |
| Batting average |  |  |  |  |
| 1 | ![Player 670541 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/670541/headshot/67/current.png) | Yordan Alvarez | ![Houston Astros](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b7e6858d9d11fe9fade351624bfbab74ec12451749feef37bd1f083d59eb4f7b.png) | .316 |
| 2 | ![Player 672515 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/672515/headshot/67/current.png) | Gabriel Moreno | ![Arizona Diamondbacks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b0/b060f0fcc21d64b978be260f0c24880c50094f0ec8e640d14896dc5045bf0b21.png) | .311 |
| 3 | ![Player 650333 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/650333/headshot/67/current.png) | Luis Arraez | ![Philadelphia Phillies](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95997c9aaac40ec5d718b667c374561b782e5cb88665d69daf3178a16401d683.png) | .310 |
| OPS |  |  |  |  |
| 1 | ![Player 670541 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/670541/headshot/67/current.png) | Yordan Alvarez | ![Houston Astros](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b7e6858d9d11fe9fade351624bfbab74ec12451749feef37bd1f083d59eb4f7b.png) | 1.033 |
| 2 | ![Player 691718 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/691718/headshot/67/current.png) | Pete Crow-Armstrong | ![Chicago Cubs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/39/39a2b071f52778bbaa9f7d58432db3dcf638bb9a25eb17a901d3551d5d859086.png) | .942 |
| 3 | ![Player 575929 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/575929/headshot/67/current.png) | Willson Contreras | ![Boston Red Sox](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/47/471966c3b3f4ab7b567b9cd29e7eefc138963182e98b31c01c922335ad265597.png) | .902 |
| Stolen bases |  |  |  |  |
| 1 | ![Player 683083 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/683083/headshot/67/current.png) | Nasim Nuñez | ![Washington Nationals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1d/1d65931fe979aec3fe59a60b2d9df900e3f84da0eca81eb1646d0ea3a93fc810.png) | 49 |
| 2 | ![Player 802415 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/802415/headshot/67/current.png) | Chandler Simpson | ![Tampa Bay Rays](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3f/3f16f721cfdbb929fac08c9e1d8f9e1ab410be8b409eed5dac9b5f5c9a7af5ae.png) | 46 |
| 3 | ![Player 677951 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/677951/headshot/67/current.png) | Bobby Witt Jr. | ![Kansas City Royals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/95/95188fdcf6d74b4e5437549ad33e20548ce8f3e696621765680354da25a0207b.png) | 45 |
| ERA |  |  |  |  |
| 1 | ![Player 694819 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/694819/headshot/67/current.png) | Jacob Misiorowski | ![Milwaukee Brewers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d4/d4f8fe1b5be4b266a7cb1520a46a863973467361a1d3fd528502e223cbe35490.png) | 1.80 |
| 2 | ![Player 693645 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/693645/headshot/67/current.png) | Cam Schlittler | ![New York Yankees](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d9/d98856c36bc8d3b0fb0bab5fabd79d2ae057619164365845cbc817b04ae74a26.png) | 1.95 |
| 3 | ![Player 519242 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/519242/headshot/67/current.png) | Chris Sale | ![Atlanta Braves](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1c/1c36c62410bbed29624672b006173af58bcdfbb066ae9d6f7c4cb99205e861d2.png) | 2.16 |
| Strikeouts |  |  |  |  |
| 1 | ![Player 694819 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/694819/headshot/67/current.png) | Jacob Misiorowski | ![Milwaukee Brewers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d4/d4f8fe1b5be4b266a7cb1520a46a863973467361a1d3fd528502e223cbe35490.png) | 252 |
| 2 | ![Player 668909 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/668909/headshot/67/current.png) | Gavin Williams | ![Cleveland Guardians](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/88/8883a4e8b7c6bb75f308f1fb27a39eb7cf81ce431ba781edbc4afe082164410f.png) | 248 |
| 3 | ![Player 656302 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/656302/headshot/67/current.png) | Dylan Cease | ![Toronto Blue Jays](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/af/af6d5454549834ea4b8cd6687618a76f936209ecf39eabdb17deaf76d21dd989.png) | 239 |
| 3 | ![Player 693645 headshot](https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_213,q_auto:best/v1/people/693645/headshot/67/current.png) | Cam Schlittler | ![New York Yankees](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d9/d98856c36bc8d3b0fb0bab5fabd79d2ae057619164365845cbc817b04ae74a26.png) | 239 |
| Data: MLB Stats API via baseballr \| Viz: sdvplotR |  |  |  |  |

## Related

- [MLB](https://sdvplotR.sportsdataverse.org/articles/mlb-viz.md) walks
  through baseballr and sdvplotR more broadly.
- [NHL](https://sdvplotR.sportsdataverse.org/articles/leaderboard-nhl.md)
  builds the same three views for hockey.
- [Social graphics,
  automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.md)
  posts leaderboards like these on a schedule.
