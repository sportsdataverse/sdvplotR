# Utility functions for sdvplotR
# ============================================================================

# The variants an image backs: ESPN's default, dark-background and scoreboard
# logos (the scoreboard mark differs from the default for a few pro teams, the
# Jets' "NY" for one, and college teams have none), nflverse's one wordmark.
logo_variants <- c("primary", "dark", "scoreboard")
wordmark_variants <- "primary"
headshot_placeholder <- "https://a.espncdn.com/i/headshots/nophoto.png"

# `variant` validated for a logo or wordmark helper; any other value errors.
# A function's default vector (every variant) picks the first.
check_variant <- function(variant, type = "logo") {
  valid <- if (type == "logo") logo_variants else wordmark_variants
  if (identical(variant, valid)) valid[[1]] else rlang::arg_match0(variant, valid, arg_nm = "variant")
}

`%||%` <- function(x, y) if (is.null(x)) y else x

is_installed <- function(pkg) requireNamespace(pkg, quietly = TRUE)

# ---------------------------------------------------------------------------
# Team reference accessors
# ---------------------------------------------------------------------------

get_team_ref <- function(sport) {
  sport <- rlang::arg_match0(tolower(trimws(sport)), supported_sports())
  logo_ref[logo_ref$sport == sport, , drop = FALSE]
}

#' Output Valid Team Names
#'
#' @description Returns a character vector of valid team abbreviations or names
#'   for a given sport.
#'
#' @param sport Character string identifying the sport. One of
#'   [supported_sports()].
#' @param type Character string, either `"abbreviation"` (default) or `"name"`.
#' @param include_conferences If `TRUE`, also list the conferences sdvplotR
#'   has a logo for: the college conferences (`"SEC"`, `"Big Ten"`, `"A-10"`)
#'   and `"AFC"`, `"NFC"` and `"NFL"`. They resolve like teams in every helper
#'   either way; the default, `FALSE`, lists teams only, so code that loops
#'   over teams sees only teams (nflplotR's `valid_team_names()` includes AFC,
#'   NFC and NFL).
#' @return A sorted character vector of valid team identifiers.
#' @export
#' @examples
#' valid_team_names("nfl")
#' valid_team_names("nba", type = "name")
valid_team_names <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("abbreviation", "name"),
    include_conferences = FALSE) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("abbreviation", "name"))

  ref <- team_rows(get_team_ref(sport), include_conferences)
  col <- if (type == "abbreviation") "team_abbr" else "team_name"
  sort(unique(ref[[col]]))
}

#' Get Team Reference Data
#'
#' @description Returns the team reference data frame for a given sport,
#'   containing team names, abbreviations, logo and wordmark URLs, colors and
#'   conference / division.
#'
#' @inheritParams valid_team_names
#' @return A data frame with one row per team (plus, with
#'   `include_conferences = TRUE`, one per conference and the NFL itself) and
#'   columns:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | sport | character | Sport key (`"nfl"`, `"nba"`, ...) |
#'   | espn_team_id | integer | ESPN team id (`NA` for conferences) |
#'   | team_abbr | character | Canonical team abbreviation |
#'   | team_name | character | Full team name |
#'   | team_short_name | character | Short display name |
#'   | team_location | character | City / school |
#'   | team_mascot | character | Mascot / nickname |
#'   | logo_url | character | Primary logo URL |
#'   | logo_dark_url | character | Dark-background logo URL |
#'   | logo_scoreboard_url | character | Scoreboard logo URL |
#'   | wordmark_url | character | Wordmark URL (`NA` when none) |
#'   | color1 | character | Primary team color (hex) |
#'   | color2 | character | Secondary team color (hex; `NA` when the source has none) |
#'   | color_source | character | `"nflverse"`, `"espn"`, `"logo"` or `"cbbplotR"`; `NA` for the AFC, NFC and NFL |
#'   | conference | character | Conference (`NA` for leagues without) |
#'   | division | character | Division (`NA` for leagues without) |
#'   | type | character | `"team"`, `"conference"` or `"league"` |
#'
#'   Colors are nflverse's for the NFL and ESPN's teams-list colors elsewhere.
#'   ESPN gives some newer or smaller college programs a stand-in instead of
#'   colors (black alone, black with its stock red, or black on black); those
#'   teams, and the ones ESPN gives no color, take the colors sdvplot's team
#'   index holds for the same ESPN team id: ESPN's own per-team entry where it
#'   has one (`"espn"`), otherwise colors derived from the team's logo
#'   (`"logo"`). Every team therefore has a primary color.
#' @export
#' @examples
#' team_reference("nfl")
#' head(team_reference("nba"))
team_reference <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    include_conferences = FALSE) {
  sport <- rlang::arg_match0(sport, supported_sports())
  team_rows(get_team_ref(sport), include_conferences)
}

