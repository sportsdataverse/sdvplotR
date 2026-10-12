# The team index (teams + aliases, from sdvplot) and the logo-mark manifest
# (sdv-assets), fetched from the SportsDataverse CDN and cached on disk. The
# copy in sysdata.rda (snapshot_*) is the fallback offline and under a CRAN
# check. Nothing else in the package touches the network or the snapshot for
# team data: everything reads index_teams(), index_aliases() and index_marks().

cdn_root <- "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public"
index_cache <- new.env(parent = emptyenv())

team_cols <- c(
  "league", "team_id", "abbr", "name", "short_name", "location", "program",
  "conference_id", "conference", "color_primary", "color_secondary", "color_source"
)
alias_cols <- c("league", "id_system", "value", "team_id", "valid_from", "valid_to")
mark_cols <- c(
  "level", "league", "entity_id", "entity_name", "mark_type", "variant", "valid_from",
  "valid_to", "source", "first_seen", "sha256", "ext", "archive_url"
)

index_url <- function() getOption("sdvplotR.index_url", paste0(cdn_root, "/index"))
manifest_url <- function() getOption("sdvplotR.manifest_url", paste0(cdn_root, "/manifest/marks.csv"))
use_snapshot <- function() isTRUE(getOption("sdvplotR.offline", FALSE)) || probably_cran()
cache_path <- function(...) file.path(tools::R_user_dir("sdvplotR", "cache"), ...)

