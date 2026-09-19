# Render the candidate sdvplotR hex logos (six options) at the SportsDataverse
# hex sizes: 1036 x 1200 (cfbfastR / oddsapiR) and 518 x 600 (hoopR / cfbplotR
# / fastRhockey). Same pointy-top hexagon, full-bleed fill, hairline edge.
#
#   Rscript data-raw/hex_logo_options.R            # all six -> dev/hex-options/
#   Rscript data-raw/hex_logo_options.R orbit      # one option
#
# Requires: ggplot2, ggpath, magick, showtext (dev-only). Team logos are drawn
# with the package's own resolvers + ggpath::geom_from_path().

devtools::load_all(quiet = TRUE)
library(ggplot2)

out_dir <- "dev/hex-options"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

navy <- "#0B1A33"
edge <- "#071224"
accent <- "#2680E4"
ice <- "#9CCBFF"
W <- 1036; H <- 1200; DPI <- 300

sysfonts::font_add_google("Chivo", "chivo", regular.wt = 400, bold.wt = 800)
sysfonts::font_add_google("Lato", "lato", regular.wt = 400, bold.wt = 900)
showtext::showtext_opts(dpi = DPI)
showtext::showtext_auto()

# ---- geometry ---------------------------------------------------------------
hex <- data.frame(
  x = cos(seq(pi / 2, 2 * pi + pi / 2, length.out = 7)),
  y = sin(seq(pi / 2, 2 * pi + pi / 2, length.out = 7))
)
xhalf <- W / H            # canvas half-width in hex units (circumradius = 1)
in_hex <- function(x, y, r = 1) abs(x) <= r * sqrt(3) / 2 & abs(y) <= r - abs(x) / sqrt(3)

# ---- background: the SportsDataverse starfield, mark inpainted, hex-masked ---
starfield <- function() {
  sky <- magick::image_read("data-raw/sdv-starfield.png")             # 1200 x 1200
  sky <- magick::image_crop(sky, "1040x1200+80+0")
  # inpaint the mark (rows 400-829, cols 80-999) with the clean sky at the top
  # of the image (rows 1-430, which end above the mark), blended with a
  # smooth-edged weight so no seam shows
  arr <- as.integer(magick::image_data(sky, "rgb"))                    # [row, col, channel]
  rows <- 400:829; cols <- 80:999
  ramp <- function(n, edge) { i <- seq_len(n); pmin(1, pmin(i - 1, n - i) / edge) }
  w <- outer(ramp(length(rows), 40), ramp(length(cols), 60))
  for (k in 1:3) {
    src <- arr[rows - 399, cols, k]
    arr[rows, cols, k] <- w * src + (1 - w) * arr[rows, cols, k]
  }
  sky <- magick::image_read(arr / 255)
  mask <- magick::image_draw(magick::image_blank(1040, 1200, "none"))
  polygon(520 + 520 * hex$x / (sqrt(3) / 2), 600 - 600 * hex$y, col = "white", border = NA)
  dev.off()
  as.raster(magick::image_composite(mask, sky, operator = "In"))
}
sky_raster <- starfield()

base_sky <- function() {
  list(
    annotation_raster(sky_raster, -sqrt(3) / 2, sqrt(3) / 2, -1, 1)
  )
}
base_flat <- function(fill = navy) {
  list(geom_polygon(data = hex, aes(x, y), fill = fill, colour = NA))
}
finish <- function(edge_col = edge) {
  list(
    geom_path(data = hex, aes(x, y), colour = edge_col, linewidth = 0.9, lineend = "round", linejoin = "round"),
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE),
    theme_void(),
    theme(plot.background = element_rect(fill = "transparent", colour = NA))
  )
}
title_text <- function(y = 0.52, size = 13, family = "chivo", colour = "white", x = 0, hjust = 0.5) {
  annotate("text", x = x, y = y, label = "sdvplotR", family = family, fontface = "bold",
           colour = colour, size = size, hjust = hjust)
}

