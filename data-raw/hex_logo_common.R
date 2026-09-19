# Shared helpers for the hex-logo candidate scripts (sourced, dev-only).
# Geometry, fonts, the SportsDataverse starfield ground, team picks, and a
# text-as-raster helper that can set the wordmark in any face, white or in the
# SDV blue-to-cyan gradient.

library(ggplot2)

navy <- "#0B1A33"
edge <- "#071224"
accent <- "#2680E4"
ice <- "#9CCBFF"
sdv_grad <- c("#3346F0", "#7FE6DC")
W <- 1036; H <- 1200; DPI <- 300
xhalf <- W / H

# ---- fonts (Google) ----------------------------------------------------------
FONTS <- list(
  chivo = list(family = "Chivo", bold = 800, italic = FALSE, scale = 1.00),
  exo = list(family = "Exo 2", bold = 800, italic = TRUE, scale = 1.05),
  barlow = list(family = "Barlow Condensed", bold = 800, italic = FALSE, scale = 1.32),
  montserrat = list(family = "Montserrat", bold = 900, italic = FALSE, scale = 0.94),
  archivo = list(family = "Archivo Black", bold = 400, italic = FALSE, scale = 0.92),
  oswald = list(family = "Oswald", bold = 700, italic = FALSE, scale = 1.22)
)
for (k in names(FONTS)) {
  f <- FONTS[[k]]
  if (f$bold == 400) {
    sysfonts::font_add_google(f$family, k)
  } else {
    sysfonts::font_add_google(f$family, k, regular.wt = 400, bold.wt = f$bold)
  }
}
showtext::showtext_opts(dpi = DPI)
showtext::showtext_auto()

# ---- geometry ---------------------------------------------------------------
hex <- data.frame(
  x = cos(seq(pi / 2, 2 * pi + pi / 2, length.out = 7)),
  y = sin(seq(pi / 2, 2 * pi + pi / 2, length.out = 7))
)
hex_halfwidth <- function(y) pmax(0, (1 - abs(y)) * sqrt(3))

# ---- ground -----------------------------------------------------------------
starfield <- function() {
  sky <- magick::image_read("data-raw/sdv-starfield.png")
  sky <- magick::image_crop(sky, "1040x1200+80+0")
  arr <- as.integer(magick::image_data(sky, "rgb"))
  rows <- 400:829; cols <- 80:999
  ramp <- function(n, edge) { i <- seq_len(n); pmin(1, pmin(i - 1, n - i) / edge) }
  w <- outer(ramp(length(rows), 40), ramp(length(cols), 60))
  ring <- w < 0.25                                   # blend zone: outside the mark, in both images
  for (k in 1:3) {
    src <- arr[rows - 399, cols, k]
    dst <- arr[rows, cols, k]
    src <- pmin(255, src * mean(dst[ring]) / mean(src[ring]))   # gain-match the clean strip to its surroundings
    arr[rows, cols, k] <- w * src + (1 - w) * dst
  }
  sky <- magick::image_read(arr / 255)
  mask <- magick::image_draw(magick::image_blank(1040, 1200, "none"))
  polygon(520 + 520 * hex$x / (sqrt(3) / 2), 600 - 600 * hex$y, col = "white", border = NA)
  dev.off()
  as.raster(magick::image_composite(mask, sky, operator = "In"))
}
sky_raster <- starfield()

base_sky <- function() list(annotation_raster(sky_raster, -sqrt(3) / 2, sqrt(3) / 2, -1, 1))
base_flat <- function(fill = navy) list(geom_polygon(data = hex, aes(x, y), fill = fill, colour = NA))
finish <- function(edge_col = edge) {
  list(
    geom_path(data = hex, aes(x, y), colour = edge_col, linewidth = 0.9, lineend = "round", linejoin = "round"),
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE),
    theme_void(),
    theme(plot.background = element_rect(fill = "transparent", colour = NA))
  )
}
line_col <- function(a = 0.55) scales::alpha(ice, a)

# ---- text as a raster layer --------------------------------------------------
# Renders `label` with showtext in the chosen face to a transparent PNG, then
# (optionally) fills the glyphs with a vertical gradient fitted to the text's
# own bounding box. Returns an annotation_raster covering the whole canvas.
text_raster <- function(label, font = "chivo", size = 13, x = 0, y = 0.5, hjust = 0.5,
                        colour = "white", gradient = NULL) {
  f <- FONTS[[font]]
  g <- ggplot() +
    annotate("text", x = x, y = y, label = label, family = font,
             fontface = if (f$bold == 400) "plain" else if (f$italic) "bold.italic" else "bold",
             colour = "white", size = size * f$scale, hjust = hjust) +
    coord_fixed(xlim = c(-xhalf, xhalf), ylim = c(-1, 1), expand = FALSE) + theme_void() +
    theme(plot.background = element_rect(fill = "transparent", colour = NA))
  fpng <- tempfile(fileext = ".png")
  ggsave(fpng, g, width = W / DPI, height = H / DPI, dpi = DPI, bg = "transparent")
  img <- magick::image_read(fpng)
  if (!is.null(gradient)) {
    a <- as.integer(magick::image_data(img, "rgba"))[, , 4] / 255
    rows <- which(rowSums(a) > 0)
    r1 <- min(rows); r2 <- max(rows)
    t <- pmin(1, pmax(0, (seq_len(H) - r1) / (r2 - r1)))          # 0 at the top of the text, 1 at the bottom
    ramp_rgb <- grDevices::colorRamp(gradient)(t) / 255              # H x 3
    out <- array(0, dim = c(H, W, 4))
    for (k in 1:3) out[, , k] <- matrix(ramp_rgb[, k], H, W)
    out[, , 4] <- a
    img <- magick::image_read(out)
  } else if (colour != "white") {
    img <- magick::image_colorize(img, 100, colour)
  }
  annotation_raster(as.raster(img), -xhalf, xhalf, -1, 1)
}
title_layer <- function(font, mode = "white", y = 0.52, size = 13, x = 0, hjust = 0.5, label = "sdvplotR") {
  text_raster(label, font = font, size = size, x = x, y = y, hjust = hjust,
              gradient = if (mode == "gradient") sdv_grad else NULL)
}

# ---- team picks --------------------------------------------------------------
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
first_colors <- function() unlist(lapply(names(picks), function(s) sdv_team_colors(s, picks[[s]][1])))

# ---- output ------------------------------------------------------------------
save_hex <- function(p, out_dir, name) {
  big <- file.path(out_dir, sprintf("%s-1036x1200.png", name))
  ggsave(big, p, width = W / DPI, height = H / DPI, units = "in", dpi = DPI, bg = "transparent")
  img <- magick::image_read(big)
  stopifnot(magick::image_info(img)$width == W, magick::image_info(img)$height == H)
  magick::image_write(magick::image_scale(img, "518x600!"), file.path(out_dir, sprintf("%s-518x600.png", name)))
  invisible(big)
}
