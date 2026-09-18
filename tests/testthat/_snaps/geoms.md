# geoms validate the sport argument

    Code
      geom_sdv_logos(sport = "xfl")
    Condition
      Error in `geom_sdv_logos()`:
      ! `sport` must be one of "nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", or "wbb", not "xfl".
      i Did you mean "nfl"?

# sdv_team_tiers builds a plot and validates input

    Code
      sdv_team_tiers(data.frame(team = "KC"), sport = "nfl")
    Condition
      Error in `sdv_team_tiers()`:
      ! The data frame `data` has to include the variables `tier_no` and `team`!

