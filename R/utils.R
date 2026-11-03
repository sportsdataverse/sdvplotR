# Utility functions for sdvplotR
# ============================================================================

headshot_placeholder <- "https://a.espncdn.com/i/headshots/nophoto.png"

`%||%` <- function(x, y) if (is.null(x)) y else x

is_installed <- function(pkg) requireNamespace(pkg, quietly = TRUE)

# ---------------------------------------------------------------------------
# Image and name lookups behind every geom, element and table helper. Team
# values resolve through the index (sdv_resolve()'s rules, plus conference and
# league keys); marks come from the logo manifest (R/marks.R).
# ---------------------------------------------------------------------------

logo_from_team <- function(team, league, season = NULL, variant = "default", id_system = "auto", strict = FALSE) {
  mark_url(team, league, season, variant, "logo", id_system, strict, call = rlang::caller_env())
}

wordmark_from_team <- function(team, league, season = NULL, variant = "default", id_system = "auto", strict = FALSE) {
  mark_url(team, league, season, variant, "wordmark", id_system, strict, call = rlang::caller_env())
}

# Alt text for an image: the team's full name, or the value itself where it
# does not resolve (the image helper has already warned about it).
team_alt <- function(team, league, season = NULL, id_system = "auto") {
  ids <- resolve_ids(team, league, season, id_system, marks = TRUE)$ids
  t <- sdv_teams(league, include_conferences = TRUE)
  nm <- t$name[match(ids, t$team_id)]
  ifelse(is.na(nm), as.character(team), nm)
}

# For a lookup whose caller handles a miss itself (shows the text, aborts with
# its own message): quiet the unresolved and no-mark warnings only. A blanket
# suppressWarnings() would also eat the once-per-session sdvplotR_fallback
# warning, which then never shows.
quiet_miss <- function(expr) {
  muffle <- function(w) invokeRestart("muffleWarning")
  withCallingHandlers(expr, sdvplotR_unresolved_warning = muffle, sdvplotR_no_mark_warning = muffle)
}

# A team or player id as text: as.character() writes 4000000 as "4e+06";
# sprintf() is exact for every whole number a double holds.
id_chr <- function(x) {
  if (!is.numeric(x)) {
    return(as.character(x))
  }
  ifelse(!is.na(x) & is.finite(x) & x == trunc(x), sprintf("%.0f", x), as.character(x))
}

headshot_alt <- function(id) paste0("Player ", id, " headshot")

# The shared tail of the image geoms' draw_panel: drop rows with no image (they
# have already warned), shrink each image to `max_px` on its longer side when
# asked, and let ggpath draw. ggiraph embeds every image in the page at its
# source size (an ESPN logo is 500 px and 20-60 KB, a headshot ~270 KB), so the
# interactive geoms ask for small copies; the static geoms draw the source.
draw_image_panel <- function(data, panel_params, coord, na.rm, max_px = NULL) {
  data <- data[!is.na(data$path), , drop = FALSE]
  if (!nrow(data)) {
    return(ggplot2::zeroGrob())
  }
  if (!is.null(max_px)) {
    data$path <- small_images(data$path, max_px)
  }
  ggpath::GeomFromPath$draw_panel(data = data, panel_params = panel_params, coord = coord, na.rm = na.rm)
}

# A copy of the image at `path` no larger than px x px, as a PNG in this
# session's temp directory (made once per image and size). An image that
# cannot be read is left to ggpath, which handles (and reports) it as usual.
# An SVG is vector, so it is left as it is (and magick warns reading one
# without librsvg).
small_image <- function(path, px) {
  if (grepl("\\.svg$", path, ignore.case = TRUE)) {
    return(path)
  }
  out <- file.path(tempdir(), "sdvplotR-images", paste0(rlang::hash(list(path, px)), ".png"))
  if (file.exists(out)) {
    return(out)
  }
  img <- tryCatch(magick::image_read(path), error = function(e) NULL)
  if (is.null(img)) {
    return(path)
  }
  dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
  magick::image_write(magick::image_scale(img, sprintf("%dx%d>", px, px)), out, format = "png")
  out
}

