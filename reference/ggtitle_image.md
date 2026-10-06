# Functions for Adding an Image to the Title of a ggplot

These functions work together to place an image to the left or right of
the title in a ggplot. `ggtitle_image()` is the main function but must
be used with `theme_title_image()`, which renders the title as markdown
and centers the image on the title text.

## Usage

``` r
ggtitle_image(
  title_image = ggplot2::waiver(),
  title = ggplot2::waiver(),
  image_height = 15,
  image_side = c("left", "right"),
  subtitle = ggplot2::waiver(),
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb", "soccer")
)

theme_title_image(...)
```

## Arguments

- title_image:

  The URL of the image to add to the title. If a valid team abbreviation
  for the specified sport, the team logo will be used.

- title:

  The text for the title.

- image_height:

  The height of the image in pixels.

- image_side:

  One of `"left"` or `"right"`. Places the image on either side of the
  title text.

- subtitle:

  Optional text for the subtitle.

- sport:

  Character string identifying the sport (for team logo resolution).

- ...:

  Other arguments passed on to
  [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html),
  such as `size`, `face` and `hjust`.

## Value

A ggplot2 labs object (for `ggtitle_image`) or theme object (for
`theme_title_image`).

## Details

The title is markdown with an inline `<img>` tag. 'gridtext' draws
inline images on the text baseline and ignores CSS `vertical-align`, so
a logo taller than the text would rise above it (ESPN's marks, padded
with transparent space, can sit wholly above the title).
`theme_title_image()` lines the middle of each image up with the middle
of the capital letters on its line. Setting `plot.title` to a plain
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
instead also renders the image, on the baseline.

Style the title through `theme_title_image(...)` (`size`, `face`,
`hjust`, ...), never with a later `theme(plot.title = ...)`: adding
`theme(plot.title = ggtext::element_markdown(hjust = 0.5))` after it
replaces the centering element with a plain markdown one, so the image
drops back to the baseline, and `theme(plot.title = element_text(...))`
is an error. Add `theme_title_image()` after any complete theme such as
[`ggplot2::theme_minimal()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
which replaces every element.

## See also

`theme_title_image()`

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

nfl <- subset(sdv_example_standings, league == "nfl")
p <- ggplot(nfl, aes(x = points_for, y = points_against)) +
  geom_point() +
  labs(title = "This Title will be overwritten",
       subtitle = "Points scored and allowed, 2025 regular season")

if (requireNamespace("ggtext", quietly = TRUE)) {
  p +
    ggtitle_image(
      title_image = "SEA",
      title = "Seattle Seahawks Analysis",
      image_height = 20,
      image_side = "left",
      sport = "nfl"
    ) +
    theme_title_image(size = 20, hjust = 0.5)
}

# }
```
