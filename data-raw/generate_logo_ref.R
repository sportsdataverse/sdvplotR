# Regenerate the internal team reference data (R/sysdata.rda)
# ============================================================================
#
# Sources:
#   * ESPN site API teams endpoints -- ids, abbreviations, names, colors, logos
#     (default / dark / scoreboard variants) for every league.
#   * ESPN core API group endpoints -- FBS / FCS / Division I membership and
#     conference for the college sports.
#   * nflreadr::load_teams() -- nflverse abbreviations, colors, wordmarks and
#     divisions for the NFL (the canonical NFL keys follow nflverse so that
#     nflfastR / nflreadr output plots without cleaning).
#
# Run from the package root:  Rscript data-raw/generate_logo_ref.R
# Requires: httr, jsonlite, nflreadr, usethis (dev-only, not package deps).

`%||%` <- function(x, y) if (is.null(x)) y else x

espn_get <- function(url) {
  resp <- httr::GET(url, httr::user_agent("Mozilla/5.0 (sdvplotR data-raw)"))
  httr::stop_for_status(resp)
  jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
}

espn_teams <- function(sport, league, slug) {
  j <- espn_get(sprintf(
    "https://site.web.api.espn.com/apis/site/v2/sports/%s/%s/teams?limit=1000",
    sport, league
  ))
  teams <- lapply(j$sports[[1]]$leagues[[1]]$teams, `[[`, "team")
  pick_logo <- function(logos, want, exclude = character()) {
    for (l in logos) {
      rel <- unlist(l$rel)
      if (all(want %in% rel) && !any(exclude %in% rel)) return(l$href)
    }
    NULL
  }
  hex <- function(x) if (is.null(x) || !nzchar(x)) NA_character_ else paste0("#", toupper(x))
  out <- lapply(teams, function(t) {
    data.frame(
      sport = slug,
      espn_team_id = as.integer(t$id),
      team_abbr = toupper(t$abbreviation),
      team_name = t$displayName,
      team_short_name = t$shortDisplayName %||% t$displayName,
      team_location = t$location %||% NA_character_,
      team_mascot = t$name %||% NA_character_,
      logo_url = pick_logo(t$logos, "default", "dark") %||% pick_logo(t$logos, character()) %||% NA_character_,
      logo_dark_url = pick_logo(t$logos, "dark", "scoreboard") %||% NA_character_,
      logo_scoreboard_url = pick_logo(t$logos, "scoreboard", "dark") %||% NA_character_,
      wordmark_url = NA_character_,
      color1 = hex(t$color),
      color2 = hex(t$alternateColor),
      conference = NA_character_,
      division = NA_character_,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, out)
  out[!is.na(out$logo_url), ]
}

# ids of the teams in an ESPN core-API group (FBS = 80, FCS = 81, D-I = 50),
# split by conference (the group's children)
core_group_membership <- function(sport, league, seasons, group) {
  base <- sprintf(
    "https://sports.core.api.espn.com/v2/sports/%s/leagues/%s/seasons/%%s/types/2/groups/%s",
    sport, league, group
  )
  for (season in seasons) {
    kids <- try(espn_get(sprintf(paste0(base, "/children?limit=100"), season)), silent = TRUE)
    if (inherits(kids, "try-error") || !length(kids$items)) next
    out <- lapply(kids$items, function(it) {
      ref <- sub("^http:", "https:", it$`$ref`)
      conf <- espn_get(ref)
      teams <- espn_get(sub("\\?.*$", "/teams?limit=1000", ref))
      ids <- vapply(teams$items, function(x) as.integer(sub(".*/teams/([0-9]+).*", "\\1", x$`$ref`)), integer(1))
      data.frame(espn_team_id = ids, conference = conf$shortName %||% conf$name, stringsAsFactors = FALSE)
    })
    message(league, " group ", group, ": season ", season, ", ", length(out), " conferences")
    return(do.call(rbind, out))
  }
  stop("no season found for ", league, " group ", group)
}

college <- function(sport, league, slug, groups, seasons) {
  d <- espn_teams(sport, league, slug)
  keep <- NULL
  for (g in names(groups)) {
    m <- core_group_membership(sport, league, seasons, groups[[g]])
    m$division <- g
    keep <- rbind(keep, m[!m$espn_team_id %in% keep$espn_team_id, ])
  }
  d <- d[d$espn_team_id %in% keep$espn_team_id, ]
  idx <- match(d$espn_team_id, keep$espn_team_id)
  d$conference <- keep$conference[idx]
  d$division <- keep$division[idx]
  dup <- duplicated(d$team_abbr)
  if (any(dup)) {
    message(slug, ": dropping duplicate abbreviation(s): ", paste(d$team_abbr[dup], collapse = ", "))
    d <- d[!dup, ]
  }
  d[order(d$team_abbr), ]
}

# ---------------------------------------------------------------------------
# Pro leagues
# ---------------------------------------------------------------------------

nfl <- espn_teams("football", "nfl", "nfl")
nflv <- as.data.frame(nflreadr::load_teams(current = TRUE))
# ESPN -> nflverse abbreviation differences
nfl$team_abbr <- ifelse(nfl$team_abbr == "WSH", "WAS", ifelse(nfl$team_abbr == "LAR", "LA", nfl$team_abbr))
idx <- match(nfl$team_abbr, nflv$team_abbr)
stopifnot(!anyNA(idx))
nfl$wordmark_url <- nflv$team_wordmark[idx]
nfl$color1 <- nflv$team_color[idx]
nfl$color2 <- nflv$team_color2[idx]
nfl$conference <- nflv$team_conf[idx]
nfl$division <- nflv$team_division[idx]

nba <- espn_teams("basketball", "nba", "nba")
nba_conf <- c(
  ATL = "Eastern", BOS = "Eastern", BKN = "Eastern", CHA = "Eastern", CHI = "Eastern",
  CLE = "Eastern", DET = "Eastern", IND = "Eastern", MIA = "Eastern", MIL = "Eastern",
  NY = "Eastern", ORL = "Eastern", PHI = "Eastern", TOR = "Eastern", WSH = "Eastern",
  DAL = "Western", DEN = "Western", GS = "Western", HOU = "Western", LAC = "Western",
  LAL = "Western", MEM = "Western", MIN = "Western", NO = "Western", OKC = "Western",
  PHX = "Western", POR = "Western", SAC = "Western", SA = "Western", UTAH = "Western"
)
nba$conference <- unname(nba_conf[nba$team_abbr])

wnba <- espn_teams("basketball", "wnba", "wnba")
wnba_conf <- c(
  ATL = "Eastern", CHI = "Eastern", CON = "Eastern", IND = "Eastern", NY = "Eastern",
  WSH = "Eastern", TOR = "Eastern",
  DAL = "Western", GS = "Western", LV = "Western", LA = "Western", MIN = "Western",
  PHX = "Western", SEA = "Western", POR = "Western"
)
wnba$conference <- unname(wnba_conf[wnba$team_abbr])

mlb <- espn_teams("baseball", "mlb", "mlb")
mlb_div <- c(
  BAL = "AL East", BOS = "AL East", NYY = "AL East", TB = "AL East", TOR = "AL East",
  CHW = "AL Central", CLE = "AL Central", DET = "AL Central", KC = "AL Central", MIN = "AL Central",
  ATH = "AL West", HOU = "AL West", LAA = "AL West", SEA = "AL West", TEX = "AL West",
  ATL = "NL East", MIA = "NL East", NYM = "NL East", PHI = "NL East", WSH = "NL East",
  CHC = "NL Central", CIN = "NL Central", MIL = "NL Central", PIT = "NL Central", STL = "NL Central",
  ARI = "NL West", COL = "NL West", LAD = "NL West", SD = "NL West", SF = "NL West"
)
mlb$division <- unname(mlb_div[mlb$team_abbr])
mlb$conference <- substr(mlb$division, 1, 2)

nhl <- espn_teams("hockey", "nhl", "nhl")
nhl_div <- c(
  BOS = "Atlantic", BUF = "Atlantic", DET = "Atlantic", FLA = "Atlantic", MTL = "Atlantic",
  OTT = "Atlantic", TB = "Atlantic", TOR = "Atlantic",
  CAR = "Metropolitan", CBJ = "Metropolitan", NJ = "Metropolitan", NYI = "Metropolitan",
  NYR = "Metropolitan", PHI = "Metropolitan", PIT = "Metropolitan", WSH = "Metropolitan",
  CHI = "Central", COL = "Central", DAL = "Central", MIN = "Central", NSH = "Central",
  STL = "Central", UTAH = "Central", WPG = "Central",
  ANA = "Pacific", CGY = "Pacific", EDM = "Pacific", LA = "Pacific", SJ = "Pacific",
  SEA = "Pacific", VAN = "Pacific", VGK = "Pacific"
)
nhl$division <- unname(nhl_div[nhl$team_abbr])
nhl$conference <- ifelse(nhl$division %in% c("Atlantic", "Metropolitan"), "Eastern", "Western")

pro <- rbind(nfl, nba, wnba, mlb, nhl)
if (anyNA(pro$conference)) {
  print(pro[is.na(pro$conference), c("sport", "team_abbr", "team_name")])
  stop("pro teams above are missing from the conference/division maps")
}
pro <- pro[order(pro$sport, pro$team_abbr), ]

# ---------------------------------------------------------------------------
# College: FBS + FCS football, Division I basketball
# ---------------------------------------------------------------------------

yr <- as.integer(format(Sys.Date(), "%Y"))
cfb <- college("football", "college-football", "cfb", c(FBS = 80, FCS = 81), c(yr, yr - 1))
mbb <- college("basketball", "mens-college-basketball", "mbb", c("D-I" = 50), c(yr + 1, yr))
wbb <- college("basketball", "womens-college-basketball", "wbb", c("D-I" = 50), c(yr + 1, yr))

logo_ref <- rbind(pro, cfb, mbb, wbb)
rownames(logo_ref) <- NULL
stopifnot(!anyNA(logo_ref$team_abbr), !anyNA(logo_ref$logo_url))
message(sum(is.na(logo_ref$color1)), " team(s) without a primary color on ESPN (kept as NA)")

# ---------------------------------------------------------------------------
# Abbreviation mapping: every key (upper case) -> canonical team_abbr.
# Keys: canonical abbr, full name, short name, location, and hand-curated
# aliases used by other data providers (ESPN vs nflverse, Basketball-Reference,
# Retrosheet, hockey-reference, ...).
# ---------------------------------------------------------------------------

aliases <- list(
  nfl = c(
    WSH = "WAS", LAR = "LA", JAC = "JAX", GNB = "GB", KAN = "KC", NWE = "NE", NOR = "NO",
    SFO = "SF", TAM = "TB", LVR = "LV", ARZ = "ARI", BLT = "BAL", CLV = "CLE", HST = "HOU",
    WFT = "WAS"
  ),
  nba = c(
    GSW = "GS", NOP = "NO", NYK = "NY", SAS = "SA", UTA = "UTAH", WAS = "WSH", PHO = "PHX",
    BRK = "BKN", CHO = "CHA", CHH = "CHA", NOR = "NO"
  ),
  wnba = c(
    CONN = "CON", WAS = "WSH", GSV = "GS", LVA = "LV", LAS = "LA", NYL = "NY", PHO = "PHX"
  ),
  mlb = c(
    CWS = "CHW", WAS = "WSH", KCR = "KC", SDP = "SD", SFG = "SF", TBR = "TB", OAK = "ATH",
    ANA = "LAA", LAN = "LAD", SLN = "STL", NYA = "NYY", NYN = "NYM", CHA = "CHW", CHN = "CHC",
    KCA = "KC", SDN = "SD", SFN = "SF", TBA = "TB", ARZ = "ARI"
  ),
  nhl = c(
    WAS = "WSH", LAK = "LA", NJD = "NJ", SJS = "SJ", TBL = "TB", VEG = "VGK", MON = "MTL",
    UTA = "UTAH", CLB = "CBJ", NAS = "NSH", WIN = "WPG"
  ),
  cfb = character(), mbb = character(), wbb = character()
)

abbr_mapping <- lapply(split(logo_ref, logo_ref$sport), function(d) {
  keys <- c(
    d$team_abbr,
    toupper(d$team_name),
    toupper(d$team_short_name),
    toupper(d$team_location)
  )
  vals <- rep(d$team_abbr, 4)
  keep <- !is.na(keys) & !duplicated(keys)
  m <- stats::setNames(vals[keep], keys[keep])
  al <- aliases[[d$sport[1]]]
  al <- al[!names(al) %in% names(m)]
  stopifnot(all(al %in% d$team_abbr))
  c(m, al)
})

# sysdata.rda also holds the NFL headshot crosswalk built by
# data-raw/nfl_headshot_ids.R; carry it over rather than dropping it
nfl_headshot_ids <- local({
  sys <- new.env()
  load("R/sysdata.rda", envir = sys)
  sys$nfl_headshot_ids
})
stopifnot(!is.null(nfl_headshot_ids))
usethis::use_data(logo_ref, abbr_mapping, nfl_headshot_ids, internal = TRUE, overwrite = TRUE)

cat("logo_ref:", nrow(logo_ref), "teams\n")
print(table(logo_ref$sport, logo_ref$division, useNA = "ifany"))
