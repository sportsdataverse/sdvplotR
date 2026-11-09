# Team identifiers -> canonical (league, team_id), never guessing: a port of
# sdvplot's _resolve.py, held to Python's answers by
# tests/testthat/fixtures/resolve_golden.csv.

# The order id_system = "auto" tries; the first system with a candidate decides.
resolve_priority <- c(
  "team_id", "espn", "espn_abbr", "nhl", "nflverse", "mlbstats", "nba_api", "hockeytech",
  "ncaa", "pff", "cricinfo", "cfbd", "bref", "sportsipy", "fangraphs", "yahoo", "kenpom", "torvik",
  "sdvplotr", "name"
)
# Other teams' ESPN ids, so only an explicit id_system reads them: NHL stats API
# ids 1-28, and Fox, CBS, 247Sports and On3 ids (Fox 25 is Ohio State, ESPN 25
# California)
resolve_explicit_only <- c("nhl_id", "fox", "cbs", "sports247", "on3")
non_team_programs <- c("conference", "league")
# the manifest levels of non-team marks: an index row's program is one of the
# above, but a division mark (the NHL's) is archived at level "division"
non_team_levels <- c(non_team_programs, "division")
# the index's id systems for the mark functions only, never an id_system and
# never read by sdv_resolve(): "mark" keys archive rows to teams, "conference"
# holds the conference rows' other names ("Southeastern Conference", "B1G"),
# "competition" the soccer competitions each club was seen in (a slug names
# many clubs)
marks_only_systems <- c("mark", "conference", "competition")
# id systems that record a league's whole history (bounds seasons per league)
history_systems <- c("bref", "sportsipy", "mlbstats", "espn_abbr")

#' Leagues sdvplotR knows
#'
#' @description The SportsDataverse league keys every `league` argument takes:
#'   the leagues of the shared team index sdvplot (Python) and sdvplot-js use.
#' @return A sorted character vector.
#' @seealso [sdv_teams()] for each league's teams.
#' @export
#' @examples
#' sdv_leagues()
sdv_leagues <- function() sort(unique(index_teams()$league), method = "radix")

check_league <- function(league, call = rlang::caller_env()) {
  if (!rlang::is_string(league)) {
    cli::cli_abort(
      "{.arg league} must be one league key such as {.val nfl}, not {.obj_type_friendly {league}}.",
      call = call
    )
  }
  if (!league %in% sdv_leagues()) {
    cli::cli_abort(c("Unknown league {.val {league}}.", i = "Known leagues: {.val {sdv_leagues()}}."), call = call)
  }
  league
}

