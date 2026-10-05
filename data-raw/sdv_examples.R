# Build `sdv_example_standings`: real final regular-season standings that the
# reference examples run on, so they show sports tables instead of the gtUtils
# demo data (mtcars, iris, airquality).
#
#   * NFL 2025: nflreadr::load_schedules() (the nflverse schedules release),
#     ranked by nflseedR::nfl_standings() with the NFL tiebreakers.
#   * NBA 2025-26: hoopR::load_nba_team_box() (the sportsdataverse-data team
#     box release), standings games only (the schedule's "STD" type: no NBA Cup
#     final, no All-Star games). Divisions and the conference ranks come from
#     ESPN's standings, the endpoint hoopR::espn_nba_standings() reads, which
#     must agree with the team box on every record.
#   * last_season_wins: the same loaders one season back (NFL 2024, NBA
#     2024-25), for year-over-year examples.
#
# Team keys, ESPN ids and names come from this package's own team_reference(),
# so every `team` resolves through clean_team_abbrs() as itself.
#
# Run from the package root: Rscript data-raw/sdv_examples.R

pkgload::load_all(quiet = TRUE)
library(dplyr, warn.conflicts = FALSE)

nfl_season <- 2025
nba_season <- 2026 # hoopR's ending-year convention: 2025-26

# NFL -------------------------------------------------------------------------

games <- nflreadr::load_schedules(nfl_season)
reg <- games[games$game_type == "REG", ]
stopifnot(nrow(reg) == 272, !anyNA(reg$result))

nfl_st <- nflseedR::nfl_standings(reg, ranks = "CONF")

post <- games[games$game_type != "REG", ]
stopifnot(!anyNA(post$result), all(post$result != 0))
post_winners <- ifelse(post$result > 0, post$home_team, post$away_team)
post_teams <- unique(c(post$home_team, post$away_team))
# the seven seeds per conference are exactly the teams that played in January
stopifnot(setequal(post_teams, nfl_st$team[nfl_st$conf_rank <= 7]))

nfl <- tibble::tibble(
  league = "nfl",
  season = as.integer(nfl_season),
  team = nfl_st$team,
  conference = nfl_st$conf,
  division = nfl_st$division,
  wins = as.integer(nfl_st$wins),
  losses = as.integer(nfl_st$losses),
  ties = as.integer(nfl_st$ties),
  points_for = as.integer(nfl_st$pf),
  points_against = as.integer(nfl_st$pa),
  conference_rank = as.integer(nfl_st$conf_rank),
  div_rank = as.integer(nfl_st$div_rank),
  # NA for the teams that missed the playoffs, as in the NBA rows
  playoff_wins = ifelse(
    nfl_st$team %in% post_teams,
    vapply(nfl_st$team, function(t) sum(post_winners == t), integer(1)),
    NA_integer_
  )
)

prev <- nflreadr::load_schedules(nfl_season - 1)
prev <- prev[prev$game_type == "REG", ]
stopifnot(nrow(prev) == 272, !anyNA(prev$result))
nfl_prev <- tibble::tibble(
  league = "nfl",
  team = c(prev$home_team, prev$away_team),
  won = c(prev$result > 0, prev$result < 0)
) |>
  group_by(league, team) |>
  summarise(last_season_wins = sum(won), .groups = "drop")
stopifnot(nrow(nfl_prev) == 32)

# NBA -------------------------------------------------------------------------

# a season's standings games only: no NBA Cup final, no All-Star games
nba_regular <- function(season, box = hoopR::load_nba_team_box(season)) {
  sched <- hoopR::load_nba_schedule(season)
  std_ids <- sched$game_id[sched$season_type == 2 & sched$type_abbreviation == "STD"]
  out <- box |>
    filter(season_type == 2, game_id %in% std_ids) |>
    group_by(team = team_abbreviation) |>
    summarise(
      games = n(),
      wins = sum(team_winner),
      losses = sum(!team_winner),
      points_for = sum(team_score),
      points_against = sum(opponent_team_score),
      .groups = "drop"
    )
  stopifnot(nrow(out) == 30, all(out$games == 82))
  out
}

box <- hoopR::load_nba_team_box(nba_season)
nba_reg <- nba_regular(nba_season, box)
nba_prev <- nba_regular(nba_season - 1) |>
  transmute(league = "nba", team, last_season_wins = wins)