# ---- team picks -------------------------------------------------------------
picks <- list(
  nfl = c("KC", "PHI", "DET", "BUF", "SF", "DAL"),
  nba = c("BOS", "LAL", "OKC", "NY", "GS", "MIL"),
  wnba = c("NY", "LV", "IND", "MIN", "SEA", "LA"),
  mlb = c("LAD", "NYY", "ATL", "SD", "BOS", "CHC"),
  nhl = c("TOR", "EDM", "FLA", "COL", "BOS", "VGK"),
  cfb = c("ALA", "UGA", "MICH", "OSU", "TEX", "ORE"),
  mbb = c("DUKE", "CONN", "KU", "UNC", "UK", "PUR"),
  wbb = c("SC", "IOWA", "LSU", "STAN", "UCLA", "ND")
)
logo_paths <- function(n) {
  p <- unlist(lapply(names(picks), function(s) logo_from_team(picks[[s]][seq_len(n)], sport = s)))
  stopifnot(!anyNA(p))
  p
}
one_per_league <- function() unlist(lapply(names(picks), function(s) logo_from_team(picks[[s]][1], sport = s)))

set.seed(7)

# ---- A. constellation: starfield, plain white type, 3-row mosaic -------------
opt_constellation <- function() {
  paths <- sample(logo_paths(3))
  hw <- c(0.62, 0.56, 0.47)
  mosaic <- data.frame(
    path = paths,
    x = unlist(lapply(hw, function(w) seq(-w, w, length.out = 8))),
    y = rep(c(-0.06, -0.32, -0.58), each = 8)
  )
  ggplot() + base_sky() +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.08, alpha = 0.95) +
    title_text() + finish()
}

# ---- B. scatter: logos as the points of a real chart -------------------------
opt_scatter <- function() {
  paths <- sample(logo_paths(2))
  n <- length(paths)
  x <- seq(-0.62, 0.62, length.out = n)
  y <- -0.62 + 0.75 * (x + 0.62) / 1.24 + rnorm(n, 0, 0.11)
  pts <- data.frame(path = paths, x = x, y = pmin(pmax(y, -0.72), 0.2))
  fit <- lm(y ~ x, pts)
  line <- data.frame(x = c(-0.7, 0.7)); line$y <- predict(fit, line)
  grid_y <- seq(-0.7, 0.25, by = 0.19); grid_x <- seq(-0.7, 0.7, by = 0.2)
  ggplot() + base_sky() +
    geom_hline(yintercept = grid_y, colour = ice, alpha = 0.12, linewidth = 0.3) +
    geom_vline(xintercept = grid_x, colour = ice, alpha = 0.12, linewidth = 0.3) +
    geom_line(data = line, aes(x, y), colour = accent, linewidth = 1.1, linetype = "22", alpha = 0.9) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.085, alpha = 0.97) +
    title_text(y = 0.52) + finish()
}

# ---- C. wall: cfbplotR / mlbplotR homage, flat navy, dense grid --------------
opt_wall <- function() {
  paths <- sample(logo_paths(6))                       # 48 logos
  rows <- 6; per_row <- 8
  hw <- c(0.55, 0.66, 0.72, 0.72, 0.66, 0.55)            # follow the hexagon taper
  ys <- seq(0.22, -0.78, length.out = rows)
  mosaic <- data.frame(
    path = paths,
    x = unlist(lapply(hw, function(w) seq(-w, w, length.out = per_row))),
    y = rep(ys, each = per_row)
  )
  ggplot() + base_flat(navy) +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.078, alpha = 0.95) +
    title_text(y = 0.55, size = 13) + finish()
}

# ---- D. orbit: one logo per league circling the wordmark ---------------------
opt_orbit <- function() {
  paths <- one_per_league()
  ang <- (seq(90, 90 - 360, length.out = 9)[1:8] + 22.5) * pi / 180   # keep the horizontal clear
  rx <- 0.62; ry <- 0.6
  pts <- data.frame(path = paths, x = rx * cos(ang), y = -0.08 + ry * sin(ang))
  ring <- data.frame(t = seq(0, 2 * pi, length.out = 300))
  ring$x <- rx * cos(ring$t); ring$y <- -0.08 + ry * sin(ring$t)
  ggplot() + base_sky() +
    geom_path(data = ring, aes(x, y), colour = ice, alpha = 0.35, linewidth = 0.5) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.13, alpha = 0.97) +
    title_text(y = -0.08, size = 11) + finish()
}

