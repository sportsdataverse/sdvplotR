# Build the internal current-mark table (logo_marks in R/sysdata.rda)
# ============================================================================
# One row per (sport, key, type, variant): the SportsDataverse logo archive's
# copy of a current logo or wordmark, for every row of logo_ref (teams,
# conferences, the NFL shield). `url` is the archive's immutable
# content-addressed file, sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/
# sha256/<ab>/<sha256>.<ext>, never the ESPN / nflverse / MLB original: ESPN
# drops and overwrites files in place (a dark logo 404'd, #61), and the
# archive names a file by its hash, so a downloaded mark can be verified.
# resolve_logo_url() / resolve_wordmark_url() (R/utils.R) read this table first
# and fall back to logo_ref's live URL only where the archive has no copy.
#
# Source: the sdv-assets manifest, manifest/marks.csv, the file
# generate_logo_history.R reads and sdvplot reads at run time (_manifest.py).
#
# Rows:
#   * The files logo_ref lists (logo_url -> "primary", logo_dark_url -> "dark",
#     logo_scoreboard_url -> "scoreboard", wordmark_url -> wordmark "primary"),
#     joined on the manifest's `url`: the archive row IS a copy of that file,
#     so every helper keeps drawing the image it drew. Where the manifest holds
#     several copies of one URL (the source replaced the file), the copy seen
#     last wins: the file the source serves today.
#   * Named variants, kept for a sport when at least half of its teams have
#     one: ESPN's per-team marks (`primary_logo_on_black_color`, `grayscale`,
#     `scoreboard_dark`, ...), joined on (league, ESPN team id); nflverse's
#     `squared` NFL logo (by abbreviation); MLB's own cap and primary marks and
#     light / dark wordmarks (source mlbstatic, SVG, joined on team name). The
#     manifest's `default` / `dark` / `scoreboard` variants are the files above
#     and are not repeated.
#
# Checks: every logo_ref URL finds its copy; the archive's file name is the
# manifest's sha256; a sample of the sources' live files is downloaded and
# hashed against the archive copies (printed: a source can replace a file
# after the archive snapshot; the archive copies must hash to their names).
#
# Run from the package root, after generate_logo_ref.R and
# generate_logo_history.R (both re-save this object):
#   Rscript data-raw/generate_logo_marks.R
# Requires: pkgload, usethis (dev-only, not package deps); R >= 4.5 for
# tools::sha256sum().

pkgload::load_all(".", quiet = TRUE)
logo_ref <- sdvplotR:::logo_ref
abbr_mapping <- sdvplotR:::abbr_mapping
logo_history <- sdvplotR:::logo_history

manifest_url <- "https://raw.githubusercontent.com/sportsdataverse/sdv-assets/main/manifest/marks.csv"
marks <- utils::read.csv(manifest_url, colClasses = "character", na.strings = "")
cdn <- "https://sdv.nyc3.cdn.digitaloceanspaces.com/"
sha_of_url <- function(url) sub("\\.[^.]+$", "", basename(url))

stopifnot(startsWith(marks$archive_url, cdn), sha_of_url(marks$archive_url) == marks$sha256)
# the copy seen last first, so match() and duplicated() keep today's file
marks <- marks[order(marks$last_seen, marks$first_seen, decreasing = TRUE), ]

# ---------------------------------------------------------------------------
# The files logo_ref lists, by URL
# ---------------------------------------------------------------------------

# the whole manifest: a conference shared by several sports (the WAC, the
# MAAC) is filed once, under league "ncaa"
listed <- c(logo_url = "primary", logo_dark_url = "dark", logo_scoreboard_url = "scoreboard", wordmark_url = "primary")
by_url <- marks[!duplicated(marks$url), ]
canonical <- do.call(rbind, lapply(names(listed), function(col) {
  i <- which(!is.na(logo_ref[[col]]))
  data.frame(
    sport = logo_ref$sport[i],
    key = logo_ref$team_abbr[i],
    type = if (col == "wordmark_url") "wordmark" else "logo",
    variant = listed[[col]],
    url = by_url$archive_url[match(logo_ref[[col]][i], by_url$url)],
    source_url = logo_ref[[col]][i]
  )
}))
if (anyNA(canonical$url)) {
  stop("not in the archive: ", paste(canonical$source_url[is.na(canonical$url)], collapse = ", "))
}

# ---------------------------------------------------------------------------
# Named variants
# ---------------------------------------------------------------------------