# the public listings show teams only unless conferences are asked for
team_rows <- function(ref, include_conferences = FALSE) {
  if (isTRUE(include_conferences)) ref else ref[ref$type == "team", , drop = FALSE]
}

#' Standardize Team Abbreviations
#'
#' @description Standardizes team abbreviations to the canonical abbreviations
#'   used by sdvplotR. Matching is case-insensitive and understands full team
#'   names (`"Kansas City Chiefs"`), common alternate abbreviations used by
#'   other data sources (`"WSH"` / `"WAS"`, `"GNB"` / `"GB"`), and historical
#'   abbreviations of relocated franchises (see [resolve_historical_abbr()]),
#'   which follow the franchise even where a provider uses the same code for
#'   another team: `"WIN"`, the original Winnipeg Jets, gives `"UTAH"`, while
#'   today's Jets are `"WPG"`.
#'   For the college sports it also takes the school names NCAA.com /
#'   stats.ncaa.org, KenPom, Bart Torvik and Sports Reference use
#'   (`"Iowa St."`, `"St. John's (NY)"`, `"Saint Mary's (CA)"`,
#'   `"Southern California"`, `"Brigham Young"`).
#'   Conference names resolve to the conference: ESPN's (`"SEC"`,
#'   `"Southeastern Conference"`), the NCAA's, KenPom's and Torvik's (`"B10"`,
#'   `"MWC"`), and the names a conference went by before (`"Pac-10"`,
#'   `"Mid-Continent Conference"`). The WAC, which ESPN no longer draws, keeps
#'   its archived ESPN mark; `"UAC"`, the name the basketball WAC took for
#'   2026-27, does not resolve to it. Where a team already uses the name, the
#'   team wins, so the American Athletic Conference is `"AAC"` (`"American"`
#'   is American University).
#'
#' @param abbr A character vector of abbreviations or team names.
#' @inheritParams valid_team_names
#' @param keep_non_matches If `TRUE` (the default) an element of `abbr` that
#'   can't be matched will be kept as is. Otherwise it will be replaced with `NA`.
#' @return A character vector with cleaned team abbreviations.
#' @export
#' @examples
#' clean_team_abbrs(c("KC", "kansas city chiefs", "OAK", "WSH"), sport = "nfl")
#' clean_team_abbrs(c("BOS", "GS", "INVALID"), sport = "nba", keep_non_matches = FALSE)
#' clean_team_abbrs(c("Iowa St.", "St. John's (NY)", "Miami (OH)"), sport = "mbb")
clean_team_abbrs <- function(
    abbr,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    keep_non_matches = TRUE) {
  sport <- rlang::arg_match0(sport, supported_sports())
  abbr <- as.character(abbr)
  a <- match_team_abbrs(abbr, sport)

  unmatched <- unique(abbr[is.na(a) & !is.na(abbr)])
  if (length(unmatched) && getOption("sdvplotR.verbose", default = interactive())) {
    cli::cli_warn("Abbreviations not found in {.val {sport}} mapping: {.val {unmatched}}")
  }

  if (isTRUE(keep_non_matches)) a <- ifelse(!is.na(a), a, abbr)

  a
}

# The passes of clean_team_abbrs(), NA where none matches. `historical = FALSE`
# skips the relocated-franchise pass, so a season-aware lookup keeps "QUE" off
# the Avalanche.
match_team_abbrs <- function(abbr, sport, historical = TRUE) {
  m <- abbr_mapping[[sport]]
  # relocated franchises first, so a relocation key wins over a provider alias
  # of the same name ("WIN" is the original Jets, not today's "WPG"), and
  # clean_team_abbrs() agrees with resolve_historical_abbr()
  key <- if (historical) resolve_historical_abbr(abbr, sport) else abbr
  a <- unname(m[toupper(key)])

  # second pass: accents and typographic punctuation, which providers write
  # inconsistently (the NHL API's "Montr\u00e9al Canadiens", ESPN's "San Jos\u00e9
  # State", Sports Reference's "Nevada\u2013Las Vegas"), folded on both sides
  miss <- is.na(a) & !is.na(abbr)
  if (any(miss)) {
    folded <- stats::setNames(m, fold_accents(names(m)))
    a[miss] <- unname(folded[toupper(fold_accents(abbr[miss]))])
  }

  a
}

