# Round 4 of hex-logo candidates: no team logos anywhere. The logo ships in the
# package (man/figures), which bundles no team marks, so these show teams by
# their colours only. Same starfield, gradient wordmark and print-safe inner
# hexagon as round 3 (hex_logo_common.R).
#
#   Rscript data-raw/hex_logo_options_v4.R                 # every design
#   Rscript data-raw/hex_logo_options_v4.R shotchart bump  # a subset
#   HEX_DEBUG=1 Rscript ...                                # draws the safe-area outline (QA only)
#
# Outputs: dev/hex-options-v4/<design>-{1036x1200,518x600}.png

devtools::load_all(quiet = TRUE)
source("data-raw/hex_logo_common.R", local = TRUE)
out_dir <- Sys.getenv("HEX_OUT", "dev/hex-options-v4")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

FONT <- "russo"
title_top <- function() title_layer(FONT, "gradient", y = 0.55, fit_width = 0.98)
team_cols <- function(i, which = "primary") {
  unlist(lapply(names(picks), function(s) sdv_team_colors(s, picks[[s]][i], which = which)))
}
prim <- team_cols(1)
sec <- team_cols(1, "secondary")
prim2 <- team_cols(2)
sec2 <- team_cols(2, "secondary")
grad <- grDevices::colorRampPalette(sdv_grad)
hline <- function(y, x0, x1, a = 0.7, lw = 0.6) {
  annotate("segment", x = x0, xend = x1, y = y, yend = y, colour = line_col(a), linewidth = lw)
}
BAR_H <- c(0.62, 0.48, 0.74, 0.4, 0.56, 0.68, 0.45, 0.8)

# ---- pills: the axis bars with rounded ends, no labels -------------------------
opt_pills <- function() {
  b <- data.frame(x = seq(-0.42, 0.42, length.out = 8), y1 = -0.5 + BAR_H * 0.74, col = prim)
  grid <- data.frame(y = -0.5 + seq(0.2, 0.8, by = 0.2) * 0.74)
  grid$half <- safe_halfwidth(grid$y) - 0.04
  ggplot() + base_sky() +
    geom_segment(data = grid, aes(x = -half, xend = half, y = y, yend = y), colour = line_col(0.16), linewidth = 0.4) +
    geom_segment(data = b, aes(x = x, xend = x, y = -0.5, yend = y1, colour = col), linewidth = 5.6, lineend = "round") +
    scale_colour_identity() + title_top() + finish()
}

# ---- winprob: two win-probability traces crossing 50% ---------------------------
opt_winprob <- function() {
  set.seed(5)
  # one home win probability: the area above 50% in the home team's colour,
  # below it in the away team's, as a win-probability chart shades it
  wp <- c(0.5, 0.56, 0.61, 0.55, 0.44, 0.36, 0.41, 0.52, 0.63, 0.71, 0.82, 0.93)
  sm <- stats::spline(seq(-0.52, 0.52, length.out = 12), wp, n = 400, method = "natural")
  y0 <- -0.62; y1 <- 0.2; mid <- (y0 + y1) / 2
  d <- data.frame(x = sm$x, y = y0 + (y1 - y0) * sm$y)
  ggplot() + base_sky() +
    geom_ribbon(data = d, aes(x = x, ymin = mid, ymax = pmax(y, mid)), fill = prim[1], alpha = 0.35) +
    geom_ribbon(data = d, aes(x = x, ymin = pmin(y, mid), ymax = mid), fill = prim[4], alpha = 0.45) +
    hline(mid, -0.56, 0.56, a = 0.45, lw = 0.45) +
    geom_line(data = d, aes(x, y), colour = "white", linewidth = 1.3, lineend = "round") +
    annotate("point", x = d$x[400], y = d$y[400], shape = 21, fill = prim[1], colour = "white", size = 3.6, stroke = 1) +
    title_top() + finish()
}

