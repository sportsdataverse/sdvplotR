# Snapshots for the pkgdown articles' calls that cannot run when the site builds: APIs a CI
# runner cannot rely on (the MLB and NHL stats APIs, Baseball Savant, ESPN's) and web scrapes.
# Each function runs the article's own code for that step, keeps the rows and columns the
# article goes on to use, and returns them with the call it made. The runner saves each one as
# vignettes/articles/fixtures/<article>/<name>.rds, stamped with the date and the package version, and
# rewrites vignettes/articles/fixtures/README.md from what is on disk.
#
# Run from the package root:
#   Rscript data-raw/article_fixtures.R                        # every fixture
#   Rscript data-raw/article_fixtures.R mlb-viz/mlb_stats_api  # one (names: see `fixtures`)
#
# Limits: 200 KB a file, 2 MB in all; .rds only (qs does not build on R 4.6).

pkgload::load_all(quiet = TRUE)
library(dplyr, warn.conflicts = FALSE)

# the season rules the articles use (see each article's load chunk); mlb-viz and nhl-viz pin
# their season instead
this_year <- function() as.integer(format(Sys.Date(), "%Y"))
before <- function(md) format(Sys.Date(), "%m-%d") < md

fx_mlb_viz <- function() {
  # mlb-viz, chunk load-data (the MLB Stats API calls)
  season <- 2026
  teams <- baseballr::mlb_teams(season = season, sport_ids = 1) |>
    select(team_id, abbreviation = team_abbreviation, team_name = team_full_name, division = division_name)
  standings <- baseballr::mlb_standings(season = season, league_id = "103,104") |>
    transmute(
      team_id = team_records_team_id,
      rank = as.integer(team_records_division_rank),
      w = team_records_wins,
      l = team_records_losses,
      gb = team_records_games_back,
      wc_gb = team_records_wild_card_games_back,
      rs = team_records_runs_scored,
      ra = team_records_runs_allowed,
      diff = team_records_run_differential,
      strk = team_records_streak_streak_code,
      clinch = team_records_clinch_indicator
    ) |>
    inner_join(teams, by = "team_id")
  games <- baseballr::mlb_schedule(season = season, level_ids = "1") |>
    filter(game_type == "R", status_detailed_state %in% c("Final", "Completed Early")) |>
    transmute(
      game_pk,
      date = as.Date(official_date),
      home_id = teams_home_team_id,
      away_id = teams_away_team_id,
      home_score = teams_home_score,
      away_score = teams_away_score
    )
  hitters <- baseballr::mlb_stats(
    stat_type = "season", stat_group = "hitting", season = season, player_pool = "All",
    sort_stat = "homeRuns", order = "desc", limit = 40
  ) |>
    select(player_id, player = player_full_name, team_id, games_played, home_runs)
  # nine franchises that moved, by Stats API team id: every season's name and abbreviation
  moved <- c(133, 144, 119, 137, 110, 142, 140, 120, 158)
  identities <- lapply(1901:season, \(s) baseballr::mlb_teams(season = s, sport_ids = 1)) |>
    bind_rows() |>
    filter(team_id %in% moved) |>
    select(team_id, season, name = team_full_name, abbreviation = team_abbreviation)
  stopifnot(
    nrow(standings) == 30, !anyNA(standings$division), nrow(games) == 2430,
    nrow(hitters) == 40, setequal(identities$team_id, moved)
  )
  list(
    season = season,
    standings = standings,
    games = games,
    hitters = hitters,
    identities = identities,
    call = paste(
      'baseballr::mlb_teams(), mlb_standings(league_id = "103,104"), mlb_schedule(),',
      'mlb_stats(player_pool = "All"), mlb_teams(season = 1901:2026)'
    ),
    package = "baseballr"
  )
}

fx_mlb_viz_savant <- function() {
  # mlb-viz, chunk load-savant (the Baseball Savant calls)
  season <- 2026
  team_xstats <- baseballr::statcast_leaderboards(
    leaderboard = "expected_statistics", year = season, player_type = "batter-team"
  ) |>
    select(team_id, woba, est_woba)
  contact <- baseballr::statcast_leaderboards(
    leaderboard = "exit_velocity_barrels", year = season, player_type = "batter"
  ) |>
    select(player_id, name = `last_name, first_name`, attempts, avg_hit_speed, brl_percent)
  # every home run the season's home run leader(s) hit, with Statcast's hit coordinates
  hitters <- baseballr::mlb_stats(
    stat_type = "season", stat_group = "hitting", season = season, player_pool = "All",
    sort_stat = "homeRuns", order = "desc", limit = 40
  )
  leaders <- hitters$player_id[hitters$home_runs == max(hitters$home_runs)]
  homers <- lapply(leaders, \(id) {
    baseballr::statcast_search_batters(paste0(season, "-03-01"), paste0(season, "-10-01"), batterid = id)
  }) |>
    bind_rows() |>
    filter(events == "home_run", game_type == "R") |>
    select(batter, game_date, hc_x, hc_y, hit_distance_sc, launch_speed)
  stopifnot(
    nrow(team_xstats) == 30, nrow(contact) > 100,
    all(table(homers$batter) == max(hitters$home_runs))
  )
  list(
    season = season,
    team_xstats = team_xstats,
    contact = contact,
    homers = homers,
    call = paste(
      'baseballr::statcast_leaderboards("expected_statistics", "exit_velocity_barrels"),',
      "statcast_search_batters()"
    ),
    package = "baseballr"
  )
}

