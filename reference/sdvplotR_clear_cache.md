# Clear the sdvplotR Image Cache

sdvplotR renders images through 'ggpath', which caches downloaded images
for the current session. This function clears that cache when 'ggpath'
exposes a cache-clearing function and is a no-op otherwise.

## Usage

``` r
sdvplotR_clear_cache()
```

## Value

Invisibly `NULL`, called for its side effect.

## Examples

``` r
sdvplotR_clear_cache()
```
