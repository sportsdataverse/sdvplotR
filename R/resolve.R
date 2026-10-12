# Team identifiers -> canonical (league, team_id), never guessing: a port of
# sdvplot's _resolve.py, held to Python's answers by
# tests/testthat/fixtures/resolve_golden.csv.

# The order id_system = "auto" tries; the first system with a candidate decides.
resolve_priority <- c(
  "team_id", "espn", "espn_abbr", "nhl", "nflverse", "mlbstats", "nba_api", "hockeytech",
  "ncaa", "pff", "cricinfo", "cfbd", "bref", "sportsipy", "fangraphs", "sdvplotr", "name"
)
# NHL stats API ids 1-28 are other teams' ESPN ids: only an explicit id_system reads them
resolve_explicit_only <- "nhl_id"
non_team_programs <- c("conference", "league")
# the index's id systems for the mark functions only, never an id_system and
# never read by sdv_resolve(): "mark" keys archive rows to teams, "conference"
# holds the conference rows' other names ("Southeastern Conference", "B1G")
marks_only_systems <- c("mark", "conference")
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
#'   counterpart of sdvplot's `teams()`.
#' @param league A league key from [sdv_leagues()], or `NULL` for every league.
#' @param include_conferences Also list the conference and league rows (the
#'   college conferences, and the AFC, NFC and NFL). Their `program` is
#'   `"conference"` or `"league"` and their `team_id` is the short name
#'   (`"SEC"`, `"AFC"`). The logo helpers draw them by that key; colour
#'   helpers and [sdv_resolve()] never answer one.
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
#' @export
#' @examples
#' sdv_teams("nfl")
#' sdv_teams("cfb", include_conferences = TRUE)
sdv_teams <- function(league = NULL, include_conferences = FALSE) {
  t <- index_teams()
  if (!isTRUE(include_conferences)) t <- t[is.na(t$program) | !t$program %in% non_team_programs, , drop = FALSE]
  if (!is.null(league)) t <- t[t$league == check_league(league), , drop = FALSE]
  rownames(t) <- NULL
  t
}

# A team value as a comparison key, as sdvplot's norm_value: trimmed, accents
# and typographic punctuation folded, case-folded, integral numbers without a
# decimal point ("13.0" -> "13"). NA for missing or empty.
# ponytail: fold_from/fold_to cover one-to-one Latin folds (U+00C0-024F,
# U+1E00-1EFF); NFKD's compatibility forms (ligatures, full-width) and
# casefold's "ss" for sharp s are not ported. Add them if the golden file ever
# fails on one.
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
#'   `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which overlap
#'   ESPN's, so `"auto"` never reads a number as one).
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
  # ponytail: only the top candidate is held to Python (golden suggest rows); later
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
