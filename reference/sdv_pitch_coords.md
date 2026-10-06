# Convert Soccer Event Coordinates to the sdvplotR Pitch Frame

Every soccer data provider uses its own coordinate frame. Opta and
Wyscout run 0-100 on both axes and are not to scale, StatsBomb uses 120
x 80, tracking providers use meters or centimeters from the center spot,
and ESPN reports the distance from the attacked goal as a fraction of
half the pitch. `sdv_pitch_coords()` converts any of them to one frame:
meters, origin at the center spot, a regulation 105 x 68 m pitch,
attacking toward `+x`, with `+y` on the attacker's left. That is the
pitch
[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
draws for `"soccer"`.

## Usage

``` r
sdv_pitch_coords(
  data,
  provider,
  x_column = NULL,
  y_column = NULL,
  flip = NULL,
  pitch_length = NULL,
  pitch_width = NULL
)
```

## Arguments

- data:

  A data frame of events.

- provider:

  The coordinate frame of `data`: `"opta"` (alias `"statsperform"`),
  `"wyscout"`, `"statsbomb"`, `"uefa"`, `"impect"`, `"espn"`,
  `"tracab"`, `"skillcorner"`, `"secondspectrum"` or `"metrica"`. Case
  is ignored.

- x_column, y_column:

  Strings naming the coordinate columns. `NULL` (the default) uses the
  provider's usual names: `"field_position_x"` and `"field_position_y"`
  for ESPN (the output of Python `espn_soccer_game_plays()`), `"x"` and
  `"y"` otherwise.

- flip:

  `NULL` (no row flipped), `TRUE`/`FALSE` for every row, or a string
  naming a logical column with no missing values; `TRUE` rows are turned
  half a turn.

- pitch_length, pitch_width:

  The venue's size in meters, for tracking providers only (the Laws of
  the Game allow 90-120 by 45-90).

## Value

`data` with `pitch_x` and `pitch_y` added (existing columns of those
names are replaced); every other input column is kept as-is:

|  |  |  |
|----|----|----|
| col_name | type | description |
| pitch_x | numeric | Meters along the pitch: -52.5 is the defended goal line, 52.5 the attacked one, 0 the halfway line |
| pitch_y | numeric | Meters across the pitch: -34 to 34; positive = the attacker's left |

## Details

The conversion is piecewise-linear between pitch landmarks: goal line,
six-yard line, penalty spot, box edge and halfway line along the pitch;
touchline, box side, six-yard side and post across it. A shot on the
edge of an Opta box therefore lands on the edge of the regulation box,
not 1.35 m outside it as a linear rescale would put it. Points beyond
the outermost landmark are extrapolated from the nearest segment, not
clamped. The landmark values come from 'mplsoccer' and ship in
`system.file("extdata", "pitch_landmarks.csv", package = "sdvplotR")`.

Tracking providers (`"tracab"`, `"skillcorner"`, `"secondspectrum"`,
`"metrica"`) are measured on the venue's real pitch, so they need
`pitch_length` and `pitch_width`. ESPN frames are derived from the Opta
frame: `opta_x = 100 - 50 * x` and `opta_y = 100 * (1 - y)`. ESPN marks
an event with no location as `(0, 0)`, which becomes `NA`.

Event providers record every action as if the team attacked left to
right. To draw two teams (or two halves of tracking data) attacking
opposite ends, `flip` them: a flipped row is turned half a turn, so its
`x` and `y` both change sign and each wing stays on its own side.

## See also

[`sdv_surface()`](https://sdvplotR.sportsdataverse.org/reference/sdv_surface.md)
draws the pitch;
[`ggsoccer::rescale_coordinates()`](https://torvaney.github.io/ggsoccer/reference/rescale_coordinates.html)
converts between provider frames without the regulation-pitch output.

## Examples

``` r
shots <- data.frame(x = c(88.5, 83, 50), y = c(50, 21.1, 100))
sdv_pitch_coords(shots, "opta")
#>      x     y pitch_x pitch_y
#> 1 88.5  50.0    41.5    0.00
#> 2 83.0  21.1    36.0  -20.16
#> 3 50.0 100.0     0.0   34.00

# two teams attacking opposite ends
shots$away <- c(FALSE, TRUE, FALSE)
sdv_pitch_coords(shots, "opta", flip = "away")
#>      x     y  away pitch_x pitch_y
#> 1 88.5  50.0 FALSE    41.5    0.00
#> 2 83.0  21.1  TRUE   -36.0   20.16
#> 3 50.0 100.0 FALSE     0.0   34.00

# tracking data, measured on the venue's pitch
tracking <- data.frame(x = c(-4150, 3600), y = c(0, -2016))
sdv_pitch_coords(tracking, "tracab", pitch_length = 105, pitch_width = 68)
#>       x     y pitch_x       pitch_y
#> 1 -4150     0   -41.5  1.776357e-15
#> 2  3600 -2016    36.0 -2.016000e+01
```
