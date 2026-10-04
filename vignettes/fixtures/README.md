# Article fixtures

Snapshots of the calls the pkgdown articles cannot make when the site builds: APIs a CI
runner cannot rely on and web scrapes. Each article shows the real
call, then reads its file here. `data-raw/article_fixtures.R` writes every file and this
table; refresh one with `Rscript data-raw/article_fixtures.R <article>/<name>`.
Limits: 200 KB a file, 2 MB in all.

| File | Call | Season | Taken | Package | KB |
|---|---|---|---|---|---|
| `grid_tables/ncaa_net.rds` | `rvest::read_html("https://www.ncaa.com/rankings/basketball-men/d1/ncaa-mens-basketball-net-rankings")` | n/a | 2026-10-04 | rvest 1.0.5 | 0.9 |
| `mlb-viz/mlb_stats_api.rds` | `baseballr::mlb_teams(), mlb_standings(league_id = "103,104"), mlb_stats(player_pool = "All", "Qualified")` | 2025 | 2026-10-04 | baseballr 2.0.0 | 2.5 |
| `nhl-viz/nhl_stats_api.rds` | `fastRhockey::nhl_stats_teams(), nhl_stats_skaters(limit = -1)` | 20252026 | 2026-10-04 | fastRhockey 1.0.0 | 2.8 |
| `reactable-integration/espn_fpi.rds` | `cfbfastR::espn_ratings_fpi()` | 2025 | 2026-10-04 | cfbfastR 3.0.0 | 0.6 |
| `reactable-integration/nhl_skaters.rds` | `fastRhockey::nhl_stats_skaters(limit = 20)` | 2026 | 2026-10-04 | fastRhockey 1.0.0 | 0.8 |
| `workflows/mlb_standings.rds` | `baseballr::mlb_teams(), mlb_standings(league_id = "103,104")` | 2025 | 2026-10-04 | baseballr 2.0.0 | 0.8 |
| `workflows/nhl_teams.rds` | `fastRhockey::nhl_stats_teams()` | 2026 | 2026-10-04 | fastRhockey 1.0.0 | 1.2 |

Total: 9.6 KB.
