# Round 2 of hex-logo candidates: the eight kept designs refined, the
# monogram re-cut with "SDV", six new remixes, and every design rendered in
# three faces (chivo / exo / barlow). Also renders a type specimen of the
# wordmark in six faces, white and gradient.
#
#   Rscript data-raw/hex_logo_options_v2.R                 # everything
#   Rscript data-raw/hex_logo_options_v2.R specimen        # only the specimen
#   Rscript data-raw/hex_logo_options_v2.R scatter trend   # named designs
#
# Outputs: dev/hex-options-v2/<design>-<font>-{1036x1200,518x600}.png

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)
out_dir <- "dev/hex-options-v2"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
set.seed(7)

# =============================================================================
# Refined keepers
# =============================================================================

# scatter: 12 logos on an L-axis with ticks, dashed trend, title top
opt_scatter <- function(font, mode = "white") {
  set.seed(3)
  paths <- sample(logo_paths(2))[1:12]
  x <- seq(-0.42, 0.5, length.out = 12)
  y <- -0.5 + 0.66 * (x + 0.42) / 0.92 + rnorm(12, 0, 0.09)
  pts <- data.frame(path = paths, x = x, y = pmin(pmax(y, -0.56), 0.22))
  fit <- lm(y ~ x, pts); line <- data.frame(x = c(-0.5, 0.58)); line$y <- predict(fit, line)
  ticks_x <- data.frame(x = seq(-0.4, 0.5, by = 0.3)); ticks_y <- data.frame(y = seq(-0.5, 0.2, by = 0.2))
  ggplot() + base_sky() +
    annotate("segment", x = -0.6, xend = 0.62, y = -0.64, yend = -0.64, colour = line_col(0.7), linewidth = 0.6) +
    annotate("segment", x = -0.6, xend = -0.6, y = -0.64, yend = 0.32, colour = line_col(0.7), linewidth = 0.6) +
    geom_segment(data = ticks_x, aes(x = x, xend = x, y = -0.64, yend = -0.67), colour = line_col(0.7), linewidth = 0.6) +
    geom_segment(data = ticks_y, aes(x = -0.6, xend = -0.63, y = y, yend = y), colour = line_col(0.7), linewidth = 0.6) +
    geom_line(data = line, aes(x, y), colour = accent, linewidth = 1.2, linetype = "22", alpha = 0.95) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.1, alpha = 0.97) +
    title_layer(font, mode, y = 0.55) + finish()
}

# axis: thinner bars, y gridlines, logos as axis labels
opt_axis <- function(font, mode = "white") {
  paths <- one_per_league(); cols <- first_colors()
  x <- seq(-0.5, 0.5, length.out = 8)
  h <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)
  base <- -0.52
  bars <- data.frame(x = x, ymax = base + h * 0.8, fill = cols, path = paths)
  grid <- data.frame(y = base + seq(0.2, 0.8, by = 0.2) * 0.8); grid$half <- hex_halfwidth(grid$y) - 0.06
  ggplot() + base_sky() +
    geom_segment(data = grid, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.18), linewidth = 0.4) +
    geom_rect(data = bars, aes(xmin = x - 0.04, xmax = x + 0.04, ymin = base, ymax = ymax, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    annotate("segment", x = -hex_halfwidth(base) + 0.06, xend = hex_halfwidth(base) - 0.06, y = base, yend = base, colour = line_col(0.7), linewidth = 0.6) +
    geom_from_path(data = bars, aes(x, base - 0.1, path = path), width = 0.082) +
    title_layer(font, mode, y = 0.56) + finish()
}

# winprob: one smooth team-coloured trace with area fill, logos at the ends
opt_winprob <- function(font, mode = "white") {
  set.seed(5)
  n <- 40
  x <- seq(-0.6, 0.6, length.out = n)
  raw <- cumsum(rnorm(n, 0, 0.12)); raw <- (raw - min(raw)) / (max(raw) - min(raw))
  sm <- stats::spline(x, raw, n = 300)
  y0 <- -0.62; y1 <- 0.16; mid <- (y0 + y1) / 2
  d <- data.frame(x = sm$x, y = y0 + (y1 - y0) * (0.1 + 0.8 * sm$y))
  kc <- sdv_team_colors("nfl", "KC"); phi <- sdv_team_colors("nfl", "PHI")
  ends <- data.frame(x = c(d$x[1], d$x[nrow(d)]), y = c(d$y[1], d$y[nrow(d)]),
                     path = c(logo_from_team("PHI", "nfl"), logo_from_team("KC", "nfl")))
  ggplot() + base_sky() +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = y), fill = kc, alpha = 0.22) +
    annotate("segment", x = -0.68, xend = 0.68, y = mid, yend = mid, colour = line_col(0.4), linewidth = 0.45, linetype = "22") +
    geom_line(data = d, aes(x, y), colour = kc, linewidth = 1.6, lineend = "round") +
    annotate("segment", x = -0.58, xend = 0.58, y = y0 - 0.08, yend = y0 - 0.08, colour = line_col(0.6), linewidth = 0.5) +
    geom_from_path(data = ends, aes(x, y, path = path), width = 0.1) +
    title_layer(font, mode, y = 0.52) + finish()
}

