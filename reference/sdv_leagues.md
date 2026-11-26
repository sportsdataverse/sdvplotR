# Leagues sdvplotR knows

The SportsDataverse league keys every `league` argument takes: the
leagues of the shared team index sdvplot (Python) and sdvplot-js use.
The Leagues and Identifiers article on the package site
(<https://sdvplotR.sportsdataverse.org/articles/leagues-and-identifiers.html>)
names each league and lists the id systems it carries.

## Usage

``` r
sdv_leagues()
```

## Value

A sorted character vector.

## See also

[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md)
for each league's teams,
[`sdv_aliases()`](https://sdvplotR.sportsdataverse.org/reference/sdv_aliases.md)
for the identifiers each league carries.

## Examples

``` r
sdv_leagues()
#>  [1] "aaf"           "aba"           "acb"           "ahl"          
#>  [5] "ajhl"          "bbl"           "bchl"          "bleague"      
#>  [9] "bnxt"          "cchl"          "cebl"          "cfb"          
#> [13] "cfl"           "chl"           "cricket"       "dbbl"         
#> [17] "dbl"           "easl"          "echl"          "elh"          
#> [21] "euroleague"    "f1"            "feb"           "fiba"         
#> [25] "gojhl"         "ha"            "ibba"          "iihf"         
#> [29] "kbl"           "kijhl"         "kzs"           "lba"          
#> [33] "lkl"           "magnus"        "mbb"           "mhl"          
#> [37] "milb"          "mjhl"          "mlb"           "nba"          
#> [41] "nbagl"         "nbl"           "nbl_au"        "ncaa_baseball"
#> [45] "ncaa_mhockey"  "ncaa_softball" "ncaa_whockey"  "nfl"          
#> [49] "nhl"           "nojhl"         "ohl"           "ojhl"         
#> [53] "phf"           "pwhl"          "qmjhl"         "shl"          
#> [57] "sjhl"          "soccer"        "sphl"          "ufl"          
#> [61] "usfl"          "ushl"          "vijhl"         "vtb"          
#> [65] "wbb"           "whl"           "wjbl"          "wnba"         
#> [69] "wnbl"          "xfl"          
```
