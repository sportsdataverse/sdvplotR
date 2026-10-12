# Team logo markers on a leaflet map

Adds a marker per row with the team's logo as its icon. A row whose team
has no logo keeps leaflet's default marker, so no point is dropped
silently.

## Usage

``` r
addSdvLogoMarkers(
  map,
  lng,
  lat,
  team,
  league,
  size = 32,
  season = NULL,
  variant = "default",
  id_system = "auto",
  strict = FALSE,
  data = leaflet::getMapData(map),
  ...
)
```

## Arguments

- map:

  A leaflet map.

- lng, lat:

  Longitudes and latitudes: vectors, or formulas read from `data`.

- team:

  Team identifiers: a vector, or a formula read from `data`.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).
  Required: one abbreviation means different teams in different leagues.

- size:

  Icon width and height, in pixels.

- season:

  `NULL` for today's logo, or a season (or one per row): a vector, or a
  formula read from `data`.

- variant:

  `"default"`, `"dark"`, or a named variant from
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  (`"scoreboard"`, `"grayscale"`, `"cap_on_light"`, ...). A team without
  it gets its closest mark of the same polarity; a name no mark in the
  archive has is an error listing the league's variants.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

- strict:

  If `TRUE`, a value that does not resolve is an error; otherwise it
  becomes `NA` with one warning per call.

- data:

  The data formulas read; defaults to the map's.

- ...:

  Passed to
  [`leaflet::addMarkers()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
  (`label`, `popup`, `layerId`, `group`, ...); a vector one per row is
  split with the rows.

## Value

The leaflet map (an htmlwidget) with the markers added.

## Examples

``` r
# \donttest{
if (requireNamespace("leaflet", quietly = TRUE)) {
  d <- data.frame(team = c("KC", "BUF"), lon = c(-94.48, -78.79), lat = c(39.05, 42.77))
  leaflet::leaflet(d) |>
    leaflet::addTiles() |>
    addSdvLogoMarkers(~lon, ~lat, ~team, league = "nfl", label = ~team)
}

{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org/copyright/\">OpenStreetMap<\/a>,  <a href=\"https://opendatacommons.org/licenses/odbl/\">ODbL<\/a>"}]},{"method":"addMarkers","args":[[39.05,42.77],[-94.48,-78.79000000000001],{"iconUrl":{"data":["https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png","https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png"],"index":[0,1]},"iconWidth":32,"iconHeight":32,"iconAnchorX":16,"iconAnchorY":16},null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},null,null,null,null,["KC","BUF"],{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[39.05,42.77],"lng":[-94.48,-78.79000000000001]}},"evals":[],"jsHooks":[]}# }
```