# chartr() rather than iconv(to = "ASCII//TRANSLIT"), whose output differs by
# platform. enc2utf8() first: in a C locale chartr() stops on an unmarked
# string holding UTF-8 bytes (a CSV read without an encoding).
fold_accents <- function(x) {
  x <- chartr(
    paste0(
      "\u00e0\u00e1\u00e2\u00e3\u00e4\u00e5\u00e7\u00e8\u00e9\u00ea\u00eb\u00ec\u00ed",
      "\u00ee\u00ef\u00f1\u00f2\u00f3\u00f4\u00f5\u00f6\u00f9\u00fa\u00fb\u00fc\u00fd",
      "\u00c0\u00c1\u00c2\u00c3\u00c4\u00c5\u00c7\u00c8\u00c9\u00ca\u00cb\u00cc\u00cd",
      "\u00ce\u00cf\u00d1\u00d2\u00d3\u00d4\u00d5\u00d6\u00d9\u00da\u00db\u00dc\u00dd",
      # curly apostrophes ("Saint Mary\u2019s")
      "\u2018\u2019"
    ),
    "aaaaaaceeeeiiiinooooouuuuyAAAAAACEEEEIIIINOOOOOUUUUY''",
    enc2utf8(x)
  )
  # en and em dashes ("Nevada\u2013Las Vegas"); chartr() would read "-" as a range
  gsub("[\u2013\u2014]", "-", x)
}

# ---------------------------------------------------------------------------
# Image resolution helpers (internal)
# ---------------------------------------------------------------------------

lookup_team_column <- function(team, sport, column) {
  team <- clean_team_abbrs(as.character(team), sport = sport, keep_non_matches = FALSE)
  ref <- get_team_ref(sport)
  unname(ref[[column]][match(team, ref$team_abbr)])
}

logo_from_team <- function(team, sport = "nfl", season = NULL) {
  season_logo(lookup_team_column(team, sport, "logo_url"), team, sport, season)
}

# Alt text for an image: the team's full name (`team` as the cell holds it;
# an unresolved value falls back to itself), or "Player <id> headshot" for an
# id, which is all a headshot helper has to go on.
team_alt <- function(team, sport) {
  nm <- lookup_team_column(team, sport, "team_name")
  ifelse(is.na(nm), as.character(team), nm)
}

headshot_alt <- function(id) paste0("Player ", id, " headshot")

wordmark_from_team <- function(team, sport = "nfl") {
  lookup_team_column(team, sport, "wordmark_url")
}

# Variant-aware lookups: a team the data has no such image for (a conference's
# dark logo, a college team's scoreboard logo) gets its primary image.
resolve_logo_url <- function(team, sport, variant = "primary", season = NULL) {
  variant <- check_variant(variant, "logo")
  col <- switch(variant,
    primary = "logo_url",
    dark = "logo_dark_url",
    scoreboard = "logo_scoreboard_url"
  )
  url <- lookup_team_column(team, sport, col)
  url <- ifelse(is.na(url), logo_from_team(team, sport), url)
  season_logo(url, team, sport, season, variant)
}

# Season-aware logos (logo_history, built by data-raw/generate_logo_history.R).
# `url` is today's logo; wherever `season` is given and logo_history has the
# team's mark for it, that mark replaces it. `season = NULL` returns `url`.
season_logo <- function(url, team, sport, season, variant = "primary") {
  if (is.null(season)) {
    return(url)
  }
  if (any(suppressWarnings(as.numeric(as.character(season))) > 9999, na.rm = TRUE)) {
    cli::cli_abort("{.arg season} takes single years (the ending year for NHL, NBA, MBB and WBB: 2005 for 2004-05), not ids like {.val 20042005}.")
  }
  hist <- historical_logo_url(team, sport, season, variant)
  url <- rep_len(url, length(hist))
  url[!is.na(hist)] <- hist[!is.na(hist)]
  url
}

