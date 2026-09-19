# Round 3 of hex-logo candidates. Every design sits on the SportsDataverse
# starfield with the wordmark in the SDV gradient, and every foreground element
# stays inside the print-safe inner hexagon (SAFE_PX in hex_logo_common.R).
#
#   Rscript data-raw/hex_logo_options_v3.R specimen          # 30-face gradient specimen
#   Rscript data-raw/hex_logo_options_v3.R                   # all designs x render_fonts
#   Rscript data-raw/hex_logo_options_v3.R scatter facets    # a subset
#   HEX_DEBUG=1 Rscript ...                                  # draws the safe-area outline (QA only)
#
# Outputs: dev/hex-options-v3/<design>-<font>-{1036x1200,518x600}.png

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)
out_dir <- "dev/hex-options-v3"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

TITLE_Y <- 0.55          # wordmark centre for top-titled designs
TITLE_W <- 0.98          # wordmark width in hex units (fits the safe hex at the title's top edge)
title_top <- function(font) title_layer(font, "gradient", y = TITLE_Y, fit_width = TITLE_W)

# ---- scatter: logos as points on an L-axis, dashed fit -----------------------
opt_scatter <- function(font) {
  set.seed(3)
  paths <- sample(logo_paths(2))[1:12]
  x <- seq(-0.4, 0.46, length.out = 12)
  y <- -0.48 + 0.62 * (x + 0.4) / 0.86 + rnorm(12, 0, 0.08)
  pts <- data.frame(path = paths, x = x, y = pmin(pmax(y, -0.52), 0.2))
  fit <- lm(y ~ x, pts); line <- data.frame(x = c(-0.48, 0.54)); line$y <- predict(fit, line)
  tx <- data.frame(x = seq(-0.4, 0.5, by = 0.3)); ty <- data.frame(y = seq(-0.5, 0.2, by = 0.2))
  ggplot() + base_sky() +
    annotate("segment", x = -0.56, xend = 0.58, y = -0.6, yend = -0.6, colour = line_col(0.7), linewidth = 0.6) +
    annotate("segment", x = -0.56, xend = -0.56, y = -0.6, yend = 0.32, colour = line_col(0.7), linewidth = 0.6) +
    geom_segment(data = tx, aes(x = x, xend = x, y = -0.6, yend = -0.63), colour = line_col(0.7), linewidth = 0.6) +
    geom_segment(data = ty, aes(x = -0.56, xend = -0.59, y = y, yend = y), colour = line_col(0.7), linewidth = 0.6) +
    geom_line(data = line, aes(x, y), colour = accent, linewidth = 1.2, linetype = "22", alpha = 0.95) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.09, alpha = 0.97) +
    title_top(font) + finish()
}

# ---- axis: team-coloured bars, logos as axis labels ---------------------------
opt_axis <- function(font) {
  paths <- one_per_league(); cols <- first_colors()
  x <- seq(-0.46, 0.46, length.out = 8)
  h <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)
  base <- -0.48
  bars <- data.frame(x = x, ymax = base + h * 0.78, fill = cols, path = paths)
  grid <- data.frame(y = base + seq(0.2, 0.8, by = 0.2) * 0.78); grid$half <- safe_halfwidth(grid$y) - 0.04
  ggplot() + base_sky() +
    geom_segment(data = grid, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.18), linewidth = 0.4) +
    geom_rect(data = bars, aes(xmin = x - 0.04, xmax = x + 0.04, ymin = base, ymax = ymax, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    annotate("segment", x = -0.58, xend = 0.58, y = base, yend = base, colour = line_col(0.7), linewidth = 0.6) +
    geom_from_path(data = bars, aes(x, base - 0.09, path = path), width = 0.075) +
    title_top(font) + finish()
}

# ---- winprob: both teams' traces, each with its logo at the end --------------
opt_winprob <- function(font) {
  set.seed(5)
  n <- 40
  x <- seq(-0.52, 0.42, length.out = n)
  raw <- cumsum(rnorm(n, 0, 0.12)); raw <- (raw - min(raw)) / (max(raw) - min(raw))
  sm <- stats::spline(x, raw, n = 300)
  y0 <- -0.6; y1 <- 0.14; mid <- (y0 + y1) / 2
  a <- y0 + (y1 - y0) * (0.1 + 0.8 * sm$y)
  d <- data.frame(x = sm$x, a = a, b = y0 + y1 - a)
  kc <- sdv_team_colors("nfl", "KC"); phi <- sdv_team_colors("nfl", "PHI")
  ends <- data.frame(x = 0.52, y = c(d$a[300], d$b[300]),
                     path = c(logo_from_team("KC", "nfl"), logo_from_team("PHI", "nfl")))
  ggplot() + base_sky() +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = a), fill = kc, alpha = 0.16) +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = b), fill = phi, alpha = 0.16) +
    annotate("segment", x = -0.58, xend = 0.6, y = mid, yend = mid, colour = line_col(0.4), linewidth = 0.45, linetype = "22") +
    geom_line(data = d, aes(x, b), colour = phi, linewidth = 1.5, lineend = "round") +
    geom_line(data = d, aes(x, a), colour = kc, linewidth = 1.5, lineend = "round") +
    geom_from_path(data = ends, aes(x, y, path = path), width = 0.085) +
    title_top(font) + finish()
}

