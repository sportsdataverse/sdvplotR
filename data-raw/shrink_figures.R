# Shrink the man/figures PNGs the package ships (they install under help/figures
# and count toward the installed size CRAN checks). Run from the package root
# after regenerating any of them (hex_logo.R and theme_previews.R source it).
# A figure wider than 1000 px is scaled down to 1000 px (the help pages show
# them at most ~800 px wide), and a truecolour one becomes a 256-colour palette
# PNG, kept only when that is smaller. Figures already at most 1000 px wide and
# stored as grey or palette PNGs are skipped, so rerunning it never quantises a
# figure twice. README-* figures are .Rbuildignore'd, so they are left alone.
figs <- list.files("man/figures", "[.]png$", full.names = TRUE)
figs <- figs[!startsWith(basename(figs), "README-")]
for (f in figs) {
  img <- magick::image_read(f)
  info <- magick::image_info(img)
  colour_type <- as.integer(readBin(f, "raw", 26)[26]) # PNG IHDR: 0 grey, 3 palette
  if (info$width <= 1000 && colour_type %in% c(0L, 3L)) next
  if (info$width > 1000) img <- magick::image_resize(img, "1000x")
  tmp <- tempfile(fileext = ".png")
  # png8 forces a palette PNG but cuts transparency to on/off, so an image with
  # any transparency (the logo) goes through "png" (magick still writes a palette).
  # quality 90 = zlib level 9 with no row filter, the smallest for palette PNGs.
  fmt <- if (info$matte) "png" else "png8"
  magick::image_write(magick::image_quantize(img, 256, dither = FALSE), tmp, format = fmt, quality = 90)
  if (file.size(tmp) < file.size(f)) file.copy(tmp, f, overwrite = TRUE)
}
cat("man/figures:", sum(file.size(figs)), "bytes\n")