# small_image() for each path, once per distinct one; NA stays NA
small_images <- function(paths, px) {
  ok <- !is.na(paths)
  u <- unique(paths[ok])
  paths[ok] <- vapply(u, small_image, character(1), px = px, USE.NAMES = FALSE)[match(paths[ok], u)]
  paths
}

# ---------------------------------------------------------------------------
# Headshots
# ---------------------------------------------------------------------------

espn_slug <- c(
  nfl = "nfl", nba = "nba", wnba = "wnba", mlb = "mlb", nhl = "nhl",
  cfb = "college-football", mbb = "mens-college-basketball",
  wbb = "womens-college-basketball",
  # ESPN files G League photos under nba/ (nba-development/ 404s): G League
  # and NBA athletes share one ESPN id space
  nbagl = "nba", soccer = "soccer"
)

espn_headshot_url <- function(espn_id, league) {
  paste0("https://a.espncdn.com/combiner/i?img=/i/headshots/", espn_slug[[league]], "/players/full/", espn_id, ".png")
}

# Headshots keyed by the league's own player id (NBA / WNBA Stats PERSON_ID,
# MLBAM, NHL API, HockeyTech player_id). An unknown NBA / WNBA / MLB / NHL id
# gets the CDN's silhouette, not a 404. cdn.nba.com and cdn.wnba.com answer 403
# to datacenter IPs. HockeyTech's leaguestat CDN answers 404 for an unknown id
# (the roster feed's "nophoto" placeholder is the feed's, not the CDN's), as
# ESPN does: the ggplot geoms skip those with a warning, and the gt / reactable
# / ggtext helpers show a broken image, as for any missing image.
hockeytech_headshot_url <- function(client) {
  paste0("https://assets.leaguestat.com/", client, "/240x240/%s.jpg")
}

league_headshot_url <- c(
  nba = "https://cdn.nba.com/headshots/nba/latest/260x190/%s.png",
  wnba = "https://cdn.wnba.com/headshots/wnba/latest/260x190/%s.png",
  mlb = paste0(
    "https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/",
    "w_213,q_auto:best/v1/people/%s/headshot/67/current.png"
  ),
  nhl = "https://assets.nhle.com/mugs/nhl/latest/%s.png",
  pwhl = hockeytech_headshot_url("pwhl"),
  ahl = hockeytech_headshot_url("ahl"),
  echl = hockeytech_headshot_url("echl"),
  ohl = hockeytech_headshot_url("ohl"),
  whl = hockeytech_headshot_url("whl"),
  qmjhl = hockeytech_headshot_url("lhjmq"), # HockeyTech's client code for the QMJHL
  ushl = hockeytech_headshot_url("ushl"),
  # the junior and minor leagues, each under its own key as client code
  sphl = hockeytech_headshot_url("sphl"),
  chl = hockeytech_headshot_url("chl"),
  bchl = hockeytech_headshot_url("bchl"),
  ajhl = hockeytech_headshot_url("ajhl"),
  sjhl = hockeytech_headshot_url("sjhl"),
  ojhl = hockeytech_headshot_url("ojhl"),
  cchl = hockeytech_headshot_url("cchl"),
  gojhl = hockeytech_headshot_url("gojhl"),
  mhl = hockeytech_headshot_url("mhl"),
  nojhl = hockeytech_headshot_url("nojhl"),
  vijhl = hockeytech_headshot_url("vijhl"),
  kijhl = hockeytech_headshot_url("kijhl"),
  mjhl = hockeytech_headshot_url("mjhl")
)