# `path`, refreshed from `url` when missing or older than `ttl` seconds. The
# download goes to a temp file in the same directory and is copied over only
# when complete, so a dropped connection never leaves a truncated cache file. A
# failed refresh returns a stale copy marked with attr "stale" (the reason), and
# errors only when there is none.
fetch_to_cache <- function(url, path, ttl = getOption("sdvplotR.index_ttl", 86400)) {
  if (file.exists(path) && difftime(Sys.time(), file.mtime(path), units = "secs") < ttl) {
    return(path)
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  tmp <- tempfile(tmpdir = dirname(path))
  on.exit(unlink(tmp), add = TRUE)
  err <- tryCatch(
    {
      warnings_fail(utils::download.file(url, tmp, mode = "wb", quiet = TRUE))
      if (!file.exists(tmp) || file.size(tmp) == 0) "empty response" else NULL
    },
    error = function(e) conditionMessage(e)
  )
  if (is.null(err)) {
    file.copy(tmp, path, overwrite = TRUE)
    return(path)
  }
  if (file.exists(path)) {
    return(structure(path, stale = err))
  }
  stop("could not download ", url, ": ", err, call. = FALSE)
}

# Any warning is a failure (a short download, a truncated or corrupt file), so
# the caller's fallback runs instead of a shortened table loading as valid;
# only warnings matching `allow` (benign ones) are muffled.
warnings_fail <- function(expr, allow = character()) {
  withCallingHandlers(expr, warning = function(w) {
    if (any(vapply(allow, grepl, NA, conditionMessage(w), fixed = TRUE))) {
      invokeRestart("muffleWarning")
    }
    stop(conditionMessage(w), call. = FALSE)
  })
}

read_index_csv <- function(path, cols) {
  # read whole, and require a final newline: a file cut off mid-row (even one
  # re-gzipped as valid) would otherwise load as a shortened table
  con <- if (grepl("\\.gz$", path)) gzfile(path, "rb") else file(path, "rb")
  on.exit(close(con))
  raw <- warnings_fail(readBin(con, "raw", n = file.size(path) * 50 + 1e6))
  if (!length(raw) || raw[length(raw)] != as.raw(10L)) stop(basename(path), " is truncated (no final newline)", call. = FALSE)
  df <- warnings_fail(utils::read.csv(
    text = rawToChar(raw), colClasses = "character", na.strings = "", encoding = "UTF-8", check.names = FALSE
  ))
  miss <- setdiff(cols, names(df))
  if (length(miss)) stop(basename(path), " lacks columns ", paste(miss, collapse = ", "), call. = FALSE)
  df <- df[cols]
  for (col in intersect(c("valid_from", "valid_to"), cols)) df[[col]] <- as.integer(df[[col]])
  df
}

warn_once <- function(id, msg, .envir = parent.frame()) {
  if (id %in% index_cache$warned) {
    return(invisible())
  }
  index_cache$warned <- c(index_cache$warned, id)
  cli::cli_warn(msg, class = "sdvplotR_fallback", .envir = .envir)
}

# teams and aliases are one unit at one version: if either fails both come
# from the same fallback
read_live_index <- function() {
  ptr <- fetch_to_cache(paste0(index_url(), "/latest.txt"), cache_path("index", "latest.txt"))
  ver <- trimws(readLines(ptr, n = 1L, warn = FALSE))
  if (!length(ver) || !grepl("^[0-9a-f]{6,64}$", ver)) stop("latest.txt does not name an index version", call. = FALSE)
  get <- function(file, cols) {
    read_index_csv(fetch_to_cache(paste(index_url(), ver, file, sep = "/"), cache_path("index", ver, file), ttl = Inf), cols)
  }
  stale <- attr(ptr, "stale")
  idx <- list(
    teams = get("teams.csv.gz", team_cols), aliases = get("aliases.csv.gz", alias_cols),
    version = ver, source = if (is.null(stale)) "live" else "cache"
  )
  # only once both reads have succeeded: a corrupt file falls back to the snapshot instead
  if (!is.null(stale)) {
    warn_once("index", c("Could not refresh the sdvplotR team index ({stale}).", i = "Using the cached index {.val {ver}}."))
  }
  idx
}

load_index <- function() {
  if (!is.null(index_cache$teams)) {
    return(invisible())
  }
  idx <- if (!use_snapshot()) {
    tryCatch(read_live_index(), error = function(e) {
      warn_once("index", c(
        "Could not read the sdvplotR team index: {conditionMessage(e)}",
        i = "Using the index bundled with the package ({.val {snapshot_meta$index_version}})."
      ))
      NULL
    })
  }
  idx <- idx %||% list(
    teams = snapshot_teams, aliases = snapshot_aliases,
    version = snapshot_meta$index_version, source = "snapshot"
  )
  list2env(idx, envir = index_cache)
  invisible()
}

snapshot_marks_table <- function() {
  m <- snapshot_marks
  m$archive_url <- paste0(cdn_root, "/sha256/", substr(m$sha256, 1, 2), "/", m$sha256, ".", m$ext)
  m
}

load_marks <- function() {
  m <- if (!use_snapshot()) {
    tryCatch(
      {
        path <- fetch_to_cache(manifest_url(), cache_path("manifest", "marks.csv"))
        df <- read_index_csv(path, mark_cols)
        stale <- attr(path, "stale")
        if (!is.null(stale)) {
          warn_once("marks", c("Could not refresh the logo manifest ({stale}).", i = "Using the cached copy."))
          source <- "cache"
        }
        attr(df, "source") <- if (is.null(stale)) "live" else "cache"
        df
      },
      error = function(e) {
        warn_once("marks", c(
          "Could not read the logo manifest: {conditionMessage(e)}",
          i = "Using the marks bundled with the package."
        ))
        NULL
      }
    )
  }
  if (is.null(m)) {
    index_cache$marks_source <- "snapshot"
    m <- snapshot_marks_table()
  } else {
    index_cache$marks_source <- attr(m, "source")
    attr(m, "source") <- NULL
    # the URL reaches HTML (gt, reactable, plotly, leaflet): only a plain https URL passes
    ok <- grepl("^https://[^[:space:]\"'<>]+$", m$archive_url)
    if (!all(ok)) {
      cli::cli_warn("Dropped {sum(!ok)} logo manifest row{?s} whose archive_url is not a plain https URL.")
      m <- m[ok, , drop = FALSE]
    }
  }
  index_cache$marks <- m
}

index_teams <- function() {
  load_index()
  index_cache$teams
}

index_aliases <- function() {
  load_index()
  index_cache$aliases
}

index_marks <- function() {
  load_index()
  if (is.null(index_cache$marks)) load_marks()
  index_cache$marks
}

forget_index <- function() {
  rm(list = ls(index_cache, all.names = TRUE), envir = index_cache)
  invisible()
}

#' Clear the sdvplotR caches
#'
#' @description sdvplotR keeps the team index, the logo manifest and the NFL
#'   headshot map in memory for the session, keeps the index and manifest on
#'   disk (in `tools::R_user_dir("sdvplotR", "cache")`) for a day, and draws
#'   images through 'ggpath', which caches them for the session. This clears
#'   all of them, so the next call reads the CDN again.
#' @return Invisibly `NULL`, called for its side effect.
#' @seealso [sdv_versions()] for what is loaded now.
#' @export
#' @examples
#' sdv_clear_cache()
sdv_clear_cache <- function() {
  forget_index()
  forget_headshot_map()
  if (!probably_cran()) unlink(tools::R_user_dir("sdvplotR", "cache"), recursive = TRUE)
  if ("clear_cache" %in% getNamespaceExports("ggpath")) getExportedValue("ggpath", "clear_cache")()
  cli::cli_alert_success("sdvplotR caches cleared.")
  invisible(NULL)
}

#' Versions of the data sdvplotR is using
#'
#' @description Which team index and logo manifest the session has loaded and
#'   where they came from: `"live"` (the SportsDataverse CDN, or the disk cache
#'   within a day of it), `"cache"` (an older disk copy, after a failed
#'   refresh) or `"snapshot"` (the copy bundled with the package: offline,
#'   with `options(sdvplotR.offline = TRUE)`, or during a CRAN check). The R
#'   counterpart of sdvplot's `versions()`.
#' @return A list with `package`, `index_version`, `index_source`,
#'   `manifest_rows` and `manifest_source`.
#' @export
#' @examples
#' sdv_versions()
sdv_versions <- function() {
  load_index()
  m <- index_marks()
  list(
    package = as.character(utils::packageVersion("sdvplotR")),
    index_version = index_cache$version,
    index_source = index_cache$source,
    manifest_rows = nrow(m),
    manifest_source = index_cache$marks_source
  )
}