# ---- constellation: two rows of logos ----------------------------------------
opt_constellation <- function(font) {
  set.seed(7)
  paths <- sample(logo_paths(2))[1:14]
  mosaic <- data.frame(path = paths,
                       x = c(seq(-0.55, 0.55, length.out = 7), seq(-0.45, 0.45, length.out = 7)),
                       y = rep(c(-0.15, -0.46), each = 7))
  ggplot() + base_sky() +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.1, alpha = 0.96) +
    title_top(font) + finish()
}

# ---- wall: five rows of eight ------------------------------------------------
opt_wall <- function(font) {
  set.seed(7)
  paths <- sample(logo_paths(5))
  hw <- c(0.56, 0.62, 0.62, 0.56, 0.46)
  ys <- seq(0.14, -0.62, length.out = 5)
  mosaic <- data.frame(path = paths,
                       x = unlist(lapply(hw, function(w) seq(-w, w, length.out = 8))),
                       y = rep(ys, each = 8))
  ggplot() + base_sky() +
    geom_from_path(data = mosaic, aes(x, y, path = path), width = 0.082, alpha = 0.95) +
    title_layer(font, "gradient", y = 0.58, fit_width = 0.9) + finish()
}

# ---- monogram: SDV cut from the logo mosaic, on the sky ----------------------
opt_monogram <- function(font) {
  set.seed(7)
  paths <- rep(sample(logo_paths(6)), length.out = 13 * 10)
  grid <- expand.grid(x = seq(-0.82, 0.82, length.out = 13), y = seq(0.9, -0.9, length.out = 10))
  grid$path <- paths
  sheet <- ggplot() +
    annotate("rect", xmin = -1, xmax = 1, ymin = -1.2, ymax = 1.2, fill = "#2B4A9E") +
    geom_from_path(data = grid, aes(x, y, path = path), width = 0.078) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void()
  f_sheet <- tempfile(fileext = ".png")
  ggsave(f_sheet, sheet, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  f <- FONTS[[font]]; load_fonts(font)
  probe <- render_text_png("SDV", font, 10, 0, 0.14, 0.5)
  a <- as.integer(magick::image_data(probe, "rgba"))[, , 4]
  cols <- which(colSums(a) > 0)
  size <- 10 * (1.24 * 600) / (max(cols) - min(cols) + 1)
  glyph <- render_text_png("SDV", font, size, 0, 0.14, 0.5)
  r_mosaic <- as.raster(magick::image_composite(glyph, magick::image_read(f_sheet), operator = "In"))
  ggplot() + base_sky() +
    annotation_raster(r_mosaic, -xhalf, xhalf, -1, 1) +
    title_layer(font, "gradient", y = -0.42, fit_width = 0.78) +
    finish()
}

# ---- trend: logos climbing a gradient-coloured trend line --------------------
opt_trend <- function(font) {
  set.seed(13)
  paths <- sample(logo_paths(2))[1:9]
  x <- seq(-0.48, 0.48, length.out = 9)
  y <- -0.56 + 0.76 * (x + 0.48) / 0.96 + rnorm(9, 0, 0.05)
  pts <- data.frame(path = paths, x = x, y = pmin(y, 0.2))
  n <- 80; lx <- seq(-0.54, 0.56, length.out = n); ly <- -0.6 + 0.82 * (lx + 0.54) / 1.1
  line <- data.frame(x = lx[-n], y = ly[-n], xend = lx[-1], yend = ly[-1],
                     col = grDevices::colorRampPalette(sdv_grad)(n - 1))
  ggplot() + base_sky() +
    geom_segment(data = line, aes(x, y, xend = xend, yend = yend, colour = col), linewidth = 2.2, lineend = "round") +
    scale_colour_identity() +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.09, alpha = 0.97) +
    title_top(font) + finish()
}