# Other providers' player ids, each read through sdv-reference-data's
# {league}_player_aliases (CONTRACT.md), which maps a source's player id to the
# ESPN athlete id: the headshot is that athlete's ESPN headshot
player_alias_sources <- list(
  nfl = c("fox", "yahoo", "cbs"),
  cfb = c("fox", "yahoo", "cbs", "ncaa"),
  nba = c("fox", "yahoo", "nba_stats"),
  wnba = c("fox", "yahoo", "wnba_stats"),
  mbb = c("fox", "yahoo", "kenpom", "ncaa"),
  wbb = c("fox", "yahoo", "ncaa")
)
provider_id_systems <- unique(unlist(player_alias_sources, use.names = FALSE))

# "espn" (ESPN athlete ids, the default in every league), "gsis" (nflverse's
# NFL ids), "league" (the league's own ids; the NFL's league id is the gsis id)
# or a player_alias_sources provider
check_id_system <- function(id_system, league, call = rlang::caller_env()) {
  id_system <- rlang::arg_match0(id_system, c("espn", "gsis", "league", provider_id_systems), error_call = call)
  if (id_system %in% provider_id_systems && !id_system %in% player_alias_sources[[league]]) {
    has <- vapply(player_alias_sources, function(s) id_system %in% s, logical(1))
    with_ids <- names(player_alias_sources)[has] # nolint: object_usage_linter. used in the cli message below
    cli::cli_abort(
      "{.code id_system = \"{id_system}\"} player ids map to ESPN athletes in {.val {with_ids}} only.",
      call = call
    )
  }
  if (id_system == "espn" && !league %in% names(espn_slug)) {
    cli::cli_abort(c(
      "No ESPN headshots for {.val {league}}; they exist for {.val {names(espn_slug)}}.",
      i = if (league %in% names(league_headshot_url)) {
        "Use the league's own player ids with {.code id_system = \"league\"}."
      }
    ), call = call)
  }
  if (id_system == "gsis" && league != "nfl") {
    cli::cli_abort("{.code id_system = \"gsis\"} takes NFL ids (nflverse's gsis ids) only.", call = call)
  }
  if (id_system == "league" && !league %in% c("nfl", names(league_headshot_url))) {
    cli::cli_abort(c(
      "{.val {league}} headshots are not available by league player id.",
      i = "Use ESPN athlete ids with {.code id_system = \"espn\"}."
    ), call = call)
  }
  if (id_system == "league" && league == "nfl") "gsis" else id_system
}

headshot_from_id <- function(player_id, league, id_system = "espn") {
  # as.character() writes 4000000 as "4e+06"; sprintf() is exact for every
  # integer a double holds. A fraction (2544.7) is a malformed id, NA.
  player_id <- if (is.numeric(player_id)) {
    whole <- !is.na(player_id) & player_id == floor(player_id)
    ifelse(whole, sprintf("%.0f", player_id), NA_character_)
  } else {
    as.character(player_id)
  }
  numeric_id <- grepl("^[0-9]+$", player_id)
  url <- if (id_system == "espn") {
    ifelse(numeric_id, espn_headshot_url(player_id, league), NA_character_)
  } else if (id_system == "gsis") {
    # gsis ids resolve through the headshot map (load_headshot_map()): NFL.com's
    # image where the roster has one, else the player's ESPN headshot
    map <- load_headshot_map()
    i <- match(player_id, map$gsis_id)
    nfl <- map$headshot_nfl[i]
    espn <- map$espn_id[i]
    ifelse(!is.na(nfl), nfl_headshot_url(nfl), ifelse(!is.na(espn), espn_headshot_url(espn, "nfl"), NA_character_))
  } else if (id_system %in% provider_id_systems) {
    map <- load_player_alias_map(league, id_system)
    espn <- map$athlete_id[match(player_id, map$source_player_id)]
    ifelse(grepl("^[0-9]+$", espn), espn_headshot_url(espn, league), NA_character_) # grepl(NA) is FALSE
  } else {
    ifelse(numeric_id, sprintf(league_headshot_url[[league]], player_id), NA_character_)
  }
  url[is.na(player_id) | player_id == ""] <- NA_character_
  unname(url)
}

