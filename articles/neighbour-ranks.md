# Neighbour Ranks

On this page

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

cfbfastR’s `load_espn_cfb_team_summaries()` reads the SportsDataverse
season summary release: one row per FBS team, with each metric next to a
`_rank` column.

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
#>    rank          team     value
#> 1    30    Louisville 0.1487155
#> 2    31 South Florida 0.1463640
#> 3    32      Virginia 0.1397002
#> 4    33           TCU 0.1341972
#> 5    34    Iowa State 0.1333091
#> 6    35      Illinois 0.1278535
#> 7    36 East Carolina 0.1276368
#> 8    37     Tennessee 0.1206984
#> 9    38        Toledo 0.1150806
#> 10   39    Pittsburgh 0.1124272
#> 11   40  Old Dominion 0.1124005
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
| 30 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7c/7c5e06bfb990c80176ef56e171bfb2de264355db54c592462d5f8a02404412e8.png)Louisville | 0.149 |
| 31 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/a7/a74207f69d800eba006138acef12a1436166c868ba14c94e1578190358dd0d14.png)South Florida | 0.146 |
| 32 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d3/d35c8362ad7a6f03b32e30bc0745cb481da320da96010c7327f3c78359ac9fe5.png)Virginia | 0.140 |
| 33 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/86/864561cb4ebf372171438c038fcf52eac3342a2c1d751e605901e144c70afda0.png)TCU | 0.134 |
| 34 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8b/8b490fe0621ea18538cf38e2b9c462beff54b26ee4707c54d024547e82e7cd63.png)Iowa State | 0.133 |
| 35 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/62/62c3b65a1ab3e8cad05832d76dd7b3fb695c8220c07f0fe5aa44ef12abcda56c.png)Illinois | 0.128 |
| 36 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0a/0ae06f5e6518c5065c93cde42d17853ddc6c6abe56502ef2bbcbf3bd52f9adb5.png)East Carolina | 0.128 |
| 37 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1e/1ef03aa847164f52dee3c8bfea023e3b75915231c01250889a549ae08b2ec9b8.png)Tennessee | 0.121 |
| 38 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/64/64a7bd6719c228709bd83551956fa1d28b0e4728dadc9dd14ed4c0fab3a0b0bb.png)Toledo | 0.115 |
| 39 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c2/c283722b1c9f4b47b7361d7d959422225de4ad4682b0eadcd66f707c015506f3.png)Pittsburgh | 0.112 |
| 40 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d7/d7715a34978cfdb27bdb863a6c0de3d7a4c122e80de0c72397b8a23aa3d10fa7.png)Old Dominion | 0.112 |

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
| 30 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7c/7c5e06bfb990c80176ef56e171bfb2de264355db54c592462d5f8a02404412e8.png)Louisville | 0.149 |
| 31 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/a7/a74207f69d800eba006138acef12a1436166c868ba14c94e1578190358dd0d14.png)South Florida | 0.146 |
| 32 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d3/d35c8362ad7a6f03b32e30bc0745cb481da320da96010c7327f3c78359ac9fe5.png)Virginia | 0.140 |
| 33 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/86/864561cb4ebf372171438c038fcf52eac3342a2c1d751e605901e144c70afda0.png)TCU | 0.134 |
| 34 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8b/8b490fe0621ea18538cf38e2b9c462beff54b26ee4707c54d024547e82e7cd63.png)Iowa State | 0.133 |
| 35 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/62/62c3b65a1ab3e8cad05832d76dd7b3fb695c8220c07f0fe5aa44ef12abcda56c.png)Illinois | 0.128 |
| 36 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0a/0ae06f5e6518c5065c93cde42d17853ddc6c6abe56502ef2bbcbf3bd52f9adb5.png)East Carolina | 0.128 |
| 37 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1e/1ef03aa847164f52dee3c8bfea023e3b75915231c01250889a549ae08b2ec9b8.png)Tennessee | 0.121 |
| 38 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/64/64a7bd6719c228709bd83551956fa1d28b0e4728dadc9dd14ed4c0fab3a0b0bb.png)Toledo | 0.115 |
| 39 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c2/c283722b1c9f4b47b7361d7d959422225de4ad4682b0eadcd66f707c015506f3.png)Pittsburgh | 0.112 |
| 40 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d7/d7715a34978cfdb27bdb863a6c0de3d7a4c122e80de0c72397b8a23aa3d10fa7.png)Old Dominion | 0.112 |

