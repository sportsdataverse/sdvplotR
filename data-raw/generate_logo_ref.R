# Regenerate the internal team reference data (R/sysdata.rda)
# ============================================================================
#
# Sources:
#   * ESPN site API teams endpoints -- ids, abbreviations, names, colors, logos
#     (default / dark / scoreboard variants) for every league.
#   * ESPN core API group endpoints -- FBS / FCS / Division I membership,
#     conference, and each conference's name and logo for the college sports.
#   * cbbplotR (Andrew Weatherman, MIT) -- conference colors, copied below.
#   * nflreadr::load_teams() -- nflverse abbreviations, colors, wordmarks and
#     divisions for the NFL (the canonical NFL keys follow nflverse so that
#     nflfastR / nflreadr output plots without cleaning).
#   * sportsdataverse-py's NCAA <-> ESPN team crosswalks (men's and women's
#     basketball, 2009-10 on) and hoopR::load_mbb_team_crosswalk() -- the
#     school names NCAA.com / stats.ncaa.org, KenPom and Bart Torvik use
#     ("Iowa St.", "St. John's (NY)"), keyed by ESPN team id.
#   * Sports Reference's school names that none of those use, mapped by hand to
#     ESPN ids below (each checked against the school's mascot).
#
# Run from the package root:  Rscript data-raw/generate_logo_ref.R
# Requires: httr, jsonlite, nflreadr, hoopR, usethis (dev-only, not package deps).


`%||%` <- function(x, y) if (is.null(x)) y else x

espn_get <- function(url) {
  resp <- httr::GET(url, httr::user_agent("Mozilla/5.0 (sdvplotR data-raw)"))
  httr::stop_for_status(resp)
  jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
}

pick_logo <- function(logos, want, exclude = character()) {
  for (l in logos) {
    rel <- unlist(l$rel)
    if (all(want %in% rel) && !any(exclude %in% rel)) return(l$href)
  }
  NULL
}
hex <- function(x) if (is.null(x) || !nzchar(x)) NA_character_ else paste0("#", toupper(x))

team_row <- function(t, slug) {
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
    type = "team",
    stringsAsFactors = FALSE
  )
}

espn_teams <- function(sport, league, slug) {
  j <- espn_get(sprintf(
    "https://site.web.api.espn.com/apis/site/v2/sports/%s/%s/teams?limit=1000",
    sport, league
  ))
  teams <- lapply(j$sports[[1]]$leagues[[1]]$teams, `[[`, "team")
  out <- do.call(rbind, lapply(teams, team_row, slug = slug))
  out[!is.na(out$logo_url), ]
}

# The teams list above leaves out some Division I programs (362 of 365 in
# men's basketball for 2025-26, and not the same ones as women's), so members
# of a core-API group that it lacks are fetched one by one.
espn_teams_by_id <- function(sport, league, slug, ids) {
  out <- lapply(ids, function(id) {
    t <- espn_get(sprintf(
      "https://site.web.api.espn.com/apis/site/v2/sports/%s/%s/teams/%s",
      sport, league, id
    ))$team
    if (is.null(t)) NULL else team_row(t, slug)
  })
  out <- do.call(rbind, out)
  if (is.null(out)) return(NULL)
  out[!is.na(out$logo_url), ]
}

# ids of the teams in an ESPN core-API group (FBS = 80, FCS = 81, D-I = 50),
# split by conference (the group's children), over every season given: a
# program that just left the group (Saint Francis, D-I men's basketball
# through 2025-26) stays drawable for the season it played. The first season
# listed wins a program's conference.
# ESPN's core API still labels the MAAC (basketball group 13) as the old
# "Metro Conference", with no logo
fix_conf <- function(conf) {
  if (identical(conf$name, "Metro Conference")) {
    conf$name <- "Metro Atlantic Athletic Conference"
    conf$shortName <- conf$midsizeName <- "MAAC"
    conf$logos <- list(list(href = "https://a.espncdn.com/i/teamlogos/ncaa_conf/500/maac.png"))
  }
  conf
}

# A conference's key is ESPN's short name, except where a team already uses
# that name: American University ("American", the AAC's short name) and
# Southern University ("Southern", football's short name for SoCon)
conf_key <- function(conf) {
  key <- conf$shortName %||% conf$name
  renamed <- c(American = "AAC", Southern = "SoCon")
  if (key %in% names(renamed)) renamed[[key]] else key
}