# gridiron: cleaner numbers, title band at midfield
opt_gridiron <- function(font, mode = "white") {
  yl <- data.frame(y = seq(-0.9, 0.9, by = 0.1)); yl$half <- hex_halfwidth(yl$y) - 0.02
  hash <- expand.grid(y = seq(-0.9, 0.9, by = 0.02), x = c(-0.2, 0.2)); hash$half <- hex_halfwidth(hash$y) - 0.02
  hash <- hash[abs(hash$x) < hash$half, ]
  nums <- data.frame(y = c(-0.6, -0.3, 0.3, 0.6), lab = c("2 0", "4 0", "4 0", "2 0"))
  nums$x <- hex_halfwidth(nums$y) - 0.22
  ggplot() + base_flat(navy) +
    geom_segment(data = yl, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.45), linewidth = 0.6) +
    geom_segment(data = hash, aes(x = x - 0.03, xend = x + 0.03, y = y, yend = y), colour = line_col(0.3), linewidth = 0.45) +
    geom_text(data = nums, aes(x = -x, y = y, label = lab), family = "chivo", colour = line_col(0.35), size = 4.2, angle = 90) +
    geom_text(data = nums, aes(x = x, y = y, label = lab), family = "chivo", colour = line_col(0.35), size = 4.2, angle = -90) +
    annotate("rect", xmin = -0.75, xmax = 0.75, ymin = -0.17, ymax = 0.17, fill = navy, alpha = 0.9) +
    title_layer(font, mode, y = 0, size = 13.5) + finish()
}

# gradient: gradient wordmark over a sparser constellation
opt_gradient <- function(font, mode = "gradient") {
  set.seed(9)
  paths <- sample(logo_paths(2))[1:10]
  pts <- data.frame(path = paths,
                    x = c(-0.5, -0.15, 0.2, 0.52, -0.55, -0.2, 0.15, 0.5, -0.3, 0.3),
                    y = c(0.02, 0.12, 0.0, 0.1, -0.36, -0.3, -0.42, -0.32, -0.66, -0.66))
  seg <- data.frame(x = pts$x[-10], y = pts$y[-10], xend = pts$x[-1], yend = pts$y[-1])
  ggplot() + base_sky() +
    geom_segment(data = seg, aes(x, y, xend = xend, yend = yend), colour = ice, alpha = 0.28, linewidth = 0.45) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.095, alpha = 0.97) +
    title_layer(font, mode, y = 0.52) + finish()
}

# constellation: two rows of larger logos
opt_constellation <- function(font, mode = "white") {
  set.seed(7)
  paths <- sample(logo_paths(2))[1:14]
  mosaic <- data.frame(path = paths,
                       x = c(seq(-0.6, 0.6, length.out = 7), seq(-0.5, 0.5, length.out = 7)),
                       y = rep(c(-0.18, -0.5), each = 7))
  ggplot() + base_sky() +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.11, alpha = 0.96) +
    title_layer(font, mode, y = 0.5) + finish()
}