# ---- quadrant: team-coloured points split by dashed mean lines -----------------
opt_quadrant <- function() {
  # one team per quadrant pair, spread over the whole panel
  pts <- data.frame(
    x = c(-0.38, -0.2, -0.4, -0.12, 0.08, 0.3, 0.44, 0.18, -0.3, 0.36, 0.02, 0.24, -0.06, 0.46, -0.44, 0.12),
    y = c(-0.48, -0.36, -0.2, -0.52, 0.08, -0.06, 0.16, -0.3, 0.06, -0.44, -0.14, 0.2, -0.32, -0.2, -0.56, -0.5),
    fill = c(prim, prim2), col = c(sec, sec2)
  )
  pts <- pts[abs(pts$x) < safe_halfwidth(pts$y) - 0.06, ]
  ggplot() + base_sky() +
    hline(-0.64, -0.54, 0.56) +
    annotate("segment", x = -0.54, xend = -0.54, y = -0.64, yend = 0.28, colour = line_col(0.7), linewidth = 0.6) +
    annotate("segment", x = mean(pts$x), xend = mean(pts$x), y = -0.62, yend = 0.28, colour = accent, linewidth = 0.8, linetype = "22") +
    annotate("segment", x = -0.52, xend = 0.56, y = mean(pts$y), yend = mean(pts$y), colour = accent, linewidth = 0.8, linetype = "22") +
    geom_point(data = pts, aes(x, y, fill = fill, colour = col), shape = 21, size = 4.6, stroke = 1.1) +
    scale_fill_identity() + scale_colour_identity() + title_top() + finish()
}

# ---- bump: five teams' ranks over six weeks ------------------------------------
opt_bump <- function() {
  # four teams over five weeks, two swaps: a sigmoid between each week's ranks
  ranks <- rbind(c(1, 1, 2, 2, 3), c(2, 3, 1, 1, 1), c(3, 2, 3, 4, 2), c(4, 4, 4, 3, 4))
  cols <- prim[c(1, 3, 5, 8)]
  x <- seq(-0.46, 0.46, length.out = 5)
  ry <- function(r) 0.14 - (r - 1) * 0.24
  sig <- function(t) 1 / (1 + exp(-12 * (t - 0.5)))
  sm <- do.call(rbind, lapply(1:4, function(i) do.call(rbind, lapply(1:4, function(k) {
    t <- seq(0, 1, length.out = 40)
    data.frame(team = i, x = x[k] + t * (x[k + 1] - x[k]), y = ry(ranks[i, k]) + sig(t) * (ry(ranks[i, k + 1]) - ry(ranks[i, k])), col = cols[i])
  }))))
  ends <- data.frame(x = x[5], y = ry(ranks[, 5]), col = cols)
  ggplot() + base_sky() +
    geom_path(data = sm, aes(x, y, group = team, colour = col), linewidth = 3.2, lineend = "round") +
    geom_point(data = ends, aes(x, y, fill = col), shape = 21, colour = "white", size = 4.4, stroke = 1) +
    scale_colour_identity() + scale_fill_identity() + title_top() + finish()
}

# ---- shotchart: half court, makes coloured by distance, misses hollow ----------
opt_shotchart <- function() {
  rim <- c(0, -0.56); base_y <- -0.66
  th <- seq(0, pi, length.out = 200)
  arc <- data.frame(x = 0.44 * cos(th), y = rim[2] + 0.44 * sin(th))
  arc <- arc[arc$y >= rim[2] + 0.06, ]
  ft <- data.frame(x = 0.12 * cos(th), y = -0.3 + 0.12 * sin(th))
  set.seed(8)
  n <- 40
  r <- c(runif(10, 0.03, 0.1), runif(12, 0.16, 0.36), runif(18, 0.47, 0.53))
  a <- runif(n, 0.15, pi - 0.15)
  s <- data.frame(x = r * cos(a), y = rim[2] + r * sin(a), made = runif(n) < 0.6)
  s <- s[s$y > base_y + 0.04 & abs(s$x) < safe_halfwidth(s$y) - 0.06, ]
  s$col <- grad(100)[pmin(100, ceiling(sqrt(s$x^2 + (s$y - rim[2])^2) / 0.53 * 100))]
  ggplot() + base_sky() +
    hline(base_y, -0.5, 0.5, a = 0.8, lw = 0.8) +
    annotate("rect", xmin = -0.12, xmax = 0.12, ymin = base_y, ymax = -0.3, fill = scales::alpha(ice, 0.06), colour = line_col(0.7), linewidth = 0.7) +
    geom_path(data = ft, aes(x, y), colour = line_col(0.7), linewidth = 0.7) +
    geom_path(data = arc, aes(x, y), colour = line_col(0.7), linewidth = 0.7) +
    annotate("segment", x = c(-0.44, 0.44), xend = c(-0.44, 0.44), y = base_y, yend = rim[2] + 0.06, colour = line_col(0.7), linewidth = 0.7) +
    annotate("point", x = rim[1], y = rim[2], shape = 21, size = 3, colour = "#FF8A3D", stroke = 1.2) +
    geom_point(data = s[!s$made, ], aes(x, y), shape = 4, colour = line_col(0.7), size = 2.4, stroke = 0.9) +
    geom_point(data = s[s$made, ], aes(x, y, fill = col), shape = 21, colour = "white", size = 3.8, stroke = 0.6) +
    scale_fill_identity() + title_top() + finish()
}

