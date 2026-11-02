# Round 5 of hex-logo candidates: muted logo walls across the eight leagues, in
# the spirit of nflplotR's hex (its NFL logos muted behind the wordmark), plus
# the round-3 "axis" chart set on such a wall. Same starfield, wordmark font and
# print-safe inner hexagon as rounds 3-4 (hex_logo_common.R).
#
#   Rscript data-raw/hex_logo_options_v5.R               # every design
#   Rscript data-raw/hex_logo_options_v5.R wall tinted   # a subset
#   HEX_DEBUG=1 Rscript ...                              # draws the safe-area outline (QA only)
#
# Outputs: dev/hex-options-v5/<design>-{1036x1200,518x600}.png

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)
out_dir <- Sys.getenv("HEX_OUT", "dev/hex-options-v5")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

FONT <- "russo"
grad <- grDevices::colorRampPalette(sdv_grad)
all_logos <- logo_paths(6)   # six teams in each of the eight leagues
LW <- 0.1                    # logo width (npc of the 1036 px canvas); the grid steps 0.25 x 0.21 units

# a hex-packed grid of cells inside the safe hexagon, `margin` in from its edge
wall_grid <- function(dx = 0.25, dy = 0.21, margin = 0.08, ymax = 0.84) {
  ys <- seq(ymax, -ymax, by = -dy)
  do.call(rbind, lapply(seq_along(ys), function(i) {
    xs <- seq(-1.2, 1.2, by = dx) + if (i %% 2) 0 else dx / 2
    keep <- abs(xs) <= safe_halfwidth(ys[i]) - margin
    data.frame(x = xs[keep], y = rep(ys[i], sum(keep)), row = i)
  }))
}
fill_wall <- function(g, seed = 7) {
  set.seed(seed)
  g$path <- sample(rep(all_logos, length.out = nrow(g)))
  g
}
# a dark band across the hexagon behind a wordmark at height y
band <- function(y, h = 0.2, a = 0.78) {
  annotate("rect", xmin = -1, xmax = 1, ymin = y - h / 2, ymax = y + h / 2, fill = scales::alpha(navy, a))
}
wordmark <- function(y = 0, w = 1.28, mode = "gradient") title_layer(FONT, mode, y = y, fit_width = w)

# ---- wall: nflplotR's layout, every league's logos muted, wordmark across ------
opt_wall <- function() {
  g <- fill_wall(wall_grid())
  g <- g[abs(g$y) > 0.18, ]
  ggplot() + base_flat("#14161C") +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.32) +
    wordmark(0, mode = "white") + finish("#05070A")
}

# ---- wall_sky: the same wall on the SportsDataverse starfield, gradient word ---
opt_wall_sky <- function() {
  g <- fill_wall(wall_grid())
  g <- g[abs(g$y) > 0.18, ]
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.34) +
    wordmark(0) + finish()
}

# ---- mono: the wall in greyscale, the wordmark the only colour -----------------
opt_mono <- function() {
  g <- fill_wall(wall_grid(), seed = 3)
  g <- g[abs(g$y) > 0.18, ]
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.4, colour = "b/w") +
    wordmark(0) + finish()
}

# ---- tinted: every logo a silhouette, shaded down the SDV gradient by row ------
opt_tinted <- function() {
  g <- fill_wall(wall_grid(), seed = 5)
  g <- g[abs(g$y) > 0.18, ]
  g$col <- grad(max(g$row))[g$row]
  ggplot() + base_flat(navy) +
    geom_from_path(data = g, aes(x, y, path = path, colour = col), width = LW, alpha = 0.45) +
    scale_colour_identity() +
    wordmark(0, mode = "white") + finish()
}

# ---- fade: logos rise from full colour at the base to nothing at the top -------
opt_fade <- function() {
  g <- fill_wall(wall_grid(), seed = 9)
  g <- g[g$y < 0.3, ]
  g$a <- pmin(0.95, pmax(0.08, (0.3 - g$y) / 1.0))
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path, alpha = a), width = LW) +
    scale_alpha_identity() +
    wordmark(0.52, w = 0.98) + finish()
}