# The mark `team` wore in `season` (vectorised over both), NA where
# logo_history has none. A key is looked up as given ("QUE", "TBL"), then as
# its canonical abbreviation ("Tampa Bay Lightning" -> "TB"), never through the
# relocation table, which would hand the Avalanche the Nordiques' seasons. A
# dark lookup falls back to that season's primary mark.
historical_logo_url <- function(team, sport, season, variant = "primary") {
  n <- if (length(team) && length(season)) max(length(team), length(season)) else 0L
  key <- toupper(rep_len(as.character(team), n))
  season <- rep_len(as.numeric(as.character(season)), n)
  keys <- list(key, match_team_abbrs(key, sport, historical = FALSE))
  h <- logo_history[logo_history$sport == sport, , drop = FALSE]
  url <- rep(NA_character_, n)
  for (v in unique(c(variant, "primary"))) {
    hv <- h[h$variant == v, , drop = FALSE]
    for (k in keys) {
      i <- which(is.na(url) & !is.na(k) & !is.na(season))
      url[i] <- vapply(i, function(j) {
        hit <- hv$url[hv$key == k[j] & hv$season_from <= season[j] & hv$season_to >= season[j]]
        if (length(hit)) hit[1] else NA_character_
      }, character(1))
    }
  }
  url
}

resolve_wordmark_url <- function(team, sport, variant = "primary") {
  check_variant(variant, "wordmark")
  wordmark_from_team(team, sport)
}

# NFL headshot map: sdvplotR publishes it from nflverse rosters (1999 onward) to
# its sdvplotr_infrastructure release (data-raw/update_headshot_gsis_map.R) and
# reads it the way nflplotR reads its own map, through nflreadr::rds_from_url(),
# which nflreadr memoises for a day (option nflreadr.cache). Offline, the read
# warns and returns no rows, so every NFL id resolves to NA and the helpers fall
# back as they do for any unknown id.
headshot_map_url <- paste0(
  "https://github.com/sportsdataverse/sdvplotR/releases/download/",
  "sdvplotr_infrastructure/headshot_gsis_map.rds"
)

load_headshot_map <- function() {
  map <- nflreadr::rds_from_url(headshot_map_url)
  if (!nrow(map) || !all(c("gsis_id", "headshot_nfl", "espn_id") %in% names(map))) {
    # nflreadr memoises a failed read too (an empty table, for a day); forget it
    # so the next call retries rather than leaving NFL headshots blank
    forget_headshot_map()
    map <- data.frame(gsis_id = character(), headshot_nfl = character(), espn_id = character())
  }
  map
}

# drop only sdvplotR's entry from nflreadr's memoised reader, not the rest of
# the user's nflreadr cache (nflplotR's cache clearing is scoped the same way)
forget_headshot_map <- function() {
  if (memoise::is.memoised(nflreadr::rds_from_url)) {
    memoise::drop_cache(nflreadr::rds_from_url)(headshot_map_url)
  }
  invisible(NULL)
}

# NFL.com image at the sized headshot transform rather than the full-size
# f_auto,q_auto the roster stores (42-56 KB instead of up to 3.4 MB), with the
# .png that nflplotR also appends: gridtext, behind the headshot axis scales,
# picks its image reader by file extension
nfl_headshot_url <- function(url) {
  url <- sub("/f_auto,q_auto/", "/t_headshot_desktop/f_auto/", url, fixed = TRUE)
  ifelse(grepl("\\.png$", url), url, paste0(url, ".png"))
}

espn_slug <- c(
  nfl = "nfl", nba = "nba", wnba = "wnba", mlb = "mlb", nhl = "nhl",
  cfb = "college-football", mbb = "mens-college-basketball",
  wbb = "womens-college-basketball"
)

espn_headshot_url <- function(espn_id, sport) {
  paste0(
    "https://a.espncdn.com/combiner/i?img=/i/headshots/",
    espn_slug[[sport]], "/players/full/", espn_id, ".png"
  )
}