#' Teams in the sdvplotR index
#'
#' @description One row per team: its canonical `team_id` (the key every
#'   helper resolves to), names, abbreviation, conference and colours. The R
#'   counterpart of sdvplot's `teams()`, and of cfbplotR's team lists by
#'   division and its `logo_ref` (see the examples).
#' @param league A league key from [sdv_leagues()], or `NULL` for every league.
#' @param include_conferences Also list the conference and league rows (the
#'   college conferences, and the AFC, NFC and NFL). Their `program` is
#'   `"conference"` or `"league"` and their `team_id` is the short name
#'   (`"SEC"`, `"AFC"`). The logo helpers draw them by that key; colour
#'   helpers and [sdv_resolve()] never answer one.
#' @param division `NULL` (every team), or one or more of `"FBS"`, `"FCS"`,
#'   `"DI"`, `"DII"`, `"DIII"`, `"P4"`, `"P5"`, `"G5"` and `"Conference"`:
#'   only the teams in any of them, as cfbplotR's division filter keeps.
#'   `"FBS"`, `"FCS"`, `"DI"`, `"DII"` and `"DIII"` read the index's
#'   `division` column (FBS, FCS, DII and DIII in college football, DI, DII
#'   and DIII in the other college leagues); an index that has no divisions
#'   for the league (one built before they were added) is an error naming
#'   it. `"P4"`, `"P5"` and `"G5"` are college football's, from
#'   each team's conference in the index, so they follow realignment as the
#'   index does:
#'
#'   * `"P4"`: the ACC, Big Ten, Big 12 and SEC, and Notre Dame.
#'   * `"P5"`: the P4 and the Pac-12, with the Pac-12's members as the index
#'     lists them (the conference rebuilt for 2026 in the current index;
#'     cfbplotR's P5 keeps the Pac-12 of 2023).
#'   * `"G5"`: the American, Conference USA, the MAC, the Mountain West and
#'     the Sun Belt, and the FBS independents other than Notre Dame, so the P5
#'     and the G5 together are the FBS, as in cfbplotR.
#'
#'   `"Conference"` gives the conference and league rows. With `division`,
#'   `include_conferences` is not read. cfbplotR's `"hoopR"` schools are the
#'   `"mbb"` league here.
#' @return A data frame:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | league | character | League key |
#'   | team_id | character | Canonical team id (the ESPN id where ESPN has the team) |
#'   | abbr | character | Abbreviation (`NA` where the league has none) |
#'   | name | character | Full name |
#'   | short_name | character | Short display name |
#'   | location | character | City or school |
#'   | program | character | `NA` for a team; `"conference"` or `"league"` for those rows |
#'   | conference_id | character | The team's conference row `team_id` |
#'   | conference | character | Conference name |
#'   | color_primary | character | Primary colour (hex) |
#'   | color_secondary | character | Secondary colour (hex) |
#'   | color_source | character | `"nflverse"`, `"espn"`, `"logo"`, `"cbbplotR"` or `"fallback"` |
#'   | division | character | College division (`"FBS"`, `"DII"`, ...); `NA` elsewhere or in an older index |
#' @export
#' @examples
#' sdv_teams("nfl")
#' sdv_teams("cfb", include_conferences = TRUE)
#'
#' # cfbplotR's P5 team list
#' sdv_teams("cfb", division = "P5")$location
#'
#' # cfbplotR's logo_ref: a logo (and, where archived, wordmark) URL per team
#' \donttest{
#' logo_ref <- transform(
#'   sdv_teams("cfb"),
#'   logo = sdv_logo_url(team_id, "cfb"),
#'   wordmark = suppressWarnings(sdv_logo_url(team_id, "cfb", mark_type = "wordmark"))
#' )
#' head(logo_ref[c("location", "color_primary", "color_secondary", "logo", "wordmark")])
#' }
sdv_teams <- function(league = NULL, include_conferences = FALSE, division = NULL) {
  t <- index_teams()
  if (!is.null(division)) {
    if (is.null(league)) cli::cli_abort("{.arg division} needs a {.arg league}, such as {.val cfb}.")
    t <- t[t$league == check_league(league), , drop = FALSE]
    t <- t[in_division(t, league, division), , drop = FALSE]
    rownames(t) <- NULL
    return(t)
  }
  if (!isTRUE(include_conferences)) t <- t[is.na(t$program) | !t$program %in% non_team_programs, , drop = FALSE]
  if (!is.null(league)) t <- t[t$league == check_league(league), , drop = FALSE]
  rownames(t) <- NULL
  t
}

# College football's tiers by conference (the index's conference_id). As of the
# 2026 index; a conference that changes its id needs an update here.
cfb_power4 <- c("cfb:acc", "cfb:big-ten", "cfb:big-12", "cfb:sec")
cfb_group5 <- c("cfb:american", "cfb:cusa", "cfb:mac", "cfb:mountain-west", "cfb:sun-belt")
cfb_notre_dame <- "87"
column_divisions <- c("FBS", "FCS", "DI", "DII", "DIII")
team_divisions <- c(column_divisions, "P4", "P5", "G5", "Conference")

