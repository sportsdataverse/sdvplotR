# valid_team_names rejects unknown sports

    Code
      valid_team_names("xfl")
    Condition
      Error in `valid_team_names()`:
      ! `sport` must be one of "nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", or "wbb", not "xfl".
      i Did you mean "nfl"?

# clean_team_abbrs warns about non-matches when verbose

    Code
      clean_team_abbrs(c("KC", "nope"), "nfl")
    Condition
      Warning:
      Abbreviations not found in "nfl" mapping: "nope"
    Output
      [1] "KC"   "nope"

