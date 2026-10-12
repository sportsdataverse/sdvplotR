# Merge and Stack Text in gt Tables with Team Colors

Takes an existing `gt` table and merges column 1 and column 2, stacking
column 1's text on top of column 2's. Top text is in all caps with black
bold text, while the lower text is smaller and colored by the team name.

## Usage

``` r
gt_merge_stack_team_color(
  gt_object,
  col1,
  col2,
  team_col,
  league,
  font_size_top = 14,
  font_size_bottom = 12,
  color = "black",
  background = NULL,
  season = NULL,
  id_system = "auto"
)
```

## Arguments

- gt_object:

  An existing gt table object of class `gt_tbl`.

- col1:

  The column to stack on top. Will be all caps, black bold text.

- col2:

  The column to merge and place below. Will be smaller and colored.

- team_col:

  The column of team names for the color of the bottom text.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- font_size_top:

  Font size for the top text.

- font_size_bottom:

  Font size for the bottom text.

- color:

  The color for the top text.

- background:

  The cell background the lower text is checked against. `NULL` (the
  default) reads the table's background color, so a table theme such as
  [`gt_theme_midnight()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_midnight.md)
  applied **before** this function is taken into account; a theme
  applied afterwards isn't seen, so set `background` then. A table with
  no background color set counts as white.

- season:

  `NULL` for today's mark, or a season (or one per team): the mark the
  team wore that season where the archive dates its marks.

- id_system:

  `"auto"` (try every id system in priority order) or one id system:
  `"team_id"`, `"espn"`, `"espn_abbr"`, `"nhl"`, `"nflverse"`,
  `"mlbstats"`, `"nba_api"`, `"hockeytech"`, `"ncaa"`, `"pff"`,
  `"cricinfo"`, `"cfbd"`, `"bref"`, `"sportsipy"`, `"fangraphs"`,
  `"sdvplotr"`, `"name"`, or `"nhl_id"` (NHL stats API ids, which
  overlap ESPN's, so `"auto"` never reads a number as one).

## Value

An object of class `gt_tbl`.

## Details

The lower text takes the team's primary color when it clears a 4.5:1
contrast ratio (WCAG AA) against the cell background, else the secondary
color, else the primary darkened (or lightened, on a dark background)
until it does, so a light primary such as Missouri's gold stays readable
on a white table and keeps its gold on a dark one.

## Examples

``` r
# \donttest{
library(gt)
library(sdvplotR)

df <- data.frame(
  team = c("KC", "BUF", "SF"),
  mascot = c("Chiefs", "Bills", "49ers"),
  wins = c(11, 10, 12)
)

df |>
  gt() |>
  gt_merge_stack_team_color(team, mascot, team, league = "nfl")


  

team
```
