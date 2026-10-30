# Team logos, wordmarks and headshots on plotly charts

Places team marks on a
[`plotly::plot_ly()`](https://rdrr.io/pkg/plotly/man/plot_ly.html) chart
at data coordinates, as layout images. The R counterpart of sdvplot's
plotly adapter. Works on native plotly charts;
[`plotly::ggplotly()`](https://rdrr.io/pkg/plotly/man/ggplotly.html)
drops layout images, so draw a ggplot with
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
or
[`geom_sdv_logos_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos_interactive.md)
instead.

## Usage

``` r
add_sdv_logos(
  p,
  x,
  y,
  team,
  league,
  size = 0.08,
  season = NULL,
  variant = "default",
  id_system = "auto",
  strict = FALSE,
  xref = "x",
  yref = "y"
)

add_sdv_wordmarks(
  p,
  x,
  y,
  team,
  league,
  size = 0.08,
  season = NULL,
  variant = "default",
  id_system = "auto",
  strict = FALSE,
  xref = "x",
  yref = "y"
)

add_sdv_headshots(
  p,
  x,
  y,
  player_id,
  league,
  size = 0.08,
  id_system = "espn",
  xref = "x",
  yref = "y"
)
```

## Arguments

- p:

  A plotly object.

- x, y:

  Positions: numbers, or category names on a categorical axis.

- team:

  Team identifiers, one per position.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- size:

  Each image is fitted by height to `size` times the y-axis span (see
  Details), so `0.08` is 8% of the axis. The width follows the image's
  aspect ratio.

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

- xref, yref:

  The axes the positions refer to (`"x2"` for a subplot's).

- player_id:

  Player ids, one per position.

## Value

The plotly object (an htmlwidget) with the images added.

## Details

Images are placed in data units and fitted by height: each is sized to
`size` times the y-axis span, as sdvplot's plotly adapter sizes them.
The span is the axis range when one is set, and otherwise everything the
chart's traces on that axis cover plus the new marks (the number of
categories on a categorical axis), so marks for a subset of the plotted
points are sized against the whole axis. Images already on the chart,
including ones set with `plotly::layout()`, are kept. Date axes are not
supported yet.

## Examples

``` r
# \donttest{
if (requireNamespace("plotly", quietly = TRUE)) {
  d <- data.frame(
    team = c("KC", "BUF", "BAL"), off = c(0.12, 0.15, 0.18), def = c(-0.05, 0.02, -0.08)
  )
  plotly::plot_ly(d, x = ~off, y = ~def, type = "scatter", mode = "markers", text = ~team) |>
    add_sdv_logos(d$off, d$def, d$team, "nfl")
}

{"x":{"visdat":{"1ff83420f955":["function () ","plotlyVisDat"]},"cur_data":"1ff83420f955","attrs":{"1ff83420f955":{"x":{},"y":{},"mode":"markers","text":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"images":[{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png","xref":"x","yref":"y","x":0.12,"y":-0.050000000000000003,"sizex":0.12,"sizey":0.0080000000000000002,"xanchor":"center","yanchor":"middle","sizing":"contain","layer":"above"},{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png","xref":"x","yref":"y","x":0.14999999999999999,"y":0.02,"sizex":0.12,"sizey":0.0080000000000000002,"xanchor":"center","yanchor":"middle","sizing":"contain","layer":"above"},{"source":"https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png","xref":"x","yref":"y","x":0.17999999999999999,"y":-0.080000000000000002,"sizex":0.12,"sizey":0.0080000000000000002,"xanchor":"center","yanchor":"middle","sizing":"contain","layer":"above"}],"xaxis":{"domain":[0,1],"automargin":true,"title":"off"},"yaxis":{"domain":[0,1],"automargin":true,"title":"def"},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[0.12,0.14999999999999999,0.17999999999999999],"y":[-0.050000000000000003,0.02,-0.080000000000000002],"mode":"markers","text":["KC","BUF","BAL"],"type":"scatter","marker":{"color":"rgba(31,119,180,1)","line":{"color":"rgba(31,119,180,1)"}},"error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"line":{"color":"rgba(31,119,180,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
