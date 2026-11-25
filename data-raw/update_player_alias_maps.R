# Build and publish the provider player id -> ESPN athlete id maps that the
# headshot helpers read for id_system = "fox", "yahoo", "cbs", "kenpom",
# "ncaa", "nba_stats" and "wnba_stats" (R/utils.R, player_alias_sources).
#
# The source is sdv-reference-data's {league}_player_aliases table in the
# sportsdataverse-data {league}_groups release. The whole table is too large to
# bundle (cfb alone has 421k rows), so it is split into one small .rds per
# (league, source), holding only the two columns a headshot needs, and
# published to the sdvplotr_infrastructure release of sportsdataverse/sdvplotR:
#
#   player_aliases_<league>_<source>.rds   source_player_id, athlete_id
#
# Usage, from the package root with gh authenticated for the repo (the release
# already exists: data-raw/update_headshot_gsis_map.R creates it):
#   Rscript data-raw/update_player_alias_maps.R [--dry-run] [--allow-shrink]
# Rerun after sdv-reference-data republishes the player_aliases tables.
# --dry-run builds and checks every map, prints the published vs new row
# counts, and uploads nothing. A map with fewer rows than its published copy
# stops the run unless --allow-shrink is given.

repo <- "sportsdataverse/sdvplotR"
tag <- "sdvplotr_infrastructure"
args <- commandArgs(trailingOnly = TRUE)
dry_run <- "--dry-run" %in% args
allow_shrink <- "--allow-shrink" %in% args
published <- system2("gh", c("release", "view", tag, "-R", repo, "--json", "assets", "--jq", shQuote(".assets[].name")),
                     stdout = TRUE)
if (!is.null(attr(published, "status"))) stop("gh release view failed")
# rows in the published copy (0 for a new pair); a listed asset that cannot be read stops the run
published_rows <- function(name) {
  if (!name %in% published) return(0L)
  nrow(readRDS(gzcon(url(sprintf("https://github.com/%s/releases/download/%s/%s", repo, tag, name)))))
}
source_url <- paste0(
  "https://github.com/sportsdataverse/sportsdataverse-data/releases/download/",
  "%1$s_groups/%1$s_player_aliases.csv"
)
# keep in step with player_alias_sources in R/utils.R
sources <- list(
  nfl = c("fox", "yahoo", "cbs"),
  cfb = c("fox", "yahoo", "cbs", "ncaa"),
  nba = c("fox", "yahoo", "nba_stats"),
  wnba = c("fox", "yahoo", "wnba_stats"),
  mbb = c("fox", "yahoo", "kenpom", "ncaa"),
  wbb = c("fox", "yahoo", "ncaa")
)

out_dir <- file.path(tempdir(), "player_aliases")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Everything is built and checked first; nothing is uploaded until every map
# has passed, so a bad table can never replace a good published file.
files <- character()
shrunk <- character()
for (league in names(sources)) {
  a <- utils::read.csv(sprintf(source_url, league), colClasses = "character", na.strings = "")
  stopifnot(all(c("source", "source_player_id", "athlete_id") %in% names(a)))
  for (src in sources[[league]]) {
    m <- unique(a[a$source == src & !is.na(a$source_player_id) & !is.na(a$athlete_id),
                  c("source_player_id", "athlete_id")])
    # the contract's cross-season rule: a provider id is one athlete; and an
    # ESPN athlete id is digits
    if (!all(grepl("^[0-9]+$", m$athlete_id))) stop(league, "/", src, ": an athlete_id that is not digits")
    if (anyDuplicated(m$source_player_id)) stop(league, "/", src, ": a provider id maps to two athletes")
    m <- m[order(m$source_player_id), ]
    rownames(m) <- NULL
    # a source with no rows yet (mbb / wbb Yahoo) gets an empty map, so readers
    # find a file rather than a 404 and keep it for the session
    path <- file.path(out_dir, sprintf("player_aliases_%s_%s.rds", league, src))
    saveRDS(m, path) # gzip: read_rds_url() reads it through gzcon()
    old <- published_rows(basename(path))
    message(league, "/", src, ": ", old, " -> ", nrow(m), " ids, ", file.size(path), " bytes")
    if (nrow(m) < old) shrunk <- c(shrunk, paste0(league, "/", src))
    files <- c(files, path)
  }
}

if (length(shrunk) && !allow_shrink) {
  stop("fewer ids than the published map: ", toString(shrunk), " (rerun with --allow-shrink to upload anyway)")
}
if (dry_run) {
  message("--dry-run: built ", length(files), " maps in ", out_dir, "; nothing uploaded")
  quit(save = "no")
}
status <- system2("gh", c("release", "upload", tag, shQuote(files), "--clobber", "-R", repo))
if (!identical(status, 0L)) stop("gh release upload failed (status ", status, ")")