# wall: dense grid on the starfield, gradient title
opt_wall <- function(font, mode = "gradient") {
  set.seed(7)
  paths <- sample(logo_paths(5))
  hw <- c(0.6, 0.68, 0.68, 0.6, 0.5)
  ys <- seq(0.14, -0.74, length.out = 5)
  mosaic <- data.frame(path = paths,
                       x = unlist(lapply(hw, function(w) seq(-w, w, length.out = 8))),
                       y = rep(ys, each = 8))
  ggplot() + base_sky() +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.086, alpha = 0.95) +
    title_layer(font, mode, y = 0.56) + finish()
}

# wordmark: bigger name, gradient rule, team-coloured ticks
opt_wordmark <- function(font, mode = "white") {
  ticks <- data.frame(x = seq(-0.56, 0.56, length.out = 8), fill = first_colors())
  ggplot() + base_flat(navy) +
    title_layer(font, mode, y = 0.1, size = 15) +
    annotate("segment", x = -0.68, xend = 0.68, y = -0.2, yend = -0.2, colour = line_col(0.7), linewidth = 0.7) +
    geom_segment(data = ticks, aes(x = x, xend = x, y = -0.2, yend = -0.31, colour = fill), linewidth = 2.4, lineend = "round") +
    scale_colour_identity() +
    text_raster("nfl   nba   wnba   mlb   nhl   cfb   mbb   wbb", font = "chivo", size = 3.6, y = -0.43, colour = ice) +
    finish()
}