# Which rows of one league's index teams `t` are in any of `division`
in_division <- function(t, league, division, call = rlang::caller_env()) {
  if (!is.character(division) || !length(division) || anyNA(division) || !all(division %in% team_divisions)) {
    cli::cli_abort("{.arg division} must be one or more of {.val {team_divisions}}.", call = call)
  }
  tiers <- intersect(division, c("P4", "P5", "G5"))
  if (length(tiers) && league != "cfb") {
    cli::cli_abort("{.val {tiers}} {?is a/are} college football tier{?s}; use {.code league = \"cfb\"}.", call = call)
  }
  cols <- intersect(division, column_divisions)
  if (length(cols) && all(is.na(t$division))) {
    cli::cli_abort(c(
      "The team index {.val {sdv_versions()$index_version}} has no {.val {league}} divisions for {.val {cols}}.",
      i = "{.val P4}, {.val P5} and {.val G5} work without it, from conferences."
    ), call = call)
  }
  # the tiers name conferences by index id: say so if the index has renamed one, rather than drop its teams
  tier_ids <- c(
    if (any(c("P4", "P5") %in% tiers)) cfb_power4, if ("P5" %in% tiers) "cfb:pac-12",
    if ("G5" %in% tiers) c(cfb_group5, "cfb:fbs-independents")
  )
  gone <- setdiff(tier_ids, t$conference_id)
  if (length(gone)) {
    cli::cli_warn(c(
      "The team index {.val {sdv_versions()$index_version}} has no teams in {.val {gone}},
       so {.val {tiers}} may be incomplete.",
      i = "The conference may have a new id; report it at {.url https://github.com/sportsdataverse/sdvplotR/issues}."
    ), call = call)
  }
  conf <- !is.na(t$program) & t$program %in% non_team_programs
  p4 <- !conf & (t$conference_id %in% cfb_power4 | t$team_id %in% cfb_notre_dame)
  p5 <- p4 | (!conf & t$conference_id %in% "cfb:pac-12")
  g5 <- !conf & (t$conference_id %in% cfb_group5 |
    (t$conference_id %in% "cfb:fbs-independents" & !t$team_id %in% cfb_notre_dame))
  keep <- ("Conference" %in% division & conf) | ("P4" %in% division & p4) |
    ("P5" %in% division & p5) | ("G5" %in% division & g5)
  if (length(cols)) keep <- keep | (!conf & toupper(t$division) %in% cols)
  keep
}

# A team value as a comparison key, as sdvplot's norm_value: trimmed, accents
# and typographic punctuation folded, case-folded, integral numbers without a
# decimal point ("13.0" -> "13"). NA for missing or empty.
# The fold tables (data-raw/export_index.py) hold what Python's NFKD + casefold
# does to each character of the Latin, ligature and full-width blocks:
# fold_from/fold_to the one-to-one folds, fold_multi_from/fold_multi_to the
# rest ("ß" -> "ss", ligatures). Other scripts' precomposed accents are
# not folded; the golden file's "norm" rows check every non-ASCII alias.
norm_value <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  if (is.numeric(x)) {
    whole <- !is.na(x) & is.finite(x) & x == trunc(x)
    out <- ifelse(whole, sprintf("%.0f", x), as.character(x))
    out[is.na(x)] <- NA_character_
    return(out)
  }
  # Python's strip() and NFKD treat these Unicode spaces as " " (NBSP, en/em/thin spaces, ideographic)
  s <- gsub("[\u00a0\u2000-\u200a\u202f\u205f\u3000]", " ", enc2utf8(as.character(x)))
  s <- trimws(s)
  wide <- !is.na(s) & grepl("[^ -~]", s)
  if (any(wide)) {
    w <- chartr(paste0(fold_from, "\u2018\u2019"), paste0(fold_to, "''"), s[wide])
    for (i in seq_along(fold_multi_from)) w <- gsub(fold_multi_from[[i]], fold_multi_to[[i]], w, fixed = TRUE)
    w <- gsub("[\u2013\u2014]", "-", w)
    s[wide] <- gsub("[\u0300-\u036f]", "", w)
  }
  s <- tolower(s)
  s <- sub("^(-?[0-9]+)\\.0+$", "\\1", s)
  s[!is.na(s) & !nzchar(s)] <- NA_character_
  s
}

