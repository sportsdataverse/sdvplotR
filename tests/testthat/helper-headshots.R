# NFL headshots read the map sdvplotR publishes to a GitHub release
# (load_headshot_map()). Tests stay offline by standing that map in with real
# rows copied from it: three players with an NFL.com image and one with only an
# ESPN id.
headshot_map_fixture <- data.frame(
  gsis_id = c("00-0026498", "00-0033873", "00-0035228", "00-0022044"),
  headshot_nfl = c(
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/jwpkjfrkzufdyh8u1mg7",
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/wdckwtob1lybvkmxnf7p",
    "https://static.www.nfl.com/image/upload/f_auto,q_auto/league/btfruyf33adgnjzpcuen",
    NA
  ),
  espn_id = c("12483", "3139477", "3917315", "4461")
)

local_headshot_map <- function(map = headshot_map_fixture, env = parent.frame()) {
  testthat::local_mocked_bindings(
    load_headshot_map = function() map,
    .package = "sdvplotR",
    .env = env
  )
}
