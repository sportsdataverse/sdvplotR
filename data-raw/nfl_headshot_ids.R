# Build the NFL headshot crosswalk in R/sysdata.rda: GSIS ID -> NFL.com image.
#
# NFL.com headshot URLs use an opaque image id per player, not the GSIS id, and
# the image lives under one of two delivery types ("private" or "upload"); an id
# only resolves under its own type. nflverse's player table carries each
# player's headshot URL, so keep "<type>/<id>" per GSIS id and let
# headshot_from_id() rebuild the URL at the sized t_headshot_desktop transform.
#
# Run from the package root: Rscript data-raw/nfl_headshot_ids.R
# Rerun when new players need headshots (nflverse refreshes players daily).

players <- nflreadr::load_players()
players <- players[!is.na(players$gsis_id) & !is.na(players$headshot), ]

m <- regmatches(
  players$headshot,
  regexec("/image/(private|upload)/.*?league/([A-Za-z0-9_-]+)$", players$headshot)
)
ok <- lengths(m) == 3
nfl_headshot_ids <- stats::setNames(
  vapply(m[ok], function(x) paste0(x[[2]], "/", x[[3]]), character(1)),
  players$gsis_id[ok]
)

stopifnot(
  !anyDuplicated(names(nfl_headshot_ids)),
  all(grepl("^(private|upload)/[A-Za-z0-9_-]+$", nfl_headshot_ids)),
  "00-0033873" %in% names(nfl_headshot_ids)
)

# sysdata.rda holds every internal object: keep the team data this script does
# not build (data-raw/generate_logo_ref.R builds those)
sys <- new.env()
load("R/sysdata.rda", envir = sys)
logo_ref <- sys$logo_ref
abbr_mapping <- sys$abbr_mapping
usethis::use_data(logo_ref, abbr_mapping, nfl_headshot_ids, internal = TRUE, overwrite = TRUE)

cat(
  "nfl_headshot_ids:", length(nfl_headshot_ids), "players;",
  sum(!ok), "headshot URLs skipped (unrecognized form)\n"
)
print(table(sub("/.*$", "", nfl_headshot_ids)))
