# A surveyed table style as a 'reactable' theme

Builds a
[`reactable::reactableTheme()`](https://glin.github.io/reactable/reference/reactableTheme.html)
from one of the 122 surveyed table styles listed by
[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md):
the text, background, hairline, stripe and hover colors, the header
label style, the body font and the cell padding come from the theme's
spec
([`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md)).

## Usage

``` r
reactable_sdv_theme(name, mode = "light")
```

## Arguments

- name:

  A registry theme id, for example `"wikipedia"`, `"datagolf"` or
  `"nejm"`.

- mode:

  `"light"` (default) or `"dark"`. `"dark"` on a light-only theme is an
  error that names three dark-capable themes in the same category.

## Value

A `reactableTheme` object.

## Details

The 27 themes of 'reactablefmtr' (`"espn"`, `"nytimes"`,
`"fivethirtyeight"`, ...) are not rebuilt here: call
`reactablefmtr::<name>()` for those. Three of their names (`"espn"`,
`"fivethirtyeight"`, `"pff"`) are also sites in the registry; the
surveyed look of those is `"espn-site"`, `"fivethirtyeight-site"` and
`"pff-site"`.

The theme does not load a font. Pass the result to
`reactable(theme = )`.

## See also

[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md),
[`table_theme_spec()`](https://sdvplotR.sportsdataverse.org/reference/table_theme_spec.md),
[`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md)

## Examples

``` r
library(reactable)
df <- data.frame(team = c("KC", "BUF", "BAL"), wins = c(12, 10, 9))
reactable(df, theme = reactable_sdv_theme("wikipedia"))

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","BAL"],"wins":[12,10,9]},"columns":[{"id":"team","name":"team","type":"character"},{"id":"wins","name":"wins","type":"numeric"}],"theme":{"color":"#202122","backgroundColor":"#f8f9fa","borderColor":"#a2a9b1","stripedColor":"#f5f5f5","highlightColor":"#ebeced","cellPadding":"3px 6px","style":{"fontFamily":"\"Arimo\", sans-serif","fontSize":"14px"},"tableStyle":{"borderTop":"none"},"headerStyle":{"background":"#eaecf0","color":"#202122","fontWeight":700,"textTransform":"none","letterSpacing":"0","fontFamily":"\"Arimo\", sans-serif","borderBottom":"1px solid #a2a9b1","fontSize":"14px"}},"dataKey":"f647f63a1a87a4575739065aae96d578"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}reactable(df, theme = reactable_sdv_theme("datagolf", mode = "dark"))

{"x":{"tag":{"name":"Reactable","attribs":{"data":{"team":["KC","BUF","BAL"],"wins":[12,10,9]},"columns":[{"id":"team","name":"team","type":"character"},{"id":"wins","name":"wins","type":"numeric"}],"theme":{"color":"#cdcdcd","backgroundColor":"#141414","borderColor":"#1e1e1e","stripedColor":"#191919","highlightColor":"#1f1f1f","cellPadding":"6px 6px","style":{"fontFamily":"\"Fira Sans\", sans-serif","fontSize":"12px"},"tableStyle":{"borderTop":"none"},"headerStyle":{"background":"#232323","color":"#cdcdcd","fontWeight":400,"textTransform":"none","letterSpacing":"0","fontFamily":"\"Fira Sans\", sans-serif","borderBottom":"1px solid #373737","fontSize":"10px"}},"dataKey":"f647f63a1a87a4575739065aae96d578"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
