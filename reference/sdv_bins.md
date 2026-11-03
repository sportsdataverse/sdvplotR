# Bin points into hexagons or squares

`sdv_bins()` bins x/y points into pointy-top hexagons (`shape = "hex"`,
the default) or axis-aligned squares (`shape = "square"`) and returns
one row per cell: its id, center, count and the rows it holds.
`sdv_bin_ids()` returns each point's cell id instead, the key that links
a point to its cell in an interactive chart
([`geom_sdv_bins_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_bins_interactive.md)).
The lattice is the one sdvplot (Python) and sdvplot-js (`binner()`) use,
with the same argument names, so all three put the same points in the
same cells with the same ids.

## Usage

``` r
sdv_bins(
  x,
  y,
  shape = "hex",
  radius = NULL,
  side = NULL,
  equal_area = FALSE,
  origin = c(0, 0),
  weights = NULL
)

sdv_bin_ids(
  x,
  y,
  shape = "hex",
  radius = NULL,
  side = NULL,
  equal_area = FALSE,
  origin = c(0, 0)
)
```

## Arguments

- x, y:

  Numeric vectors of point coordinates, the same length.

- shape:

  `"hex"` (the default) or `"square"`.

- radius:

  The hexagons' circumradius; for squares, with `equal_area = TRUE`, the
  circumradius of the hexagon whose area each square has.

- side:

  The squares' side.

- equal_area:

  For squares: size them by `radius` to the area of a hexagon of that
  circumradius, so a hex chart and a square chart of the same data have
  cells of the same area.

- origin:

  The point a cell is centered on, `c(x, y)` in the points' units: a
  hoop-centered lattice, origin = the basket's coordinates. The default
  `c(0, 0)` centers a cell on the data origin.

- weights:

  `NULL` (the default) or a numeric vector as long as `x`, each point's
  weight (points scored, say). A cell's `weight` is the sum of its
  points' weights; a missing or non-finite weight counts 0, but the
  point is still binned and counted.

## Value

`sdv_bins()`: a data frame with one row per cell, in first-seen order:

|  |  |  |
|----|----|----|
| col_name | type | description |
| cell_id | character | The cell's id, `"x,y"` (see Details) |
| x | numeric | The cell center's x, in the points' units |
| y | numeric | The cell center's y, in the points' units |
| count | integer | Points in the cell |
| weight | numeric | The sum of the cell's points' `weights` (its `count` without `weights`) |
| rows | list | Integer positions (1-based) of the cell's points in `x` / `y`, in input order |

`sdv_bin_ids()`: a character vector as long as `x`, each point's cell id
(`NA` for a skipped point).

## Details

Sizes are in the points' own units (data space, not pixels): a hexagon
has circumradius `radius`, a square side `side`, and with
`equal_area = TRUE` a square has the area of a hexagon of circumradius
`radius` (side `radius * sqrt(3 * sqrt(3) / 2)`, about
`1.6119 * radius`). Both lattices have a cell centered on `origin`,
`c(0, 0)` by default: for a hoop-centered lattice, origin = the basket's
coordinates (the points are binned as `x - origin[1]`, `y - origin[2]`
and the centers shifted back, so ids are still the absolute centers).

- Hexagons are d3-hexbin's lattice: rows `1.5 * radius` apart, columns
  `sqrt(3) * radius` apart, odd rows shifted half a column. Each point
  goes to the center d3-hexbin picks, which is close to but not exactly
  the nearest one, so about 1-2% of points sit just outside the hexagon
  drawn for their cell (22 of 2000 real shots at radius 10). That is
  faithful to d3-hexbin, sdvplot-js and sdvplot.

- Squares are centered on `(i * side, j * side)` and half-open: a point
  exactly on an edge goes to the higher cell (JavaScript's
  `Math.round()`, which d3-hexbin uses). Every point lies inside its
  square.

Cells come in first-seen order: the cell of the first point first.
Points with a missing or non-finite coordinate are skipped (sdvplot-js
skips `NaN`; it would put an infinite one in a cell of its own).

**Ids are strings**, as in sdvplot-js's linked interactivity: a cell's
id is `"x,y"`, its center written as JavaScript writes a number (the
shortest decimal that reads back exactly, `-0` as `0`), the
`data-sdv-id` sdvplot-js stamps on the cell. The rim cell of a shot
chart in the NBA legacy frame is `"0,0"` for either shape.

## See also

[`geom_sdv_bins()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_bins.md)
to draw the cells,
[`geom_sdv_bins_interactive()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_bins_interactive.md)
to link them to their points.

## Examples

``` r
# three Brooklyn shots of 2025-26, NBA legacy frame (tenths of a foot,
# hoop at the origin): the two at the rim share a 1 ft hexagon
x <- c(0, -1, -44)
y <- c(0, 7, 252)
sdv_bins(x, y, radius = 10)
#>                   cell_id         x   y count weight rows
#> 1                     0,0   0.00000   0     2      2 1, 2
#> 2 -43.301270189221924,255 -43.30127 255     1      1    3
sdv_bins(x, y, shape = "square", side = 10)
#>   cell_id   x   y count weight rows
#> 1     0,0   0   0     1      1    1
#> 2    0,10   0  10     1      1    2
#> 3 -40,250 -40 250     1      1    3
sdv_bins(x, y, shape = "square", radius = 10, equal_area = TRUE)
#>                                  cell_id         x        y count weight rows
#> 1                                    0,0   0.00000   0.0000     2      2 1, 2
#> 2 -48.355646932059386,257.89678363765006 -48.35565 257.8968     1      1    3
sdv_bin_ids(x, y, radius = 10)
#> [1] "0,0"                     "0,0"                    
#> [3] "-43.301270189221924,255"
# the same shots in feet from the baseline, the hoop at (0, 5.25): a
# hoop-centered lattice puts them in the same cells, weighted by points
sdv_bins(x / 10, y / 10 + 5.25, radius = 1, origin = c(0, 5.25), weights = c(2, 2, 3))
#>                    cell_id         x     y count weight rows
#> 1                   0,5.25  0.000000  5.25     2      4 1, 2
#> 2 -4.330127018922193,30.75 -4.330127 30.75     1      3    3
```