# nolint start: line_length_linter. table rows cannot wrap
#' Player headshot URLs
#'
#' @description The headshot image URL for player ids, as every sdvplotR
#'   headshot helper draws it. The R counterpart of sdvplot's `headshot_url()`.
#' @param player_id A vector of player ids.
#' @inheritParams sdv_resolve
#' @param id_system `"espn"` (ESPN athlete ids; the default, for every
#'   league with ESPN headshots), `"gsis"` (nflverse's NFL gsis ids, such as
#'   `"00-0033873"`, read through a published map), `"league"` (the league's
#'   own player id), or another provider's player id, drawn as the ESPN
#'   athlete's headshot: `"fox"`, `"yahoo"`, `"cbs"`, `"kenpom"`, `"ncaa"`
#'   (stats.ncaa.org), `"nba_stats"` or `"wnba_stats"`. The details of
#'   [sdv_headshot_url()] list which leagues take which.
#' @return A character vector the length of `player_id`: the URL, or `NA` for
#'   a missing or malformed id or (gsis, a provider) one not in its map. The URL is built
#'   from the id alone, so an id the CDN has no photo for still gets one: ESPN
#'   and HockeyTech answer it with a 404, which the ggplot geoms skip with a
#'   warning and the gt, reactable and ggtext helpers show as a broken image;
#'   the NBA, WNBA, MLB and NHL CDNs serve a silhouette.
#' @details
#' Headshots by league and `id_system`:
#'
#' | League | `"espn"` | `"league"` |
#' |---|---|---|
#' | nfl | ESPN athlete id | gsis id (as `"gsis"`) |
#' | nba, wnba | ESPN athlete id | NBA / WNBA Stats `PERSON_ID` |
#' | mlb | ESPN athlete id | MLBAM id |
#' | nhl | ESPN athlete id | NHL API player id |
#' | nbagl | ESPN athlete id (the NBA's id space) | none |
#' | soccer | ESPN athlete id | none |
#' | cfb, mbb, wbb | ESPN athlete id | none |
#' | pwhl, ahl, echl, ohl, whl, qmjhl, ushl | none | HockeyTech `player_id` |
#' | sphl, chl, bchl, ajhl, sjhl, ojhl, cchl, gojhl, mhl, nojhl, vijhl, kijhl, mjhl | none | HockeyTech `player_id` |
#'
#' ESPN files G League photos with the NBA's, so a G League player's ESPN id
#' is the one ESPN uses for him in the NBA. ESPN has photos for only part of
#' the G League and soccer rosters. The HockeyTech leagues' images come from
#' the leagues' stats provider's CDN (`assets.leaguestat.com`), keyed by the
#' `player_id` in their HockeyTech feeds. Other leagues have no headshots;
#' F1 drivers have none because formula1.com keys its photos by its own driver
#' reference (`MAXVER01`), not a driver number or Jolpica `driver_id`.
#'
#' Other providers' player ids map to ESPN athlete ids through
#' sdv-reference-data's `{league}_player_aliases` tables (the
#' sportsdataverse-data `{league}_groups` releases), and draw that athlete's
#' ESPN headshot. The map for a league and provider is downloaded when first
#' needed and kept for the session; an id it does not hold is `NA`.
#'
#' | League | Provider `id_system` |
#' |---|---|
#' | nfl | `"fox"`, `"yahoo"`, `"cbs"` |
#' | cfb | `"fox"`, `"yahoo"`, `"cbs"`, `"ncaa"` |
#' | nba | `"fox"`, `"yahoo"`, `"nba_stats"` |
#' | wnba | `"fox"`, `"yahoo"`, `"wnba_stats"` |
#' | mbb | `"fox"`, `"yahoo"`, `"kenpom"`, `"ncaa"` |
#' | wbb | `"fox"`, `"yahoo"`, `"ncaa"` |
#' @seealso [sdv_logo_url()].
#' @export
#' @examples
#' sdv_headshot_url(3139477, "nfl")
#' sdv_headshot_url("2544", "nba", id_system = "league")
#' sdv_headshot_url(52, "pwhl", id_system = "league")
#' \donttest{
#' # nflverse gsis ids read the published headshot map
#' sdv_headshot_url("00-0033873", "nfl", id_system = "gsis")
#' }
# nolint end
sdv_headshot_url <- function(player_id, league, id_system = "espn") {
  check_league(league)
  headshot_from_id(player_id, league, check_id_system(id_system, league))
}

