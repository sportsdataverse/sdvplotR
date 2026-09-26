# Build the NFL headshot crosswalk in R/sysdata.rda: GSIS ID -> NFL.com image.
#
# NFL.com headshot URLs use an opaque image id per player, not the GSIS id, and
# the image lives under one of two delivery types ("private" or "upload"); an id
# only resolves under its own type. nflverse's player table carries each
# player's headshot URL, so keep "<type>/<id>" per GSIS id and let
# headshot_from_id() rebuild the URL at the sized t_headshot_desktop transform.
#
# Players with no NFL.com image but an ESPN athlete id get "espn/<id>" instead,
# resolved to ESPN's headshot. This is a snapshot: nflplotR downloads nflverse's
# map at run time instead, so a GSIS id added to nflverse after the last rebuild
# returns NA here until this script is rerun.
#
# Run from the package root: Rscript data-raw/nfl_headshot_ids.R
# Rerun when new players need headshots (nflverse refreshes players daily).

# sysdata.rda holds every internal object: load the team data this script does
# not build (data-raw/generate_logo_ref.R builds those) first, and stop before
# downloading anything if it is missing
sys <- new.env()
load("R/sysdata.rda", envir = sys)
logo_ref <- sys$logo_ref
abbr_mapping <- sys$abbr_mapping
stopifnot(!is.null(logo_ref), !is.null(abbr_mapping))

all_players <- nflreadr::load_players()
all_players <- all_players[!is.na(all_players$gsis_id), ]
players <- all_players[!is.na(all_players$headshot), ]

m <- regmatches(
  players$headshot,
  regexec("/image/(private|upload)/.*?league/([A-Za-z0-9_-]+)$", players$headshot)
)
ok <- lengths(m) == 3
nfl_headshot_ids <- stats::setNames(
  vapply(m[ok], function(x) paste0(x[[2]], "/", x[[3]]), character(1)),
  players$gsis_id[ok]
)

# ESPN fallback for players NFL.com has no image for
espn_only <- all_players[is.na(all_players$headshot) & !is.na(all_players$espn_id) &
  grepl("^[0-9]+$", all_players$espn_id), ]
nfl_headshot_ids <- c(
  nfl_headshot_ids,
  stats::setNames(paste0("espn/", espn_only$espn_id), espn_only$gsis_id)
)

stopifnot(
  !anyDuplicated(names(nfl_headshot_ids)),
  all(grepl("^((private|upload)/[A-Za-z0-9_-]+|espn/[0-9]+)$", nfl_headshot_ids)),
  "00-0033873" %in% names(nfl_headshot_ids)
)

usethis::use_data(logo_ref, abbr_mapping, nfl_headshot_ids, internal = TRUE, overwrite = TRUE)

cat(
  "nfl_headshot_ids:", length(nfl_headshot_ids), "players;",
  sum(!ok), "headshot URLs skipped (unrecognized form)\n"
)
print(table(sub("/.*$", "", nfl_headshot_ids)))
