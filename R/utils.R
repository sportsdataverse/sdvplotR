# Utility functions for sdvplotR
# ============================================================================

logo_variants <- c("primary", "dark", "light", "alt", "classic", "helmet")
wordmark_variants <- c("primary", "dark", "light", "alt", "classic")
headshot_placeholder <- "https://a.espncdn.com/i/headshots/nophoto.png"

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
#' @return A sorted character vector of valid team identifiers.
#' @export
#' @examples
#' valid_team_names("nfl")
#' valid_team_names("nba", type = "name")
valid_team_names <- function(
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    type = c("abbreviation", "name")) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("abbreviation", "name"))

  ref <- get_team_ref(sport)
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
#' @return A data frame with one row per team and columns:
#'
#'   | col_name | type | description |
#'   |---|---|---|
#'   | sport | character | Sport key (`"nfl"`, `"nba"`, ...) |
#'   | espn_team_id | character | ESPN team id |
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
#'   | color2 | character | Secondary team color (hex) |
#'   | conference | character | Conference (`NA` for leagues without) |
#'   | division | character | Division (`NA` for leagues without) |
#' @export
#' @examples
#' team_reference("nfl")
#' head(team_reference("nba"))
team_reference <- function(sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")) {
  sport <- rlang::arg_match0(sport, supported_sports())
  get_team_ref(sport)
}

#' Standardize Team Abbreviations
#'
#' @description Standardizes team abbreviations to the canonical abbreviations
#'   used by sdvplotR. Matching is case-insensitive and understands full team
#'   names (`"Kansas City Chiefs"`), common alternate abbreviations used by
#'   other data sources (`"WSH"` / `"WAS"`, `"GNB"` / `"GB"`), and historical
#'   abbreviations of relocated franchises (see [resolve_historical_abbr()]).
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
clean_team_abbrs <- function(
    abbr,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    keep_non_matches = TRUE) {
  sport <- rlang::arg_match0(sport, supported_sports())
  abbr <- as.character(abbr)

  m <- abbr_mapping[[sport]]
  key <- toupper(abbr)
  a <- unname(m[key])

  # second pass: historical franchise abbreviations
  miss <- is.na(a) & !is.na(abbr)
  if (any(miss)) {
    a[miss] <- unname(m[toupper(resolve_historical_abbr(abbr[miss], sport))])
  }

  unmatched <- unique(abbr[is.na(a) & !is.na(abbr)])
  if (length(unmatched) && getOption("sdvplotR.verbose", default = interactive())) {
    cli::cli_warn("Abbreviations not found in {.val {sport}} mapping: {.val {unmatched}}")
  }

  if (isTRUE(keep_non_matches)) a <- ifelse(!is.na(a), a, abbr)

  a
}

# ---------------------------------------------------------------------------
# Image resolution helpers (internal)
# ---------------------------------------------------------------------------

lookup_team_column <- function(team, sport, column) {
  team <- clean_team_abbrs(as.character(team), sport = sport, keep_non_matches = FALSE)
  ref <- get_team_ref(sport)
  unname(ref[[column]][match(team, ref$team_abbr)])
}

logo_from_team <- function(team, sport = "nfl") {
  lookup_team_column(team, sport, "logo_url")
}

wordmark_from_team <- function(team, sport = "nfl") {
  lookup_team_column(team, sport, "wordmark_url")
}

# Variant-aware lookups with fallback to the primary image.
resolve_logo_url <- function(team, sport, variant = "primary") {
  variant <- rlang::arg_match0(variant, logo_variants)
  col <- switch(variant,
    primary = "logo_url",
    dark    = "logo_dark_url",
    light   = "logo_light_url",
    alt     = "logo_alt_url",
    classic = "logo_classic_url",
    helmet  = "helmet_url"
  )
  url <- if (col %in% names(logo_ref)) lookup_team_column(team, sport, col) else NA_character_
  ifelse(is.na(url), logo_from_team(team, sport), url)
}

resolve_wordmark_url <- function(team, sport, variant = "primary") {
  variant <- rlang::arg_match0(variant, wordmark_variants)
  col <- switch(variant,
    primary = "wordmark_url",
    dark    = "wordmark_dark_url",
    light   = "wordmark_light_url",
    alt     = "wordmark_alt_url",
    classic = "wordmark_classic_url"
  )
  url <- if (col %in% names(logo_ref)) lookup_team_column(team, sport, col) else NA_character_
  ifelse(is.na(url), wordmark_from_team(team, sport), url)
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

# Player IDs are GSIS IDs for the NFL and ESPN athlete IDs everywhere else.
headshot_from_id <- function(player_id, sport = "nfl") {
  # as.character() writes round numbers like 4000000 as "4e+06"
  player_id <- if (is.numeric(player_id)) {
    ifelse(is.na(player_id), NA_character_, sprintf("%.0f", player_id))
  } else {
    as.character(player_id)
  }
  espn_slug <- c(
    nba = "nba", wnba = "wnba", mlb = "mlb", nhl = "nhl",
    cfb = "college-football", mbb = "mens-college-basketball",
    wbb = "womens-college-basketball"
  )
  url <- if (sport == "nfl") {
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
      ifelse(
        !is.na(espn),
        paste0("https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/", espn, ".png"),
        NA_character_
      )
    )
  } else {
    ifelse(
      grepl("^[0-9]+$", player_id),
      paste0(
        "https://a.espncdn.com/combiner/i?img=/i/headshots/",
        espn_slug[[sport]], "/players/full/", player_id, ".png"
      ),
      NA_character_
    )
  }
  url[is.na(player_id) | player_id == ""] <- NA_character_
  unname(url)
}

# HTML helpers for axis labels rendered through ggtext::element_markdown()
logo_html <- function(team_abbr, sport, type = c("height", "width"), size = 15) {
  type <- rlang::arg_match(type)
  urls <- logo_from_team(team_abbr, sport = sport)
  ifelse(is.na(urls), team_abbr, sprintf("<img src='%s' %s = '%s'>", urls, type, size))
}

headshot_html <- function(player_id, sport, type = c("height", "width"), size = 25) {
  type <- rlang::arg_match(type)
  urls <- headshot_from_id(player_id, sport = sport)
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
