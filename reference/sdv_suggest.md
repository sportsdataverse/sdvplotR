# Suggest teams for a value that did not resolve

Up to `n` candidate teams for a misspelled or unknown value, best first.
It never picks one for you: similar names can be different teams. The R
counterpart of sdvplot's `suggest()`.

## Usage

``` r
sdv_suggest(x, league, n = 5)
```

## Arguments

- x:

  One team value.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- n:

  The most candidates to return.

## Value

A data frame with `team_id` and `name`, empty when nothing is close.

## Examples

``` r
sdv_suggest("Kansas Cty Chiefs", "nfl", n = 2)
#>   team_id               name
#> 1      12 Kansas City Chiefs
```