fx_nhl_viz <- function() {
  # nhl-viz, chunk load-api (api-web.nhle.com and records.nhl.com)
  season <- 2026
  standings <- fastRhockey::nhl_standings(date = "2026-04-16") |>
    select(
      team_abbr, team_name, conference_name, division_name, division_sequence, games_played,
      wins, losses, ot_losses, points, point_pctg, regulation_wins, goals_for, goals_against,
      goal_differential, streak_code, streak_count
    )
  # one franchise's every season: the Winnipeg Jets (1979), the Coyotes, Utah
  lineage <- fastRhockey::nhl_records_franchise_season_results() |>
    filter(game_type_id == 2, team_id %in% c(33, 27, 53, 59, 68), season_id <= 20252026) |>
    select(season_id, team_id, tri_code, team_name, games_played, points)
  stopifnot(
    nrow(standings) == 32, all(standings$games_played == 82),
    nrow(lineage) == 46, !anyDuplicated(lineage$season_id)
  )
  list(
    season = season,
    standings = standings,
    lineage = lineage,
    call = "fastRhockey::nhl_standings(), nhl_records_franchise_season_results()",
    package = "fastRhockey"
  )
}

fx_reactable_fpi <- function() {
  # reactable-integration, chunk cfb-data
  cfb_season <- this_year() - before("12-15")
  cfb_fpi <- cfbfastR::espn_ratings_fpi(year = cfb_season) |>
    mutate(fpi = as.numeric(fpi)) |>
    arrange(desc(fpi)) |>
    select(team = team_abbreviation, fpi, w, l) |>
    slice_head(n = 25)
  stopifnot(nrow(cfb_fpi) == 25, !anyNA(cfb_fpi$fpi))
  list(cfb_season = cfb_season, cfb_fpi = cfb_fpi, call = "cfbfastR::espn_ratings_fpi()", package = "cfbfastR")
}

fx_reactable_nhl <- function() {
  # reactable-integration, chunk nhl-data
  nhl_season <- this_year() - before("04-20")
  nhl_skaters <- fastRhockey::nhl_stats_skaters(season = paste0(nhl_season - 1, nhl_season), limit = 20) |>
    mutate(team = sub(".*,\\s*", "", team_abbrevs)) |>
    select(skater_full_name, team, player_id, goals, assists, points)
  stopifnot(nrow(nhl_skaters) == 20)
  list(
    nhl_season = nhl_season, nhl_skaters = nhl_skaters,
    call = "fastRhockey::nhl_stats_skaters(limit = 20)", package = "fastRhockey"
  )
}

fx_workflows_mlb <- function() {
  # workflows, chunk mlb-workflow-data (steps 1 and 2)
  mlb_season <- this_year() - before("10-05")
  teams <- baseballr::mlb_teams(season = mlb_season, sport_ids = 1) |>
    select(team_id, team_abbreviation, team_name = team_full_name)
  standings <- baseballr::mlb_standings(season = mlb_season, league_id = "103,104") |>
    transmute(
      team_id = team_records_team_id,
      wins = team_records_wins,
      losses = team_records_losses,
      win_pct = as.numeric(team_records_winning_percentage)
    ) |>
    inner_join(teams, by = "team_id") |>
    slice_max(win_pct, n = 15, with_ties = FALSE) |>
    mutate(rank = row_number(), logo = team_abbreviation) |>
    select(rank, logo, team_name, wins, losses, win_pct)
  stopifnot(nrow(standings) == 15)
  list(
    mlb_season = mlb_season, standings = standings,
    call = 'baseballr::mlb_teams(), mlb_standings(league_id = "103,104")', package = "baseballr"
  )
}

fx_workflows_nhl <- function() {
  # workflows, chunk nhl-workflow-data (step 1)
  nhl_season <- this_year() - before("04-20")
  nhl_teams <- fastRhockey::nhl_stats_teams(season = paste0(nhl_season - 1, nhl_season)) |>
    select(team_full_name, goals_for_per_game, goals_against_per_game, point_pct)
  stopifnot(nrow(nhl_teams) >= 32)
  list(nhl_season = nhl_season, nhl_teams = nhl_teams, call = "fastRhockey::nhl_stats_teams()", package = "fastRhockey")
}