# Headshots keyed by the league's own player id, as hoopR's
# nba_player_headshot_url() / wehoop's wnba_playerheadshot() (NBA and WNBA Stats
# PERSON_ID), mlbplotR (MLBAM) and the NHL API (its `headshot` for players with
# no current team: mugs/nhl/latest, the same image as the season/team mug)
# build them. An unknown id gets the CDN's silhouette, not a 404. cdn.nba.com and cdn.wnba.com answer 403 to datacenter
# IPs, so a ggplot drawn on CI or a server can come back without the image.
league_headshot_url <- c(
  nba = "https://cdn.nba.com/headshots/nba/latest/260x190/%s.png",
  wnba = "https://cdn.wnba.com/headshots/wnba/latest/260x190/%s.png",
  mlb = paste0(
    "https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/",
    "w_213,q_auto:best/v1/people/%s/headshot/67/current.png"
  ),
  nhl = "https://assets.nhle.com/mugs/nhl/latest/%s.png"
)

# `id_type` for the exported headshot helpers: NULL keeps each sport's default
# (GSIS ids for the NFL, ESPN athlete ids otherwise).
check_id_type <- function(id_type, sport) {
  if (is.null(id_type)) {
    return(NULL)
  }
  id_type <- rlang::arg_match0(id_type, c("espn", "league"))
  if (id_type == "league" && !sport %in% c("nfl", names(league_headshot_url))) {
    cli::cli_abort(c(
      "{.val {sport}} headshots are not available by league player ID.",
      "i" = "Use ESPN athlete IDs with {.code id_type = \"espn\"}."
    ))
  }
  id_type
}

# Player IDs are GSIS IDs for the NFL and ESPN athlete IDs everywhere else, unless
# `id_type` says otherwise: "espn" takes ESPN athlete IDs for every sport,
# "league" the league's own ID (GSIS; NBA / WNBA Stats PERSON_ID; MLBAM; NHL API).
# Both are plain digits, so which one an ID is can't be told from its shape.
headshot_from_id <- function(player_id, sport = "nfl", id_type = NULL) {
  id_type <- id_type %||% if (sport == "nfl") "league" else "espn"
  # as.character() writes round numbers like 4000000 as "4e+06", and scipen
  # only changes the notation: it keeps 15 significant digits. sprintf() is
  # exact for every integer a double holds. A fraction (2544.7) is a malformed
  # id, NA like any other, not the id it would round to.
  player_id <- if (is.numeric(player_id)) {
    whole <- !is.na(player_id) & player_id == floor(player_id)
    ifelse(whole, sprintf("%.0f", player_id), NA_character_)
  } else {
    as.character(player_id)
  }
  numeric_id <- grepl("^[0-9]+$", player_id)

  url <- if (id_type == "espn") {
    ifelse(numeric_id, espn_headshot_url(player_id, sport), NA_character_)
  } else if (sport == "nfl") {
    # GSIS ids resolve through the headshot map sdvplotR publishes (see
    # load_headshot_map()): NFL.com's image where the roster has one, otherwise
    # the player's ESPN athlete headshot. Bare numeric NFL ids are not accepted:
    # nflverse's numeric id systems (nfl, pff, otc) collide with ESPN ids.
    map <- load_headshot_map()
    i <- match(player_id, map$gsis_id)
    nfl <- map$headshot_nfl[i]
    espn <- map$espn_id[i]
    ifelse(
      !is.na(nfl),
      nfl_headshot_url(nfl),
      ifelse(!is.na(espn), espn_headshot_url(espn, "nfl"), NA_character_)
    )
  } else {
    ifelse(numeric_id, sprintf(league_headshot_url[[sport]], player_id), NA_character_)
  }
  url[is.na(player_id) | player_id == ""] <- NA_character_
  unname(url)
}