teams <- logo_ref[logo_ref$type == "team", ]
named <- marks[
  marks$level == "team" & marks$league %in% teams$sport & !marks$variant %in% c("default", "dark", "scoreboard"),
]
named$key <- NA_character_
src <- named$source
named$key[src == "espn"] <- teams$team_abbr[match(
  paste(named$league, named$entity_id)[src == "espn"], paste(teams$sport, teams$espn_team_id)
)]
named$key[src == "nflverse"] <- teams$team_abbr[match(
  paste("nfl", named$entity_id)[src == "nflverse"], paste(teams$sport, teams$team_abbr)
)]
named$key[src == "mlbstatic"] <- teams$team_abbr[match(
  paste("mlb", named$entity_name)[src == "mlbstatic"], paste(teams$sport, teams$team_name)
)]
# relocated identities ESPN still files (OAK, SD, STL), minor-league clubs, and
# any source without a key above are left out
named <- named[!is.na(named$key), ]
named <- named[!duplicated(named[c("league", "key", "mark_type", "variant")]), ]
named <- data.frame(
  sport = named$league, key = named$key, type = named$mark_type, variant = named$variant, url = named$archive_url
)

# a variant belongs to a sport when at least half of its teams have one
n_teams <- table(teams$sport)
have <- table(paste(named$sport, named$type, named$variant))
frac <- as.numeric(have) / as.numeric(n_teams[sub(" .*", "", names(have))])
keep <- names(have)[frac >= 0.5]
message("named variants dropped (under half of the sport's teams):")
print(data.frame(variant = names(have)[frac < 0.5], teams = as.integer(have)[frac < 0.5]), row.names = FALSE)
named <- named[paste(named$sport, named$type, named$variant) %in% keep, ]

# ---------------------------------------------------------------------------
# Checks and save
# ---------------------------------------------------------------------------

logo_marks <- rbind(canonical[c("sport", "key", "type", "variant", "url")], named)
logo_marks <- logo_marks[order(logo_marks$sport, logo_marks$key, logo_marks$type, logo_marks$variant), ]
rownames(logo_marks) <- NULL

stopifnot(
  !anyNA(logo_marks),
  startsWith(logo_marks$url, cdn),
  !anyDuplicated(logo_marks[c("sport", "key", "type", "variant")]),
  paste(logo_marks$sport, logo_marks$key) %in% paste(logo_ref$sport, logo_ref$team_abbr),
  # every row of the team reference has its primary logo
  paste(logo_ref$sport, logo_ref$team_abbr) %in%
    with(logo_marks, paste(sport, key)[type == "logo" & variant == "primary"])
)

# coverage: teams with each variant, per sport
message("archive coverage (teams with the mark, of ", nrow(teams), "):")
cov <- with(logo_marks[paste(logo_marks$sport, logo_marks$key) %in% paste(teams$sport, teams$team_abbr), ], {
  table(paste(type, variant), sport)
})
print(cov)
message("teams without an archived mark their sport has:")
for (sv in rownames(cov)) {
  for (s in colnames(cov)) {
    if (cov[sv, s] == 0 || cov[sv, s] == n_teams[[s]]) next
    tv <- strsplit(sv, " ")[[1]]
    has <- logo_marks$key[logo_marks$sport == s & logo_marks$type == tv[1] & logo_marks$variant == tv[2]]
    message("  ", s, " ", sv, ": ", paste(setdiff(teams$team_abbr[teams$sport == s], has), collapse = ", "))
  }
}

# integrity: the archive serves what its names say; how many sources still
# serve the archived bytes (three files per sport)
if (getRversion() >= "4.5.0") {
  set.seed(14)
  sampled <- do.call(rbind, lapply(split(canonical, canonical$sport), function(d) d[sample(nrow(d), 3), ]))
  sha_of_file <- function(url) {
    f <- tempfile()
    on.exit(unlink(f))
    utils::download.file(url, f, mode = "wb", quiet = TRUE)
    unname(tools::sha256sum(f))
  }
  archived <- vapply(sampled$url, sha_of_file, "")
  stopifnot(archived == sha_of_url(sampled$url))
  live <- vapply(sampled$source_url, function(u) tryCatch(sha_of_file(u), error = function(e) NA_character_), "")
  same <- live == archived
  message(sum(same, na.rm = TRUE), " of ", length(same), " sampled source files are byte-identical to the archive copy")
  if (!all(same, na.rm = TRUE)) {
    message("differ (replaced at the source since the snapshot): ", paste(sampled$source_url[!same %in% TRUE], collapse = ", "))
  }
}

usethis::use_data(
  logo_ref, abbr_mapping, logo_history, logo_marks,
  internal = TRUE, overwrite = TRUE, compress = "xz"
)
