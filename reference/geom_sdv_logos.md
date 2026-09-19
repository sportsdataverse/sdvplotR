# ggplot2 Layer for Visualizing Sports Team Logos

This geom is used to plot sports team logos instead of points in a
ggplot. It requires x, y aesthetics as well as a valid team
abbreviation. The latter can be checked with
[`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md).

## Usage

``` r
geom_sdv_logos(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = TRUE
)

GeomSDVlogo
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html). If
  specified and `inherit.aes = TRUE` (the default), it is combined with
  the default mapping at the top level of the plot. You must supply
  `mapping` if there is no plot mapping.

- data:

  The data to be displayed in this layer. There are three options:

  If `NULL`, the default, the data is inherited from the plot data as
  specified in the call to
  [`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

  A `data.frame`, or other object, will override the plot data. All
  objects will be fortified to produce a data frame. See
  [`fortify()`](https://ggplot2.tidyverse.org/reference/fortify.html)
  for which variables will be created.

  A `function` will be called with a single argument, the plot data. The
  return value must be a `data.frame`, and will be used as the layer
  data. A `function` can be created from a `formula` (e.g.
  `~ head(.x, 10)`).

- stat:

  The statistical transformation to use on the data for this layer. When
  using a `geom_*()` function to construct a layer, the `stat` argument
  can be used to override the default coupling between geoms and stats.
  The `stat` argument accepts the following:

  - A `Stat` ggproto subclass, for example `StatCount`.

  - A string naming the stat. To give the stat as a string, strip the
    function name of the `stat_` prefix. For example, to use
    [`stat_count()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
    give the stat as `"count"`.

  - For more information and other ways to specify the stat, see the
    [layer
    stat](https://ggplot2.tidyverse.org/reference/layer_stats.html)
    documentation.

- position:

  A position adjustment to use on the data for this layer. This can be
  used in various ways, including to prevent overplotting and improving
  the display. The `position` argument accepts the following:

  - The result of calling a position function, such as
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html).
    This method allows for passing extra arguments to the position.

  - A string naming the position adjustment. To give the position as a
    string, strip the function name of the `position_` prefix. For
    example, to use
    [`position_jitter()`](https://ggplot2.tidyverse.org/reference/position_jitter.html),
    give the position as `"jitter"`.

  - For more information and other ways to specify the position, see the
    [layer
    position](https://ggplot2.tidyverse.org/reference/layer_positions.html)
    documentation.

- ...:

  Other arguments passed on to
  [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html)'s
  `params` argument. These arguments broadly fall into one of 4
  categories below. Notably, further arguments to the `position`
  argument, or aesthetics that are required can *not* be passed through
  `...`. Unknown arguments that are not part of the 4 categories below
  are ignored.

  - Static aesthetics that are not mapped to a scale, but are at a fixed
    value and apply to the layer as a whole. For example,
    `colour = "red"` or `linewidth = 3`. The geom's documentation has an
    **Aesthetics** section that lists the available options. The
    'required' aesthetics cannot be passed on to the `params`. Please
    note that while passing unmapped aesthetics as vectors is
    technically possible, the order and required length is not
    guaranteed to be parallel to the input data.

  - When constructing a layer using a `stat_*()` function, the `...`
    argument can be used to pass on parameters to the `geom` part of the
    layer. An example of this is
    `stat_density(geom = "area", outline.type = "both")`. The geom's
    documentation lists which parameters it can accept.

  - Inversely, when constructing a layer using a `geom_*()` function,
    the `...` argument can be used to pass on parameters to the `stat`
    part of the layer. An example of this is
    `geom_area(stat = "density", adjust = 0.5)`. The stat's
    documentation lists which parameters it can accept.

  - The `key_glyph` argument of
    [`layer()`](https://ggplot2.tidyverse.org/reference/layer.html) may
    also be passed on through `...`. This can be one of the functions
    described as [key
    glyphs](https://ggplot2.tidyverse.org/reference/draw_key.html), to
    change the display of the layer in the legend.

- sport:

  Character string identifying the sport. One of: `"nfl"`, `"nba"`,
  `"wnba"`, `"mlb"`, `"nhl"`, `"cfb"`, `"mbb"`, `"wbb"`.

- na.rm:

  If `FALSE`, the default, missing values are removed with a warning. If
  `TRUE`, missing values are silently removed.

- show.legend:

  logical. Should this layer be included in the legends? `NA`, the
  default, includes if any aesthetics are mapped. `FALSE` never
  includes, and `TRUE` always includes. It can also be a named logical
  vector to finely select the aesthetics to display. To include legend
  keys for all levels, even when no data exists, use `TRUE`. If `NA`,
  all levels are shown in legend, but unobserved levels are omitted.

- inherit.aes:

  If `FALSE`, overrides the default aesthetics, rather than combining
  with them. This is most useful for helper functions that define both
  data and aesthetics and shouldn't inherit behaviour from the default
  plot specification, e.g.
  [`annotation_borders()`](https://ggplot2.tidyverse.org/reference/annotation_borders.html).

## Value

A ggplot2 layer
([`ggplot2::layer()`](https://ggplot2.tidyverse.org/reference/layer.html))
that can be added to a plot created with
[`ggplot2::ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html).

## Aesthetics

`geom_sdv_logos()` understands the following aesthetics (required
aesthetics are in bold):

- **x**:

  \- The x-coordinate.

- **y**:

  \- The y-coordinate.

- **team**:

  \- The team abbreviation. Should be one of
  [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md).
  The function tries to clean team names internally.

- `alpha = NULL`:

  \- The alpha channel, i.e. transparency level, as a numerical value
  between 0 and 1.

- `colour = NULL`:

  \- The image will be colorized with this colour. Use the special
  character `"b/w"` to set it to black and white.

- `angle = 0`:

  \- The angle of the image as a numerical value between 0 and 360
  degrees.

- `hjust = 0.5`:

  \- The horizontal adjustment relative to the given x coordinate.

- `vjust = 0.5`:

  \- The vertical adjustment relative to the given y coordinate.

- `width = 1.0`:

  \- The desired width of the image in `npc` (Normalised Parent
  Coordinates). A typical size is `width = 0.075`.

- `height = 1.0`:

  \- The desired height of the image in `npc`. A typical size is
  `height = 0.1`.

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

team_abbr <- valid_team_names("nfl")[1:16]

df <- data.frame(
  a = rep(1:4, 4),
  b = sort(rep(1:4, 4), decreasing = TRUE),
  teams = team_abbr
)

ggplot(df, aes(x = a, y = b)) +
  geom_sdv_logos(aes(team = teams), sport = "nfl", width = 0.075) +
  geom_label(aes(label = teams), nudge_y = -0.35, alpha = 0.5) +
  theme_void()

# }
```
