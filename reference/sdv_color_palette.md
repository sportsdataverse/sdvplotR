# Get Team Color Palette

Returns a color palette for a given sport, suitable for use with ggplot2
`scale_fill_manual` or `scale_color_manual`.

## Usage

``` r
sdv_color_palette(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  teams = NULL,
  type = c("primary", "secondary")
)
```

## Arguments

- sport:

  Character string identifying the sport.

- teams:

  Character vector of team names or abbreviations. If `NULL`, returns
  all teams.

- type:

  Character string, `"primary"` or `"secondary"`.

## Value

Named character vector of colors.

## Examples

``` r
sdv_color_palette("nfl", c("KC", "BUF", "SF"))
#>        KC       BUF        SF 
#> "#E31837" "#00338D" "#AA0000" 
```