# monogram: "SDV" cut from the logo mosaic, name beneath
opt_monogram <- function(font, mode = "white") {
  set.seed(7)
  paths <- rep(sample(logo_paths(6)), length.out = 16 * 12)
  grid <- expand.grid(x = seq(-0.82, 0.82, length.out = 16), y = seq(0.9, -0.9, length.out = 12))
  grid$path <- paths
  sheet <- ggplot() +
    annotate("rect", xmin = -1, xmax = 1, ymin = -1.2, ymax = 1.2, fill = "#1B3A6B") +
    geom_from_path(data = grid, aes(x, y, path = path), width = 0.06) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void()
  f_sheet <- tempfile(fileext = ".png")
  ggsave(f_sheet, sheet, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  f <- FONTS[[font]]
  glyph <- ggplot() +
    annotate("text", x = 0, y = 0.12, label = "SDV", family = font,
             fontface = if (f$bold == 400) "plain" else if (f$italic) "bold.italic" else "bold",
             colour = "white", size = 44 * f$scale) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void() +
    theme(plot.background = element_rect(fill = "transparent", colour = NA))
  f_glyph <- tempfile(fileext = ".png")
  ggsave(f_glyph, glyph, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  r_mosaic <- as.raster(magick::image_composite(magick::image_read(f_glyph), magick::image_read(f_sheet), operator = "In"))
  ggplot() + base_flat(navy) +
    annotation_raster(r_mosaic, -xhalf, xhalf, -1, 1) +
    title_layer(font, mode, y = -0.42, size = 9.5) +
    finish()
}

# =============================================================================
# New remixes
# =============================================================================

# trend: gradient wordmark, logos climbing a gradient-coloured trend line
opt_trend <- function(font, mode = "gradient") {
  set.seed(13)
  paths <- sample(logo_paths(2))[1:9]
  x <- seq(-0.55, 0.55, length.out = 9)
  y <- -0.62 + 0.8 * (x + 0.55) / 1.1 + rnorm(9, 0, 0.06)
  pts <- data.frame(path = paths, x = x, y = pmin(y, 0.2))
  n <- 80; lx <- seq(-0.52, 0.6, length.out = n); ly <- -0.62 + 0.84 * (lx + 0.52) / 1.12
  line <- data.frame(x = lx[-n], y = ly[-n], xend = lx[-1], yend = ly[-1],
                     col = grDevices::colorRampPalette(sdv_grad)(n - 1))
  ggplot() + base_sky() +
    geom_segment(data = line, aes(x, y, xend = xend, yend = yend, colour = col), linewidth = 2.2, lineend = "round") +
    scale_colour_identity() +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.1, alpha = 0.97) +
    title_layer(font, mode, y = 0.55) + finish()
}

# stack: a ranked horizontal bar chart in team colours with logos at the axis
opt_stack <- function(font, mode = "white") {
  paths <- one_per_league(); cols <- first_colors()
  len <- c(0.9, 0.78, 0.7, 0.6, 0.52, 0.42, 0.34, 0.24)
  ys <- seq(0.22, -0.7, length.out = 8)
  bars <- data.frame(y = ys, xmax = -0.35 + len * 0.95, fill = cols, path = paths)
  ggplot() + base_sky() +
    geom_rect(data = bars, aes(xmin = -0.35, xmax = xmax, ymin = y - 0.045, ymax = y + 0.045, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    annotate("segment", x = -0.35, xend = -0.35, y = -0.78, yend = 0.3, colour = line_col(0.7), linewidth = 0.6) +
    geom_from_path(data = bars, aes(-0.46, y, path = path), width = 0.078) +
    title_layer(font, mode, y = 0.56) + finish()
}

# field: the gridiron as the chart canvas, logos plotted on it
opt_field <- function(font, mode = "white") {
  set.seed(21)
  yl <- data.frame(y = seq(-0.9, 0.9, by = 0.1)); yl$half <- hex_halfwidth(yl$y) - 0.02
  paths <- sample(logo_paths(1))[1:6]
  pts <- data.frame(path = paths, x = c(-0.42, -0.15, 0.1, 0.4, -0.28, 0.25), y = c(-0.62, -0.42, -0.5, -0.2, -0.1, -0.7))
  ggplot() + base_flat(navy) +
    geom_segment(data = yl, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.35), linewidth = 0.55) +
    annotate("segment", x = -0.62, xend = 0.62, y = -0.05, yend = -0.05, colour = accent, linewidth = 1.2, linetype = "22", alpha = 0.9) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.11, alpha = 0.97) +
    geom_polygon(data = data.frame(y = c(0.36, 0.7, 0.7, 0.36)), aes(x = c(-1, -1, 1, 1) * hex_halfwidth(y) + c(0.01, 0.01, -0.01, -0.01), y = y), fill = navy, alpha = 0.9) +
    title_layer(font, mode, y = 0.53) + finish()
}

# honeycomb: 19 logos in a hexagonal flower, name beneath
opt_honeycomb <- function(font, mode = "white") {
  set.seed(17)
  paths <- sample(logo_paths(3))[1:19]
  s <- 0.155
  centres <- rbind(
    c(0, 0),
    t(sapply(0:5, function(k) c(s * sqrt(3) * cos(pi / 6 + k * pi / 3), s * sqrt(3) * sin(pi / 6 + k * pi / 3)))),
    t(sapply(0:5, function(k) c(2 * s * sqrt(3) * cos(pi / 6 + k * pi / 3), 2 * s * sqrt(3) * sin(pi / 6 + k * pi / 3)))),
    t(sapply(0:5, function(k) c(3 * s * cos(k * pi / 3), 3 * s * sin(k * pi / 3))))
  )
  pts <- data.frame(path = paths, x = centres[, 1], y = centres[, 2] + 0.16)
  cells <- do.call(rbind, lapply(seq_len(nrow(pts)), function(i) {
    t <- seq(pi / 6, 2 * pi + pi / 6, length.out = 7)
    data.frame(id = i, x = pts$x[i] + s * 0.98 * cos(t), y = pts$y[i] + s * 0.98 * sin(t))
  }))
  ggplot() + base_sky() +
    geom_polygon(data = cells, aes(x, y, group = id), fill = navy, colour = line_col(0.35), alpha = 0.55, linewidth = 0.5) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.076, alpha = 0.97) +
    title_layer(font, mode, y = -0.72, size = 9.5) + finish()
}

