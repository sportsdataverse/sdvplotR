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

# Player IDs are ESPN athlete IDs everywhere; the NFL also takes GSIS IDs.
headshot_from_id <- function(player_id, sport = "nfl") {
  player_id <- as.character(player_id)
  espn_slug <- c(
    nba = "nba", wnba = "wnba", mlb = "mlb", nhl = "nhl",
    cfb = "college-football", mbb = "mens-college-basketball",
    wbb = "womens-college-basketball"
  )
  url <- if (sport == "nfl") {
    # GSIS ids resolve through nflverse's crosswalk to NFL.com's own image id
    # ("<delivery type>/<id>"); numeric ids are ESPN athlete ids, as elsewhere
    nfl <- unname(nfl_headshot_ids[player_id])
    ifelse(
      !is.na(nfl),
      paste0(
        "https://static.www.nfl.com/image/",
        sub("/", "/t_headshot_desktop/f_auto/league/", nfl, fixed = TRUE)
      ),
      ifelse(
        grepl("^[0-9]+$", player_id),
        paste0("https://a.espncdn.com/combiner/i?img=/i/headshots/nfl/players/full/", player_id, ".png"),
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

#' Clear the sdvplotR Image Cache
#'
#' @description sdvplotR renders images through 'ggpath', which caches
#'   downloaded images for the current session. This function clears that
#'   cache when 'ggpath' exposes a cache-clearing function and is a no-op
#'   otherwise.
#' @return Invisibly `NULL`, called for its side effect.
#' @export
#' @examples
#' sdvplotR_clear_cache()
sdvplotR_clear_cache <- function() {
  if ("clear_cache" %in% getNamespaceExports("ggpath")) {
    getExportedValue("ggpath", "clear_cache")()
    cli::cli_alert_success("sdvplotR image cache cleared.")
  }
  invisible(NULL)
}
