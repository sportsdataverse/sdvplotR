# Resolve a surveyed table theme

One theme from the registry listed by
[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md):
fonts, sizes, a complete palette and the structure (rules, stripes,
label style), with every `{key}` in the structure's border strings
replaced by a palette color.

## Usage

``` r
table_theme_spec(name, mode = c("light", "dark"))
```

## Arguments

- name:

  The theme id, for example `"datagolf"`, `"wikipedia"` or `"nejm"`.
  `"espn"`, `"fivethirtyeight"` and `"pff"` are reactablefmtr names, not
  registry ids: the surveyed look of those sites is `"espn-site"`,
  `"fivethirtyeight-site"` and `"pff-site"`.

- mode:

  `"light"` (default) or `"dark"`. Palette keys a theme leaves out take
  the shared defaults. `"dark"` on a light-only theme is an error that
  names three dark-capable themes in the same category.

## Value

A list with `id`, `source`, `category`, `fonts`, `sizes`, `palette`,
`structure` and `dark_policy`.

## See also

[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md)
to list the ids,
[`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md)
and
[`reactable_sdv_theme()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_theme.md)
to apply one.

## Examples

``` r
spec <- table_theme_spec("datagolf", "dark")
spec$palette$bg
#> [1] "#141414"
spec$structure$rowRule
#> [1] "1px solid #1e1e1e"
```
