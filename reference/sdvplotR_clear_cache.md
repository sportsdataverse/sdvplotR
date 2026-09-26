# Clear the sdvplotR Caches

sdvplotR reads the NFL headshot map through 'nflreadr', which memoises
it for a day, and renders images through 'ggpath', which caches
downloaded images for the session. This function clears both (the
'ggpath' cache when 'ggpath' exposes a cache-clearing function), so the
next NFL headshot reads the current published map.

## Usage

``` r
sdvplotR_clear_cache()
```

## Value

Invisibly `NULL`, called for its side effect.

## Examples

``` r
sdvplotR_clear_cache()
#> ✔ sdvplotR cache cleared.
```
