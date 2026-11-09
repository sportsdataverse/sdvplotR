# Player names -> ESPN athlete ids, from published rosters: a port of
# cfbplotR's add_athlete_id_col(). The rosters are cfbfastR-data's yearly
# cfb_rosters_<season>.rds files (2009 on, ESPN athlete ids), read when first
# needed and kept for the session like the player alias maps (R/utils.R);
# offline, or on a failed read, a season has no rows.

roster_url <- function(league, season) {
  paste0(
    "https://raw.githubusercontent.com/sportsdataverse/cfbfastR-data/main/rosters/rds/cfb_rosters_",
    season, ".rds"
  )
}
roster_leagues <- "cfb"
roster_first_season <- 2009L

# The latest season with rosters: it starts on August 15, as cfbplotR's
# most_recent_cfb_season()
latest_roster_season <- function(today = Sys.Date()) {
  y <- as.integer(format(today, "%Y"))
  if (format(today, "%m-%d") >= "08-15") y else y - 1L
}

empty_roster <- function() {
  data.frame(
    season = integer(), athlete_id = character(), name = character(),
    team = character(), headshot_url = character()
  )
}

load_roster <- function(league, season) {
  key <- paste0("roster_", league, "_", season)
  if (!is.null(player_alias_cache[[key]])) {
    return(player_alias_cache[[key]])
  }
  empty <- empty_roster()
  if (use_snapshot()) {
    return(empty)
  }
  r <- read_rds_url(roster_url(league, season))
  if (!is.data.frame(r) || !all(c("athlete_id", "first_name", "last_name", "team") %in% names(r))) {
    return(empty)
  }
  id <- id_chr(r$athlete_id)
  out <- data.frame(
    season = rep(as.integer(season), nrow(r)), athlete_id = id,
    name = paste(r$first_name, r$last_name), team = as.character(r$team),
    headshot_url = if ("headshot_url" %in% names(r)) as.character(r$headshot_url) else espn_headshot_url(id, league)
  )
  player_alias_cache[[key]] <- out
  out
}

# The one column `quo` selects in `df`, or NULL for a NULL quosure
pick_col <- function(df, quo, arg, call) {
  if (rlang::quo_is_null(quo)) {
    return(NULL)
  }
  pos <- tidyselect::eval_select(quo, df)
  if (length(pos) != 1L) cli::cli_abort("{.arg {arg}} must name one column of {.arg df}.", call = call)
  names(pos)
}