# ---- drives: yard lines with team-coloured drive arrows ------------------------
opt_drives <- function() {
  yl <- data.frame(x = seq(-0.5, 0.5, by = 0.1))
  yl$y0 <- -0.64; yl$y1 <- 0.24
  dr <- data.frame(y = seq(0.14, -0.54, length.out = 7), x0 = c(-0.42, -0.3, -0.46, -0.1, -0.36, 0.02, -0.24),
                   x1 = c(0.44, 0.06, 0.2, 0.46, 0.3, 0.4, 0.12), col = c(prim[1:4], prim[6:8]))
  ggplot() + base_sky() +
    geom_segment(data = yl, aes(x = x, xend = x, y = y0, yend = y1), colour = line_col(0.22), linewidth = 0.45) +
    annotate("segment", x = c(-0.5, 0.5), xend = c(-0.5, 0.5), y = -0.64, yend = 0.24, colour = line_col(0.6), linewidth = 0.7) +
    geom_segment(data = dr, aes(x = x0, xend = x1, y = y, yend = y, colour = col), linewidth = 2.2, lineend = "round",
                 arrow = grid::arrow(length = grid::unit(0.09, "in"), type = "closed")) +
    geom_point(data = dr, aes(x0, y, colour = col), size = 2.4) +
    scale_colour_identity() + title_top() + finish()
}

# ---- chips: each team's primary and secondary, split on the diagonal -----------
opt_chips <- function() {
  w <- 0.2; gap <- 0.035
  cx <- rep(seq(-1.5, 1.5) * (w + gap), 2); cy <- rep(c(-0.06, -0.06 - w - gap), each = 4)
  tri <- function(i, upper) {
    x0 <- cx[i] - w / 2; x1 <- cx[i] + w / 2; y0 <- cy[i] - w / 2; y1 <- cy[i] + w / 2
    if (upper) data.frame(id = paste0(i, "u"), x = c(x0, x1, x0), y = c(y0, y1, y1), fill = prim[i])
    else data.frame(id = paste0(i, "l"), x = c(x0, x1, x1), y = c(y0, y0, y1), fill = sec[i])
  }
  p <- do.call(rbind, c(lapply(1:8, tri, upper = TRUE), lapply(1:8, tri, upper = FALSE)))
  ggplot() + base_sky() +
    geom_polygon(data = p, aes(x, y, group = id, fill = fill), colour = NA) +
    annotate("rect", xmin = cx - w / 2, xmax = cx + w / 2, ymin = cy - w / 2, ymax = cy + w / 2, fill = NA, colour = line_col(0.5), linewidth = 0.4) +
    scale_fill_identity() + title_top() + finish()
}

