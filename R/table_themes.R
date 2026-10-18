# The surveyed table-style registry (inst/extdata/table_themes.json): resolve one
# theme, or list them. Same values and semantics as sdvplot's _table_themes.py and
# sdvtables' registry.ts, so every language agrees.

.tt_cache <- new.env(parent = emptyenv())

# same defaults as sdvplot (shoot.py palette())
.tt_defaults <- list(
  bg = "#ffffff", text = "#222222", muted = "#666666", accent = "#c70000",
  rule = "#222222", hline = "#e5e5e5", stripe = "#f5f5f5", summaryBg = "#f0f0f0",
  link = "#1a5fb4", pos = "#17692f", neg = "#a1231b", posBg = "#e3f3e6",
  negBg = "#fbe5e4", heatLow = "#f8696b", heatMid = "#fcfcff", heatHigh = "#63be7b"
)

# light fallbacks are unreadable on a dark ground
.tt_dark_defaults <- list(
  text = "#e8e8e8", muted = "#a0a6ad", rule = "#e8e8e8", hline = "#2c3138",
  stripe = "#1c2026", summaryBg = "#2a2f36", link = "#8ab4f8", pos = "#5fd08a",
  neg = "#ff8a80", posBg = "#123522", negBg = "#3d1614", bg = "#14171c"
)

# reactablefmtr ports share these bare names with registry ids of other looks
.tt_site_ports <- c("espn", "fivethirtyeight", "pff")

.tt_fmtr_names <- c(
  "cerulean", "clean", "cosmo", "cyborg", "dark", "darkly", "default", "espn",
  "fivethirtyeight", "flatly", "hoverdark", "hoverlight", "journal", "lux",
  "midnight", "midnightblue", "minty", "no_lines", "nytimes", "pff", "sandstone",
  "sanfran", "slate", "spacelab", "sunrise", "superhero", "void"
)

.tt_registry <- function() {
  if (is.null(.tt_cache$registry)) {
    path <- system.file("extdata", "table_themes.json", package = "sdvplotR")
    .tt_cache$registry <- jsonlite::read_json(path, simplifyVector = FALSE)$themes
  }
  .tt_cache$registry
}

.tt_dark_ids <- function(reg = .tt_registry()) {
  sort(names(reg)[vapply(reg, function(t) !identical(t$darkPolicy, "none"), logical(1))],
    method = "radix"
  )
}

.tt_palette <- function(spec, mode) {
  p <- .tt_defaults
  if (mode == "dark") p[names(.tt_dark_defaults)] <- .tt_dark_defaults
  over <- spec[[mode]]
  for (k in names(over)) {
    v <- over[[k]]
    if (!is.null(v) && nzchar(v)) p[[k]] <- v
  }
  p$page <- if (is.null(p$page)) p$bg else p$page
  p$labelBg <- if (is.null(p$labelBg)) p$bg else p$labelBg
  p$labelColor <- if (is.null(p$labelColor)) p$muted else p$labelColor
  lapply(p, as.character)
}

# css with each {key} taken from the palette, else its default, else #888888; empty is "none"
.tt_border <- function(css, palette) {
  if (is.null(css) || !nzchar(css)) {
    return("none")
  }
  keys <- unique(regmatches(css, gregexpr("\\{\\w+\\}", css))[[1]])
  for (k in keys) {
    key <- substr(k, 2, nchar(k) - 1)
    val <- palette[[key]]
    if (is.null(val) || !nzchar(val)) val <- .tt_defaults[[key]]
    if (is.null(val)) val <- "#888888"
    css <- gsub(k, val, css, fixed = TRUE)
  }
  css
}

# up to 3 close registry ids: agrep for the candidates, adist (then id) for a stable order
.tt_close <- function(name, ids) {
  hit <- agrep(name, ids, max.distance = 0.3, value = TRUE)
  if (!length(hit)) {
    return(character())
  }
  d <- drop(utils::adist(name, hit))
  utils::head(hit[order(d, hit, method = "radix")], 3)
}

# the CSS generic family a face falls back to, guessed from its name (same rule as sdvplot)
.tt_generic_family <- function(family) {
  if (is.null(family) || !nzchar(family)) {
    return("sans-serif")
  }
  if (grepl("mono|code|courier", family, ignore.case = TRUE)) {
    return("monospace")
  }
  serif <- "serif|slab|bodoni|caslon|garamond|playfair|lora|newsreader|tinos|spectral|gelasio|merriweather"
  if (grepl(serif, family, ignore.case = TRUE) && !grepl("sans", tolower(family), fixed = TRUE)) {
    return("serif")
  }
  "sans-serif"
}

# a css font-family value: the quoted family then its generic fallback
.tt_font_stack <- function(family) {
  if (is.null(family) || !nzchar(family)) {
    return("sans-serif")
  }
  paste0("\"", family, "\", ", .tt_generic_family(family))
}

.tt_check_mode <- function(mode, call = rlang::caller_env()) {
  if (!is.character(mode) || length(mode) != 1L || !mode %in% c("light", "dark")) {
    cli::cli_abort("{.arg mode} must be {.val light} or {.val dark}, not {.obj_type_friendly {mode}}.", call = call)
  }
  invisible(mode)
}

