# gt_merge_stack_team_color stacks and colours text

    Code
      gt_merge_stack_team_color(df, team, mascot, team, sport = "nfl")
    Condition
      Error in `gt_merge_stack_team_color()`:
      ! 'gt_object' must be a 'gt_tbl', have you accidentally passed raw data?

# gt_tiers alt-names each entry by the team its image shows

    Code
      gt_tiers(gt(d), c(A = "#1B7837", B = "#B2182B"), alt = "Logo")
    Condition
      Error in `gt_tiers()`:
      ! `alt` must be a function that takes the image URLs.
      x Got <character>.
      i Use `alt = function(url) ...`, or leave it `NULL` to name each team.