nba_post <- box |>
  filter(season_type == 3) |>
  group_by(team = team_abbreviation) |>
  summarise(playoff_wins = sum(team_winner), .groups = "drop")
stopifnot(nrow(nba_post) == 16)

espn <- jsonlite::fromJSON(
  paste0(
    "https://site.web.api.espn.com/apis/v2/sports/basketball/nba/standings",
    "?season=", nba_season, "&level=3"
  ),
  simplifyVector = FALSE
)
espn_rows <- list()
for (conf in espn$children) {
  for (div in conf$children) {
    for (e in div$standings$entries) {
      stat <- function(nm) {
        v <- Filter(function(s) identical(s$name, nm), e$stats)[[1]]$value
        as.integer(round(v))
      }
      espn_rows[[length(espn_rows) + 1]] <- tibble::tibble(
        team = e$team$abbreviation,
        division = div$name,
        espn_wins = stat("wins"),
        espn_losses = stat("losses"),
        espn_pf = stat("pointsFor"),
        espn_pa = stat("pointsAgainst"),
        conference_rank = stat("playoffSeed")
      )
    }
  }
}
espn_st <- bind_rows(espn_rows)

nba <- nba_reg |>
  inner_join(espn_st, by = "team") |>
  left_join(nba_post, by = "team")
# two sources, one season: the release's records must match ESPN's standings
# (records exactly; points within one, since the two disagree by a point in two
# 2025-26 games, CLE and UTAH scoring one more in the box scores; the box scores
# are kept)
stopifnot(
  nrow(nba) == 30,
  identical(nba$wins, nba$espn_wins), identical(nba$losses, nba$espn_losses),
  all(abs(nba$points_for - nba$espn_pf) <= 1),
  all(abs(nba$points_against - nba$espn_pa) <= 1)
)

nba <- tibble::tibble(
  league = "nba",
  season = as.integer(nba_season),
  team = nba$team,
  conference = NA_character_, # from team_reference() below
  division = nba$division,
  wins = as.integer(nba$wins),
  losses = as.integer(nba$losses),
  ties = 0L,
  points_for = as.integer(nba$points_for),
  points_against = as.integer(nba$points_against),
  conference_rank = nba$conference_rank,
  div_rank = NA_integer_,
  playoff_wins = as.integer(nba$playoff_wins)
)

# Together --------------------------------------------------------------------

ref <- bind_rows(team_reference("nfl"), team_reference("nba")) |>
  filter(type == "team") |>
  transmute(league = sport, team = team_abbr, espn_team_id, team_name, ref_conf = conference)

sdv_example_standings <- bind_rows(nfl, nba) |>
  left_join(ref, by = c("league", "team")) |>
  left_join(bind_rows(nfl_prev, nba_prev), by = c("league", "team")) |>
  mutate(
    conference = coalesce(conference, ref_conf),
    win_pct = round((wins + ties / 2) / (wins + losses + ties), 3)
  )
stopifnot(
  !anyNA(sdv_example_standings$espn_team_id),
  !anyNA(sdv_example_standings$last_season_wins),
  identical(
    sdv_example_standings$conference[sdv_example_standings$league == "nfl"],
    sdv_example_standings$ref_conf[sdv_example_standings$league == "nfl"]
  )
)

# division order: the NFL's tiebroken ranks; the NBA's by record, then seed
sdv_example_standings <- sdv_example_standings |>
  arrange(desc(league), conference, division, div_rank, desc(win_pct), conference_rank) |>
  select(
    league, season, team, espn_team_id, team_name, conference, division,
    wins, losses, ties, win_pct, points_for, points_against,
    conference_rank, playoff_wins, last_season_wins
  )

# every key is canonical, so it resolves to itself in each helper
for (lg in c("nfl", "nba")) {
  k <- sdv_example_standings$team[sdv_example_standings$league == lg]
  stopifnot(identical(clean_team_abbrs(k, sport = lg, keep_non_matches = FALSE), k))
}
# within a conference the ranks run 1..n
stopifnot(all(tapply(
  sdv_example_standings$conference_rank,
  paste(sdv_example_standings$league, sdv_example_standings$conference),
  function(r) identical(sort(r), seq_along(r))
)))

print(sdv_example_standings, n = 5, width = Inf)
usethis::use_data(sdv_example_standings, overwrite = TRUE, compress = "xz")
