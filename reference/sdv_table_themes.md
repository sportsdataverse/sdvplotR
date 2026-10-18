# List the surveyed table themes

The registry of 122 table styles surveyed from published sources
(`"datagolf"`, `"wikipedia"`, `"nejm"`, ...), shared with the Python and
JavaScript packages. Use an id with
[`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md),
[`reactable_sdv_theme()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_theme.md)
or
[`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md).

## Usage

``` r
sdv_table_themes(mode = NULL, category = NULL)
```

## Arguments

- mode:

  `"dark"` keeps only the themes that have a dark variant; `"light"` or
  `NULL` (the default) keeps all.

- category:

  Keep only this category (for example `"sports"`); `NULL` keeps all.

## Value

A tibble with one row per theme: `id`, `source`, `category` and
`dark_policy` (`"native"`, `"derived"` or `"none"`).

## See also

[`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md)
to resolve one theme,
[`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md)
and
[`reactable_sdv_theme()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_theme.md)
to apply one.

## Examples

``` r
sdv_table_themes()
#> # A tibble: 122 × 4
#>    id               source                               category dark_policy
#>    <chr>            <chr>                                <chr>    <chr>      
#>  1 aer              American Economic Review (AEA style) journal  none       
#>  2 ag-grid-alpine   AG Grid Alpine                       library  native     
#>  3 ag-grid-balham   AG Grid Balham                       library  native     
#>  4 ag-grid-material AG Grid Material                     library  native     
#>  5 ag-grid-quartz   AG Grid Quartz                       library  native     
#>  6 annual-report    Annual-report financial statement    finance  none       
#>  7 apa-7            APA 7 table style                    journal  none       
#>  8 arxiv-booktabs   arXiv / LaTeX booktabs               journal  none       
#>  9 axios            Axios                                news     derived    
#> 10 barrons-markets  Barron's markets data                finance  derived    
#> # ℹ 112 more rows
sdv_table_themes(mode = "dark", category = "sports")
#> # A tibble: 35 × 4
#>    id                   source                  category dark_policy
#>    <chr>                <chr>                   <chr>    <chr>      
#>  1 baseball-prospectus  Baseball Prospectus     sports   derived    
#>  2 baseball-reference   Baseball-Reference      sports   derived    
#>  3 baseball-savant      Baseball Savant         sports   derived    
#>  4 basketball-reference Basketball-Reference    sports   derived    
#>  5 chess-com            Chess.com leaderboards  sports   native     
#>  6 cleaning-the-glass   Cleaning the Glass      sports   derived    
#>  7 datagolf             DataGolf                sports   native     
#>  8 dunks-and-threes     Dunks & Threes          sports   native     
#>  9 espn-site            ESPN (BPI / FPI tables) sports   derived    
#> 10 evanmiya             EvanMiya                sports   native     
#> # ℹ 25 more rows
```