# ---- stack: ranked team-coloured bars with logos at the axis -----------------
opt_stack <- function(font) {
  paths <- one_per_league(); cols <- first_colors()
  len <- c(0.9, 0.78, 0.7, 0.6, 0.52, 0.42, 0.34, 0.24)
  ys <- seq(0.22, -0.6, length.out = 8)
  bars <- data.frame(y = ys, xmax = -0.32 + len * 0.86, fill = cols, path = paths)
  ggplot() + base_sky() +
    geom_rect(data = bars, aes(xmin = -0.32, xmax = xmax, ymin = y - 0.042, ymax = y + 0.042, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    annotate("segment", x = -0.32, xend = -0.32, y = -0.68, yend = 0.3, colour = line_col(0.7), linewidth = 0.6) +
    geom_from_path(data = bars, aes(-0.42, y, path = path), width = 0.07) +
    title_top(font) + finish()
}

# ---- field: faint yard lines as the chart canvas, logos plotted on it --------
opt_field <- function(font) {
  set.seed(21)
  yl <- data.frame(y = seq(-0.7, 0.3, by = 0.1)); yl$half <- safe_halfwidth(yl$y) - 0.03
  paths <- sample(logo_paths(1))[1:6]
  pts <- data.frame(path = paths, x = c(-0.4, -0.14, 0.1, 0.4, -0.26, 0.26), y = c(-0.58, -0.4, -0.48, -0.18, -0.08, -0.66))
  ggplot() + base_sky() +
    geom_segment(data = yl, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.3), linewidth = 0.5) +
    annotate("segment", x = -0.58, xend = 0.58, y = -0.04, yend = -0.04, colour = accent, linewidth = 1.2, linetype = "22", alpha = 0.9) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.1, alpha = 0.97) +
    title_top(font) + finish()
}

# ---- honeycomb: 19 logos in hex cells, wordmark above ------------------------
opt_honeycomb <- function(font) {
  set.seed(17)
  paths <- sample(logo_paths(3))[1:19]
  s <- 0.14
  centres <- rbind(
    c(0, 0),
    t(sapply(0:5, function(k) c(s * sqrt(3) * cos(pi / 6 + k * pi / 3), s * sqrt(3) * sin(pi / 6 + k * pi / 3)))),
    t(sapply(0:5, function(k) c(2 * s * sqrt(3) * cos(pi / 6 + k * pi / 3), 2 * s * sqrt(3) * sin(pi / 6 + k * pi / 3)))),
    t(sapply(0:5, function(k) c(3 * s * cos(k * pi / 3), 3 * s * sin(k * pi / 3))))
  )
  pts <- data.frame(path = paths, x = centres[, 1], y = centres[, 2] - 0.16)
  cells <- do.call(rbind, lapply(seq_len(nrow(pts)), function(i) {
    t <- seq(pi / 6, 2 * pi + pi / 6, length.out = 7)
    data.frame(id = i, x = pts$x[i] + s * 0.98 * cos(t), y = pts$y[i] + s * 0.98 * sin(t))
  }))
  ggplot() + base_sky() +
    geom_polygon(data = cells, aes(x, y, group = id), fill = navy, colour = line_col(0.35), alpha = 0.55, linewidth = 0.5) +
    geom_from_path(data = pts, aes(x, y, path = path), width = 0.07, alpha = 0.97) +
    title_layer(font, "gradient", y = 0.6, fit_width = 0.9) + finish()
}

