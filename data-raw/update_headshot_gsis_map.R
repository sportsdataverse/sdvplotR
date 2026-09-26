# Build and publish the NFL headshot map and player id crosswalk that sdvplotR
# loads at run time, following nflplotR's data-raw/update_headshot_gsis_map.R.
#
# nflplotR builds its map from NFL API rosters and publishes it to the
# nflplotr_infrastructure release of nflverse/nflplotR; sdvplotR builds the same
# shape from nflverse's public rosters (nflreadr::load_rosters()) and publishes
# to the sdvplotr_infrastructure release of sportsdataverse/sdvplotR:
#
#   headshot_gsis_map_<season>.rds  one per season, 1999 to the current season
#   headshot_gsis_map.rds           every player at their latest season: gsis_id,
#                                   headshot_nfl (NFL.com image), espn_id, season
#   nfl_player_id_crosswalk.rds/csv every player's ids (GSIS, ESPN, PFR, PFF,
#                                   Sportradar, Sleeper, ...) at their latest season
#
# Usage, from the package root with gh authenticated for the repo:
#   Rscript data-raw/update_headshot_gsis_map.R current   # this season (scheduled)
#   Rscript data-raw/update_headshot_gsis_map.R all       # backfill 1999 onward
# .github/workflows/update-headshot-map.yaml runs the "current" mode weekly.

args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args)) args[[1]] else "current"
stopifnot(mode %in% c("current", "all"))

repo <- "sportsdataverse/sdvplotR"
tag <- "sdvplotr_infrastructure"
first_season <- 1999
current_season <- nflreadr::most_recent_season(roster = TRUE)
seasons_to_update <- if (mode == "all") first_season:current_season else current_season
release_url <- sprintf("https://github.com/%s/releases/download/%s", repo, tag)

out_dir <- file.path(tempdir(), tag)
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

gh <- function(...) {
  status <- system2("gh", c(...))
  if (!identical(status, 0L)) stop("gh ", paste(c(...)[1:2], collapse = " "), " failed (status ", status, ")")
  invisible(TRUE)
}
# --clobber deletes each asset, then uploads its replacement (gh retries a 5xx
# three times), as nflversedata::nflverse_upload() does. An upload that still
# fails leaves that asset missing and this run red; readers resolve NFL ids to
# NA meanwhile and retry each call, so a rerun restores headshots at once.
upload <- function(files) gh("release", "upload", tag, files, "--clobber", "-R", repo)

# the release is created once; later runs only upload
if (!identical(suppressWarnings(system2("gh", c("release", "view", tag, "-R", repo), stdout = FALSE, stderr = FALSE)), 0L)) {
  gh(
    # a pre-release, so it never becomes the repo's "Latest" release (which
    # install_github("sportsdataverse/sdvplotR@*release") would install)
    "release", "create", tag, "-R", repo, "--prerelease", "--latest=false",
    "--title", shQuote("sdvplotR Infrastructure"),
    "--notes", shQuote(paste(
      "Data sdvplotR loads at run time. Built from nflverse rosters by",
      "data-raw/update_headshot_gsis_map.R and refreshed weekly by",
      ".github/workflows/update-headshot-map.yaml."
    ))
  )
}

is_gsis <- function(id) !is.na(id) & grepl("^00-00[0-9]{5}$", id) # as nflplotR

season_map <- function(s) {
  r <- as.data.frame(nflreadr::load_rosters(s))
  r <- r[is_gsis(r$gsis_id) & (!is.na(r$headshot_url) | !is.na(r$espn_id)), ]
  data.frame(
    gsis_id = r$gsis_id,
    headshot_nfl = r$headshot_url,
    espn_id = as.character(r$espn_id),
    season = as.integer(s),
    stringsAsFactors = FALSE
  )[!duplicated(r$gsis_id), ]
}

# Everything is built and checked first; nothing is uploaded until every check
# has passed, so a bad season can never replace a good published file.

