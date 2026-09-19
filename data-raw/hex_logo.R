# Build the sdvplotR hex logo (man/figures/logo.png) with the package itself.
# ============================================================================
# Design: the SportsDataverse starfield (the org's brand background) masked to
# a hex, a brick mosaic of team logos from all eight leagues drawn with the
# package's own geom_from_path(), and the package name in plain bold white.
#
# Run from the package root:  Rscript data-raw/hex_logo.R
# Requires: ggplot2, ggpath, showtext, magick (dev-only).

devtools::load_all(quiet = TRUE)
library(ggplot2)

navy <- "#0B1A33"
edge <- "#071224"

sysfonts::font_add_google("Chivo", "chivo", bold.wt = 800)
showtext::showtext_opts(dpi = 600)
showtext::showtext_auto()

# pointy-top hexagon with circumradius 1 (width sqrt(3), height 2)
hex <- data.frame(
  x = cos(seq(pi / 2, 2 * pi + pi / 2, length.out = 7)),
  y = sin(seq(pi / 2, 2 * pi + pi / 2, length.out = 7))
)

# Background: the SportsDataverse starfield (sdv-web brand asset), with the
# SDV mark in the centre patched over by a clean strip of the same sky, then
# masked to the hexagon.
sky <- magick::image_read("data-raw/sdv-starfield.png")          # 1200 x 1200
sky <- magick::image_crop(sky, "1040x1200+80+0")                  # hex aspect
# feathered patch of clean sky (from above the mark) laid over the mark
patch <- magick::image_crop(sky, "760x480+140+0")
feather <- magick::image_draw(magick::image_blank(760, 480, "none"))
rect(80, 80, 680, 400, col = "white", border = NA)
dev.off()
feather <- magick::image_blur(feather, radius = 0, sigma = 40)
patch <- magick::image_composite(feather, patch, operator = "In")
sky <- magick::image_composite(sky, patch, operator = "Over", offset = "+140+370")
# mask to the hexagon (source-in)
hex_mask <- magick::image_draw(magick::image_blank(1040, 1200, "none"))
polygon(520 + 520 * hex$x / (sqrt(3) / 2), 600 - 600 * hex$y, col = "white", border = NA)
dev.off()
sky <- magick::image_composite(hex_mask, sky, operator = "In")
sky_raster <- as.raster(sky)

# three logos per league, laid out as a staggered brick mosaic
teams <- list(
  nfl = c("KC", "PHI", "DET"),
  nba = c("BOS", "LAL", "OKC"),
  wnba = c("NY", "LV", "IND"),
  mlb = c("LAD", "NYY", "ATL"),
  nhl = c("TOR", "EDM", "FLA"),
  cfb = c("ALA", "UGA", "MICH"),
  mbb = c("DUKE", "CONN", "KU"),
  wbb = c("SC", "IOWA", "LSU")
)
paths <- unlist(lapply(names(teams), function(s) logo_from_team(teams[[s]], sport = s)))
stopifnot(!anyNA(paths))
set.seed(7)
paths <- sample(paths)
rows <- 3
per_row <- 8
half_width <- c(0.62, 0.56, 0.47)   # taper with the hexagon
mosaic <- data.frame(
  path = paths,
  x = unlist(lapply(half_width, function(w) seq(-w, w, length.out = per_row))),
  y = rep(c(-0.06, -0.32, -0.58), each = per_row)
)

p <- ggplot() +
  annotation_raster(sky_raster, -sqrt(3) / 2, sqrt(3) / 2, -1, 1) +
  geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.08, alpha = 0.95) +
  annotate("text", x = 0, y = 0.5, label = "sdvplotR", family = "chivo", fontface = "bold",
           colour = "white", size = 6.6) +
  geom_path(data = hex, aes(x, y), colour = edge, linewidth = 1.1, lineend = "round", linejoin = "round") +
  coord_fixed(xlim = c(-sqrt(3) / 2 - 0.01, sqrt(3) / 2 + 0.01), ylim = c(-1.01, 1.01), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", colour = NA))

ggsave("man/figures/logo.png", p, width = 1.9 * sqrt(3) / 2 * 1.02, height = 1.9 * 1.01, units = "in", dpi = 600, bg = "transparent")
cat("wrote man/figures/logo.png\n")

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
