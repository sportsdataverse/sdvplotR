# Build the sdvplotR hex logo (man/figures/logo.png) and the pkgdown favicons.
# ============================================================================
# Design ("wall_sky", chosen 2026-11-02, round 5 of hex_logo_options_v5.R):
# the SportsDataverse starfield masked to the org's hex, a muted wall of team
# logos from all eight leagues (six teams each, as nflplotR's hex mutes the NFL's
# behind its name), and the wordmark across the middle in Russo One with the SDV
# blue-to-cyan gradient. Everything sits inside a 30 px print-safe inset (see
# SAFE_PX).
#
# Run from the package root:  Rscript data-raw/hex_logo.R
# Requires: ggplot2, ggpath, magick, showtext, sysfonts (dev-only).
# The candidate explorations that led here live in hex_logo_options*.R.

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)

LOGO_FONT <- "russo"
load_fonts(LOGO_FONT)

# hex-packed rows 0.21 apart, cells 0.25 apart, kept 0.08 inside the safe hexagon;
# the rows next to the wordmark (|y| <= 0.18) stay empty
ys <- seq(0.84, -0.84, by = -0.21)
wall <- do.call(rbind, lapply(seq_along(ys), function(i) {
  xs <- seq(-1.2, 1.2, by = 0.25) + if (i %% 2) 0 else 0.125
  keep <- abs(xs) <= safe_halfwidth(ys[i]) - 0.08
  data.frame(x = xs[keep], y = rep(ys[i], sum(keep)))
}))
set.seed(7)
wall$path <- sample(rep(logo_paths(6), length.out = nrow(wall)))
wall <- wall[abs(wall$y) > 0.18, ]

p <- ggplot() + base_sky() +
  geom_from_path(data = wall, aes(x, y, path = path), width = 0.1, alpha = 0.34) +
  title_layer(LOGO_FONT, "gradient", y = 0, fit_width = 1.28) +
  finish()

dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)
big <- save_hex(p, tempdir(), "sdvplotR-logo")
# 480 px wide is twice the largest size the README and site show it at; the
# full 1036 x 1200 render would add a megabyte to the installed package
magick::image_write(magick::image_resize(magick::image_read(big), "480x"), "man/figures/logo.png", format = "png")
cat("wrote man/figures/logo.png (480 x 556) with", nrow(wall), "logos\n")

# favicons for pkgdown (pkgdown::build_favicons() needs an external API)
logo <- magick::image_trim(magick::image_read(big))
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
# pkgdown's template also links favicon.svg: an SVG wrapping the 96 px PNG
png96 <- base64enc::base64encode("pkgdown/favicon/favicon-96x96.png")
writeLines(sprintf(paste0(
  '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="96" height="96" viewBox="0 0 96 96">',
  '<image width="96" height="96" xlink:href="data:image/png;base64,%s"/></svg>'
), png96), "pkgdown/favicon/favicon.svg")
cat("wrote pkgdown/favicon/*\n")

# shrink man/figures/logo.png to a palette PNG (installed size)
source("data-raw/shrink_figures.R")