season_bounds <- function(league) {
  b <- index_cache$season_bounds
  if (is.null(b)) {
    a <- index_aliases()
    yrs <- c(a$valid_from, a$valid_to)
    last <- max(c(yrs, as.integer(format(Sys.Date(), "%Y")) + 1L), na.rm = TRUE)
    b <- list(.all = c(min(yrs, na.rm = TRUE), last))
    h <- a[a$id_system %in% history_systems, , drop = FALSE]
    for (lg in unique(h$league[!is.na(h$valid_to)])) {
      x <- h[h$league == lg, , drop = FALSE]
      b[[lg]] <- c(min(c(x$valid_from, x$valid_to), na.rm = TRUE), last)
    }
    index_cache$season_bounds <- b
  }
  b[[league]] %||% b[[".all"]]
}

# season: NULL, one year, or one per team; years as numbers or digit strings.
norm_seasons <- function(season, n, league, call = rlang::caller_env()) {
  if (is.null(season)) {
    return(rep(NA_integer_, n))
  }
  if (length(season) != 1L && length(season) != n) {
    cli::cli_abort(
      "{.arg season} has {length(season)} values but there are {n} teams; pass one season or one per team.",
      call = call
    )
  }
  if (is.factor(season)) season <- as.character(season)
  num <- suppressWarnings(as.numeric(season))
  bad <- !is.na(season) & (is.na(num) | !is.finite(num) | abs(num) > .Machine$integer.max |
    num != trunc(num) | is.logical(season))
  if (is.character(season)) bad <- bad | (!is.na(season) & !grepl("^\\s*[0-9]+\\s*$", season))
  if (any(bad)) {
    v <- season[bad][[1]]
    split <- regmatches(v, regexec("^\\s*(\\d{4})\\s*[-/]\\s*(\\d{2}|\\d{4})\\s*$", v))[[1]]
    hint <- if (length(split)) {
      paste0(" For a split season pass its ending year: ", as.integer(split[2]) + 1L, ".")
    } else {
      ""
    }
    cli::cli_abort(paste0("{.arg season} must be a year such as 2020, not {.val {v}}.", hint), call = call)
  }
  yr <- as.integer(num)
  b <- season_bounds(league)
  out <- !is.na(yr) & (yr < b[1] | yr > b[2])
  if (any(out)) {
    cli::cli_abort(
      "Season {yr[out][1]} is outside the seasons sdvplotR knows for {.val {league}} ({b[1]} to {b[2]}).",
      call = call
    )
  }
  rep_len(yr, n)
}

league_lookup <- function(league) {
  key <- paste0("lookup:", league)
  if (is.null(index_cache[[key]])) {
    a <- index_aliases()
    a <- a[a$league == league, , drop = FALSE]
    a$key <- norm_value(a$value)
    a <- a[!is.na(a$key), , drop = FALSE]
    nm <- a[!a$id_system %in% marks_only_systems, , drop = FALSE]
    latest <- suppressWarnings(max(c(nm$valid_from, nm$valid_to), na.rm = TRUE))
    index_cache[[key]] <- list(
      a = a,
      rows = list2env(split(seq_len(nrow(a)), paste(a$id_system, a$key, sep = "\r")), hash = TRUE),
      latest = if (is.finite(latest)) as.integer(latest) else NA_integer_
    )
  }
  index_cache[[key]]
}

