# Historical team abbreviation mappings
# ============================================================================

#' Resolve Historical Team Abbreviations
#'
#' @description Maps defunct or relocated franchise abbreviations to the
#'   abbreviation of the current franchise, so historical data (e.g. `"OAK"`
#'   for the Raiders, `"SEA"` for the SuperSonics) resolves to the correct
#'   current team (`"LV"`, `"OKC"`). [clean_team_abbrs()] applies these
#'   mappings automatically; this function exposes them directly.
#'
#' @details The result is the package's canonical key, the one
#'   [clean_team_abbrs()] returns: nflverse abbreviations for the NFL (the
#'   St. Louis Rams' `"STL"` gives `"LA"`), ESPN's elsewhere (`"NOH"` gives
#'   `"NO"`, `"WSB"` gives `"WSH"`). A relocation key follows the franchise,
#'   in both functions: `"WIN"` is the original Winnipeg Jets (1979-96), so it
#'   gives the Utah club they became, while today's Jets are `"WPG"`.
#'
#' @param abbr Character vector of team abbreviations (possibly historical).
#' @param sport Character string identifying the sport. One of
#'   [supported_sports()].
#' @return A character vector the same length as `abbr` holding the
#'   current-team abbreviation, or the input unchanged where no mapping exists.
#' @export
#' @examples
#' resolve_historical_abbr(c("OAK", "SD", "KC"), sport = "nfl")
#' resolve_historical_abbr("MON", sport = "mlb")
#' resolve_historical_abbr("SEA", sport = "nba")
resolve_historical_abbr <- function(abbr, sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer")) {
  sport <- rlang::arg_match0(sport, supported_sports())
  abbr <- as.character(abbr)
  m <- historical_team_mappings[[sport]]
  if (is.null(m)) return(abbr)
  mapped <- unname(m[toupper(abbr)])
  abbr[!is.na(mapped)] <- mapped[!is.na(mapped)]
  abbr
}

# Keys = historical abbreviation (upper case), values = the current franchise's
# canonical key (team_abbr in logo_ref, which tests assert). Only franchises
# that still exist today are mapped; defunct franchises with no successor are
# intentionally absent so they resolve to NA downstream. A key here wins over an
# alias of the same name in abbr_mapping (see match_team_abbrs()).
historical_team_mappings <- list(
  nfl = c(
    OAK = "LV",   # Raiders: Oakland -> Las Vegas (2020)
    SD  = "LAC",  # Chargers: San Diego -> Los Angeles (2017)
    STL = "LA",   # Rams: St. Louis -> Los Angeles (2016)
    BLT = "BAL",  # Baltimore Ravens (PFR-style code)
    HST = "HOU",  # Houston Texans (PFR-style code)
    CLV = "CLE",  # Cleveland Browns (PFR-style code)
    ARZ = "ARI"   # Arizona Cardinals (PFR-style code)
  ),
  nba = c(
    SEA = "OKC",  # SuperSonics -> Thunder (2008)
    NJN = "BKN",  # Nets: New Jersey -> Brooklyn (2012)
    NJ  = "BKN",
    NOH = "NO",   # New Orleans Hornets -> Pelicans (2013)
    NOK = "NO",   # New Orleans / Oklahoma City Hornets (2005-2007)
    VAN = "MEM",  # Grizzlies: Vancouver -> Memphis (2001)
    SDC = "LAC",  # Clippers: San Diego -> Los Angeles (1984)
    KCK = "SAC",  # Kings: Kansas City -> Sacramento (1985)
    WSB = "WSH"   # Washington Bullets -> Wizards (1997)
  ),
  wnba = c(
    DET = "DAL",  # Shock: Detroit -> Tulsa -> Dallas Wings (2016)
    TUL = "DAL",
    UTA = "LV",   # Starzz: Utah -> San Antonio -> Las Vegas Aces (2018)
    SAS = "LV",
    SA  = "LV"
  ),
  mlb = c(
    OAK = "ATH",  # Athletics: Oakland -> Sacramento (2025)
    MON = "WSH",  # Expos: Montreal -> Washington Nationals (2005)
    FLA = "MIA",  # Marlins: Florida -> Miami (2012)
    CAL = "LAA",  # Angels: California -> Anaheim -> Los Angeles
    ANA = "LAA",
    TBD = "TB",   # Devil Rays -> Rays (2008)
    MTL = "WSH"
  ),
  nhl = c(
    ARI = "UTAH", # Coyotes: Arizona -> Utah (2024)
    PHX = "UTAH", # Coyotes: Phoenix -> Arizona (2014)
    WIN = "UTAH", # Jets (original): Winnipeg -> Phoenix (1996)
    QUE = "COL",  # Nordiques: Quebec -> Colorado Avalanche (1995)
    HFD = "CAR",  # Whalers: Hartford -> Carolina Hurricanes (1997)
    MNS = "DAL",  # North Stars: Minnesota -> Dallas (1993)
    ATF = "CGY",  # Flames: Atlanta -> Calgary (1980)
    ATL = "WPG",  # Thrashers: Atlanta -> Winnipeg Jets (2011)
    CLR = "NJ"    # Rockies: Colorado -> New Jersey Devils (1982)
  )
)
