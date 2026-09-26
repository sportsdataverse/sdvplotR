# Background colors used by the `gt_theme_*()` table themes

A lookup of the background color each `gt_theme_*` function sets, used
to match a saved image's canvas to the table sitting on it.
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
and
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md)
pad the image using their own `bg` argument, and a mismatch shows up as
a border around the table.

## Usage

``` r
theme_bg
```

## Format

A tibble with one row per theme, and one per style for the themes that
take a `style` argument:

- theme:

  The theme function name.

- has_style:

  The `style` value the row applies to (`"light"` or `"dark"`) for
  [`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md),
  [`gt_theme_sofa()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sofa.md)
  and
  [`gt_theme_tier()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_tier.md),
  or `""` for themes without one.

- bg:

  The background color the theme applies, as a hex code.

## Source

Read back from each theme's `table.background.color` by
`data-raw/theme_bg.R`.
[`gt_theme_drench()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_drench.md)
takes its background from its `color` argument and
[`gt_theme_broadsheet()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_broadsheet.md)
from its `paper` argument; their rows hold the default.

## See also

[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md),
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md).

## Examples

``` r
# look up the background a theme uses, then match the canvas to it
bg <- theme_bg$bg[theme_bg$theme == "gt_theme_gtutils"]
bg
#> [1] "#FFFDF5"

if (FALSE) { # interactive() && requireNamespace("webshot2", quietly = TRUE) && isTRUE(file.exists(suppressMessages(chromote::find_chrome())))
# saving needs a headless Chrome (webshot2)
# \donttest{
gt::gt(head(mtcars)) %>%
  gt_theme_gtutils() %>%
  gt_save_crop(tempfile(fileext = ".png"), bg = bg)
# }
}
```
