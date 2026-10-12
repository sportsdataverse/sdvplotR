# Article fixtures

Snapshots of the calls the pkgdown articles cannot make when the site builds: APIs a CI
runner cannot rely on and web scrapes. Each article shows the real
call, then reads its file here. `data-raw/article_fixtures.R` writes every file and this
table; refresh one with `Rscript data-raw/article_fixtures.R <article>/<name>`.
Limits: 200 KB a file, 2 MB in all.

| File | Call | Season | Taken | Package | KB |
|---|---|---|---|---|---|
| `mlb-viz/mlb_stats_api.rds` | `baseballr::mlb_teams(), mlb_standings(league_id = "103,104"), mlb_schedule(), mlb_stats(player_pool = "All"), mlb_teams(season = 1901:2026)` | 2026 | 2026-10-05 | baseballr 2.0.0 | 13.1 |
| `mlb-viz/savant.rds` | `baseballr::statcast_leaderboards("expected_statistics", "exit_velocity_barrels"), statcast_search_batters()` | 2026 | 2026-10-05 | baseballr 2.0.0 | 5.9 |
| `nhl-viz/nhl_api.rds` | `fastRhockey::nhl_standings(), nhl_records_franchise_season_results()` | 2026 | 2026-10-05 | fastRhockey 1.0.0 | 2.0 |
| `reactable-integration/espn_fpi.rds` | `cfbfastR::espn_ratings_fpi()` | 2025 | 2026-10-04 | cfbfastR 3.0.0 | 0.6 |
| `reactable-integration/nhl_skaters.rds` | `fastRhockey::nhl_stats_skaters(limit = 20)` | 2026 | 2026-10-04 | fastRhockey 1.0.0 | 0.8 |
| `recipe-mlb-run-differential/mlb_schedule.rds` | `baseballr::mlb_schedule(level_ids = "1"), mlb_teams(), mlb_standings(league_id = "103,104")` | 2026 | 2026-10-05 | baseballr 2.0.0 | 11.0 |
| `workflows/mlb_standings.rds` | `baseballr::mlb_teams(), mlb_standings(league_id = "103,104")` | 2026 | 2026-10-05 | baseballr 2.0.0 | 0.8 |
| `workflows/nhl_teams.rds` | `fastRhockey::nhl_stats_teams()` | 2026 | 2026-10-04 | fastRhockey 1.0.0 | 1.2 |

Total: 35.4 KB.
