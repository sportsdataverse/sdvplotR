# Snapshots for the pkgdown articles' calls that cannot run when the site builds: APIs a CI
# runner cannot rely on (the MLB and NHL stats APIs, ESPN's), web scrapes and a call that needs
# a key. Each function runs the article's own code for that step, keeps the rows and columns the
# article goes on to use, and returns them with the call it made. The runner saves each one as
# vignettes/fixtures/<article>/<name>.rds, stamped with the date and the package version, and
# rewrites vignettes/fixtures/README.md from what is on disk.
#
# Run from the package root:
#   Rscript data-raw/article_fixtures.R                        # every fixture
#   Rscript data-raw/article_fixtures.R mlb-viz/mlb_stats_api  # one (names: see `fixtures`)
# workflows/odds_spreads needs ODDS_API_KEY (a free key from The Odds API).
#
# Limits: 200 KB a file, 2 MB in all; .rds only (qs does not build on R 4.6).

pkgload::load_all(quiet = TRUE)
library(dplyr, warn.conflicts = FALSE)

# the season rules the articles use (see each article's load chunk)
this_year <- function() as.integer(format(Sys.Date(), "%Y"))
before <- function(md) format(Sys.Date(), "%m-%d") < md

fx_mlb_viz <- function() {
  # mlb-viz, chunks load-data and player-comparison
  season <- this_year() - before("10-05")
  teams <- baseballr::mlb_teams(season = season, sport_ids = 1) |>
    select(team_id, team_abbreviation, team_name = team_full_name, division_name)
  team_stats <- baseballr::mlb_standings(season = season, league_id = "103,104") |>
    transmute(
      team_id = team_records_team_id,
      wins = team_records_wins,
      losses = team_records_losses,
      win_pct = as.numeric(team_records_winning_percentage),
      runs_scored = team_records_runs_scored,
      runs_allowed = team_records_runs_allowed
    ) |>
    inner_join(teams, by = "team_id")
  player_stats <- baseballr::mlb_stats(
    stat_type = "season", stat_group = "hitting", season = season, player_pool = "All"
  )
  qualified <- baseballr::mlb_stats(
    stat_type = "season", stat_group = "hitting", season = season, player_pool = "Qualified"
  )
  stopifnot(nrow(teams) == 30, nrow(team_stats) == 30)
  list(
    season = season,
    teams = teams,
    team_stats = team_stats,
    # the article plots the top 8 by home runs and the top 5 by batting average
    player_stats = player_stats |>
      select(player_id, player_full_name, games_played, home_runs) |>
      slice_max(home_runs, n = 40, with_ties = FALSE),
    qualified = qualified |>
      select(player_id, avg) |>
      slice_max(as.numeric(avg), n = 40, with_ties = FALSE),
    call = 'baseballr::mlb_teams(), mlb_standings(league_id = "103,104"), mlb_stats(player_pool = "All", "Qualified")',
    package = "baseballr"
  )
}

fx_nhl_viz <- function() {
  # nhl-viz, chunk load-data
  season <- this_year() - before("04-20")
  season_id <- paste0(season - 1, season)
  team_stats <- fastRhockey::nhl_stats_teams(season = season_id) |>
    mutate(team_abbr = clean_team_abbrs(team_full_name, sport = "nhl"))
  player_stats <- fastRhockey::nhl_stats_skaters(season = season_id, limit = -1)
  stopifnot(nrow(team_stats) >= 32, !anyNA(team_stats$team_abbr))
  list(
    season = season,
    season_id = season_id,
    team_stats = team_stats |>
      select(
        team_full_name, team_abbr, goals_for_per_game, goals_against_per_game,
        point_pct, wins, losses, ot_losses, points
      ),
    # the article plots the top 8 by goals and the top 5 by goals and by assists
    player_stats = player_stats |>
      select(player_id, skater_full_name, games_played, goals, assists) |>
      filter(min_rank(desc(goals)) <= 40 | min_rank(desc(assists)) <= 40),
    call = "fastRhockey::nhl_stats_teams(), nhl_stats_skaters(limit = -1)",
    package = "fastRhockey"
  )
}

fx_grid_tables <- function() {
  # grid_tables, chunk net-scrape
  net_page <- rvest::read_html(
    "https://www.ncaa.com/rankings/basketball-men/d1/ncaa-mens-basketball-net-rankings"
  )
  as_of <- stringr::str_extract(rvest::html_text2(net_page), "Through Games [A-Za-z]+\\.? \\d+ \\d{4}")
  data <- rvest::html_table(rvest::html_element(net_page, "table")) |>
    select(
      net = Rank, team = School, conf = Conf,
      quad1 = `Quad 1`, quad2 = `Quad 2`, quad3 = `Quad 3`, quad4 = `Quad 4`,
      prev_rk = Prev
    ) |>
    filter(net <= 25)
  stopifnot(nrow(data) == 25, !is.na(as_of))
  list(
    as_of = as_of,
    data = data,
    call = 'rvest::read_html("https://www.ncaa.com/rankings/basketball-men/d1/ncaa-mens-basketball-net-rankings")',
    package = "rvest"
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

fx_workflows_odds <- function() {
  # workflows, chunk odds-spreads (step 2)
  if (!nzchar(Sys.getenv("ODDS_API_KEY"))) {
    stop("ODDS_API_KEY is not set: the odds snapshot needs a key from The Odds API")
  }
  spreads <- oddsapiR::toa_sports_odds(sport_key = "americanfootball_nfl", markets = "spreads") |>
    mutate(team = clean_team_abbrs(outcomes_name, sport = "nfl")) |>
    group_by(team) |>
    summarise(spread = median(outcomes_point, na.rm = TRUE), .groups = "drop")
  stopifnot(nrow(spreads) > 0, !anyNA(spreads$team))
  list(
    spreads = spreads,
    call = 'oddsapiR::toa_sports_odds(sport_key = "americanfootball_nfl", markets = "spreads")',
    package = "oddsapiR"
  )
}

fixtures <- list(
  "mlb-viz/mlb_stats_api" = fx_mlb_viz,
  "nhl-viz/nhl_stats_api" = fx_nhl_viz,
  "grid_tables/ncaa_net" = fx_grid_tables,
  "reactable-integration/espn_fpi" = fx_reactable_fpi,
  "reactable-integration/nhl_skaters" = fx_reactable_nhl,
  "workflows/mlb_standings" = fx_workflows_mlb,
  "workflows/nhl_teams" = fx_workflows_nhl,
  "workflows/odds_spreads" = fx_workflows_odds
)

fixture_dir <- file.path("vignettes", "fixtures")

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
    "runner cannot rely on, web scrapes and a call that needs a key. Each article shows the real",
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
