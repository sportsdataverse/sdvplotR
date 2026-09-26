# Render the man/figures previews for the SportsDataverse table themes.
#
# Run from the package root: Rscript data-raw/theme_previews.R
#
# Each preview is saved with gt_save_crop(), padded in the theme's own
# background (from theme_bg). Set SDV_PREVIEW_HTML_DIR to write the themed
# tables as HTML there instead, for a machine where chromote cannot load the
# Google Fonts the themes import; screenshot the `.gt_table` in each file at 2x
# and pad it with magick::image_border() in the same background.

pkgload::load_all(quiet = TRUE)
library(gt)

# 2023 regular season, AFC West
standings <- data.frame(
  team = c("KC", "LV", "DEN", "LAC"),
  name = c("Kansas City Chiefs", "Las Vegas Raiders", "Denver Broncos", "Los Angeles Chargers"),
  w = c(11, 8, 8, 5),
  l = c(6, 9, 9, 12)
)
standings$pct <- standings$w / (standings$w + standings$l)

standings_table <- function() {
  gt(standings) |>
    gt_sdv_logos(columns = "team", sport = "nfl", height = 28) |>
    cols_label(team = "", name = "Team", w = "W", l = "L", pct = "Win pct") |>
    # sports convention: win percentage without the leading zero (.647)
    fmt(columns = "pct", fns = function(x) sub("^0", "", sprintf("%.3f", x))) |>
    tab_header("AFC West standings", "2023 regular season") |>
    tab_source_note("Data: nflverse")
}

# 2023 regular season, Kansas City Chiefs
leaders_table <- function() {
  data.frame(
    player = c("Patrick Mahomes", "Travis Kelce", "Isiah Pacheco"),
    stat = c("Passing", "Receiving", "Rushing"),
    yards = c(4183, 984, 935)
  ) |>
    gt() |>
    cols_label(player = "Player", stat = "", yards = "Yards") |>
    fmt_number(columns = "yards", decimals = 0) |>
    tab_header("Chiefs yardage leaders", "2023 regular season") |>
    tab_source_note("Data: nflverse")
}

previews <- list(
  gt_theme_sdv = list(standings_table() |> gt_theme_sdv(density = "social"), "gt_theme_sdv", "light"),
  gt_theme_sdv_dark = list(
    standings_table() |> gt_theme_sdv(style = "dark", density = "social"), "gt_theme_sdv", "dark"
  ),
  gt_theme_sdv_team = list(
    leaders_table() |> gt_theme_sdv_team(team = "KC", sport = "nfl", density = "social"), "gt_theme_sdv_team", ""
  )
)

html_dir <- Sys.getenv("SDV_PREVIEW_HTML_DIR")
for (name in names(previews)) {
  p <- previews[[name]]
  bg <- theme_bg$bg[theme_bg$theme == p[[2]] & theme_bg$has_style == p[[3]]]
  if (nzchar(html_dir)) {
    dir.create(html_dir, showWarnings = FALSE, recursive = TRUE)
    gtsave(p[[1]], file.path(html_dir, paste0(name, ".html")))
    writeLines(bg, file.path(html_dir, paste0(name, ".bg")))
  } else {
    gt_save_crop(p[[1]], file.path("man/figures", paste0(name, ".png")), bg = bg, whitespace = 40)
  }
}
