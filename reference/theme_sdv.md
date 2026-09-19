# Theme Helpers for SDV Axis Labels

These functions are convenience wrappers around a theme call that
activates markdown in x-axis and y-axis labels using
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html).

## Usage

``` r
theme_x_sdv()

theme_y_sdv()
```

## Value

A ggplot2 theme object.

## Details

These functions are a wrapper around the function calls
`ggplot2::theme(axis.text.x = ggtext::element_markdown())` as well as
`ggplot2::theme(axis.text.y = ggtext::element_markdown())`. They are
made to be used in conjunction with
[`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
and
[`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
respectively.

## See also

[`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md),
[`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

team_abbr <- valid_team_names("nfl")[1:8]

df <- data.frame(
  random_value = runif(length(team_abbr), 0, 1),
  teams = team_abbr
)

if (requireNamespace("ggtext", quietly = TRUE)) {
  ggplot(df, aes(x = teams, y = random_value)) +
    geom_col(width = 0.5) +
    scale_x_sdv(sport = "nfl") +
    theme_minimal() +
    theme_x_sdv()
}

# }
```
