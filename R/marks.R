# Choosing a team's mark from the logo manifest, as sdvplot's _marks.py: the
# variant, then season coverage within each variant, then source preference.

# Official sources first, then archived copies, then derived crops (sdv-assets source names)
source_rank <- c(
  espn = 0L, nflverse = 1L, nhl = 1L, mlbstatic = 1L, fox = 1L, hockeytech = 2L, cricinfo = 2L,
  "ncaa.com" = 3L, "nwhl.co" = 4L, shiftstats = 4L, wayback = 4L, "aaf.com" = 5L, "aaf-strip-crop" = 6L
)
mark_types <- c("logo", "wordmark")

check_mark_type <- function(mark_type, call = rlang::caller_env()) {
  if (!rlang::is_string(mark_type) || !mark_type %in% mark_types) {
    cli::cli_abort("{.arg mark_type} must be one of {.val {mark_types}}, not {.val {mark_type}}.", call = call)
  }
}

# A variant no mark in the archive has is a typo, not one this team lacks (that
# falls back); "default" and "dark" are always valid.
check_mark_variant <- function(variant, league, call = rlang::caller_env()) {
  if (rlang::is_string(variant) && variant %in% c("default", "dark")) {
    return(invisible(variant))
  }
  if (!rlang::is_string(variant) || !variant %in% index_marks()$variant) {
    known <- sort(unique(c("default", "dark", stats::na.omit(ranked_marks(league)$variant))), method = "radix")
    cli::cli_abort(c(
      "Unknown variant {.val {variant}}: no mark in the archive has it.",
      i = "{.val {league}} marks come in {.val {known}}."
    ), call = call)
  }
  invisible(variant)
}

# key ("source:entity_id" for a team mark, "level:league:source:entity_id" for
# a conference or league mark) -> team_id, unique mappings only, with the union
# of the mapping's season ranges (NA = unbounded on that side)
mark_aliases <- function(league) {
  a <- index_aliases()
  a <- a[a$league == league & a$id_system == "mark", , drop = FALSE]
  g <- split(seq_len(nrow(a)), tolower(trimws(a$value)))
  g <- g[vapply(g, function(i) length(unique(a$team_id[i])) == 1L, logical(1))]
  data.frame(
    key = names(g),
    team_id = vapply(g, function(i) a$team_id[i[1]], character(1)),
    valid_from = vapply(g, function(i) if (anyNA(a$valid_from[i])) NA_integer_ else min(a$valid_from[i]), integer(1)),
    valid_to = vapply(g, function(i) if (anyNA(a$valid_to[i])) NA_integer_ else max(a$valid_to[i]), integer(1)),
    row.names = NULL
  )
}

# Every manifest row of one league that maps to one index row, with its
# effective range (the row's narrowed by its alias's), best first.
ranked_marks <- function(league) {
  key <- paste0("ranked:", league)
  if (is.null(index_cache[[key]])) {
    m <- index_marks()
    nt <- m$level %in% non_team_programs
    m <- m[(m$level == "team" & m$league == league) | nt, , drop = FALSE]
    nt <- m$level %in% non_team_programs
    k <- ifelse(nt, paste(m$level, m$league, m$source, m$entity_id, sep = ":"), paste(m$source, m$entity_id, sep = ":"))
    al <- mark_aliases(league)
    j <- match(tolower(trimws(k)), al$key)
    m <- m[!is.na(j), , drop = FALSE]
    j <- j[!is.na(j)]
    m$team_id <- al$team_id[j]
    m$valid_from <- pmax(m$valid_from, al$valid_from[j], na.rm = TRUE)
    m$valid_to <- pmin(m$valid_to, al$valid_to[j], na.rm = TRUE)
    m$source_rank <- unname(source_rank[m$source])
    m$source_rank[is.na(m$source_rank)] <- 5L
    o <- order(m$source_rank, is.na(m$valid_to), m$valid_to, m$first_seen, m$valid_from, m$sha256,
      decreasing = c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE), method = "radix", na.last = TRUE
    )
    m <- m[o, , drop = FALSE]
    rownames(m) <- NULL
    index_cache[[key]] <- m
  }
  index_cache[[key]]
}

# The best mark: the requested variant; then, keeping its polarity, "default"
# and an on_light variant, or for "dark" an on_dark variant and then "default";
# then any variant. Within each, season-covering rows first (explicit ranges
# before open-ended ones), else any row.
select_mark <- function(team_id, league, season, variant, mark_type) {
  r <- ranked_marks(league)
  r <- r[r$team_id == team_id & r$mark_type == mark_type, , drop = FALSE]
  side <- if (variant == "dark") "dark" else "light"
  v <- r$variant
  requested <- v == variant
  polarity <- v == paste0("on_", side) | endsWith(v, paste0("_on_", side))
  default <- v == "default"
  sets <- if (side == "dark") list(requested, polarity, default) else list(requested, default, polarity)
  for (keep in c(sets, list(rep(TRUE, nrow(r))))) {
    f <- which(keep %in% TRUE)
    if (!is.na(season)) {
      cov <- f[(is.na(r$valid_from[f]) | season >= r$valid_from[f]) & (is.na(r$valid_to[f]) | season <= r$valid_to[f])]
      dated <- cov[!is.na(r$valid_from[cov]) | !is.na(r$valid_to[cov])]
      if (length(dated)) return(r[dated[1], , drop = FALSE])
      if (length(cov)) return(r[cov[1], , drop = FALSE])
    }
    if (length(f)) return(r[f[1], , drop = FALSE])
  }
  NULL
}

