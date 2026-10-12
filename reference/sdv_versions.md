# Versions of the data sdvplotR is using

Which team index and logo manifest the session has loaded and where they
came from: `"live"` (the SportsDataverse CDN, or the disk cache within a
day of it), `"cache"` (an older disk copy, after a failed refresh) or
`"snapshot"` (the copy bundled with the package: offline, with
`options(sdvplotR.offline = TRUE)`, or during a CRAN check). The R
counterpart of sdvplot's `versions()`.

## Usage

``` r
sdv_versions()
```

## Value

A list with `package`, `index_version`, `index_source`, `manifest_rows`
and `manifest_source`.

## Examples

``` r
sdv_versions()
#> $package
#> [1] "0.1.0"
#> 
#> $index_version
#> [1] "0aeef853ec2b"
#> 
#> $index_source
#> [1] "live"
#> 
#> $manifest_rows
#> [1] 44462
#> 
#> $manifest_source
#> [1] "live"
#> 
```