#' Team Logo and Player Headshot URLs
#'
#' @description The image URLs behind every sdvplotR geom, theme element and
#'   table helper, for your own `<img>` tags, markdown, 'ggpath' layers or
#'   image tooling. `sdv_logo_url()` resolves team keys the way
#'   [clean_team_abbrs()] does (aliases, full names, historical abbreviations,
#'   conference names); `sdv_headshot_url()` builds a headshot URL from a
#'   player id. These are the R counterparts of sdvplot's `logo_url()` and
#'   `headshot_url()`.
#'
#' @param team A character vector of team abbreviations or names.
#' @inheritParams valid_team_names
#' @param variant The logo variant: `"primary"` (ESPN's default mark),
#'   `"dark"` (the dark-background mark) or `"scoreboard"` (ESPN's scoreboard
#'   mark, which differs from the primary for a few pro teams: the Jets' `NY`).
#'   A team without the requested variant gives its primary logo; any other
#'   value is an error.
#' @param season A season year (the ending year for the NHL: 2005 for
#'   2004-05) or a vector of them, recycled against `team`. Where sdvplotR has
#'   the mark the team wore that season (NHL, and the NFL's and WNBA's
#'   relocated identities), that mark is returned; otherwise today's. `NULL`
#'   (the default) gives today's logo.
#' @param player_id A vector of player ids: nflverse GSIS ids for the NFL
#'   (`"00-0033873"`), ESPN athlete ids elsewhere, unless `id_type` says
#'   otherwise.
#' @param id_type `NULL` (the default) takes each sport's default id;
#'   `"espn"` ESPN athlete ids for any sport; `"league"` the league's own ids
#'   (GSIS; NBA / WNBA Stats `PERSON_ID`; MLBAM; NHL API), which the league CDN
#'   serves without a lookup (a silhouette for an unknown id). College sports
#'   have no league ids.
#' @return A character vector the length of `team` / `player_id`: the image
#'   URL, or `NA` for a team that does not resolve, a player id that is
#'   missing, malformed or (NFL GSIS) not in the headshot map, or a league
#'   without wordmarks.
#' @seealso [team_reference()] for every team's URLs at once,
#'   [geom_sdv_logos()] and [gt_sdv_logos()] which draw them.
#' @export
#' @examples
#' sdv_logo_url(c("KC", "Buffalo Bills", "WAS"), sport = "nfl")
#' sdv_logo_url("NYJ", sport = "nfl", variant = "scoreboard")
#' sdv_logo_url("QUE", sport = "nhl", season = 1990)
#' sdv_logo_url("SEC", sport = "cfb")
#'
#' sdv_headshot_url(3917315, sport = "mbb")
#' sdv_headshot_url("2544", sport = "nba", id_type = "league")
#' \donttest{
#' # NFL GSIS ids read the published headshot map
#' sdv_headshot_url("00-0033873", sport = "nfl")
#' }
sdv_logo_url <- function(
    team,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    variant = c("primary", "dark", "scoreboard"),
    season = NULL) {
  sport <- rlang::arg_match0(sport, supported_sports())
  resolve_logo_url(team, sport, variant, season)
}

#' @rdname sdv_logo_url
#' @export
sdv_headshot_url <- function(
    player_id,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    id_type = NULL) {
  sport <- rlang::arg_match0(sport, supported_sports())
  headshot_from_id(player_id, sport, check_id_type(id_type, sport))
}

# HTML helpers for axis labels rendered through ggtext::element_markdown()
logo_html <- function(team_abbr, sport, type = c("height", "width"), size = 15) {
  type <- rlang::arg_match(type)
  urls <- logo_from_team(team_abbr, sport = sport)
  ifelse(is.na(urls), team_abbr, sprintf("<img src='%s' %s = '%s'>", urls, type, size))
}

headshot_html <- function(player_id, sport, type = c("height", "width"), size = 25, id_type = NULL) {
  type <- rlang::arg_match(type)
  urls <- headshot_from_id(player_id, sport = sport, id_type = id_type)
  ifelse(is.na(urls), player_id, sprintf("<img src='%s' %s = '%s'>", urls, type, size))
}

# ---------------------------------------------------------------------------
# Cache management
# ---------------------------------------------------------------------------

#' Clear the sdvplotR Caches
#'
#' @description sdvplotR reads the NFL headshot map through 'nflreadr', which
#'   memoises it for a day, and renders images through 'ggpath', which caches
#'   downloaded images for the session. This function clears both (the
#'   'ggpath' cache when 'ggpath' exposes a cache-clearing function), so the
#'   next NFL headshot reads the current published map.
#' @return Invisibly `NULL`, called for its side effect.
#' @export
#' @examples
#' sdvplotR_clear_cache()
sdvplotR_clear_cache <- function() {
  # the NFL headshot map is memoised by nflreadr's reader
  forget_headshot_map()
  if ("clear_cache" %in% getNamespaceExports("ggpath")) {
    getExportedValue("ggpath", "clear_cache")()
  }
  cli::cli_alert_success("sdvplotR cache cleared.")
  invisible(NULL)
}