mark_url <- function(team, league, season = NULL, variant = "default", mark_type = "logo",
                     id_system = "auto", strict = FALSE, call = rlang::caller_env()) {
  check_league(league, call)
  check_mark_type(mark_type, call)
  check_mark_variant(variant, league, call)
  r <- resolve_ids(team, league, season, id_system, marks = TRUE, call = call)
  report_unresolved(team, r$why, league, strict, call)
  seasons <- norm_seasons(season, length(r$ids), league, call)
  combo <- paste(r$ids, seasons, sep = "\r")
  u <- which(!duplicated(combo) & !is.na(r$ids))
  url_u <- vapply(u, function(j) {
    row <- select_mark(r$ids[j], league, seasons[j], variant, mark_type)
    if (is.null(row)) NA_character_ else row$archive_url
  }, character(1))
  out <- url_u[match(combo, combo[u])]
  out[is.na(r$ids)] <- NA_character_
  none <- unique(as.character(team)[!is.na(r$ids) & is.na(out)])
  if (length(none)) {
    cli::cli_warn("No {mark_type} archived for {.val {none}} ({.val {league}}).",
      class = "sdvplotR_no_mark_warning", call = call
    )
  }
  unname(out)
}

#' Every archived mark for a team
#'
#' @description The logo manifest's rows for one team (logos and wordmarks,
#'   every variant, source and era), best first: the rows the logo helpers
#'   choose from. The R counterpart of sdvplot's `marks()`.
#' @param team One team identifier, or a conference or league key (`"SEC"`, `"AFC"`).
#' @inheritParams sdv_resolve
#' @return A data frame of manifest rows with `team_id`, `variant`,
#'   `mark_type`, `valid_from`, `valid_to` (the effective season range),
#'   `source`, `source_rank` and `archive_url`.
#' @export
#' @examples
#' m <- sdv_marks("KC", "nfl")
#' table(m$variant)
sdv_marks <- function(team, league, season = NULL, id_system = "auto") {
  if (length(team) != 1L) cli::cli_abort("{.arg team} must be one team; use {.fn sdv_resolve} for several.")
  r <- resolve_ids(team, league, season, id_system, marks = TRUE)
  report_unresolved(team, r$why, league, strict = TRUE)
  if (is.na(r$ids)) cli::cli_abort("{.fn sdv_marks} needs a team, not {.val {team}}.")
  m <- ranked_marks(league)
  m <- m[m$team_id == r$ids, , drop = FALSE]
  rownames(m) <- NULL
  m
}

#' Team logo and wordmark URLs
#'
#' @description The image URL behind every sdvplotR geom, theme element and
#'   table helper: the SportsDataverse archive's copy of the team's mark
#'   (content-addressed and immutable), chosen for the season. The R
#'   counterpart of sdvplot's `logo_url()`.
#' @param team A vector of team identifiers, or conference / league keys
#'   (`"SEC"`, `"Big 12"`, `"AFC"`), read after every team alias.
#' @inheritParams sdv_resolve
#' @param season `NULL` for today's mark, or a season (or one per team): the
#'   mark the team wore that season where the archive dates its marks.
#' @param variant `"default"`, `"dark"`, or a named variant from
#'   [sdv_marks()] (`"scoreboard"`, `"grayscale"`, `"cap_on_light"`, ...). A
#'   team without it gets its closest mark of the same polarity; a name no mark
#'   in the archive has is an error listing the league's variants.
#' @param mark_type `"logo"` or `"wordmark"`.
#' @return A character vector the length of `team`: the URL, or `NA` (with a
#'   warning) where the team does not resolve or has no such mark.
#' @seealso [sdv_headshot_url()], [sdv_marks()].
#' @export
#' @examples
#' sdv_logo_url(c("KC", "Buffalo Bills", "OAK"), "nfl")
#' sdv_logo_url("NYJ", "nfl", variant = "scoreboard")
#' sdv_logo_url("QUE", "nhl", season = 1990)
#' sdv_logo_url("KC", "nfl", mark_type = "wordmark")
#' sdv_logo_url("SEC", "cfb")
sdv_logo_url <- function(team, league, season = NULL, variant = "default", mark_type = "logo",
                         id_system = "auto", strict = FALSE) {
  mark_url(team, league, season, variant, mark_type, id_system, strict)
}