core_group_membership <- function(sport, league, seasons, group) {
  base <- sprintf(
    "https://sports.core.api.espn.com/v2/sports/%s/leagues/%s/seasons/%%s/types/2/groups/%s",
    sport, league, group
  )
  found <- NULL
  for (season in seasons) {
    kids <- try(espn_get(sprintf(paste0(base, "/children?limit=100"), season)), silent = TRUE)
    if (inherits(kids, "try-error") || !length(kids$items)) next
    out <- lapply(kids$items, function(it) {
      ref <- sub("^http:", "https:", it$`$ref`)
      conf <- fix_conf(espn_get(ref))
      teams <- espn_get(sub("\\?.*$", "/teams?limit=1000", ref))
      ids <- vapply(teams$items, function(x) as.integer(sub(".*/teams/([0-9]+).*", "\\1", x$`$ref`)), integer(1))
      data.frame(
        espn_team_id = ids,
        conference = conf_key(conf),
        conf_name = conf$name,
        conf_short = conf$midsizeName %||% conf$shortName %||% conf$name,
        conf_logo = if (length(conf$logos)) conf$logos[[1]]$href else NA_character_,
        stringsAsFactors = FALSE
      )
    })
    message(league, " group ", group, ": season ", season, ", ", length(out), " conferences")
    out <- do.call(rbind, out)
    found <- rbind(found, out[!out$espn_team_id %in% found$espn_team_id, ])
  }
  if (is.null(found)) stop("no season found for ", league, " group ", group)
  found
}

college <- function(sport, league, slug, groups, seasons) {
  d <- espn_teams(sport, league, slug)
  keep <- NULL
  for (g in names(groups)) {
    m <- core_group_membership(sport, league, seasons, groups[[g]])
    m$division <- g
    keep <- rbind(keep, m[!m$espn_team_id %in% keep$espn_team_id, ])
  }
  missing <- setdiff(keep$espn_team_id, d$espn_team_id)
  if (length(missing)) {
    message(slug, ": fetching ", length(missing), " group member(s) missing from the teams list")
    d <- rbind(d, espn_teams_by_id(sport, league, slug, missing))
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
  # one row per conference, drawn like a team; a conference without an ESPN
  # logo is left out
  cf <- keep[!duplicated(keep$conference), ]
  if (any(is.na(cf$conf_logo))) message(slug, ": no logo for conference(s): ", paste(cf$conference[is.na(cf$conf_logo)], collapse = ", "))
  cf <- cf[!is.na(cf$conf_logo), ]
  ci <- match(cf$conf_name, conf_colors$name)
  if (anyNA(ci)) message(slug, ": no color for conference(s): ", paste(cf$conference[is.na(ci)], collapse = ", "))
  cf <- data.frame(
    sport = slug,
    espn_team_id = NA_integer_,
    team_abbr = cf$conference,
    team_name = cf$conf_name,
    team_short_name = cf$conf_short,
    team_location = NA_character_,
    team_mascot = NA_character_,
    logo_url = cf$conf_logo,
    logo_dark_url = NA_character_,
    logo_scoreboard_url = NA_character_,
    wordmark_url = NA_character_,
    color1 = conf_colors$color1[ci],
    color2 = conf_colors$color2[ci],
    conference = cf$conference,
    division = cf$division,
    type = "conference",
    stringsAsFactors = FALSE
  )
  rbind(d[order(d$team_abbr), ], cf[order(cf$team_abbr), ])
}

# Conference colors from cbbplotR (Andrew Weatherman, MIT), keyed by ESPN's
# full conference name, so a football conference with the same name shares them
conf_colors <- data.frame(
  name = c(
    "America East Conference", "American Conference", "Atlantic 10 Conference",
    "Atlantic Coast Conference", "Atlantic Sun Conference", "Big 12 Conference",
    "Big East Conference", "Big Sky Conference", "Big South Conference",
    "Big Ten Conference", "Big West Conference", "Coastal Athletic Association",
    "Conference USA", "Horizon League", "Ivy League",
    "Metro Atlantic Athletic Conference", "Mid-American Conference",
    "Mid-Eastern Athletic Conference", "Missouri Valley Conference",
    "Mountain West Conference", "Northeast Conference", "Ohio Valley Conference",
    "Pac-12 Conference", "Patriot League", "Southeastern Conference",
    "Southern Conference", "Southland Conference", "Southwestern Athletic Conference",
    "Summit League", "Sun Belt Conference", "West Coast Conference"
  ),
  color1 = c(
    "#00B1E2", "#0E1D41", "#E2201B", "#003CA6", "#F2E60B", "#FA4238", "#07205B",
    "#0133A0", "#0082CB", "#0082CB", "#11175E", "#002648", "#002638", "#F5A018",
    "#18563F", "#084FA2", "#009844", "#582C82", "#CF162D", "#4E2D7F", "#035F9B",
    "#A51844", "#001A6F", "#00205A", "#012D74", "#001588", "#C1A552", "#E2201B",
    "#01549E", "#0C2140", "#24CAD2"
  ),
  color2 = c(
    "#121C4E", "#E2201B", "#E2201B", "#003CA6", "#4C4F54", "#FA4238", "#CF162D",
    "#43C6E7", "#ED7422", "#0082CB", "#A30145", "#002648", "#E31C47", "#F5A018",
    "#18563F", "#E2373F", "#0C2140", "#FEB81D", "#13216A", "#AFAFAF", "#035F9B",
    "#D0AE85", "#001A6F", "#D9291C", "#FFD040", "#001588", "#C1A552", "#E2201B",
    "#01549E", "#F5A606", "#24CAD2"
  ),
  stringsAsFactors = FALSE
)

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

# the AFC, NFC and NFL logos, which nflplotR also draws (it has no colors for them)
nfl_marks <- data.frame(
  sport = "nfl",
  espn_team_id = NA_integer_,
  team_abbr = c("AFC", "NFC", "NFL"),
  team_name = c("American Football Conference", "National Football Conference", "National Football League"),
  team_short_name = c("AFC", "NFC", "NFL"),
  team_location = NA_character_,
  team_mascot = NA_character_,
  logo_url = paste0("https://a.espncdn.com/i/teamlogos/", c("nfl/500/afc", "nfl/500/nfc", "leagues/500/nfl"), ".png"),
  logo_dark_url = paste0("https://a.espncdn.com/i/teamlogos/", c("nfl/500-dark/afc", "nfl/500-dark/nfc", "leagues/500-dark/nfl"), ".png"),
  logo_scoreboard_url = NA_character_,
  wordmark_url = NA_character_,
  color1 = NA_character_,
  color2 = NA_character_,
  conference = c("AFC", "NFC", NA),
  division = NA_character_,
  type = c("conference", "conference", "league"),
  stringsAsFactors = FALSE
)
pro <- rbind(pro, nfl_marks)

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
    KCA = "KC", SDN = "SD", SFN = "SF", TBA = "TB", ARZ = "ARI",
    # MLB Stats API / Baseball Savant (baseballr) and FanGraphs / Baseball-Reference
    AZ = "ARI", WSN = "WSH"
  ),
  nhl = c(
    WAS = "WSH", LAK = "LA", NJD = "NJ", SJS = "SJ", TBL = "TB", VEG = "VGK", MON = "MTL",
    UTA = "UTAH", CLB = "CBJ", NAS = "NSH", WIN = "WPG"
  ),
  # ESPN feeds abbreviate these differently from its teams list: box scores
  # write Butler BUT and New Orleans UNO, and FPI writes Buffalo BUFF and Air
  # Force AFA
  cfb = c(BUFF = "BUF", AFA = "AF"),
  mbb = c(BUT = "BTLR", UNO = "NOLA", BUFF = "BUF", AFA = "AF"),
  wbb = c(BUT = "BTLR", UNO = "NOLA", BUFF = "BUF", AFA = "AF")
)