#' Add ESPN athlete ids to a data frame of player names
#'
#' @description Matches player names (and, where given, their team and
#'   season) to published rosters and adds each player's ESPN athlete id, the
#'   id the headshot helpers ([geom_sdv_headshots()], [gt_sdv_headshots()],
#'   ...) read. The counterpart of cfbplotR's `add_athlete_id_col()`. The
#'   rosters are cfbfastR-data's college football rosters, 2009 on, read over
#'   the network when first needed and kept for the session. Like cfbplotR's,
#'   the match is experimental: check the ids it gives.
#' @details Names match ignoring case, accents and surrounding spaces. Teams
#'   match through [sdv_resolve()], so any name or id it accepts for the
#'   roster's team works; a team it cannot resolve matches by name. A name
#'   that matches more than one athlete is left `NA` (cfbplotR returns one row
#'   for each), so the result has a row for each row of `df`: pass `team_col`
#'   and `season_col` to tell players with one name apart.
#'
#'   Without `season_col` (and no `season` column) the latest season's
#'   rosters are read, or the season before when the latest is not published
#'   yet. Offline, or when a roster cannot be read, the call warns and the
#'   ids it could not find are `NA`; it does not error.
#' @param df A data frame.
#' @param name_col The column of `df` with player names (a bare name or a
#'   string).
#' @param team_col The column with each player's team, or `NULL`: then a
#'   `team` or `school` column of `df`, if there is one.
#' @param season_col The column with each row's season, or `NULL`: then a
#'   `season` column of `df`, if there is one. Seasons outside the rosters'
#'   (2009 to the latest) match no one.
#' @param league A league with rosters: `"cfb"`.
#' @param headshot_urls If `TRUE`, also add each player's headshot URL.
#' @return `df` with an `athlete_id` column (character; `NA` where no single
#'   athlete matched) and, with `headshot_urls = TRUE`, a `headshot_url`
#'   column.
#' @seealso [sdv_headshot_url()]
#' @export
#' @examples
#' \donttest{
#' x <- data.frame(player_name = c("Britain Covey", "JT Daniels"))
#' try(sdv_add_athlete_id(x, player_name))
#'
#' x$season <- c(2021, 2021)
#' x$team <- c("Utah", "Georgia")
#' try(sdv_add_athlete_id(x, player_name, team, season, headshot_urls = TRUE))
#' }
sdv_add_athlete_id <- function(
    df,
    name_col,
    team_col = NULL,
    season_col = NULL,
    league = "cfb",
    headshot_urls = FALSE
) {
  call <- rlang::current_env()
  league <- check_league(league)
  if (!league %in% roster_leagues) {
    cli::cli_abort("sdvplotR has rosters for {.val {roster_leagues}} only, not {.val {league}}.")
  }
  if (!is.data.frame(df)) cli::cli_abort("{.arg df} must be a data frame, not {.obj_type_friendly {df}}.")
  if ("athlete_id" %in% names(df)) cli::cli_abort("{.arg df} already has an {.field athlete_id} column.")
  name_col <- pick_col(df, rlang::enquo(name_col), "name_col", call)
  if (is.null(name_col)) cli::cli_abort("{.arg name_col} must name a column of {.arg df}.")
  team_col <- pick_col(df, rlang::enquo(team_col), "team_col", call) %||%
    intersect(c("team", "school"), names(df))[1]
  season_col <- pick_col(df, rlang::enquo(season_col), "season_col", call) %||%
    intersect("season", names(df))[1]
  if (is.na(team_col)) team_col <- NULL
  if (is.na(season_col)) season_col <- NULL

  latest <- latest_roster_season()
  if (!is.null(season_col)) {
    s <- suppressWarnings(as.integer(df[[season_col]]))
    seasons <- sort(unique(s[!is.na(s) & s >= roster_first_season & s <= latest]), decreasing = TRUE)
    if (!length(seasons)) {
      cli::cli_inform(
        "No season in {.field {season_col}} has rosters ({roster_first_season} to {latest}); using {latest}."
      )
      season_col <- NULL
    }
  }
  if (!is.null(season_col)) {
    rosters <- do.call(rbind, lapply(seasons, load_roster, league = league))
  } else {
    seasons <- latest
    rosters <- load_roster(league, latest)
    if (!nrow(rosters) && !use_snapshot()) {
      cli::cli_inform("No {latest} rosters yet; using {latest - 1L}.")
      seasons <- latest - 1L
      rosters <- load_roster(league, seasons)
    }
  }
  if (is.null(rosters) || !nrow(rosters)) {
    cli::cli_warn(
      c(
        "Could not read the {.val {league}} rosters for {.val {seasons}}, so every {.field athlete_id} is {.val NA}.",
        i = if (use_snapshot()) "sdvplotR is offline ({.code options(sdvplotR.offline)} or a CRAN check)."
      ),
      class = "sdvplotR_no_roster_warning"
    )
    rosters <- empty_roster()
  }

  # one key per row: name, then team, then season
  key_df <- norm_value(df[[name_col]])
  key_ro <- norm_value(rosters$name)
  if (!is.null(team_col)) {
    team_key <- function(x) {
      x <- as.character(x)
      id <- resolve_ids(x, league)$ids
      ifelse(is.na(id), paste0("name:", norm_value(x)), id)
    }
    key_df <- paste(key_df, team_key(df[[team_col]]), sep = "\r")
    key_ro <- paste(key_ro, team_key(rosters$team), sep = "\r")
  }
  if (!is.null(season_col)) {
    key_df <- paste(key_df, suppressWarnings(as.integer(df[[season_col]])), sep = "\r")
    key_ro <- paste(key_ro, rosters$season, sep = "\r")
  }
  # a key naming more than one athlete matches no one
  u <- !duplicated(paste(key_ro, rosters$athlete_id))
  ambiguous <- unique(key_ro[u][duplicated(key_ro[u])])
  i <- match(key_df, key_ro)
  i[is.na(df[[name_col]]) | key_df %in% ambiguous] <- NA
  # a row whose team is missing matches no one (a missing roster team would share its key)
  if (!is.null(team_col)) i[is.na(df[[team_col]]) | !nzchar(trimws(as.character(df[[team_col]])))] <- NA
  n_amb <- sum(key_df %in% ambiguous & !is.na(df[[name_col]]))
  if (n_amb) {
    cli::cli_warn(c(
      "{n_amb} row{?s} matched more than one athlete, so {?its/their} {.field athlete_id} {?is/are} {.val NA}.",
      i = "Pass {.arg team_col} and {.arg season_col} to tell them apart."
    ))
  }
  df$athlete_id <- rosters$athlete_id[i]
  if (isTRUE(headshot_urls)) df$headshot_url <- rosters$headshot_url[i]
  df
}
