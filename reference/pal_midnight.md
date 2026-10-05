# A rank palette for dark backgrounds

A five-color green-to-red ramp with its luminance range lifted so it
still reads on a near-black background. The default palette in
[`gt_color_ranks()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_ranks.md)
is built for white paper, and its mid-tones collapse into a dark ground.
Pass this instead when using
[`gt_theme_midnight()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_midnight.md)
or
[`gt_theme_terminal()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_terminal.md).

## Usage

``` r
pal_midnight
```

## Format

A character vector of five hex colors, running best to worst.

## See also

[`gt_theme_midnight()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_midnight.md).

## Examples

``` r
west <- subset(sdv_example_standings, league == "nba" & conference == "Western",
  c(team_name, wins, losses, win_pct))
gt::gt(west) %>%
  gt_theme_midnight() %>%
  gt_color_ranks(win_pct, palette = pal_midnight)


  

team_name
```
