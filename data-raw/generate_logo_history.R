# Build the internal season-aware logo table (logo_history in R/sysdata.rda)
# ============================================================================
#
# One row per (sport, key, variant) era: the mark a team wore for seasons
# season_from..season_to. `url` is the immutable content-addressed copy in the
# sportsdataverse/sdv-assets archive (DigitalOcean Spaces CDN), never the
# original: ESPN and the NHL overwrite files in place (ESPN's wnba por.png now
# holds the 2026 Portland Fire).
#
# Sources:
#   * sdv-assets manifest/marks.csv
#     - NHL: the NHL records API logo catalog (source "nhl"), every club's
#       marks by season range since 1917-18, light and dark, keyed by the NHL
#       triCode of that identity (QUE, HFD, TBL). Seasons are ENDING years.
#     - NFL / WNBA: ESPN's frozen logos of relocated and defunct identities
#       (source "espn", a.espncdn.com/i/teamlogos/{nfl,wnba}/500[-dark]/{abbr}.png).
#       The manifest has no seasons for these; data-raw/logo_history_legacy.csv
#       holds them (single-year seasons) with a source note per row.
#   * api.nhle.com/stats/rest/en/team -- the full name of each NHL team id.
#
# Run from the package root, after data-raw/generate_logo_ref.R (the canonical
# keys come from abbr_mapping):  Rscript data-raw/generate_logo_history.R
# Requires: pkgload, jsonlite, usethis (dev-only, not package deps).

pkgload::load_all(".", quiet = TRUE)
logo_ref <- sdvplotR:::logo_ref
abbr_mapping <- sdvplotR:::abbr_mapping
logo_marks <- sdvplotR:::logo_marks

manifest_url <- "https://raw.githubusercontent.com/sportsdataverse/sdv-assets/main/manifest/marks.csv"
marks <- utils::read.csv(manifest_url, colClasses = "character", na.strings = "")
cdn <- "https://sdv.nyc3.cdn.digitaloceanspaces.com/"

# ---------------------------------------------------------------------------
# NHL
# ---------------------------------------------------------------------------

nhl <- marks[marks$source == "nhl" & marks$level == "team", ]
# LNH is the league's French-language shield (records API team 99), not a club
nhl <- nhl[nhl$entity_name != "LNH", ]
# the catalog files end _light (primary), _dark, _alt (secondary marks) or
# _black (a third jersey); only the primary and dark marks are kept
suffix <- sub("^.*_([a-z]+)\\.svg$", "\\1", nhl$url)
nhl$variant <- c(light = "primary", dark = "dark")[suffix]
nhl <- nhl[!is.na(nhl$variant), ]

teams <- jsonlite::fromJSON("https://api.nhle.com/stats/rest/en/team")$data
nhl$identity_name <- teams$fullName[match(as.integer(nhl$entity_id), teams$id)]
stopifnot(!anyNA(nhl$identity_name))

nhl$season_from <- as.integer(nhl$valid_from)
nhl$season_to <- as.integer(nhl$valid_to)
stopifnot(!anyNA(nhl$season_from), all(nhl$season_from <= nhl$season_to))

# The catalog's eras overlap where a new mark starts (CHI 1999, DAL 2013), where
# one window is off by a season (the Mammoth listed from 2024-25, when the club
# was the Utah Hockey Club) and where a defunct club's last mark is listed twice
# (ARI_light.svg beside the dated file). Each season gets the narrowest era
# covering it, a dated file before an undated one.
seasons <- lapply(seq_len(nrow(nhl)), function(i) nhl$season_from[i]:nhl$season_to[i])
by_season <- nhl[rep(seq_len(nrow(nhl)), lengths(seasons)), ]
by_season$season <- unlist(seasons)
by_season <- by_season[order(
  by_season$season_to - by_season$season_from,
  !grepl("_[0-9]{8}", by_season$url)
), ]
by_season <- by_season[!duplicated(by_season[c("entity_name", "variant", "season")]), ]

# back into runs of consecutive seasons with the same mark
by_season <- by_season[order(by_season$entity_name, by_season$variant, by_season$season), ]
run <- cumsum(c(TRUE, diff(by_season$season) != 1 |
  utils::head(by_season$archive_url, -1) != utils::tail(by_season$archive_url, -1) |
  utils::head(by_season$entity_name, -1) != utils::tail(by_season$entity_name, -1) |
  utils::head(by_season$variant, -1) != utils::tail(by_season$variant, -1)))