# facets: a 2x2 grid of tiny team-coloured charts under the name, like a ggplot
opt_facets <- function(font, mode = "white") {
  cols <- first_colors()
  panel <- function(cx, cy, w = 0.5, h = 0.36) list(
    annotate("rect", xmin = cx - w / 2, xmax = cx + w / 2, ymin = cy - h / 2, ymax = cy + h / 2,
             fill = scales::alpha(navy, 0.55), colour = line_col(0.5), linewidth = 0.5)
  )
  # bars
  bx <- seq(-0.47, -0.13, length.out = 4); bars <- data.frame(x = bx, ymax = -0.17 + c(0.2, 0.28, 0.12, 0.24), fill = cols[1:4])
  # line
  lx <- seq(0.1, 0.5, length.out = 12); ly <- -0.12 + 0.12 * sin(seq(0, 5, length.out = 12)); line <- data.frame(x = lx, y = ly)
  # scatter
  set.seed(2); sc <- data.frame(x = runif(14, -0.47, -0.13), y = runif(14, -0.66, -0.4), fill = sample(cols, 14, TRUE))
  # tiles
  tl <- expand.grid(x = seq(0.11, 0.49, length.out = 6), y = seq(-0.66, -0.4, length.out = 4)); tl$fill <- sample(cols, 24, TRUE)
  ggplot() + base_sky() +
    panel(-0.3, -0.05) + panel(0.3, -0.05) + panel(-0.3, -0.53) + panel(0.3, -0.53) +
    geom_rect(data = bars, aes(xmin = x - 0.035, xmax = x + 0.035, ymin = -0.2, ymax = ymax, fill = fill)) +
    geom_line(data = line, aes(x, y), colour = cols[3], linewidth = 1.2) +
    geom_point(data = sc, aes(x, y, colour = fill), size = 2.6) +
    geom_tile(data = tl, aes(x, y, fill = fill), width = 0.062, height = 0.07) +
    scale_fill_identity() + scale_colour_identity() +
    title_layer(font, mode, y = 0.5) + finish()
}

# stripes: eight slanted jersey stripes in team colours under the name
opt_stripes <- function(font, mode = "white") {
  cols <- first_colors()
  xs <- seq(-0.5, 0.5, length.out = 8)
  stripes <- do.call(rbind, lapply(seq_along(xs), function(i) {
    x0 <- xs[i]; w <- 0.055; sk <- 0.14
    data.frame(id = i, fill = cols[i],
               x = c(x0 - w + sk, x0 + w + sk, x0 + w - sk, x0 - w - sk),
               y = c(-0.12, -0.12, -0.6, -0.6))
  }))
  ggplot() + base_flat(navy) +
    geom_polygon(data = stripes, aes(x, y, group = id, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    title_layer(font, mode, y = 0.36, size = 14) + finish()
}

# =============================================================================
# Type specimen: the wordmark alone, six faces, white + gradient
# =============================================================================
render_specimen <- function() {
  for (k in names(FONTS)) for (mode in c("white", "gradient")) {
    p <- ggplot() + base_sky() + title_layer(k, mode, y = 0.05, size = 15) +
      text_raster(FONTS[[k]]$family, font = "chivo", size = 3.6, y = -0.3, colour = ice) + finish()
    save_hex(p, out_dir, sprintf("specimen-%s-%s", k, mode))
    cat("rendered specimen", k, mode, "\n")
  }
}

# =============================================================================
# render matrix
# =============================================================================
designs <- list(
  scatter = opt_scatter, axis = opt_axis, winprob = opt_winprob, gridiron = opt_gridiron,
  gradient = opt_gradient, constellation = opt_constellation, wall = opt_wall, wordmark = opt_wordmark,
  monogram = opt_monogram,
  trend = opt_trend, stack = opt_stack, field = opt_field, honeycomb = opt_honeycomb,
  facets = opt_facets, stripes = opt_stripes
)
render_fonts <- c("chivo", "exo", "barlow")
gradient_extra <- c("scatter", "axis", "winprob", "wordmark", "stripes")   # also render a gradient-title variant (chivo)

args <- commandArgs(trailingOnly = TRUE)
if (!length(args) || "specimen" %in% args) render_specimen()
todo <- if (length(args)) intersect(names(designs), args) else names(designs)
for (nm in todo) {
  for (fnt in render_fonts) {
    save_hex(designs[[nm]](fnt), out_dir, sprintf("%s-%s", nm, fnt))
    cat("rendered", nm, fnt, "\n")
  }
  if (nm %in% gradient_extra) {
    save_hex(designs[[nm]]("chivo", mode = "gradient"), out_dir, sprintf("%s-chivo-gradient", nm))
    cat("rendered", nm, "chivo gradient\n")
  }
}
