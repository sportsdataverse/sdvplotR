# Build the sdvplotR hex logo (man/figures/logo.png) with the package itself.
# ============================================================================
# Design: the SportsDataverse starfield navy hex, a brick mosaic of team logos
# from all eight leagues drawn with geom_sdv_logos(), and the package name with
# the "R" picked out in the SportsDataverse accent blue.
#
# Run from the package root:  Rscript data-raw/hex_logo.R
# Requires: ggplot2, ggpath, showtext, ragg (dev-only).

devtools::load_all(quiet = TRUE)
library(ggplot2)

navy <- "#0B1A33"
accent <- "#2680E4"
ice <- "#9CCBFF"

sysfonts::font_add_google("Exo 2", "exo", bold.wt = 800)
showtext::showtext_opts(dpi = 600)
showtext::showtext_auto()

# pointy-top hexagon with circumradius 1
hex <- data.frame(
  x = cos(seq(pi / 2, 2 * pi + pi / 2, length.out = 7)),
  y = sin(seq(pi / 2, 2 * pi + pi / 2, length.out = 7))
)
in_hex <- function(x, y, r = 1) abs(x) <= r * sqrt(3) / 2 & abs(y) <= r - abs(x) / sqrt(3)

# starfield background
set.seed(2026)
stars <- data.frame(x = runif(3000, -1, 1), y = runif(3000, -1, 1))
stars <- stars[in_hex(stars$x, stars$y, 0.985), ]
stars$size <- rexp(nrow(stars), 14) + 0.03
stars$alpha <- runif(nrow(stars), 0.15, 0.9)
stars <- stars[order(stars$size), ][seq_len(min(700, nrow(stars))), ]

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
  geom_polygon(data = hex, aes(x, y), fill = navy, colour = NA) +
  scale_size_identity() +
  geom_point(data = stars, aes(x, y, size = size, alpha = alpha), colour = "white", shape = 16) +
  scale_alpha_identity() +
  geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.08, alpha = 0.95) +
  annotate("text", x = 0.17, y = 0.54, label = "sdvplot", family = "exo", fontface = "bold.italic",
           colour = "white", size = 6.4, hjust = 1) +
  annotate("text", x = 0.17, y = 0.54, label = "R", family = "exo", fontface = "bold.italic",
           colour = accent, size = 8.4, hjust = 0) +
  annotate("text", x = 0, y = 0.28, label = "S P O R T S D A T A V E R S E", family = "exo",
           colour = ice, size = 1.6, alpha = 0.9) +
  geom_path(data = hex, aes(x, y), colour = accent, linewidth = 3.2, lineend = "round") +
  coord_fixed(xlim = c(-0.95, 0.95), ylim = c(-1.05, 1.05), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", colour = NA))

ggsave("man/figures/logo.png", p, width = 1.9, height = 2.1, units = "in", dpi = 600, bg = "transparent")
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