nhl_history <- do.call(rbind, lapply(split(by_season, run), function(r) {
  data.frame(
    sport = "nhl",
    key = r$entity_name[1],
    season_from = min(r$season),
    season_to = max(r$season),
    variant = r$variant[1],
    url = r$archive_url[1],
    identity_name = r$identity_name[1]
  )
}))

# Eras of a current identity whose triCode is not sdvplotR's key (TBL -> TB,
# NJD -> NJ, LAK -> LA, SJS -> SJ, UTA -> UTAH) are keyed by both. Historical
# identities (QUE, HFD, ATL) keep only their own key, so the Avalanche's key
# never draws a Nordiques mark.
current <- unique(nhl_history$key[nhl_history$season_to == max(nhl_history$season_to)])
canonical <- abbr_mapping$nhl[current]
stopifnot(!anyNA(canonical), all(canonical %in% logo_ref$team_abbr[logo_ref$sport == "nhl"]))
renamed <- canonical[canonical != current]
message("NHL triCodes also keyed by sdvplotR's abbreviation: ", paste(names(renamed), renamed, sep = " -> ", collapse = ", "))
extra <- nhl_history[nhl_history$key %in% names(renamed), ]
extra$key <- unname(renamed[extra$key])
nhl_history <- rbind(nhl_history, extra)

# A club's current era is left out: its season then resolves to today's logo
# (ESPN's PNG, the same mark), so only true historical eras need rsvg.
nhl_history <- nhl_history[nhl_history$season_to < max(nhl_history$season_to), ]

# ---------------------------------------------------------------------------
# NFL / WNBA relocated and defunct identities (ESPN's frozen statics)
# ---------------------------------------------------------------------------

# The Oakland Raiders (nfl/500/oak.png) are left out: ESPN's file is the
# current Raiders shield, only re-encoded.
legacy <- utils::read.csv("data-raw/logo_history_legacy.csv", colClasses = "character")
espn <- marks[marks$source == "espn" & marks$level == "team", ]
espn_file <- function(sport, abbr, folder) {
  sprintf("https://a.espncdn.com/i/teamlogos/%s/%s/%s.png", sport, folder, abbr)
}

legacy_history <- do.call(rbind, lapply(seq_len(nrow(legacy)), function(i) {
  l <- legacy[i, ]
  mark <- espn[espn$league == l$sport & espn$url %in% espn_file(l$sport, l$espn_abbr, c("500", "500-dark")), ]
  if (!nrow(mark)) {
    message("dropping ", l$sport, " ", l$key, ": not in the manifest")
    return(NULL)
  }
  # the identity's mark must differ from today's franchise's (SD vs LAC, DET vs DAL)
  now <- logo_from_team(l$key, l$sport)
  now_sha <- espn$sha256[match(now, espn$url)]
  if (!is.na(now) && is.na(now_sha)) stop("today's ", now, " is not in the manifest")
  if (!is.na(now) && now_sha %in% mark$sha256) {
    message("dropping ", l$sport, " ", l$key, ": same image as today's ", now)
    return(NULL)
  }
  data.frame(
    sport = l$sport,
    key = l$key,
    season_from = as.integer(l$season_from),
    season_to = as.integer(l$season_to),
    variant = ifelse(grepl("/500-dark/", mark$url), "dark", "primary"),
    url = mark$archive_url,
    identity_name = l$identity_name
  )
}))

# ---------------------------------------------------------------------------
# Checks and save
# ---------------------------------------------------------------------------

logo_history <- rbind(nhl_history, legacy_history)
logo_history <- logo_history[order(logo_history$sport, logo_history$key, logo_history$variant, logo_history$season_from), ]
rownames(logo_history) <- NULL

stopifnot(
  !anyNA(logo_history),
  startsWith(logo_history$url, cdn),
  logo_history$variant %in% c("primary", "dark"),
  logo_history$key == toupper(logo_history$key)
)
# one mark per sport, key, variant and season
prev_to <- with(logo_history, ave(season_to, sport, key, variant, FUN = function(x) c(-Inf, utils::head(x, -1))))
stopifnot(all(logo_history$season_from > prev_to))
# every key with a dark era has a primary one (the resolver falls back to it)
stopifnot(all(with(logo_history, paste(sport, key)[variant == "dark"] %in% paste(sport, key)[variant == "primary"])))

usethis::use_data(
  logo_ref, abbr_mapping, logo_history, logo_marks,
  internal = TRUE, overwrite = TRUE, compress = "xz"
)

print(table(logo_history$sport, logo_history$variant))
