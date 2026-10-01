# Neighbour Ranks

A rank says where a team sits, but not how close the teams around it
are. This recipe puts one team in the middle of an 11-row table, the
five teams ranked just above it and the five just below, so the gap to
its neighbours shows next to the number.

It uses three sdvplotR helpers:
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
for the logos and names,
[`gt_color_ranks()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_ranks.md)
for the rank column and
[`gt_highlight_cells()`](https://sdvplotR.sportsdataverse.org/reference/gt_highlight_cells.md)
for the focal row.

``` r

library(sdvplotR)
library(gt)
```

## The data

cfbfastR’s
[`load_espn_cfb_team_summaries()`](https://cfbfastR.sportsdataverse.org/reference/load_espn_cfb_team_summaries.html)
reads the SportsDataverse season summary release: one row per FBS team,
with each metric next to a `_rank` column.

``` r

summaries <- as.data.frame(cfbfastR::load_espn_cfb_team_summaries(2025))
dim(summaries)
#> [1] 136 781
head(grep("_rank$", names(summaries), value = TRUE))
#> [1] "playsgame_off_rank"      "TEPA_off_rank"          
#> [3] "EPAgame_off_rank"        "EPAplay_off_rank"       
#> [5] "EPAdrive_off_rank"       "early_down_EPA_off_rank"
```

Not every metric has a rank, so check the three this recipe uses. Rank 1
is the best team in each one: the highest net and offensive EPA per
play, and the fewest EPA per play allowed on defense.

``` r

metrics <- c(
  net_adj_epa = "Net adj. EPA/play",
  EPAplay_off = "Offense EPA/play",
  EPAplay_def = "Defense EPA/play"
)
stopifnot(all(paste0(names(metrics), "_rank") %in% names(summaries)))
```

## The window

Sort by the rank column and take the 11 rows centred on the team. Near
the top or bottom of the table there are not five teams on both sides,
so the window slides instead of shrinking: it stays 11 rows and the
focal team moves off centre.

``` r

neighbours <- function(data, team, metric, k = 5) {
  data <- data[order(data[[paste0(metric, "_rank")]]), ]
  i <- match(team, data$pos_team)
  first <- min(max(i - k, 1), nrow(data) - 2 * k)
  rows <- data[first:(first + 2 * k), ]
  data.frame(
    rank = rows[[paste0(metric, "_rank")]],
    team = rows$pos_team,
    value = rows[[metric]]
  )
}

focal <- "Illinois"
neighbours(summaries, focal, "net_adj_epa")
#>    rank          team      value
#> 1    33 Arizona State 0.14895167
#> 2    34           LSU 0.14863508
#> 3    35           TCU 0.14363305
#> 4    36    Iowa State 0.14187993
#> 5    37    Pittsburgh 0.14057645
#> 6    38      Illinois 0.12903856
#> 7    39        Toledo 0.12589637
#> 8    40  Old Dominion 0.12225295
#> 9    41   Wake Forest 0.10366062
#> 10   42      NC State 0.10080771
#> 11   43          Duke 0.09787713
```

## The table

The rank colors use the whole league as their domain (`1` to the number
of teams), not the 11 rows on show, so a mid-table window reads as
mid-table. The focal team’s name and value are filled with
[`gt_highlight_cells()`](https://sdvplotR.sportsdataverse.org/reference/gt_highlight_cells.md),
which takes a logical mask the same shape as the columns it fills.

``` r

neighbour_table <- function(data, focal_team, metric, label) {
  win <- neighbours(data, focal_team, metric)
  is_focal <- win$team == focal_team
  gt(win) |>
    tab_header(title = label) |>
    gt_sdv_logos(team, sport = "cfb", height = 20, include_name = TRUE) |>
    fmt_number(value, decimals = 3) |>
    cols_label(rank = "Rank", team = "Team", value = "Value") |>
    gt_theme_sdv_team(team = focal_team, sport = "cfb", density = "compact") |>
    gt_color_ranks(rank, domain = c(1, nrow(data))) |>
    gt_highlight_cells(c(team, value), cbind(is_focal, is_focal), bold = TRUE)
}

neighbour_table(summaries, focal, "net_adj_epa", metrics[["net_adj_epa"]])
```

| Net adj. EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 33 | ![The ASU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/9.png)Arizona State | 0.149 |
| 34 | ![The LSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/99.png)LSU | 0.149 |
| 35 | ![The TCU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2628.png)TCU | 0.144 |
| 36 | ![The ISU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/66.png)Iowa State | 0.142 |
| 37 | ![The PITT logo](https://a.espncdn.com/i/teamlogos/ncaa/500/221.png)Pittsburgh | 0.141 |
| 38 | ![The ILL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/356.png)Illinois | 0.129 |
| 39 | ![The TOL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2649.png)Toledo | 0.126 |
| 40 | ![The ODU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/295.png)Old Dominion | 0.122 |
| 41 | ![The WAKE logo](https://a.espncdn.com/i/teamlogos/ncaa/500/154.png)Wake Forest | 0.104 |
| 42 | ![The NCSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/152.png)NC State | 0.101 |
| 43 | ![The DUKE logo](https://a.espncdn.com/i/teamlogos/ncaa/500/150.png)Duke | 0.098 |

## Three metrics side by side

The same function, once per metric, laid out with
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md).

``` r

tables <- lapply(names(metrics), function(m) {
  neighbour_table(summaries, focal, m, metrics[[m]])
})
gt_grid(
  tables,
  ncol = 3,
  gap = 12,
  title = paste(focal, "and its neighbours"),
  subtitle = "2025 FBS season, five teams either side by rank",
  caption = "Data: cfbfastR::load_espn_cfb_team_summaries()"
)
```

Illinois and its neighbours

2025 FBS season, five teams either side by rank

| Net adj. EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 33 | ![The ASU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/9.png)Arizona State | 0.149 |
| 34 | ![The LSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/99.png)LSU | 0.149 |
| 35 | ![The TCU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2628.png)TCU | 0.144 |
| 36 | ![The ISU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/66.png)Iowa State | 0.142 |
| 37 | ![The PITT logo](https://a.espncdn.com/i/teamlogos/ncaa/500/221.png)Pittsburgh | 0.141 |
| 38 | ![The ILL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/356.png)Illinois | 0.129 |
| 39 | ![The TOL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2649.png)Toledo | 0.126 |
| 40 | ![The ODU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/295.png)Old Dominion | 0.122 |
| 41 | ![The WAKE logo](https://a.espncdn.com/i/teamlogos/ncaa/500/154.png)Wake Forest | 0.104 |
| 42 | ![The NCSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/152.png)NC State | 0.101 |
| 43 | ![The DUKE logo](https://a.espncdn.com/i/teamlogos/ncaa/500/150.png)Duke | 0.098 |

| Offense EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 27 | ![The MEM logo](https://a.espncdn.com/i/teamlogos/ncaa/500/235.png)Memphis | 0.144 |
| 28 | ![The SMU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2567.png)SMU | 0.141 |
| 29 | ![The ARMY logo](https://a.espncdn.com/i/teamlogos/ncaa/500/349.png)Army | 0.138 |
| 30 | ![The RUTG logo](https://a.espncdn.com/i/teamlogos/ncaa/500/164.png)Rutgers | 0.134 |
| 31 | ![The TEX logo](https://a.espncdn.com/i/teamlogos/ncaa/500/251.png)Texas | 0.132 |
| 32 | ![The ILL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/356.png)Illinois | 0.131 |
| 33 | ![The OHIO logo](https://a.espncdn.com/i/teamlogos/ncaa/500/195.png)Ohio | 0.129 |
| 34 | ![The EMU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2199.png)Eastern Michigan | 0.126 |
| 35 | ![The MICH logo](https://a.espncdn.com/i/teamlogos/ncaa/500/130.png)Michigan | 0.123 |
| 36 | ![The UAB logo](https://a.espncdn.com/i/teamlogos/ncaa/500/5.png)UAB | 0.120 |
| 37 | ![The PSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/213.png)Penn State | 0.119 |

| Defense EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 96 | ![The FLA logo](https://a.espncdn.com/i/teamlogos/ncaa/500/57.png)Florida | 0.135 |
| 97 | ![The MRSH logo](https://a.espncdn.com/i/teamlogos/ncaa/500/276.png)Marshall | 0.135 |
| 98 | ![The MSST logo](https://a.espncdn.com/i/teamlogos/ncaa/500/344.png)Mississippi State | 0.136 |
| 99 | ![The UL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/309.png)Louisiana | 0.138 |
| 100 | ![The APP logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2026.png)App State | 0.141 |
| 101 | ![The ILL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/356.png)Illinois | 0.142 |
| 102 | ![The TEM logo](https://a.espncdn.com/i/teamlogos/ncaa/500/218.png)Temple | 0.144 |
| 103 | ![The CAL logo](https://a.espncdn.com/i/teamlogos/ncaa/500/25.png)California | 0.145 |
| 104 | ![The SJSU logo](https://a.espncdn.com/i/teamlogos/ncaa/500/23.png)San José State | 0.145 |
| 105 | ![The TXST logo](https://a.espncdn.com/i/teamlogos/ncaa/500/326.png)Texas State | 0.145 |
| 106 | ![The CLT logo](https://a.espncdn.com/i/teamlogos/ncaa/500/2429.png)Charlotte | 0.150 |

Data: cfbfastR::load_espn_cfb_team_summaries()

## Checking the window

A team more than five places from either end is row 6 of 11. Check it
for every team on all three metrics, then look at the rows the top and
bottom teams land on.

``` r

row_of <- function(team, metric) {
  match(team, neighbours(summaries, team, metric)$team)
}
n <- nrow(summaries)

for (m in names(metrics)) {
  ranks <- summaries[[paste0(m, "_rank")]]
  rows <- vapply(summaries$pos_team, row_of, integer(1), metric = m)
  stopifnot(all(rows[ranks > 5 & ranks <= n - 5] == 6))
}

ranks <- summaries$net_adj_epa_rank
edges <- summaries$pos_team[order(ranks)][c(1:6, (n - 5):n)]
data.frame(
  team = edges,
  rank = ranks[match(edges, summaries$pos_team)],
  row = unname(vapply(edges, row_of, integer(1), metric = "net_adj_epa"))
)
#>             team rank row
#> 1        Indiana    1   1
#> 2     Ohio State    2   2
#> 3     Notre Dame    3   3
#> 4          Miami    4   4
#> 5     Texas Tech    5   5
#> 6         Oregon    6   6
#> 7     Kent State  131   6
#> 8      Charlotte  132   7
#> 9          Akron  133   8
#> 10    Ball State  134   9
#> 11   Sam Houston  135  10
#> 12 Massachusetts  136  11
```
