# The offline / CRAN fallback in R/sysdata.rda: sdvplot's team index and a
# trimmed copy of the sdv-assets logo manifest, as R/index.R reads them live.
# Run data-raw/export_index.py first, then, from the package root:
#   Rscript data-raw/build_index_snapshot.R
src <- "data-raw/index"
ver <- trimws(readLines(file.path(src, "latest.txt"), n = 1))
read_csv_chr <- function(path) {
  con <- if (grepl("\\.gz$", path)) gzfile(path) else file(path)
  df <- utils::read.csv(con, colClasses = "character", na.strings = "", encoding = "UTF-8", check.names = FALSE)
  for (col in intersect(c("valid_from", "valid_to"), names(df))) df[[col]] <- as.integer(df[[col]])
  df
}
snapshot_teams <- read_csv_chr(file.path(src, ver, "teams.csv.gz"))
snapshot_aliases <- read_csv_chr(file.path(src, ver, "aliases.csv.gz"))
marks <- read_csv_chr(file.path(src, "marks.csv"))
snapshot_marks <- marks[c(
  "level", "league", "entity_id", "entity_name", "mark_type", "variant",
  "valid_from", "valid_to", "source", "first_seen", "sha256", "ext"
)]
snapshot_meta <- list(index_version = ver, manifest_rows = nrow(marks), built = format(Sys.Date()))
fold <- readLines(file.path(src, "fold.txt"), encoding = "UTF-8")
fold_from <- fold[[1]]
fold_to <- fold[[2]]
stopifnot(nchar(fold_from) == nchar(fold_to))

env <- new.env()
load("R/sysdata.rda", envir = env)
rm(list = intersect(c("logo_ref", "logo_marks", "logo_history", "abbr_mapping", "soccer_ambiguous"), ls(env)), envir = env)
for (n in c("snapshot_teams", "snapshot_aliases", "snapshot_marks", "snapshot_meta", "fold_from", "fold_to")) {
  assign(n, get(n), envir = env)
}
save(list = ls(env), file = "R/sysdata.rda", envir = env, compress = "xz")
message("sysdata.rda: ", file.size("R/sysdata.rda"), " bytes; index ", ver)