# ---- E. axis: the signature feature, logos as axis labels --------------------
opt_axis <- function() {
  paths <- one_per_league()
  teams <- unlist(lapply(names(picks), function(s) picks[[s]][1]))
  cols <- unlist(lapply(names(picks), function(s) sdv_team_colors(s, picks[[s]][1])))
  n <- 8
  x <- seq(-0.5, 0.5, length.out = n)
  h <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)
  bars <- data.frame(x = x, h = h, fill = cols, path = paths)
  base <- -0.55
  ggplot() + base_sky() +
    geom_rect(data = bars, aes(xmin = x - 0.05, xmax = x + 0.05, ymin = base, ymax = base + h * 0.85, fill = fill), alpha = 0.92) +
    scale_fill_identity() +
    geom_hline(yintercept = base, colour = ice, alpha = 0.6, linewidth = 0.5) +
    geom_from_path(data = bars, aes(x, base - 0.1, path = path), width = 0.085) +
    title_text(y = 0.56) + finish()
}

# ---- F. gradient: SDV blue-to-cyan wordmark + constellation lines ------------
gradient_title <- function() {
  txt <- magick::image_blank(1600, 420, "none")
  txt <- magick::image_annotate(txt, "sdvplotR", font = "Chivo", weight = 800, size = 300,
                                color = "white", gravity = "center")
  grad <- magick::image_blank(1600, 420, pseudo_image = "gradient:#3346F0-#7FE6DC")
  as.raster(magick::image_composite(txt, grad, operator = "In"))
}
opt_gradient <- function() {
  paths <- sample(logo_paths(2))[1:12]
  pts <- data.frame(path = paths,
                    x = c(-0.55, -0.2, 0.15, 0.5, -0.62, -0.25, 0.1, 0.45, -0.4, 0.0, 0.35, 0.62),
                    y = c(0.0, 0.12, -0.02, 0.1, -0.35, -0.28, -0.4, -0.3, -0.66, -0.58, -0.7, -0.55))
  seg <- data.frame(x = pts$x[-nrow(pts)], y = pts$y[-nrow(pts)], xend = pts$x[-1], yend = pts$y[-1])
  ggplot() + base_sky() +
    geom_segment(data = seg, aes(x, y, xend = xend, yend = yend), colour = ice, alpha = 0.3, linewidth = 0.45) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.085, alpha = 0.97) +
    annotation_raster(gradient_title(), -0.7, 0.7, 0.34, 0.7) +
    finish()
}

# ---- three more concepts, two designs each ---------------------------------
source("data-raw/hex_logo_concepts.R", local = TRUE)

# ---- render -----------------------------------------------------------------
options_list <- list(
  constellation = opt_constellation, scatter = opt_scatter, wall = opt_wall,
  orbit = opt_orbit, axis = opt_axis, gradient = opt_gradient,
  gridiron = opt_gridiron, surfaces = opt_surfaces,
  palette = opt_palette, winprob = opt_winprob,
  monogram = opt_monogram, wordmark = opt_wordmark
)
which <- commandArgs(trailingOnly = TRUE)
if (length(which)) options_list <- options_list[which]

for (nm in names(options_list)) {
  p <- options_list[[nm]]()
  big <- file.path(out_dir, sprintf("sdvplotR-%s-1036x1200.png", nm))
  ggsave(big, p, width = W / DPI, height = H / DPI, units = "in", dpi = DPI, bg = "transparent")
  img <- magick::image_read(big)
  stopifnot(magick::image_info(img)$width == W, magick::image_info(img)$height == H)
  magick::image_write(magick::image_scale(img, "518x600!"), file.path(out_dir, sprintf("sdvplotR-%s-518x600.png", nm)))
  cat("rendered", nm, "\n")
}
