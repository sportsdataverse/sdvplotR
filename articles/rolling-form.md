# Rolling Form

A season average is slow to move. A team’s form changes faster: the
offense that struggled in September can look different over its last two
games or so. This recipe compares each team’s last 150 offensive plays
with the 150 before them, then lists the five biggest risers and the
five biggest fallers.

There is no NBA rolling-window release yet, so this recipe is college
football only.

``` r

library(sdvplotR)
library(gt)
library(dplyr, warn.conflicts = FALSE)
```

## The data

The `cfb_rolling_windows` release has one file per season and no R
loader, so read it by URL.
[`nflreadr::load_from_url()`](https://nflreadr.nflverse.com/reference/load_from_url.html)
reads the `.rds` copy with packages the site already uses. The
`.parquet` and `.csv` copies hold the same rows.

``` r

url <- paste0(
  "https://github.com/sportsdataverse/sportsdataverse-data/releases/download/",
  "cfb_rolling_windows/rolling_windows_2026.rds"
)
windows <- as.data.frame(nflreadr::load_from_url(url))
stopifnot(nrow(windows) > 0)
dim(windows)
#> [1] 23778    20
names(windows)
#>  [1] "season"          "entity_type"     "entity_id"       "entity_name"    
#>  [5] "team_id"         "metric"          "window_unit"     "window_n"       
#>  [9] "cur"             "prev"            "season_start"    "career_baseline"
#> [13] "delta_prev"      "delta_season"    "delta_career"    "delta_prev_rank"
#> [17] "n"               "qualified"       "last_event_date" "as_of_date"
```

Each row is one player or team, one metric and one window size.

- `cur` is the metric over the last `window_n` events (plays, carries,
  dropbacks or targets, named in `window_unit`).
- `prev` is the metric over the `window_n` events before those.
- `delta_prev` is `cur - prev`, and `delta_prev_rank` ranks it (1 is the
  biggest rise).
- `n` is how many events the last window holds. A row is `qualified`
  once that window is full.

``` r

count(windows, entity_type, metric, window_unit, window_n)
#>    entity_type       metric window_unit window_n    n
#> 1       player          epa       carry       50 1902
#> 2       player          epa       carry      100 1902
#> 3       player          epa    dropback       50  583
#> 4       player          epa    dropback      100  583
#> 5       player          epa    dropback      300  583
#> 6       player          epa      target       30 2935
#> 7       player          epa      target       60 2935
#> 8       player success_rate       carry       50 1902
#> 9       player success_rate       carry      100 1902
#> 10      player success_rate    dropback       50  583
#> 11      player success_rate    dropback      100  583
#> 12      player success_rate    dropback      300  583
#> 13      player success_rate      target       30 2935
#> 14      player success_rate      target       60 2935
#> 15        team          epa        play      150  233
#> 16        team          epa        play      300  233
#> 17        team success_rate        play      150  233
#> 18        team success_rate        play      300  233
```

This file is the season in progress. The date shows how current it is:

``` r

as_of <- unique(windows$as_of_date)
stopifnot(length(as_of) == 1)
as_of
#> [1] "2026-09-26"
```

## Risers and fallers

Keep teams, EPA per play and the 150-play window, and only qualified
rows that also have a previous window: a program with no earlier plays
has no change to rank. The percentile places each team’s last 150 plays
among every team in the same pool, so a big riser can still be below
average.

``` r

pool <- windows |>
  filter(
    entity_type == "team", metric == "epa", window_n == 150,
    qualified, !is.na(prev)
  ) |>
  mutate(pct = 100 * percent_rank(cur))
stopifnot(all(pool$n == 150), !anyDuplicated(pool$entity_id))
nrow(pool)
#> [1] 226

movers <- bind_rows(
  Risers = slice_max(pool, delta_prev, n = 5, with_ties = FALSE),
  Fallers = slice_min(pool, delta_prev, n = 5, with_ties = FALSE),
  .id = "group"
) |>
  select(group, entity_name, prev, cur, n, pct, delta_prev_rank)
movers
#>      group               entity_name        prev        cur   n        pct
#> 1   Risers      Alabama Crimson Tide -0.10151620  0.4945306 150 100.000000
#> 2   Risers    Oklahoma State Cowboys -0.13878441  0.4332472 150  99.111111
#> 3   Risers       South Florida Bulls -0.10999821  0.3512151 150  96.444444
#> 4   Risers               BYU Cougars -0.01676469  0.3991717 150  98.666667
#> 5   Risers     Northwestern Wildcats -0.12312879  0.2857645 150  92.888889
#> 6  Fallers    Northern Iowa Panthers  0.26090279 -0.3017157 150   8.000000
#> 7  Fallers      Holy Cross Crusaders  0.26830223 -0.2380549 150  15.555556
#> 8  Fallers        Maryland Terrapins  0.27575280 -0.1924150 150  20.444444
#> 9  Fallers   Louisiana Tech Bulldogs  0.14168189 -0.3138782 150   5.777778
#> 10 Fallers Northwestern State Demons -0.16528011 -0.5938391 150   0.000000
#>    delta_prev_rank
#> 1                1
#> 2                2
#> 3                3
#> 4                4
#> 5                5
#> 6              226
#> 7              225
#> 8              224
#> 9              223
#> 10             222
```

The pool holds every team the release covers, FCS programs as well as
FBS.

## The table

[`gt_delta()`](https://sdvplotR.sportsdataverse.org/reference/gt_delta.md)
computes the change from the two rate columns, so the table shows the
arithmetic it ranks. Every rate shows its sample: the earlier window is
150 plays by definition, and the last window’s `n` sits next to its
rate. The change column’s green and red are not the only cue, since
every change also carries its sign. Pass `color_positive` and
`color_negative` to
[`gt_delta()`](https://sdvplotR.sportsdataverse.org/reference/gt_delta.md)
for a pair that does not rely on red-green vision.

``` r

movers |>
  gt(groupname_col = "group") |>
  gt_sdv_logos(entity_name, sport = "cfb", height = 22, include_name = TRUE) |>
  gt_delta(prev, cur, column_label = "Change", decimals = 3) |>
  fmt_number(c(prev, cur), decimals = 3) |>
  cols_merge(c(cur, n), pattern = "{1} (n = {2})") |>
  gt_percentile_bar(pct, width = 160) |>
  cols_label(
    entity_name = "Team",
    prev = "Previous 150 plays",
    cur = "Last 150 plays",
    pct = "Last 150, percentile",
    delta_prev_rank = "Change rank"
  ) |>
  tab_header(
    title = "Offensive form: last 150 plays vs the 150 before",
    subtitle = paste("EPA per play, 2026 season, as of", as_of)
  ) |>
  tab_source_note("Data: sportsdataverse-data release cfb_rolling_windows") |>
  gt_theme_sdv(density = "compact")
```

[TABLE]
