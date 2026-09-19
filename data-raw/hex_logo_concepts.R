# Additional hex-logo concepts, sourced by data-raw/hex_logo_options.R.
# Three concepts beyond the starfield-plus-logos family, two designs each:
#   SURFACES  (sportyR homage)   gridiron, surfaces
#   DATA      (the chart itself) palette, winprob
#   TYPE      (letterform-led)   monogram, wordmark

arc <- function(cx, cy, r, from, to, n = 120, ry = r) {
  t <- seq(from, to, length.out = n) * pi / 180
  data.frame(x = cx + r * cos(t), y = cy + ry * sin(t))
}
line_col <- function(a = 0.55) scales::alpha(ice, a)

# ---- G1. gridiron: yard lines + hash marks, wordmark at midfield -------------
opt_gridiron <- function() {
  yl <- data.frame(y = seq(-0.95, 0.95, by = 0.1))
  yl$half <- pmax(0, (1 - abs(yl$y)) * sqrt(3) - 0.02)
  hash <- expand.grid(y = seq(-0.95, 0.95, by = 0.02), x = c(-0.22, 0.22))
  hash$half <- pmax(0, (1 - abs(hash$y)) * sqrt(3) - 0.02)
  hash <- hash[abs(hash$x) < hash$half, ]
  nums <- data.frame(
    y = seq(-0.8, 0.8, by = 0.2),
    lab = c("1 0", "2 0", "3 0", "4 0", "5 0", "4 0", "3 0", "2 0", "1 0")
  )
  nums$x <- pmax(0.25, (1 - abs(nums$y)) * sqrt(3) - 0.28)
  ggplot() + base_flat(navy) +
    geom_segment(data = yl, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.5), linewidth = 0.6) +
    geom_segment(data = hash, aes(x = x - 0.03, xend = x + 0.03, y = y, yend = y), colour = line_col(0.35), linewidth = 0.45) +
    geom_text(data = nums, aes(x = -x, y = y, label = lab), family = "chivo", colour = line_col(0.4), size = 3.2, angle = 90) +
    geom_text(data = nums, aes(x = x, y = y, label = lab), family = "chivo", colour = line_col(0.4), size = 3.2, angle = -90) +
    annotate("rect", xmin = -0.62, xmax = 0.62, ymin = -0.17, ymax = 0.17, fill = navy, alpha = 0.85) +
    title_text(y = 0, size = 13.5) + finish()
}