# HTML helpers for axis labels rendered through ggtext::element_markdown()
logo_html <- function(team, league, type = c("height", "width"), size = 15, season = NULL, id_system = "auto") {
  img_html(logo_from_team(team, league, season = season, id_system = id_system), team, rlang::arg_match(type), size)
}

headshot_html <- function(player_id, league, type = c("height", "width"), size = 25, id_system = "espn") {
  img_html(headshot_from_id(player_id, league, id_system), player_id, rlang::arg_match(type), size)
}

# An axis label's <img>, `size` px on one side, from a copy at most 4 x size
# px a side: the label never draws it larger (sharp up to ~380 dpi), and an SVG
# device (ggiraph, svglite) writes the image into the file, where a source logo
# is 20-60 KB. Forward slashes: markdown reads a backslash in a path as an escape.
img_html <- function(urls, label, type, size) {
  ok <- !is.na(urls)
  urls <- chartr("\\", "/", small_images(urls, ceiling(4 * as.numeric(size))))
  ifelse(ok, sprintf("<img src='%s' %s = '%s'>", urls, type, size), label)
}

# NFL headshot map: sdvplotR publishes it from nflverse rosters (1999 onward) to
# its sdvplotr_infrastructure release (data-raw/update_headshot_gsis_map.R) and
# reads it once per session. Only a good read is cached, so a failed one retries
# on the next call. Offline, the read warns and returns no rows, so every NFL id
# resolves to NA and the helpers fall back as they do for any unknown id.
headshot_map_url <- paste0(
  "https://github.com/sportsdataverse/sdvplotR/releases/download/",
  "sdvplotr_infrastructure/headshot_gsis_map.rds"
)

headshot_map_cache <- new.env(parent = emptyenv())

load_headshot_map <- function() {
  if (!is.null(headshot_map_cache$map)) {
    return(headshot_map_cache$map)
  }
  empty <- data.frame(gsis_id = character(), headshot_nfl = character(), espn_id = character())
  # offline (sdvplotR.offline, or a CRAN check) the map is never fetched
  if (use_snapshot()) {
    return(empty)
  }
  map <- read_rds_url(headshot_map_url)
  if (!is.data.frame(map) || !nrow(map) ||
      !all(c("gsis_id", "headshot_nfl", "espn_id") %in% names(map))) {
    return(empty)
  }
  headshot_map_cache$map <- map
  map
}

forget_headshot_map <- function() {
  headshot_map_cache$map <- NULL
  rm(list = ls(player_alias_cache), envir = player_alias_cache)
  invisible(NULL)
}

# Provider player id -> ESPN athlete id maps, one per (league, source):
# data-raw/update_player_alias_maps.R publishes them from the
# sportsdataverse-data {league}_player_aliases tables (cfb's alone has 421k
# rows, too many to bundle) to the sdvplotr_infrastructure release. Each is read
# when first needed and kept for the session; offline, and on a failed read
# (which warns and retries on the next call), it has no rows, so every id is NA.
# A source with no ids in a league yet is published as an empty map.
player_alias_map_url <- function(league, source) {
  paste0(
    "https://github.com/sportsdataverse/sdvplotR/releases/download/",
    "sdvplotr_infrastructure/player_aliases_", league, "_", source, ".rds"
  )
}

