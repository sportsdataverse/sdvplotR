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
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  font_size_top = 14,
  font_size_bottom = 12,
  color = "black"
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

- sport:

  Character string identifying the sport.

- font_size_top:

  Font size for the top text.

- font_size_bottom:

  Font size for the bottom text.

- color:

  The color for the top text.

## Value

An object of class `gt_tbl`.

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
  gt_merge_stack_team_color(team, mascot, team, sport = "nfl")


  

team
```