# ---- spotlight: the muted wall with one logo per league lit in full colour -----
opt_spotlight <- function() {
  g <- fill_wall(wall_grid(), seed = 11)
  g <- g[abs(g$y) > 0.18, ]
  lit <- vapply(names(picks), function(s) {
    i <- which(g$path == logo_from_team(picks[[s]][1], league = s))
    if (length(i)) i[1] else NA_integer_
  }, integer(1))
  g$a <- 0.22
  g$a[stats::na.omit(lit)] <- 1
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path, alpha = a), width = LW) +
    scale_alpha_identity() +
    wordmark(0) + finish()
}

# ---- band: the wordmark on a dark band through the wall ------------------------
opt_band <- function() {
  g <- fill_wall(wall_grid(), seed = 13)
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.5) +
    band(0, h = 0.26) +
    annotate("segment", x = -1, xend = 1, y = c(-0.13, 0.13), yend = c(-0.13, 0.13), colour = line_col(0.6), linewidth = 0.5) +
    wordmark(0, w = 1.2) + finish()
}

# ---- columns: a square grid (no offset rows), muted ----------------------------
opt_columns <- function() {
  xs <- seq(-0.63, 0.63, length.out = 6)
  ys <- c(0.62, 0.44, 0.26, -0.26, -0.44, -0.62)
  g <- expand.grid(i = 1:6, j = 1:6)
  g$x <- xs[g$i]; g$y <- ys[g$j]
  g$path <- all_logos[(g$j - 1) * 8 + g$i]
  g <- g[abs(g$x) <= safe_halfwidth(g$y) - 0.06, ]
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.4) +
    wordmark(0) + finish()
}

# ---- axis_wall: the shipped "axis" bar chart over a faint wall -----------------
opt_axis_wall <- function() {
  g <- fill_wall(wall_grid(), seed = 17)
  paths <- one_per_league(); cols <- first_colors()
  x <- seq(-0.46, 0.46, length.out = 8)
  h <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)
  base <- -0.48
  bars <- data.frame(x = x, ymax = base + h * 0.78, fill = cols, path = paths)
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW, alpha = 0.12) +
    geom_rect(data = bars, aes(xmin = x - 0.04, xmax = x + 0.04, ymin = base, ymax = ymax, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    annotate("segment", x = -0.58, xend = 0.58, y = base, yend = base, colour = line_col(0.7), linewidth = 0.6) +
    geom_from_path(data = bars, aes(x, base - 0.09, path = path), width = 0.075) +
    title_layer(FONT, "gradient", y = 0.55, fit_width = 0.98) + finish()
}

# ---- halo: a ring of full-colour logos round the wordmark, wall muted beyond ---
opt_halo <- function() {
  # 16 logos (two per league, leagues alternating) evenly round an ellipse
  t <- seq(0, 2 * pi, length.out = 17)[-17] + pi / 16
  ring <- data.frame(x = 0.6 * cos(t), y = 0.42 * sin(t), path = per_league(2))
  g <- fill_wall(wall_grid(), seed = 19)
  g <- g[(g$x / 0.78)^2 + (g$y / 0.58)^2 > 1, ]
  ggplot() + base_sky() +
    geom_from_path(data = g, aes(x, y, path = path), width = LW * 0.9, alpha = 0.16) +
    geom_from_path(data = ring, aes(x, y, path = path), width = LW, alpha = 0.95) +
    wordmark(0, w = 0.82) + finish()
}

designs <- list(
  wall = opt_wall, wall_sky = opt_wall_sky, mono = opt_mono, tinted = opt_tinted, fade = opt_fade,
  spotlight = opt_spotlight, band = opt_band, columns = opt_columns, axis_wall = opt_axis_wall, halo = opt_halo
)

args <- commandArgs(trailingOnly = TRUE)
todo <- if (length(args)) intersect(names(designs), args) else names(designs)
load_fonts(FONT)
for (nm in todo) {
  save_hex(designs[[nm]](), out_dir, nm)
  cat("rendered", nm, "\n")
}
