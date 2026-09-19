# Supported Sports

Returns the sport identifiers accepted by the `sport` argument of every
sdvplotR function.

## Usage

``` r
supported_sports()
```

## Value

A character vector: `"nfl"`, `"nba"`, `"wnba"`, `"mlb"`, `"nhl"`,
`"cfb"` (college football), `"mbb"` (men's college basketball) and
`"wbb"` (women's college basketball).

## Examples

``` r
supported_sports()
#> [1] "nfl"  "nba"  "wnba" "mlb"  "nhl"  "cfb"  "mbb"  "wbb" 
```
