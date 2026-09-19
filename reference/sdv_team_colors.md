# Get Team Colors

Returns the primary and secondary colors (hex codes) for a given team.

## Usage

``` r
sdv_team_colors(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  team = NULL,
  type = c("primary", "secondary", "all")
)
```

## Arguments

- sport:

  Character string identifying the sport.

- team:

  Character string or vector of team name(s) or abbreviation(s). If
  `NULL`, returns colors for all teams.

- type:

  Character string, `"primary"`, `"secondary"`, or `"all"`.

## Value

With `team` supplied, a named character vector (one element per team,
`NA` for unmatched teams): the primary or secondary hex code, or for
`type = "all"` the two codes as one `"primary, secondary"` string. With
`team = NULL` and `type = "all"`, a data frame with columns:

|           |           |                             |
|-----------|-----------|-----------------------------|
| col_name  | type      | description                 |
| team_abbr | character | Canonical team abbreviation |
| team_name | character | Full team name              |
| primary   | character | Primary team color (hex)    |
| secondary | character | Secondary team color (hex)  |

With `team = NULL` and any other `type`, a named character vector of
every team's color.

## Examples

``` r
# Get primary color for Kansas City Chiefs
sdv_team_colors("nfl", "KC")
#>        KC 
#> "#E31837" 

# Get both colors for multiple teams
sdv_team_colors("nfl", c("KC", "BUF"), type = "all")
#>                 KC                BUF 
#> "#E31837, #FFB612" "#00338D, #C60C30" 

# Get all NFL team primary colors
sdv_team_colors("nfl", type = "primary")
#>       ARI       ATL       BAL       BUF       CAR       CHI       CIN       CLE 
#> "#97233F" "#A71930" "#241773" "#00338D" "#0085CA" "#0B162A" "#FB4F14" "#FF3C00" 
#>       DAL       DEN       DET        GB       HOU       IND       JAX        KC 
#> "#002244" "#002244" "#0076B6" "#203731" "#03202F" "#002C5F" "#006778" "#E31837" 
#>        LA       LAC        LV       MIA       MIN        NE        NO       NYG 
#> "#003594" "#007BC7" "#000000" "#008E97" "#4F2683" "#002244" "#D3BC8D" "#0B2265" 
#>       NYJ       PHI       PIT       SEA        SF        TB       TEN       WAS 
#> "#003F2D" "#004C54" "#000000" "#002244" "#AA0000" "#A71930" "#4495D2" "#5A1414" 
```