# The team ids one key names under the deciding id system: one id is a match,
# several are ambiguous, none is unknown. With a season, a first pass keeps only
# aliases whose range covers it; then a pass at the league's latest season (a
# reused code means its current holder); then a pass ignoring ranges.
match_key <- function(key, season, systems, lk) {
  whens <- unique(stats::na.omit(c(season, lk$latest)))
  for (when in c(as.list(whens), list(NULL))) {
    for (sys in systems) {
      i <- get0(paste(sys, key, sep = "\r"), envir = lk$rows, inherits = FALSE)
      if (is.null(i)) next
      if (!is.null(when)) {
        vf <- lk$a$valid_from[i]
        vt <- lk$a$valid_to[i]
        i <- i[(is.na(vf) | when >= vf) & (is.na(vt) | when <= vt)]
        if (!length(i)) next
      }
      return(sort(unique(lk$a$team_id[i]), method = "radix"))
    }
  }
  character()
}

resolve_systems <- function(id_system, call = rlang::caller_env()) {
  ok <- c("auto", resolve_priority, resolve_explicit_only)
  if (!rlang::is_string(id_system) || !id_system %in% ok) {
    cli::cli_abort("{.arg id_system} must be one of {.val {ok}}, not {.val {id_system}}.", call = call)
  }
  if (id_system == "auto") resolve_priority else id_system
}

# normalized key -> team_id of the league's conference and league rows, by the
# row's own key and then its "conference" aliases (the build keeps a key naming
# one row only); read after every team alias, and only for marks
non_team_keys <- function(league) {
  t <- sdv_teams(league, include_conferences = TRUE)
  t <- t[t$program %in% non_team_programs, , drop = FALSE]
  a <- league_lookup(league)$a
  a <- a[a$id_system == "conference", , drop = FALSE]
  keys <- c(norm_value(t$team_id), a$key)
  ids <- c(t$team_id, a$team_id)
  keep <- !is.na(keys) & !duplicated(keys)
  stats::setNames(ids[keep], keys[keep])
}

resolve_ids <- function(x, league, season = NULL, id_system = "auto", marks = FALSE, call = rlang::caller_env()) {
  check_league(league, call)
  systems <- resolve_systems(id_system, call)
  keys <- norm_value(x)
  seasons <- norm_seasons(season, length(keys), league, call)
  lk <- league_lookup(league)
  nt <- if (marks) non_team_keys(league) else character()
  teams <- sdv_teams(league)
  combo <- paste(keys, seasons, sep = "\r")
  u <- which(!duplicated(combo) & !is.na(keys))
  id_u <- why_u <- rep(NA_character_, length(u))
  for (k in seq_along(u)) {
    hit <- match_key(keys[u[k]], seasons[u[k]], systems, lk)
    if (!length(hit) && keys[u[k]] %in% names(nt)) hit <- nt[[keys[u[k]]]]
    if (length(hit) == 1L) {
      id_u[k] <- hit
    } else if (!length(hit)) {
      why_u[k] <- "unknown"
    } else {
      nm <- teams$name[match(hit, teams$team_id)]
      why_u[k] <- paste("ambiguous:", paste(trimws(paste(hit, ifelse(is.na(nm), "", nm))), collapse = " or "))
    }
  }
  j <- match(combo, combo[u])
  list(ids = unname(id_u[j]), why = unname(why_u[j]))
}

report_unresolved <- function(x, why, league, strict = FALSE, call = rlang::caller_env()) {
  bad <- !is.na(why)
  if (!any(bad)) {
    return(invisible())
  }
  v <- as.character(x)[bad]
  w <- why[bad]
  keep <- !duplicated(v)
  shown <- paste0("'", v[keep], "' (", w[keep], ")") # nolint: object_usage_linter. used in msg's cli glue
  msg <- "{sum(keep)} value{?s} did not resolve to a {.val {league}} team: {shown}."
  hint <- if (any(startsWith(w, "ambiguous"))) {
    c(i = "Pass {.arg season} for a code reused across eras, or {.arg id_system} for the id system of the values.")
  }
  if (isTRUE(strict)) cli::cli_abort(c(msg, hint), class = "sdvplotR_unresolved", call = call)
  cli::cli_warn(c(msg, hint, i = "Use {.fn sdv_suggest} for candidates, or {.code strict = TRUE} to error."),
    class = "sdvplotR_unresolved_warning", call = call
  )
}

