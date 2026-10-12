# Create Team Tier Plots

This function sets up a ggplot to visualize team tiers across any league
supported by sdvplotR. Teams are organized by performance or other
metrics into labeled tiers.

## Usage

``` r
sdv_team_tiers(
  data,
  league,
  title = glue::glue("{toupper(league)} Team Tiers"),
  subtitle = glue::glue("created with the #sdvplotR Tiermaker"),
  caption = NULL,
  tier_desc = c(`1` = "Elite", `2` = "Very Good", `3` = "Medium", `4` = "Bad", `5` =
    "What are they doing?", `6` = "", `7` = ""),
  presort = FALSE,
  alpha = 0.8,
  width = 0.075,
  no_line_below_tier = NULL,
  devel = FALSE,
  theme = c("dark", "light"),
  variant = "auto",
  season = NULL,
  id_system = "auto",
  strict = FALSE
)
```

## Arguments

- data:

  A data frame that must include the variables `tier_no` (the number of
  the tier starting from the top tier no. 1) and `team` (the team:
  anything
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  accepts). If data includes the variable `tier_rank`, these ranks will
  be used within each tier. Otherwise, if `presort = FALSE`, the
  function will assume that data is already sorted and if
  `presort = TRUE`, teams will be sorted alphabetically within tiers.

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md).

- title:

  The title of the plot. If `NULL`, it will be omitted.

- subtitle:

  The subtitle of the plot. If `NULL`, it will be omitted.

- caption:

  The caption of the plot. If `NULL`, it will be omitted.

- tier_desc:

  A named vector of tier descriptions. Names must equal the tier numbers
  from `tier_no`.

- presort:

  If `FALSE` (the default) the function assumes that the teams are
  already sorted within the tiers. Will otherwise sort alphabetically.

- alpha:

  The alpha channel of the logos (transparency level).

- width:

  The desired width of the logo in `npc`.

- no_line_below_tier:

  Vector of tier numbers. The function won't draw tier separation lines
  below these tiers.

- devel:

  Determines if logos shall be rendered. If `FALSE` (the default), logos
  will be rendered on each run. If `TRUE` the team abbreviations will be
  plotted instead of the logos. This is much faster and helps with plot
  development.

- theme:

  `"dark"` (the default: a near-black background with white labels) or
  `"light"` (a white background with dark labels and lines).

- variant:

  The logo variant to draw. `"auto"` (the default, as sdvplot's
  `team_tiers()`) draws each team's dark-background mark (`"dark"`) on
  the dark theme and its default mark on the light theme, so dark logos
  such as the Capitals' or Penn State's don't fade into the dark
  background. Any other value is `"default"`, `"dark"` or a named
  variant from
  [`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md)
  (see
  [`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)),
  drawn on either theme. A team without the variant draws its closest
  mark, with no warning.

- season, id_system, strict:

  Passed to
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  and the logo lookup: a season for dated marks, the identifier system
  of `team`, and whether an unresolved team is an error.

## Value

A ggplot object.

## Examples

``` r
# \donttest{
library(sdvplotR)
library(ggplot2)

# Build the team tiers data
df <- data.frame(
  tier_no = c(1, 1, 2, 2, 3, 3),
  team = c("KC", "DET", "BAL", "PHI", "BUF", "GB")
)

# Plot team tiers, each team's primary logo on white
sdv_team_tiers(df, league = "nfl", theme = "light")

# }
```