| Offense EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 29 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f8/f844b98efad3ea95ba434826c6e9f1707487000a0c65c51412e3dc067971433c.png)Eastern Michigan | 0.120 |
| 30 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1d/1dbe095805cd1636fc5aac2918eedf81b4dad43329a8c1e665616ee1d79840a7.png)SMU | 0.119 |
| 31 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/90/905b2e96ff5a391a789276d4b211134ca295a91bc352d1ba5668c79fbfcc0bbb.png)UAB | 0.116 |
| 32 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bb/bbe36252ce70f54489fbd0a0c0ec27bfdbd4f84d2789fc9906bda5ccd93c7aab.png)Army | 0.113 |
| 33 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2f/2fbdfa08adebb0be79d920a92b46e7e153e6dff49a4335b93b86a527525f836b.png)Ohio | 0.111 |
| 34 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/62/62c3b65a1ab3e8cad05832d76dd7b3fb695c8220c07f0fe5aa44ef12abcda56c.png)Illinois | 0.111 |
| 35 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0e/0efa003a56ec95d664b71d799fabe5e927d2ddd23cea90d5bab42df971abd080.png)Penn State | 0.109 |
| 36 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2a/2a7cb32da0408fbd277fa184f3eee42ce983ebab70c8e819abb2865ac440717c.png)Temple | 0.106 |
| 37 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/12/12d69bb78c3443bdbcc5a7659f288840a7a3862d70043eda3d8868a229eb7696.png)Texas | 0.104 |
| 38 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ee/ee51da26e5cdf389cc787c58478f10bb03503832e35f862b4f208d273819d8ec.png)NC State | 0.100 |
| 39 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d2/d2cb5546e8f39a2cffebd99ddbb06be2bb4b4b634414a6e628573ad4bd04f1f2.png)Utah State | 0.093 |

| Defense EPA/play |  |  |
|----|----|----|
| Rank | Team | Value |
| 94 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1d/1da7fba7069492d881b01a375a5ffde5632273d31118d4466d1b92db447daefb.png)Marshall | 0.108 |
| 95 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/59/5953d0a7dd1e44d82402467043f2cd63003d74a0dc3bff754cb467ab93104436.png)North Texas | 0.110 |
| 96 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/50/504a8c3ff5469e6c367e3925e573324e8efd0c0e42a034658e1609a62f1b1ed3.png)Louisiana | 0.111 |
| 97 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/18/1854b6d52609c4db7daacc59ce122017c3eabd2e70b9c66deeec297183d4d46b.png)Mississippi State | 0.112 |
| 98 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ee/ee51da26e5cdf389cc787c58478f10bb03503832e35f862b4f208d273819d8ec.png)NC State | 0.114 |
| 99 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/62/62c3b65a1ab3e8cad05832d76dd7b3fb695c8220c07f0fe5aa44ef12abcda56c.png)Illinois | 0.117 |
| 100 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b7/b786de17b998fa272d6e02d193d2a84db93b4339975301d825af770d3b2ede5a.png)San José State | 0.118 |
| 101 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e9/e99c6598ff920716bf12c731a4b52039c2350d373d2a86d98df4dd592c491d4d.png)Kent State | 0.118 |
| 102 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/48/487c6f3fbe9c41cf532b6de285f1d35585ee7ca9510e5aa45000d97a1f597e5d.png)App State | 0.119 |
| 103 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0e/0e81afbb4d334e48237c83fd2cea6239871e2f8167def9ce9a836b1e2a325366.png)Texas State | 0.119 |
| 104 | ![](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1e/1ef03aa847164f52dee3c8bfea023e3b75915231c01250889a549ae08b2ec9b8.png)Tennessee | 0.121 |

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
#> 7      Charlotte  131   6
#> 8        Buffalo  132   7
#> 9          Akron  133   8
#> 10    Ball State  134   9
#> 11   Sam Houston  135  10
#> 12 Massachusetts  136  11
```