#' List the surveyed table themes
#'
#' The registry of 122 table styles surveyed from published sources
#' (`"datagolf"`, `"wikipedia"`, `"nejm"`, ...), shared with the Python and
#' JavaScript packages. Use an id with [gt_theme_source()],
#' [reactable_theme_sdv()] or [table_theme_spec()].
#'
#' @param mode `"dark"` keeps only the themes that have a dark variant;
#'   `"light"` or `NULL` (the default) keeps all.
#' @param category Keep only this category (for example `"sports"`); `NULL`
#'   keeps all.
#'
#' @returns A tibble with one row per theme: `id`, `source`, `category` and
#'   `dark_policy` (`"native"`, `"derived"` or `"none"`).
#'
#' @examples
#' sdv_table_themes()
#' sdv_table_themes(mode = "dark", category = "sports")
#'
#' @seealso [table_theme_spec()] to resolve one theme, [gt_theme_source()] and
#'   [reactable_theme_sdv()] to apply one.
#' @export
sdv_table_themes <- function(mode = NULL, category = NULL) {
  if (!is.null(mode)) .tt_check_mode(mode)
  reg <- .tt_registry()
  keep <- vapply(reg, function(t) {
    !(identical(mode, "dark") && identical(t$darkPolicy, "none")) &&
      (is.null(category) || identical(t$category, category))
  }, logical(1))
  reg <- reg[keep]
  dplyr::tibble(
    id = names(reg),
    source = vapply(reg, function(t) t$source, character(1), USE.NAMES = FALSE),
    category = vapply(reg, function(t) t$category, character(1), USE.NAMES = FALSE),
    dark_policy = vapply(reg, function(t) t$darkPolicy, character(1), USE.NAMES = FALSE)
  )
}

#' Resolve a surveyed table theme
#'
#' One theme from the registry listed by [sdv_table_themes()]: fonts, sizes, a
#' complete palette and the structure (rules, stripes, label style), with every
#' `{key}` in the structure's border strings replaced by a palette color.
#'
#' @param name The theme id, for example `"datagolf"`, `"wikipedia"` or `"nejm"`.
#'   `"espn"`, `"fivethirtyeight"` and `"pff"` are reactablefmtr names, not
#'   registry ids: the surveyed look of those sites is `"espn-site"`,
#'   `"fivethirtyeight-site"` and `"pff-site"`.
#' @param mode `"light"` (default) or `"dark"`. Palette keys a theme leaves out
#'   take the shared defaults. `"dark"` on a light-only theme is an error that
#'   names three dark-capable themes in the same category.
#'
#' @returns A list with `id`, `source`, `category`, `fonts`, `sizes`, `palette`,
#'   `structure` and `dark_policy`.
#'
#' @examples
#' spec <- table_theme_spec("datagolf", "dark")
#' spec$palette$bg
#' spec$structure$rowRule
#'
#' @seealso [sdv_table_themes()] to list the ids, [gt_theme_source()] and
#'   [reactable_theme_sdv()] to apply one.
#' @export
table_theme_spec <- function(name, mode = c("light", "dark")) {
  mode <- if (identical(mode, c("light", "dark"))) "light" else mode
  .tt_check_mode(mode)
  if (!is.character(name) || length(name) != 1L || is.na(name)) {
    cli::cli_abort("{.arg name} must be a single theme id, not {.obj_type_friendly {name}}.")
  }
  reg <- .tt_registry()
  if (!name %in% names(reg)) {
    if (name %in% .tt_site_ports) {
      site <- paste0(name, "-site")
      port <- paste0("reactablefmtr::", name, "()")
      cli::cli_abort(c(
        "{.val {name}} is a reactablefmtr name, not a registry theme.",
        "i" = "Use {.val {site}} for the surveyed site look, or {.code {port}} for the port."
      ))
    }
    close <- .tt_close(name, names(reg))
    msg <- c("Unknown table theme {.val {name}}.")
    if (length(close)) msg <- c(msg, "i" = "Did you mean {.val {close}}?")
    cli::cli_abort(c(msg, "i" = "See {.fn sdv_table_themes} for the ids."))
  }
  s <- reg[[name]]
  if (mode == "dark" && (identical(s$darkPolicy, "none") || !length(s$dark))) {
    dark <- .tt_dark_ids(reg)
    same <- utils::head(dark[vapply(reg[dark], function(t) identical(t$category, s$category), logical(1))], 3)
    cat_ <- s$category
    advice <- if (length(same)) {
      paste0("dark-capable themes in category '", cat_, "': ", paste(same, collapse = ", "))
    } else {
      paste0("no dark-capable themes in category '", cat_, "'; try: ", paste(utils::head(dark, 3), collapse = ", "))
    }
    # rlang, not cli: cli wraps the sentence at the console width and splits the suggestion list
    rlang::abort(paste0("Theme '", name, "' is light-only; ", advice), class = "sdvplotR_light_only")
  }
  pal <- .tt_palette(s, mode)
  # a string is a border (or a plain word like "left"); lists and numbers pass through
  structure <- lapply(s$structure, function(v) if (is.character(v)) .tt_border(v, pal) else v)
  list(
    id = name, source = s$source, category = s$category,
    fonts = s$fonts, sizes = s$sizes, palette = pal, structure = structure,
    dark_policy = s$darkPolicy
  )
}