# ---- tiers: gtUtils-style tier rows with team-coloured tokens ------------------
opt_tiers <- function() {
  ys <- c(0.12, -0.13, -0.38)
  tabs <- data.frame(y = ys, fill = c(sdv_grad[2], grad(3)[2], sdv_grad[1]))
  n <- c(3, 5, 4)
  tok <- do.call(rbind, lapply(1:3, function(i) data.frame(x = -0.22 + (seq_len(n[i]) - 1) * 0.15, y = ys[i])))
  tok$fill <- c(prim, prim2)[seq_len(nrow(tok))]; tok$col <- c(sec, sec2)[seq_len(nrow(tok))]
  ggplot() + base_sky() +
    annotate("rect", xmin = -0.52, xmax = 0.52, ymin = ys - 0.1, ymax = ys + 0.1, fill = scales::alpha(ice, 0.06), colour = line_col(0.3), linewidth = 0.4) +
    geom_rect(data = tabs, aes(xmin = -0.52, xmax = -0.34, ymin = y - 0.1, ymax = y + 0.1, fill = fill)) +
    geom_point(data = tok, aes(x, y, fill = fill, colour = col), shape = 21, size = 6, stroke = 1.4) +
    scale_fill_identity() + scale_colour_identity() + title_top() + finish()
}

# ---- lollipop: a ranked horizontal lollipop chart ------------------------------
opt_lollipop <- function() {
  v <- sort(c(0.86, 0.74, 0.66, 0.55, 0.47, 0.38, 0.3), decreasing = TRUE)
  d <- data.frame(y = seq(0.2, -0.58, length.out = 7), x1 = -0.5 + v * 1.0, fill = prim[c(3, 1, 6, 8, 2, 5, 4)], col = sec[c(3, 1, 6, 8, 2, 5, 4)])
  ggplot() + base_sky() +
    annotate("segment", x = -0.5, xend = -0.5, y = -0.64, yend = 0.26, colour = line_col(0.7), linewidth = 0.6) +
    geom_segment(data = d, aes(x = -0.5, xend = x1, y = y, yend = y, colour = fill), linewidth = 1.3) +
    geom_point(data = d, aes(x1, y, fill = fill, colour = col), shape = 21, size = 4.6, stroke = 1.1) +
    scale_fill_identity() + scale_colour_identity() + title_top() + finish()
}

# ---- ridges: overlapping team-coloured distributions ---------------------------
opt_ridges <- function() {
  xs <- seq(-0.5, 0.5, length.out = 300)
  mu <- c(-0.12, 0.08, -0.02, 0.16, -0.18); sdv <- c(0.12, 0.1, 0.15, 0.09, 0.13)
  base <- c(0.1, -0.06, -0.22, -0.38, -0.54); cols <- prim[c(5, 3, 1, 6, 2)]
  d <- do.call(rbind, lapply(1:5, function(i) {
    y <- stats::dnorm(xs, mu[i], sdv[i]); data.frame(r = i, x = xs, b = base[i], y = base[i] + 0.3 * y / max(y), col = cols[i])
  }))
  ggplot() + base_sky() +
    geom_ribbon(data = d, aes(x = x, ymin = b, ymax = y, group = r, fill = col), alpha = 0.55) +
    geom_line(data = d, aes(x, y, group = r), colour = line_col(0.85), linewidth = 0.5) +
    scale_fill_identity() + title_top() + finish()
}

# ---- matrix: a schedule-matrix heat grid in the SDV gradient -------------------
opt_matrix <- function() {
  set.seed(4)
  g <- expand.grid(i = 1:8, j = 1:6)
  g$x <- -0.42 + (g$i - 1) * 0.12; g$y <- 0.18 - (g$j - 1) * 0.15
  g$fill <- grad(100)[sample(10:100, nrow(g), replace = TRUE)]
  g$fill[g$i == g$j + 1] <- "#FFFFFF10"
  ggplot() + base_sky() +
    geom_tile(data = g, aes(x, y, fill = fill), width = 0.1, height = 0.125, colour = NA) +
    scale_fill_identity() + title_top() + finish()
}

designs <- list(
  pills = opt_pills, winprob = opt_winprob, quadrant = opt_quadrant, bump = opt_bump,
  shotchart = opt_shotchart, drives = opt_drives, chips = opt_chips, tiers = opt_tiers,
  lollipop = opt_lollipop, ridges = opt_ridges, matrix = opt_matrix
)

args <- commandArgs(trailingOnly = TRUE)
todo <- if (length(args)) intersect(names(designs), args) else names(designs)
load_fonts(FONT)
for (nm in todo) {
  save_hex(designs[[nm]](), out_dir, nm)
  cat("rendered", nm, "\n")
}
