# Output Valid Team Names

Returns a character vector of valid team abbreviations or names for a
given sport.

## Usage

``` r
valid_team_names(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
  type = c("abbreviation", "name")
)
```

## Arguments

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

- type:

  Character string, either `"abbreviation"` (default) or `"name"`.

## Value

A sorted character vector of valid team identifiers.

## Examples

``` r
valid_team_names("nfl")
#>  [1] "ARI" "ATL" "BAL" "BUF" "CAR" "CHI" "CIN" "CLE" "DAL" "DEN" "DET" "GB" 
#> [13] "HOU" "IND" "JAX" "KC"  "LA"  "LAC" "LV"  "MIA" "MIN" "NE"  "NO"  "NYG"
#> [25] "NYJ" "PHI" "PIT" "SEA" "SF"  "TB"  "TEN" "WAS"
valid_team_names("nba", type = "name")
#>  [1] "Atlanta Hawks"          "Boston Celtics"         "Brooklyn Nets"         
#>  [4] "Charlotte Hornets"      "Chicago Bulls"          "Cleveland Cavaliers"   
#>  [7] "Dallas Mavericks"       "Denver Nuggets"         "Detroit Pistons"       
#> [10] "Golden State Warriors"  "Houston Rockets"        "Indiana Pacers"        
#> [13] "LA Clippers"            "Los Angeles Lakers"     "Memphis Grizzlies"     
#> [16] "Miami Heat"             "Milwaukee Bucks"        "Minnesota Timberwolves"
#> [19] "New Orleans Pelicans"   "New York Knicks"        "Oklahoma City Thunder" 
#> [22] "Orlando Magic"          "Philadelphia 76ers"     "Phoenix Suns"          
#> [25] "Portland Trail Blazers" "Sacramento Kings"       "San Antonio Spurs"     
#> [28] "Toronto Raptors"        "Utah Jazz"              "Washington Wizards"    
```
