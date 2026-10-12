# Clear the sdvplotR caches

sdvplotR keeps the team index, the logo manifest and the NFL headshot
map in memory for the session, keeps the index and manifest on disk (in
`tools::R_user_dir("sdvplotR", "cache")`) for a day. This clears them,
and the image cache of 'ggpath' when 'ggpath' provides a way to, so the
next call reads the CDN again.

## Usage

``` r
sdv_clear_cache()
```

## Value

Invisibly `NULL`, called for its side effect.

## See also

[`sdv_versions()`](https://sdvplotR.sportsdataverse.org/reference/sdv_versions.md)
for what is loaded now.

## Examples

``` r
sdv_clear_cache()
#> ✔ sdvplotR caches cleared.
```
