# Team logos as plotly axis labels

Replaces a categorical axis's tick labels with team logos.

## Usage

``` r
sdv_axis_logos(
  p,
  teams,
  league,
  axis = c("x", "y"),
  size = 0.08,
  season = NULL,
  variant = "default",
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- p:

  A plotly object.

- teams:

  The axis categories, in the chart's order (the team values the chart
  plots on that axis).

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- axis:

  `"x"` or `"y"`.

- size:

  Image size as a fraction of the plot area on the other axis.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- variant:

  `"default"`, `"dark"`, or a named variant from
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  (`"scoreboard"`, `"grayscale"`, `"cap_on_light"`, ...). A team without
  it gets its closest mark of the same polarity; a name no mark in the
  archive has is an error listing the league's variants.

- id_system:

  For headshots, as in
  [`sdv_headshot_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_headshot_url.md).

- strict:

  If `TRUE`, a value that does not resolve is an error; otherwise it
  becomes `NA` with one warning per call.

## Value

The plotly object (an htmlwidget).

## Examples

``` r
# \donttest{
if (requireNamespace("plotly", quietly = TRUE)) {
  teams <- c("KC", "BUF", "BAL")
  plotly::plot_ly(x = teams, y = c(11, 13, 12), type = "bar") |>
    sdv_axis_logos(teams, "nfl")
}

{"x":{"visdat":{"25bf79e53dbd":["function () ","plotlyVisDat"]},"cur_data":"25bf79e53dbd","attrs":{"25bf79e53dbd":{"x":["KC","BUF","BAL"],"y":[11,13,12],"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"bar"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"xaxis":{"domain":[0,1],"automargin":true,"showticklabels":false,"title":[],"type":"category","categoryorder":"array","categoryarray":["BAL","BUF","KC"]},"images":[{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png","xref":"x","yref":"paper","x":"KC","y":0,"sizex":1,"sizey":0.080000000000000002,"xanchor":"center","yanchor":"top","sizing":"contain","layer":"above"},{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png","xref":"x","yref":"paper","x":"BUF","y":0,"sizex":1,"sizey":0.080000000000000002,"xanchor":"center","yanchor":"top","sizing":"contain","layer":"above"},{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png","xref":"x","yref":"paper","x":"BAL","y":0,"sizex":1,"sizey":0.080000000000000002,"xanchor":"center","yanchor":"top","sizing":"contain","layer":"above"}],"yaxis":{"domain":[0,1],"automargin":true,"title":[]},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":["KC","BUF","BAL"],"y":[11,13,12],"type":"bar","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