#' Resolve team identifiers to canonical team ids
#'
#' @description Turns whatever team identifiers you have (abbreviations, full
#'   names, ESPN, nflverse, MLB Stats, nba_api, HockeyTech, CFBD, Sports
#'   Reference and other ids) into the index's canonical `team_id`, never
#'   guessing. Every sdvplotR helper that takes a team resolves it this way.
#'   The R counterpart of sdvplot's `resolve()`, and it gives the same answers.
#' @param x A vector of team identifiers (character, numeric or factor).
#' @param league A league key from [sdv_leagues()]. Required: one abbreviation
#'   means different teams in different leagues.
#' @param season `NULL`, one season year, or one per value: picks the team
#'   that used a reused code that season. Without one, a reused code means its
#'   current holder. Split seasons take their ending year (2021 for 2020-21).
#' @param id_system `"auto"` (try every id system in priority order) or one
#'   id system: `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
#'   `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
#'   `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
#'   `"yahoo"`, `"kenpom"`, `"torvik"`, `"sdvplotr"`, `"name"`, or one
#'   `"auto"` never tries because its numbers overlap ESPN's: `"nhl_id"` (NHL
#'   stats API ids), `"fox"`, `"cbs"`, `"sports247"` (247Sports team and
#'   institution ids) or `"on3"`.
#' @param strict If `TRUE`, a value that does not resolve is an error;
#'   otherwise it becomes `NA` with one warning per call.
#' @return A character vector of `team_id`s, the length of `x`.
#' @seealso [sdv_suggest()] for a value that did not resolve, [sdv_teams()].
#' @export
#' @examples
#' sdv_resolve(c("KC", "Kansas City Chiefs", "OAK"), "nfl")
#' sdv_resolve("QUE", "nhl", season = 1990)
#' sdv_resolve(c("Iowa St.", "Miami (OH)"), "mbb")
sdv_resolve <- function(x, league, season = NULL, id_system = "auto", strict = FALSE) {
  r <- resolve_ids(x, league, season, id_system)
  report_unresolved(x, r$why, league, strict)
  r$ids
}

#' Suggest teams for a value that did not resolve
#'
#' @description Up to `n` candidate teams for a misspelled or unknown value,
#'   best first. It never picks one for you: similar names can be different
#'   teams. The R counterpart of sdvplot's `suggest()`.
#' @param x One team value.
#' @inheritParams sdv_resolve
#' @param n The most candidates to return.
#' @return A data frame with `team_id` and `name`, empty when nothing is close.
#' @export
#' @examples
#' sdv_suggest("Kansas Cty Chiefs", "nfl", n = 2)
sdv_suggest <- function(x, league, n = 5) {
  check_league(league)
  if (!rlang::is_scalar_integerish(n) || n < 1) cli::cli_abort("{.arg n} must be a whole number of at least 1.")
  out <- data.frame(team_id = character(), name = character())
  key <- norm_value(x)[1]
  if (is.na(key)) {
    return(out)
  }
  lk <- league_lookup(league)
  # a conference row's name is never a team candidate (Python's suggest() skips it too)
  a <- lk$a[lk$a$id_system != "conference", , drop = FALSE]
  keys <- unique(a$key)
  # Only the top candidate is held to Python (golden suggest rows); later
  # candidates order by edit distance, not difflib's ratio, so their order may differ.
  sim <- 1 - drop(utils::adist(key, keys)) / pmax(nchar(key), nchar(keys))
  ord <- order(-sim, keys, method = "radix")
  ord <- ord[sim[ord] >= 0.6]
  if (!length(ord)) {
    return(out)
  }
  ids <- unique(unlist(lapply(keys[ord], function(k) a$team_id[a$key == k]), use.names = FALSE))
  ids <- utils::head(ids, n)
  t <- sdv_teams(league, include_conferences = TRUE)
  nm <- t$name[match(ids, t$team_id)]
  data.frame(team_id = ids, name = ifelse(is.na(nm), ids, nm))
}

