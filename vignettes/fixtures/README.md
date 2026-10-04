# Article fixtures

Snapshots of the calls the pkgdown articles cannot make when the site builds: APIs a CI
runner cannot rely on, web scrapes and a call that needs a key. Each article shows the real
call, then reads its file here. `data-raw/article_fixtures.R` writes every file and this
table; refresh one with `Rscript data-raw/article_fixtures.R <article>/<name>`.
Limits: 200 KB a file, 2 MB in all.

| File | Call | Season | Taken | Package | KB |
|---|---|---|---|---|---|
| `mlb-viz/mlb_stats_api.rds` | `baseballr::mlb_teams(), mlb_standings(league_id = "103,104"), mlb_stats(player_pool = "All", "Qualified")` | 2025 | 2026-10-04 | baseballr 2.0.0 | 2.5 |
| `nhl-viz/nhl_stats_api.rds` | `fastRhockey::nhl_stats_teams(), nhl_stats_skaters(limit = -1)` | 20252026 | 2026-10-04 | fastRhockey 1.0.0 | 2.8 |

Total: 5.3 KB.