# ---- facets: four small sports charts, each with logos -----------------------
opt_facets <- function(font) {
  paths <- one_per_league(); cols <- first_colors()
  pw <- 0.44; ph <- 0.34
  cx <- c(-0.245, 0.245); cy <- c(-0.06, -0.48)
  panel <- function(x, y) annotate("rect", xmin = x - pw / 2, xmax = x + pw / 2, ymin = y - ph / 2, ymax = y + ph / 2,
                                   fill = scales::alpha(navy, 0.6), colour = line_col(0.5), linewidth = 0.5)
  # TL: bars with logo labels
  bx <- cx[1] + c(-0.13, 0, 0.13); bars <- data.frame(x = bx, ymax = cy[1] - 0.09 + c(0.18, 0.24, 0.12), fill = cols[1:3], path = paths[1:3])
  # TR: two win-prob traces with logos
  lx <- seq(cx[2] - 0.18, cx[2] + 0.1, length.out = 30); set.seed(4)
  w <- cumsum(rnorm(30, 0, 0.02)); w <- (w - min(w)) / (max(w) - min(w)); la <- cy[1] - 0.1 + 0.2 * w; lb <- 2 * cy[1] - la
  tr <- data.frame(x = lx, a = la, b = lb)
  # BL: logo scatter
  sc <- data.frame(x = cx[1] + c(-0.13, -0.04, 0.05, 0.13), y = cy[2] + c(-0.1, 0.02, -0.04, 0.1), path = paths[5:8])
  # BR: standings rows, logo + coloured bar
  ry <- cy[2] + c(0.1, 0.03, -0.04, -0.11); st <- data.frame(y = ry, xmax = cx[2] - 0.1 + c(0.25, 0.2, 0.15, 0.1), fill = cols[c(4, 6, 2, 8)], path = paths[c(4, 6, 2, 8)])
  ggplot() + base_sky() +
    panel(cx[1], cy[1]) + panel(cx[2], cy[1]) + panel(cx[1], cy[2]) + panel(cx[2], cy[2]) +
    geom_rect(data = bars, aes(xmin = x - 0.035, xmax = x + 0.035, ymin = cy[1] - 0.09, ymax = ymax, fill = fill)) +
    geom_from_path(data = bars, aes(x, cy[1] - 0.135, path = path), width = 0.04) +
    geom_line(data = tr, aes(x, a), colour = cols[1], linewidth = 1) +
    geom_line(data = tr, aes(x, b), colour = cols[2], linewidth = 1) +
    geom_from_path(data = data.frame(x = cx[2] + 0.15, y = c(la[30], lb[30]), path = paths[1:2]), aes(x, y, path = path), width = 0.04) +
    geom_from_path(data = sc, aes(x, y, path = path), width = 0.05) +
    geom_rect(data = st, aes(xmin = cx[2] - 0.1, xmax = xmax, ymin = y - 0.022, ymax = y + 0.022, fill = fill)) +
    geom_from_path(data = st, aes(cx[2] - 0.16, y, path = path), width = 0.036) +
    scale_fill_identity() +
    title_top(font) + finish()
}

# ---- stripes: eight slanted team-colour stripes on the sky -------------------
opt_stripes <- function(font) {
  cols <- first_colors()
  xs <- seq(-0.46, 0.46, length.out = 8)
  stripes <- do.call(rbind, lapply(seq_along(xs), function(i) {
    x0 <- xs[i]; w <- 0.05; sk <- 0.13
    data.frame(id = i, fill = cols[i],
               x = c(x0 - w + sk, x0 + w + sk, x0 + w - sk, x0 - w - sk),
               y = c(-0.12, -0.12, -0.58, -0.58))
  }))
  ggplot() + base_sky() +
    geom_polygon(data = stripes, aes(x, y, group = id, fill = fill), alpha = 0.95) +
    scale_fill_identity() +
    title_layer(font, "gradient", y = 0.34, fit_width = 1.1) + finish()
}

# ---- specimen: 30 faces, gradient ------------------------------------------
render_specimen <- function() {
  load_fonts()
  for (k in names(FONTS)) {
    if (!k %in% sysfonts::font_families()) next
    p <- ggplot() + base_sky() + title_layer(k, "gradient", y = 0.05, fit_width = 1.15) +
      text_raster(FONTS[[k]]$family, font = "chivo", size = 3.4, y = -0.3, colour = ice) + finish()
    save_hex(p, out_dir, sprintf("specimen-%s", k))
    cat("rendered specimen", k, "\n")
  }
}

designs <- list(
  scatter = opt_scatter, axis = opt_axis, winprob = opt_winprob, constellation = opt_constellation,
  wall = opt_wall, monogram = opt_monogram, trend = opt_trend, stack = opt_stack, field = opt_field,
  honeycomb = opt_honeycomb, facets = opt_facets, stripes = opt_stripes
)
render_fonts <- c("chivo", "exo", "barlow", "russo")

args <- commandArgs(trailingOnly = TRUE)
fonts_arg <- sub("^--fonts=", "", grep("^--fonts=", args, value = TRUE))
if (length(fonts_arg)) render_fonts <- strsplit(fonts_arg, ",")[[1]]
args <- grep("^--", args, value = TRUE, invert = TRUE)
if (!length(args) || "specimen" %in% args) render_specimen()
todo <- if (length(args)) intersect(names(designs), args) else names(designs)
load_fonts(render_fonts)
for (nm in todo) for (fnt in render_fonts) {
  save_hex(designs[[nm]](fnt), out_dir, sprintf("%s-%s", nm, fnt))
  cat("rendered", nm, fnt, "\n")
}
