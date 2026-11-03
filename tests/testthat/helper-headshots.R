# NFL headshots read the map sdvplotR publishes to a GitHub release
# (load_headshot_map()). Tests stay offline by standing that map in with real
# rows copied from it: three players with an NFL.com image and one with no NFL.com
# image in any season, only an ESPN id.
headshot_map_fixture <- data.frame(
  gsis_id = c("00-0026498", "00-0033873", "00-0035228", "00-0031078"),
  headshot_nfl = c(
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/jwpkjfrkzufdyh8u1mg7",
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/wdckwtob1lybvkmxnf7p",
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/btfruyf33adgnjzpcuen",
    NA
  ),
  espn_id = c("12483", "3139477", "3917315", "16885")
)

local_headshot_map <- function(map = headshot_map_fixture, env = parent.frame()) {
  testthat::local_mocked_bindings(
    load_headshot_map = function() map,
    .package = "sdvplotR",
    .env = env
  )
}

# Provider headshots read one map per (league, source) (load_player_alias_map()).
# Real rows of nba_player_aliases: LeBron James (ESPN 1966) by his Yahoo, Fox and
# NBA Stats ids.
player_alias_fixture <- list(
  nba_yahoo = data.frame(source_player_id = "nba.p.3704", athlete_id = "1966"),
  nba_fox = data.frame(source_player_id = "1120", athlete_id = "1966"),
  nba_nba_stats = data.frame(source_player_id = "2544", athlete_id = "1966")
)

local_player_alias_maps <- function(maps = player_alias_fixture, env = parent.frame()) {
  testthat::local_mocked_bindings(
    load_player_alias_map = function(league, source) {
      m <- maps[[paste0(league, "_", source)]]
      if (is.null(m)) data.frame(source_player_id = character(), athlete_id = character()) else m
    },
    .package = "sdvplotR",
    .env = env
  )
}