#' Clean team names to one display name
#'
#' @description Standardizes team names, abbreviations and ids to one
#'   display name per team, for joins and labels. The counterpart of
#'   cfbplotR's `clean_school_names()` and its alias (and of nflplotR's
#'   abbreviation cleaner with `column = "abbr"`), built on
#'   [sdv_resolve()]: every alias and id system it reads cleans to the same
#'   name, and a value it cannot resolve without guessing (an unknown name, or
#'   one that names two teams) is not cleaned.
#' @inheritParams sdv_resolve
#' @param keep_non_matches If `TRUE` (the default) a value that does not
#'   resolve is kept as it is, quietly. Otherwise it becomes `NA`, with one
#'   warning per call.
#' @param column The [sdv_teams()] column to return: `"location"` (the
#'   default; the school in college sports, the city in the pros, and closest
#'   to cfbplotR's names), `"short_name"`, `"name"`, `"abbr"` or `"team_id"`.
#' @return A character vector the length of `x`.
#' @seealso [sdv_resolve()] for team ids, [sdv_aliases()] for every name
#'   the index knows.
#' @export
#' @examples
#' x <- c("utah", "San Jose State", "Hawaii", "UTSA", "SLC", "USC")
#' # keep the values that do not resolve
#' sdv_clean_names(x, "cfb")
#' # or replace them with NA
#' sdv_clean_names(x, "cfb", keep_non_matches = FALSE)
#' sdv_clean_names(c("Kansas City Chiefs", "OAK"), "nfl", column = "abbr")
sdv_clean_names <- function(
    x,
    league,
    keep_non_matches = TRUE,
    column = c("location", "short_name", "name", "abbr", "team_id"),
    season = NULL,
    id_system = "auto"
) {
  column <- rlang::arg_match(column)
  r <- resolve_ids(x, league, season, id_system)
  t <- sdv_teams(league)
  out <- t[[column]][match(r$ids, t$team_id)]
  if (isTRUE(keep_non_matches)) {
    miss <- is.na(out)
    out[miss] <- id_chr(x)[miss]
  } else {
    report_unresolved(x, r$why, league)
  }
  out
}

# nolint start: line_length_linter. table rows cannot wrap
#' Team aliases in the sdvplotR index
#'
#' @description Every team name, abbreviation and provider id the index
#'   resolves, one row per alias: what [sdv_resolve()] reads. The counterpart
#'   of cfbplotR's `team_name_mapping` (see the examples). The R counterpart of
#'   sdvplot's alias table.
#' @param league A league key from [sdv_leagues()], or `NULL` for every league.
#' @return A data frame:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | league | character | League key |
#'   | id_system | character | The id system of `value` (`"name"`, `"espn"`, `"cfbd"`, ...; see [sdv_resolve()]). `"mark"`, `"conference"` and `"competition"` rows serve the logo helpers only |
#'   | value | character | The alias as the index stores it (lookups ignore case and accents) |
#'   | team_id | character | The [sdv_teams()] `team_id` it names |
#'   | valid_from | integer | First season the alias names this team (`NA`: always) |
#'   | valid_to | integer | Last season the alias names this team (`NA`: still) |
#' @seealso [sdv_clean_names()], [sdv_resolve()], [sdv_teams()].
#' @export
#' @examples
#' a <- sdv_aliases("cfb")
#' head(a[a$id_system == "name", ])
#'
#' # cfbplotR's team_name_mapping: each name -> its school
#' nm <- a[a$id_system %in% c("name", "cfbd", "sdvplotr"), ]
#' t <- sdv_teams("cfb")
#' mapping <- stats::setNames(t$location[match(nm$team_id, t$team_id)], nm$value)
#' head(mapping)
# nolint end
sdv_aliases <- function(league = NULL) {
  a <- index_aliases()
  if (!is.null(league)) a <- a[a$league == check_league(league), , drop = FALSE]
  rownames(a) <- NULL
  a
}
