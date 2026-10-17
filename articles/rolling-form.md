# Rolling Form

On this page

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
#> [1] 25556    20
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
#> 1       player          epa       carry       50 2082
#> 2       player          epa       carry      100 2082
#> 3       player          epa    dropback       50  640
#> 4       player          epa    dropback      100  640
#> 5       player          epa    dropback      300  640
#> 6       player          epa      target       30 3112
#> 7       player          epa      target       60 3112
#> 8       player success_rate       carry       50 2082
#> 9       player success_rate       carry      100 2082
#> 10      player success_rate    dropback       50  640
#> 11      player success_rate    dropback      100  640
#> 12      player success_rate    dropback      300  640
#> 13      player success_rate      target       30 3112
#> 14      player success_rate      target       60 3112
#> 15        team          epa        play      150  235
#> 16        team          epa        play      300  235
#> 17        team success_rate        play      150  235
#> 18        team success_rate        play      300  235
```

This file is the season in progress. The date shows how current it is:

``` r

as_of <- unique(windows$as_of_date)
stopifnot(length(as_of) == 1)
as_of
#> [1] "2026-10-17"
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
#> [1] 228

movers <- bind_rows(
  Risers = slice_max(pool, delta_prev, n = 5, with_ties = FALSE),
  Fallers = slice_min(pool, delta_prev, n = 5, with_ties = FALSE),
  .id = "group"
) |>
  select(group, entity_name, prev, cur, n, pct, delta_prev_rank)
movers
#>      group                 entity_name        prev         cur   n       pct
#> 1   Risers     Louisiana Tech Bulldogs -0.26370043  0.33967572 150 99.118943
#> 2   Risers          UL Monroe Warhawks -0.07478280  0.26962508 150 96.035242
#> 3   Risers       Texas Southern Tigers -0.34182483 -0.02342592 150 46.255507
#> 4   Risers Southern Miss Golden Eagles -0.07446965  0.23110259 150 93.832599
#> 5   Risers             Charlotte 49ers -0.26187563  0.03375997 150 58.590308
#> 6  Fallers      Northern Iowa Panthers  0.27039169 -0.27320753 150  8.810573
#> 7  Fallers        Holy Cross Crusaders  0.30123470 -0.20416812 150 17.180617
#> 8  Fallers        Sam Houston Bearkats  0.12909540 -0.34428527 150  3.083700
#> 9  Fallers   Eastern Washington Eagles  0.14616080 -0.27163475 150  9.251101
#> 10 Fallers   Northwestern State Demons -0.13158858 -0.54315963 150  0.000000
#>    delta_prev_rank
#> 1                1
#> 2                2
#> 3                3
#> 4                4
#> 5                5
#> 6              228
#> 7              227
#> 8              226
#> 9              225
#> 10             224
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
  gt_sdv_logos(entity_name, league = "cfb", height = 22, include_name = TRUE) |>
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