# School names other college sources use, by ESPN team id. ESPN's college
# team ids are per school, so the basketball names also serve football. A name
# that points at two schools is dropped rather than guessed.
crosswalk_url <- paste0(
  "https://raw.githubusercontent.com/sportsdataverse/sportsdataverse-py/main/",
  "sportsdataverse/%s/data/ncaa_espn_team_crosswalk_%s.csv"
)
ncaa <- do.call(rbind, lapply(c("mbb", "wbb"), function(s) {
  read.csv(sprintf(crosswalk_url, s, s), stringsAsFactors = FALSE)[
    , c("season", "ncaa_team", "espn_team_id", "ncaa_conference", "espn_conference_name")
  ]
}))
# the last two seasons hoopR has published (it refuses later ones)
kp_season <- hoopR::most_recent_mbb_season()
kp <- as.data.frame(hoopR::load_mbb_team_crosswalk(seasons = c(kp_season - 1, kp_season)))
# Sports Reference's season pages name these schools differently from ESPN, the
# NCAA, KenPom and Torvik; the rest of its 2025-26 Division I list resolves.
# Mapped by hand to ESPN ids and checked against each school's mascot on its
# index. Dashes are hyphens here: clean_team_abbrs() folds Sports Reference's
# en dashes to them.
sports_reference <- c(
  "Brigham Young" = 252L, "Southern Methodist" = 2567L, "Texas Christian" = 2628L,
  "Virginia Commonwealth" = 2670L, "Louisiana State" = 99L, "Illinois-Chicago" = 82L,
  "Texas-Rio Grande Valley" = 292L, "College of Charleston" = 232L, "TAMUCC" = 357L,
  "Appalachian State" = 2026L, "Southern Mississippi" = 2572L, "Loyola (IL)" = 2350L,
  "Tennessee-Martin" = 2630L, "Nicholls State" = 2447L, "Central Connecticut State" = 2115L,
  "Loyola (MD)" = 2352L, "Massachusetts-Lowell" = 2349L, "Maryland-Eastern Shore" = 2379L,
  "Louisiana-Monroe" = 2433L, "Nevada-Las Vegas" = 2439L
)
school_names <- data.frame(
  name = c(ncaa$ncaa_team, kp$kp_team, kp$bart_team, names(sports_reference)),
  espn_team_id = as.integer(c(ncaa$espn_team_id, kp$espn_team_id, kp$espn_team_id, sports_reference)),
  stringsAsFactors = FALSE
)
school_names <- unique(school_names[!is.na(school_names$name) & nzchar(school_names$name) &
  !is.na(school_names$espn_team_id), ])
