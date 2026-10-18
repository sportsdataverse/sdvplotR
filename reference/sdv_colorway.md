# Team colours as a plotly colorway

Sets the chart's trace colours to the teams' colours, in order.

## Usage

``` r
sdv_colorway(
  p,
  league,
  teams = NULL,
  which = c("primary", "secondary"),
  season = NULL,
  id_system = "auto"
)
```

## Arguments

- p:

  A plotly object.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- teams:

  Team identifiers, or `NULL` for every team.

- which:

  `"primary"` or `"secondary"`.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- id_system:

  For headshots, as in
  [`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md).

## Value

The plotly object (an htmlwidget).

## Examples

``` r
# \donttest{
if (requireNamespace("plotly", quietly = TRUE)) {
  plotly::plot_ly(type = "bar") |> sdv_colorway("nfl", c("KC", "BUF"))
}

{"x":{"visdat":{"25ab3731b506":["function () ","plotlyVisDat"]},"cur_data":"25ab3731b506","attrs":{"25ab3731b506":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"bar"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"colorway":["#e31837","#00338d"],"xaxis":{"domain":[0,1],"automargin":true},"yaxis":{"domain":[0,1],"automargin":true},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"type":"bar","marker":{"color":"rgba(227,24,55,1)","line":{"color":"rgba(227,24,55,1)"}},"error_y":{"color":"rgba(227,24,55,1)"},"error_x":{"color":"rgba(227,24,55,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