# ---- G2. surfaces: court arc, faceoff circle, diamond, penalty box in one sky
opt_surfaces <- function() {
  three <- arc(0, 0.8, 0.66, 205, 335)
  key <- data.frame(x = c(-0.24, -0.24, 0.24, 0.24), y = c(0.8, 0.4, 0.4, 0.8))
  ft <- arc(0, 0.4, 0.24, 180, 360)
  face <- arc(-0.46, -0.44, 0.24, 0, 360)
  dot <- arc(-0.46, -0.44, 0.032, 0, 360)
  diamond <- data.frame(x = c(0.46, 0.66, 0.46, 0.26, 0.46), y = c(-0.24, -0.44, -0.64, -0.44, -0.24))
  mound <- arc(0.46, -0.44, 0.045, 0, 360)
  penalty <- data.frame(x = c(-0.3, 0.3, 0.3, -0.3, -0.3), y = c(-0.9, -0.9, -0.74, -0.74, -0.9))
  penarc <- arc(0, -0.74, 0.14, 0, 180, ry = 0.08)
  ggplot() + base_sky() +
    geom_path(data = three, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_path(data = key, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_path(data = ft, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_path(data = face, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_polygon(data = dot, aes(x, y), fill = line_col(0.8)) +
    geom_path(data = diamond, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_polygon(data = mound, aes(x, y), fill = line_col(0.8)) +
    geom_path(data = penalty, aes(x, y), colour = line_col(), linewidth = 0.9) +
    geom_path(data = penarc, aes(x, y), colour = line_col(), linewidth = 0.9) +
    title_text(y = 0.02, size = 13.5) + finish()
}

# ---- H1. palette: a swatch grid of real team colours, one row per league -----
league_colors <- function(n = 12) {
  lapply(names(picks), function(s) {
    ref <- team_reference(s)
    cols <- ref$color1[!is.na(ref$color1)]
    cols[!cols %in% c("#FFFFFF", "#000000")][seq_len(n)]
  })
}
opt_palette <- function() {
  cols <- league_colors(12)
  rows <- length(cols); per_row <- 12
  ys <- seq(0.24, -0.76, length.out = rows)
  hw <- (1 - abs(ys)) * sqrt(3) - 0.16
  tiles <- do.call(rbind, lapply(seq_len(rows), function(i) {
    xs <- seq(-hw[i], hw[i], length.out = per_row)
    data.frame(x = xs, y = ys[i], fill = cols[[i]], w = diff(xs)[1] * 0.82)
  }))
  ggplot() + base_flat(navy) +
    geom_tile(data = tiles, aes(x, y, fill = fill, width = w), height = 0.1) +
    scale_fill_identity() +
    title_text(y = 0.55, size = 13) + finish()
}

# ---- H2. winprob: two team-coloured win-probability traces ------------------
opt_winprob <- function() {
  set.seed(11)
  n <- 120
  x <- seq(-0.6, 0.6, length.out = n)
  wp <- 0.5 + cumsum(rnorm(n, 0, 0.045)); wp <- (wp - min(wp)) / (max(wp) - min(wp))
  wp <- 0.12 + 0.76 * wp
  y0 <- -0.6; y1 <- 0.16; mid <- (y0 + y1) / 2
  d <- data.frame(x = x, a = y0 + (y1 - y0) * wp, b = y0 + (y1 - y0) * (1 - wp))
  kc <- sdv_team_colors("nfl", "KC"); phi <- sdv_team_colors("nfl", "PHI")
  ggplot() + base_sky() +
    geom_hline(yintercept = mid, colour = line_col(0.35), linewidth = 0.4, linetype = "22") +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = a), fill = kc, alpha = 0.18) +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = b), fill = phi, alpha = 0.18) +
    geom_line(data = d, aes(x, a), colour = kc, linewidth = 1.3) +
    geom_line(data = d, aes(x, b), colour = phi, linewidth = 1.3) +
    geom_hline(yintercept = y0, colour = line_col(0.5), linewidth = 0.5) +
    title_text(y = 0.5, size = 13) + finish()
}

# ---- I1. monogram: a giant R filled with the logo mosaic ---------------------
opt_monogram <- function() {
  paths <- rep(sample(logo_paths(6)), length.out = 14 * 12)
  grid <- expand.grid(x = seq(-0.78, 0.78, length.out = 14), y = seq(0.9, -0.9, length.out = 12))
  grid$path <- paths
  sheet <- ggplot() +
    annotate("rect", xmin = -1, xmax = 1, ymin = -1.2, ymax = 1.2, fill = "#1B3A6B") +
    geom_from_path(data = grid, aes(x, y, path = path), width = 0.068) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void()
  f_sheet <- tempfile(fileext = ".png")
  ggsave(f_sheet, sheet, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  glyph <- ggplot() +
    annotate("text", x = 0, y = -0.14, label = "R", family = "chivo", fontface = "bold", colour = "white", size = 108) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void() +
    theme(plot.background = element_rect(fill = "transparent", colour = NA))
  f_glyph <- tempfile(fileext = ".png")
  ggsave(f_glyph, glyph, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  r_mosaic <- as.raster(magick::image_composite(magick::image_read(f_glyph), magick::image_read(f_sheet), operator = "In"))
  ggplot() + base_flat(navy) +
    annotation_raster(r_mosaic, -xhalf, xhalf, -1, 1) +
    annotate("text", x = 0, y = 0.66, label = "sdvplot", family = "chivo", fontface = "bold", colour = "white", size = 9) +
    finish()
}

# ---- I2. wordmark: the name on an axis with eight team-coloured ticks --------
opt_wordmark <- function() {
  cols <- unlist(lapply(names(picks), function(s) sdv_team_colors(s, picks[[s]][1])))
  ticks <- data.frame(x = seq(-0.56, 0.56, length.out = 8), fill = cols)
  ggplot() + base_flat(navy) +
    annotate("text", x = 0, y = 0.08, label = "sdvplotR", family = "chivo", fontface = "bold", colour = "white", size = 14.5) +
    annotate("segment", x = -0.66, xend = 0.66, y = -0.2, yend = -0.2, colour = line_col(0.7), linewidth = 0.7) +
    geom_segment(data = ticks, aes(x = x, xend = x, y = -0.2, yend = -0.3, colour = fill), linewidth = 2.2, lineend = "round") +
    scale_colour_identity() +
    annotate("text", x = 0, y = -0.42, label = "nfl  nba  wnba  mlb  nhl  cfb  mbb  wbb", family = "chivo",
             colour = line_col(0.85), size = 3.6) +
    finish()
}