# 1. one map per season updated in this run
built <- list()
for (s in seasons_to_update) {
  m <- season_map(s)
  share <- mean(!is.na(m$headshot_nfl))
  if (nrow(m) < 1000 || share < 0.9) {
    stop("season ", s, ": ", nrow(m), " players, ", round(100 * share), "% with a headshot")
  }
  built[[as.character(s)]] <- m
  message("season ", s, ": ", nrow(m), " players, ", round(100 * share), "% with a headshot")
}

# 2. every season combined, each player at their latest season; seasons not
# rebuilt in this run come from their published file
all_seasons <- lapply(first_season:current_season, function(s) {
  if (!is.null(built[[as.character(s)]])) {
    return(built[[as.character(s)]])
  }
  m <- as.data.frame(nflreadr::rds_from_url(sprintf("%s/headshot_gsis_map_%s.rds", release_url, s)))
  if (nrow(m) == 0) stop("could not read the published map for season ", s, "; run the 'all' mode first")
  m
})
combined <- do.call(rbind, all_seasons)
# each player's latest season with an NFL.com image (nflplotR keeps only rows
# with one); a player with none keeps their latest row, for the ESPN id
combined <- combined[order(combined$gsis_id, is.na(combined$headshot_nfl), -combined$season), ]
headshot_gsis_map <- combined[!duplicated(combined$gsis_id), ]
rownames(headshot_gsis_map) <- NULL

# positive controls before anything is published
stopifnot(
  nrow(headshot_gsis_map) > 15000,
  !anyDuplicated(headshot_gsis_map$gsis_id),
  "00-0033873" %in% headshot_gsis_map$gsis_id,
  !is.na(headshot_gsis_map$headshot_nfl[headshot_gsis_map$gsis_id == "00-0033873"])
)

# 3. the id crosswalk, from the same rosters, each player at their latest season
rosters <- as.data.frame(nflreadr::load_rosters(first_season:current_season))
# load_rosters() drops a season whose download fails; refuse a partial crosswalk
missing_seasons <- setdiff(first_season:current_season, unique(rosters$season))
if (length(missing_seasons)) stop("rosters missing seasons: ", paste(missing_seasons, collapse = ", "))
rosters <- rosters[is_gsis(rosters$gsis_id), ]
rosters <- rosters[order(rosters$gsis_id, -rosters$season), ]
rosters <- rosters[!duplicated(rosters$gsis_id), ]
id_cols <- intersect(
  c(
    "gsis_id", "espn_id", "pfr_id", "pff_id", "sportradar_id", "sleeper_id", "yahoo_id",
    "rotowire_id", "fantasy_data_id", "esb_id", "smart_id", "gsis_it_id"
  ),
  names(rosters)
)
crosswalk <- rosters[, c(id_cols, intersect(c("full_name", "position", "team", "season"), names(rosters)))]
crosswalk[id_cols] <- lapply(crosswalk[id_cols], as.character)
names(crosswalk)[names(crosswalk) == "team"] <- "latest_team"
names(crosswalk)[names(crosswalk) == "season"] <- "latest_season"
rownames(crosswalk) <- NULL
stopifnot(nrow(crosswalk) >= nrow(headshot_gsis_map), "00-0033873" %in% crosswalk$gsis_id)

# 4. every check has passed: write and upload
season_files <- vapply(names(built), function(s) {
  f <- file.path(out_dir, sprintf("headshot_gsis_map_%s.rds", s))
  saveRDS(built[[s]], f)
  f
}, character(1))
f_map <- file.path(out_dir, "headshot_gsis_map.rds")
saveRDS(headshot_gsis_map, f_map)
f_rds <- file.path(out_dir, "nfl_player_id_crosswalk.rds")
f_csv <- file.path(out_dir, "nfl_player_id_crosswalk.csv")
saveRDS(crosswalk, f_rds)
utils::write.csv(crosswalk, f_csv, row.names = FALSE, na = "")
upload(c(season_files, f_map, f_rds, f_csv))

message(
  "published ", tag, ": ", length(seasons_to_update), " season file(s); headshot map ",
  nrow(headshot_gsis_map), " players; crosswalk ", nrow(crosswalk), " players"
)
