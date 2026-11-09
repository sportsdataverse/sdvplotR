# Preview a ggplot at the size it will be saved

Saves the plot to a temporary file with
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
and opens it, so you see it at the size, aspect ratio and resolution of
the saved image (and faster than RStudio's plot pane draws plots full of
images). In RStudio the file opens in the Viewer pane (this needs
'rstudioapi'), elsewhere in your browser. It opens only in an
interactive session. The counterpart of nflplotR's and cfbplotR's
`ggpreview()`.

## Usage

``` r
sdv_ggpreview(
  plot = ggplot2::last_plot(),
  width = NA,
  height = NA,
  asp = NULL,
  dpi = 300,
  device = "png",
  units = c("in", "cm", "mm", "px"),
  scale = 1,
  limitsize = TRUE,
  bg = NULL,
  ...
)
```

## Arguments

- plot:

  Plot to save, defaults to last plot displayed.

- width, height:

  Plot size in units expressed by the `units` argument. If not supplied,
  uses the size of the current graphics device.

- asp:

  The aspect ratio, `width / height`. When a number, the `height` is set
  to `width / asp`; with no `width`, the `width` is `height * asp`, or 7
  inches when neither is given.

- dpi:

  Plot resolution. Also accepts a string input: "retina" (320), "print"
  (300), or "screen" (72). Only applies when converting pixel units, as
  is typical for raster output types.

- device:

  Device to use. Can either be a device function (e.g.
  [png](https://rdrr.io/r/grDevices/png.html)), or one of "eps", "ps",
  "tex" (pictex), "pdf", "jpeg", "tiff", "png", "bmp", "svg" or "wmf"
  (windows only). If `NULL` (default), the device is guessed based on
  the `filename` extension.

- units:

  One of the following units in which the `width` and `height` arguments
  are expressed: `"in"`, `"cm"`, `"mm"` or `"px"`.

- scale:

  Multiplicative scaling factor.

- limitsize:

  When `TRUE` (the default),
  [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) will
  not save images larger than 50x50 inches, to prevent the common error
  of specifying dimensions in pixels.

- bg:

  Background colour. If `NULL`, uses the `plot.background` fill value
  from the plot theme.

- ...:

  Other arguments passed on to the graphics device function, as
  specified by `device`.

## Value

The path of the image, invisibly.

## Examples

``` r
# \donttest{
library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point()
# opens only in an interactive session
path <- sdv_ggpreview(p, width = 5, asp = 16 / 9, dpi = 72)
file.exists(path)
#> [1] TRUE
# }
```
