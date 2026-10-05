#' Background colors used by the `gt_theme_*()` table themes
#'
#' A lookup of the background color each `gt_theme_*` function sets, used to match
#' a saved image's canvas to the table sitting on it. [gt_save_crop()] and
#' [gt_social_crop()] pad the image using their own `bg` argument, and a mismatch
#' shows up as a border around the table.
#'
#' @format A tibble with one row per theme, and one per style for the themes
#'   that take a `style` argument:
#' \describe{
#'   \item{theme}{The theme function name.}
#'   \item{has_style}{The `style` value the row applies to (`"light"` or
#'     `"dark"`) for [gt_theme_sdv()], [gt_theme_sofa()] and [gt_theme_tier()], or `""` for themes
#'     without one.}
#'   \item{bg}{The background color the theme applies, as a hex code.}
#' }
#'
#' @source Read back from each theme's `table.background.color` by
#'   `data-raw/theme_bg.R`. [gt_theme_drench()] takes its background from its
#'   `color` argument and [gt_theme_broadsheet()] from its `paper` argument;
#'   their rows hold the default.
#'
#' @examples
#' # look up the background a theme uses, then match the canvas to it
#' bg <- theme_bg$bg[theme_bg$theme == "gt_theme_gtutils"]
#' bg
#'
#' @examplesIf interactive() && rlang::is_installed("webshot2") && isTRUE(file.exists(chromote::find_chrome()))
#' # saving needs a headless Chrome (webshot2)
#' \donttest{
#' nfc_west <- subset(sdv_example_standings, division == "NFC West",
#'   c(team_name, wins:points_against))
#' gt::gt(nfc_west) %>%
#'   gt_theme_gtutils() %>%
#'   gt_save_crop(tempfile(fileext = ".png"), bg = bg)
#' }
#'
#' @seealso [gt_save_crop()], [gt_social_crop()].
"theme_bg"

#' Final regular-season standings for the examples
#'
#' Real standings for one completed season in two leagues, one row per team:
#' the 2025 NFL season and the 2025-26 NBA season. The reference examples run on
#' it, so the table and plot helpers are shown on sports data. Each `team` is
#' the abbreviation [valid_team_names()] lists, so it works as the team input of
#' every logo, color and headshot helper as it is.
#'
#' @format A tibble with 62 rows (32 NFL teams, then 30 NBA teams), ordered by
#'   league, conference, division and division finish, and 16 columns:
#' \describe{
#'   \item{league}{`"nfl"` or `"nba"`, the `sport` value the helpers take.}
#'   \item{season}{`2025` for the NFL; `2026` for the NBA, whose 2025-26
#'     season goes by its ending year as in 'hoopR'.}
#'   \item{team}{Team abbreviation.}
#'   \item{espn_team_id}{ESPN team id.}
#'   \item{team_name}{Full team name.}
#'   \item{conference}{`"AFC"` or `"NFC"`; `"Eastern"` or `"Western"`.}
#'   \item{division}{Division, as `"AFC East"` or `"Atlantic"`.}
#'   \item{wins, losses, ties}{The regular-season record. NBA games can't end
#'     tied, so `ties` is `0` there.}
#'   \item{win_pct}{Winning percentage, a tie counting as half a win, rounded
#'     to three decimals.}
#'   \item{points_for, points_against}{Regular-season points scored and
#'     allowed.}
#'   \item{conference_rank}{Final place in the conference with the league's
#'     tiebreakers applied: the NFL's playoff seeds are 1 to 7, the NBA's
#'     playoff places 1 to 6 and its play-in places 7 to 10.}
#'   \item{playoff_wins}{Postseason wins, not counting the NBA's play-in;
#'     `NA` for a team that missed the playoffs.}
#'   \item{last_season_wins}{Regular-season wins the season before: the NFL's
#'     2024 and the NBA's 2024-25.}
#' }
#'
#' @source Built by `data-raw/sdv_examples.R`. NFL: the nflverse schedules
#'   release, `nflreadr::load_schedules(2025)`, with the standings and
#'   conference ranks from `nflseedR::nfl_standings()`. NBA: the
#'   sportsdataverse-data team box release, `hoopR::load_nba_team_box(2026)`,
#'   counting standings games only (not the NBA Cup final or the All-Star
#'   games), with divisions and conference ranks from ESPN's standings (the
#'   endpoint `hoopR::espn_nba_standings()` reads), whose records the script
#'   checks against the box scores. `last_season_wins` comes from the same
#'   loaders one season back. Team names and ESPN ids come from
#'   [team_reference()].
#'
#' @examples
#' # one division, in finishing order
#' subset(sdv_example_standings, division == "NFC West", c(team, wins:win_pct))
#'
#' # the teams that reached the playoffs
#' playoffs <- subset(sdv_example_standings, !is.na(playoff_wins))
#' table(playoffs$league)
#'
#' # with logos, which are downloaded
#' \donttest{
#' subset(sdv_example_standings, division == "Atlantic", c(team, wins, losses)) |>
#'   gt::gt() |>
#'   gt_sdv_logos(columns = "team", sport = "nba")
#' }
"sdv_example_standings"