player_alias_cache <- new.env(parent = emptyenv())

load_player_alias_map <- function(league, source) {
  key <- paste0(league, "_", source)
  if (!is.null(player_alias_cache[[key]])) {
    return(player_alias_cache[[key]])
  }
  empty <- data.frame(source_player_id = character(), athlete_id = character())
  if (use_snapshot()) {
    return(empty)
  }
  map <- read_rds_url(player_alias_map_url(league, source))
  # an empty map is a good read (the source has no ids there yet, as mbb / wbb
  # Yahoo), kept like any other; only a failed read is retried
  if (!is.data.frame(map) || !all(names(empty) %in% names(map))) {
    return(empty)
  }
  player_alias_cache[[key]] <- map
  map
}

# readRDS() of a remote .rds. Any failure, opening the connection (offline, a
# 404) or reading it, warns and returns NULL rather than erroring: CRAN checks
# may run without network. gzcon() explicitly: readRDS() only gunzips a
# connection whose class is "url", and url() on a file:// address returns a
# "file" connection. gzcon() handles gzip (saveRDS()'s default, which
# data-raw/update_headshot_gsis_map.R uses) and plain streams, not xz or bzip2.
read_rds_url <- function(url) {
  fail <- function(e) {
    cli::cli_warn("Failed to read {.url {url}}: {conditionMessage(e)}")
    NULL
  }
  con <- tryCatch(suppressWarnings(gzcon(url(url, "rb"))), error = fail)
  if (is.null(con)) {
    return(NULL)
  }
  on.exit(close(con), add = TRUE)
  tryCatch(readRDS(con), error = fail)
}

# NFL.com image at the sized headshot transform rather than the full-size
# f_auto,q_auto the roster stores (42-56 KB instead of up to 3.4 MB), with the
# .png that nflplotR also appends: gridtext, behind the headshot axis scales,
# picks its image reader by file extension
nfl_headshot_url <- function(url) {
  url <- sub("/f_auto,q_auto/", "/t_headshot_desktop/f_auto/", url, fixed = TRUE)
  ifelse(grepl("\\.png$", url), url, paste0(url, ".png"))
}

# Screenshots a gt table to `filename` through headless Chrome, as
# gtExtras::gtsave_extra() did (without taking gtExtras and its paletteer
# subtree as a dependency): the table is saved as a standalone HTML page and
# webshot2 captures it, padded by `expand` pixels. webshot2's progress chatter
# goes to stderr, so it is captured rather than printed.
gt_webshot <- function(data, filename, zoom = 2, expand = 5) {
  rlang::check_installed("webshot2", reason = "to save a `gt` table as an image.")
  html <- tempfile(fileext = ".html")
  on.exit(unlink(html), add = TRUE)
  htmltools::save_html(htmltools::as.tags(data), html)
  utils::capture.output(
    webshot2::webshot(
      paste0("file:///", gsub("\\", "/", html, fixed = TRUE)),
      file = filename, zoom = zoom, expand = expand
    ),
    type = "message"
  )
  invisible(filename)
}

# Runs a save that launches headless Chrome (gt_webshot(),
# webshot2::webshot()) with chromote given at least `seconds` to open Chrome's
# debugging port. chromote's default is 10 seconds, which a loaded machine (a CI
# runner building the articles) misses: "Chrome debugging port not open after
# 10 seconds". A longer setting the user already made is kept; the option is
# restored afterwards. chromote reads it when it launches Chrome, so it matters
# for the first save of a session.
with_chrome_timeout <- function(expr, seconds = 60) {
  old <- options(chromote.timeout = max(seconds, getOption("chromote.timeout", 10)))
  on.exit(options(old), add = TRUE)
  force(expr)
}
