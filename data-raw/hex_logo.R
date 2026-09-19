# Build the sdvplotR hex logo (man/figures/logo.png) and the pkgdown favicons.
# ============================================================================
# Design ("axis", chosen 2026-09-18): the SportsDataverse starfield masked to
# the org's hex, the wordmark set in Russo One with the SDV blue-to-cyan
# gradient, and a bar chart in eight teams' own colours -- one team per league,
# their logos as the axis labels -- drawn with the package's own resolvers and
# ggpath. Everything sits inside a 30 px print-safe inset (see SAFE_PX).
#
# Run from the package root:  Rscript data-raw/hex_logo.R
# Requires: ggplot2, ggpath, magick, showtext, sysfonts (dev-only).
# The candidate explorations that led here live in hex_logo_options*.R.

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)

LOGO_FONT <- "russo"
load_fonts(LOGO_FONT)

logo_teams <- vapply(names(picks), function(s) picks[[s]][1], character(1))   # KC BOS NY LAD PHI FSU PUR SC
paths <- one_per_league()
cols <- first_colors()

x <- seq(-0.46, 0.46, length.out = 8)
h <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)
base <- -0.48
bars <- data.frame(x = x, ymax = base + h * 0.78, fill = cols, path = paths)
grid <- data.frame(y = base + seq(0.2, 0.8, by = 0.2) * 0.78)
grid$half <- safe_halfwidth(grid$y) - 0.04

p <- ggplot() + base_sky() +
  geom_segment(data = grid, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.18), linewidth = 0.4) +
  geom_rect(data = bars, aes(xmin = x - 0.04, xmax = x + 0.04, ymin = base, ymax = ymax, fill = fill), alpha = 0.95) +
  scale_fill_identity() +
  annotate("segment", x = -0.58, xend = 0.58, y = base, yend = base, colour = line_col(0.7), linewidth = 0.6) +
  geom_from_path(data = bars, aes(x, base - 0.09, path = path), width = 0.075) +
  title_layer(LOGO_FONT, "gradient", y = 0.55, fit_width = 0.98) +
  finish()

dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)
big <- save_hex(p, tempdir(), "sdvplotR-logo")
file.copy(big, "man/figures/logo.png", overwrite = TRUE)
cat("wrote man/figures/logo.png (1036 x 1200) with", paste(logo_teams, collapse = " "), "\n")

# favicons for pkgdown (pkgdown::build_favicons() needs an external API)
logo <- magick::image_trim(magick::image_read("man/figures/logo.png"))
dir.create("pkgdown/favicon", showWarnings = FALSE, recursive = TRUE)
square <- function(px) {
  magick::image_extent(magick::image_scale(logo, sprintf("%dx%d", px, px)), sprintf("%dx%d", px, px), color = "none")
}
for (px in c(60, 76, 120, 152, 180)) {
  magick::image_write(square(px), sprintf("pkgdown/favicon/apple-touch-icon-%dx%d.png", px, px))
}
magick::image_write(square(180), "pkgdown/favicon/apple-touch-icon.png")
magick::image_write(square(16), "pkgdown/favicon/favicon-16x16.png")
magick::image_write(square(32), "pkgdown/favicon/favicon-32x32.png")
magick::image_write(square(96), "pkgdown/favicon/favicon-96x96.png")
magick::image_write(c(square(16), square(32), square(48)), "pkgdown/favicon/favicon.ico", format = "ico")
cat("wrote pkgdown/favicon/*\n")