fx_recipe_mlb <- function() {
  # recipe-mlb-run-differential, chunk data (a finished season, so the season is pinned)
  season <- 2026
  schedule <- baseballr::mlb_schedule(season = season, level_ids = "1") |>
    filter(game_type == "R") |>
    select(
      game_pk, official_date, status_coded_game_state,
      teams_home_team_id, teams_away_team_id, teams_home_score, teams_away_score
    )
  teams <- baseballr::mlb_teams(season = season, sport_ids = 1) |>
    select(team_id, team_abbreviation)
  official <- baseballr::mlb_standings(season = season, league_id = "103,104") |>
    transmute(team_id = team_records_team_id, run_differential = team_records_run_differential)
  stopifnot(nrow(teams) == 30, nrow(official) == 30, nrow(schedule) >= 2430)
  list(
    season = season, schedule = schedule, teams = teams, official = official,
    call = 'baseballr::mlb_schedule(level_ids = "1"), mlb_teams(), mlb_standings(league_id = "103,104")',
    package = "baseballr"
  )
}

fixtures <- list(
  "mlb-viz/mlb_stats_api" = fx_mlb_viz,
  "mlb-viz/savant" = fx_mlb_viz_savant,
  "nhl-viz/nhl_api" = fx_nhl_viz,
  "reactable-integration/espn_fpi" = fx_reactable_fpi,
  "reactable-integration/nhl_skaters" = fx_reactable_nhl,
  "workflows/mlb_standings" = fx_workflows_mlb,
  "workflows/nhl_teams" = fx_workflows_nhl,
  "recipe-mlb-run-differential/mlb_schedule" = fx_recipe_mlb
)

fixture_dir <- file.path("vignettes", "articles", "fixtures")

save_fixture <- function(x, name) {
  # plain data frames: no package classes for readRDS() to need when the article reads it
  x <- lapply(x, function(v) if (is.data.frame(v)) as.data.frame(v) else v)
  x$taken <- Sys.Date()
  x$package <- paste(x$package, utils::packageVersion(x$package))
  path <- file.path(fixture_dir, paste0(name, ".rds"))
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # write beside the target, check the size, and only then move it into place
  tmp <- tempfile(tmpdir = dirname(path), fileext = ".rds")
  on.exit(unlink(tmp))
  saveRDS(x, tmp, compress = "xz")
  kb <- file.size(tmp) / 1024
  if (kb > 200) stop(path, " would be ", round(kb), " KB; the limit is 200 KB")
  file.rename(tmp, path)
  message(sprintf("%s  %.1f KB  %s", path, kb, x$package))
}

write_readme <- function() {
  files <- sort(list.files(fixture_dir, pattern = "\\.rds$", recursive = TRUE))
  kb <- file.size(file.path(fixture_dir, files)) / 1024
  rows <- vapply(seq_along(files), function(i) {
    x <- readRDS(file.path(fixture_dir, files[i]))
    # exact names: `$` partial-matches (x$season would pick up a `season_results` element)
    season <- x[["season_id"]] %||% x[["season"]] %||% x[["mlb_season"]] %||% x[["nhl_season"]] %||%
      x[["cfb_season"]] %||% "n/a"
    sprintf("| `%s` | `%s` | %s | %s | %s | %.1f |", files[i], x$call, season, format(x$taken), x$package, kb[i])
  }, character(1))
  writeLines(c(
    "# Article fixtures",
    "",
    "Snapshots of the calls the pkgdown articles cannot make when the site builds: APIs a CI",
    "runner cannot rely on and web scrapes. Each article shows the real",
    "call, then reads its file here. `data-raw/article_fixtures.R` writes every file and this",
    "table; refresh one with `Rscript data-raw/article_fixtures.R <article>/<name>`.",
    "Limits: 200 KB a file, 2 MB in all.",
    "",
    "| File | Call | Season | Taken | Package | KB |",
    "|---|---|---|---|---|---|",
    rows,
    "",
    sprintf("Total: %.1f KB.", sum(kb))
  ), file.path(fixture_dir, "README.md"))
  if (sum(kb) > 2048) stop("the fixtures total ", round(sum(kb)), " KB; the limit is 2 MB")
}

wanted <- commandArgs(trailingOnly = TRUE)
if (!length(wanted)) wanted <- names(fixtures)
unknown <- setdiff(wanted, names(fixtures))
if (length(unknown)) {
  stop("unknown fixture ", toString(unknown), "; known: ", toString(names(fixtures)))
}
for (name in wanted) save_fixture(fixtures[[name]](), name)
write_readme()