school_names$key <- toupper(school_names$name)
ambiguous <- unique(school_names$key[duplicated(school_names$key)])
if (length(ambiguous)) message("dropping school names used for two schools: ", paste(ambiguous, collapse = ", "))
school_names <- school_names[!school_names$key %in% ambiguous, ]
message(nrow(school_names), " NCAA / KenPom / Torvik / Sports Reference school names")

# Conference names the same sources use ("Big Ten", "A-10", "B10", "MWC"),
# mapped to ESPN's full conference name by majority over the latest season's
# teams (the crosswalks carry each team's current ESPN conference)
conf_votes <- rbind(
  with(ncaa[ncaa$season == max(ncaa$season), ], data.frame(name = ncaa_conference, conf = espn_conference_name)),
  with(kp[kp$season == max(kp$season), ], data.frame(name = c(kp_conf, bart_conf), conf = c(espn_conference, espn_conference)))
)
conf_votes <- conf_votes[!is.na(conf_votes$name) & nzchar(conf_votes$name) & !is.na(conf_votes$conf), ]
conf_votes <- aggregate(list(n = rep(1L, nrow(conf_votes))), conf_votes[c("name", "conf")], sum)
conf_votes <- conf_votes[order(conf_votes$name, -conf_votes$n), ]
conf_votes$share <- conf_votes$n / ave(conf_votes$n, conf_votes$name, FUN = sum)
conf_names <- conf_votes[!duplicated(conf_votes$name) & conf_votes$share > 0.5, c("name", "conf")]
conf_names$key <- toupper(conf_names$name)
conf_names <- conf_names[!duplicated(conf_names$key), ]

abbr_mapping <- lapply(split(logo_ref, logo_ref$sport), function(ref) {
  d <- ref[ref$type == "team", ]
  keys <- c(
    d$team_abbr,
    toupper(d$team_name),
    toupper(d$team_short_name),
    toupper(d$team_location)
  )
  vals <- rep(d$team_abbr, 4)
  keep <- !is.na(keys) & !duplicated(keys)
  m <- stats::setNames(vals[keep], keys[keep])
  if (d$sport[1] %in% c("cfb", "mbb", "wbb")) {
    # ESPN's own keys win; only names ESPN doesn't use are added
    sn <- school_names[school_names$espn_team_id %in% d$espn_team_id & !school_names$key %in% names(m), ]
    m <- c(m, stats::setNames(d$team_abbr[match(sn$espn_team_id, d$espn_team_id)], sn$key))
  }
  # conferences (and the NFL shield): their names, then other sources' names
  # for them, wherever no team already uses the name
  cf <- ref[ref$type != "team", ]
  if (nrow(cf)) {
    ck <- c(toupper(cf$team_abbr), toupper(cf$team_name), toupper(cf$team_short_name))
    cv <- rep(cf$team_abbr, 3)
    add <- !is.na(ck) & !duplicated(ck) & !ck %in% names(m)
    m <- c(m, stats::setNames(cv[add], ck[add]))
    cn <- conf_names[conf_names$conf %in% cf$team_name & !conf_names$key %in% names(m), ]
    m <- c(m, stats::setNames(cf$team_abbr[match(cn$conf, cf$team_name)], cn$key))
    # every conference resolves to itself
    stopifnot(identical(unname(m[toupper(cf$team_abbr)]), cf$team_abbr))
  }
  al <- aliases[[d$sport[1]]]
  # a curated alias must not lose to a crosswalk or conference name
  clash <- names(al) %in% names(m) & m[names(al)] != al
  if (any(clash)) stop(d$sport[1], " aliases shadowed by other keys: ", paste(names(al)[clash], collapse = ", "))
  al <- al[!names(al) %in% names(m)]
  stopifnot(all(al %in% d$team_abbr))
  c(m, al)
})

usethis::use_data(logo_ref, abbr_mapping, internal = TRUE, overwrite = TRUE)

cat("logo_ref:", nrow(logo_ref), "teams\n")
print(table(logo_ref$sport, logo_ref$division, useNA = "ifany"))
