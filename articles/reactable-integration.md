# reactable Integration

On this page

## Overview

`sdvplotR` provides a family of helpers for embedding team logos,
wordmarks, player headshots, and team-colored bars in
[`reactable`](https://glin.github.io/reactable/) tables. These
complement the existing `gt` helpers
([`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
et al.) and are designed for interactive / web-first dashboards.

All functions follow the same **sport / variant / size** contract as
their `ggplot2` and `gt` counterparts:

| Argument | Purpose |
|----|----|
| `sport` | One of [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md) |
| `variant` | `"primary"`, `"dark"`, `"light"`, `"alt"`, `"classic"`, `"helmet"` (NFL) |
| `height` | Image height in pixels |
| `team_col`, `value_col` | Column names for color / bar resolution |

The image helpers
([`reactable_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
[`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
…) return HTML, so their columns need `html = TRUE`.

------------------------------------------------------------------------

## Basic: Team logos in a standings table

``` r

library(reactable)
library(sdvplotR)
library(dplyr)

# Regular-season records from nflreadr's schedules, one row per team per game,
# for the last completed regular season (NFL seasons are named for the year they
# start and end in early January)
season <- as.integer(format(Sys.Date(), "%Y")) - 1 -
  (format(Sys.Date(), "%m-%d") < "01-15")

standings <- nflreadr::load_schedules(season) |>
  filter(game_type == "REG", !is.na(result)) |>
  nflreadr::clean_homeaway() |>
  group_by(team_abbr = team) |>
  summarise(
    wins = sum(team_score > opponent_score),
    losses = sum(team_score < opponent_score),
    pct = mean(team_score > opponent_score) + 0.5 * mean(team_score == opponent_score),
    .groups = "drop"
  ) |>
  arrange(desc(pct)) |>
  slice_head(n = 16)

reactable(
  standings,
  columns = list(
    team_abbr = colDef(
      name = "Team",
      cell = reactable_sdv_logos(sport = "nfl", height = 28),
      html = TRUE
    ),
    pct = colDef(
      format = colFormat(digits = 3),
      style = reactable_sdv_team_color_bar(
        standings,
        team_col = "team_abbr",
        sport = "nfl",
        max_value = 1
      )
    )
  )
)
```

------------------------------------------------------------------------

## Dark mode variants

`reactable` tables often sit inside dark-themed dashboards. Use
`variant = "dark"` for high-contrast logos on dark backgrounds:

``` r

reactable(
  standings,
  theme = reactableTheme(
    color = "#e0e0e0",
    backgroundColor = "#1a1a1a",
    borderColor = "#333"
  ),
  columns = list(
    team_abbr = colDef(
      cell = reactable_sdv_logos(sport = "nfl", variant = "dark", height = 28),
      html = TRUE
    )
  )
)
```

------------------------------------------------------------------------

## Logo column headers

Replace column headers (e.g., per-team stat columns) with the team’s
logo:

``` r

# A wide table with one column per team (example values)
wide_df <- data.frame(
  week = 1:4,
  KC  = c(0.21, 0.05, 0.14, 0.30), BUF = c(0.12, 0.25, 0.08, 0.18),
  SF  = c(0.09, 0.16, 0.22, 0.04), DAL = c(-0.03, 0.11, 0.02, 0.07),
  PHI = c(0.15, 0.19, 0.12, 0.23), MIA = c(0.01, -0.06, 0.10, 0.03)
)

reactable(
  wide_df,
  columns = reactable_sdv_cols_label(
    wide_df,
    sport = "nfl",
    variant = "primary",
    height = 26
  )
)
```

------------------------------------------------------------------------

## Team-colored rows

Use
[`reactable_sdv_team_color_bg()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
to tint entire rows with the team’s primary color at low opacity —
useful for scanning standings quickly:

``` r

reactable(
  standings,
  columns = list(
    team_abbr = colDef(
      cell = reactable_sdv_logos(sport = "nfl", height = 28),
      html = TRUE
    ),
    wins    = colDef(style = reactable_sdv_team_color_bg(standings, "team_abbr", sport = "nfl")),
    losses  = colDef(style = reactable_sdv_team_color_bg(standings, "team_abbr", sport = "nfl")),
    pct     = colDef(style = reactable_sdv_team_color_bg(standings, "team_abbr", sport = "nfl"))
  )
)
```

------------------------------------------------------------------------

## Player headshots

Headshots use the same
[`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md)
helper across all sports. NFL headshots take GSIS IDs, the `gsis_id` in
nflreadr’s rosters:

``` r

roster <- nflreadr::load_rosters(seasons = season) |>
  filter(team %in% c("KC", "BUF", "SF"), position == "QB", !is.na(gsis_id)) |>
  select(full_name, team, position, gsis_id)

reactable(
  roster,
  columns = list(
    full_name = colDef(name = "Player"),
    team = colDef(cell = reactable_sdv_logos(sport = "nfl", height = 24), html = TRUE),
    gsis_id = colDef(
      name = "Headshot",
      cell = reactable_sdv_headshots(sport = "nfl", height = 40),
      html = TRUE
    )
  )
)
```

------------------------------------------------------------------------

## Cross-sport examples

All helpers work identically across sports — only the `sport` argument
changes.

### NBA standings (hoopR)

``` r

# the last completed regular season (named for the year it ends, in mid-April)
nba_season <- as.integer(format(Sys.Date(), "%Y")) -
  (format(Sys.Date(), "%m-%d") < "04-20")
nba_standings <- hoopR::load_nba_standings(seasons = nba_season) |>
  filter(stat_name %in% c("wins", "losses", "winPercent")) |>
  select(team = team_abbreviation, conference = group_abbreviation, stat_name, value) |>
  tidyr::pivot_wider(names_from = stat_name, values_from = value) |>
  arrange(desc(winPercent)) |>
  slice_head(n = 10)

reactable(
  nba_standings,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "nba", height = 28), html = TRUE),
    winPercent = colDef(name = "Pct", format = colFormat(digits = 3))
  )
)
```

### CFB power ratings (cfbfastR)

ESPN’s Football Power Index, which needs no API key:

``` r

# the last completed college football regular season (it ends in mid-December)
cfb_season <- as.integer(format(Sys.Date(), "%Y")) -
  (format(Sys.Date(), "%m-%d") < "12-15")
cfb_fpi <- cfbfastR::espn_ratings_fpi(year = cfb_season) |>
  # FPI arrives as text; sort it as a number
  mutate(fpi = as.numeric(fpi)) |>
  arrange(desc(fpi)) |>
  select(team = team_abbreviation, fpi, w, l) |>
  slice_head(n = 25)
```

The table below uses a snapshot of this call taken on October 04, 2026
(cfbfastR 3.0.0), because ESPN’s API is not called when this site is
built.

``` r

reactable(
  cfb_fpi,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "cfb", height = 28), html = TRUE),
    fpi = colDef(name = "FPI", format = colFormat(digits = 1))
  )
)
```

### NHL skater stats (fastRhockey)

``` r

# the last completed regular season (named for the year it ends, in mid-April)
nhl_season <- as.integer(format(Sys.Date(), "%Y")) -
  (format(Sys.Date(), "%m-%d") < "04-20")
nhl_skaters <- fastRhockey::nhl_stats_skaters(
  season = paste0(nhl_season - 1, nhl_season),
  limit = 20
) |>
  # a player traded mid-season lists every team; keep his last
  mutate(team = sub(".*,\\s*", "", team_abbrevs)) |>
  select(skater_full_name, team, player_id, goals, assists, points)
```

The table below uses a snapshot of this call taken on October 04, 2026
(fastRhockey 1.0.0), because the NHL Stats API is not called when this
site is built.

``` r

reactable(
  nhl_skaters,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "nhl", height = 28), html = TRUE),
    player_id = colDef(
      name = "Headshot",
      # NHL API player ids: the NHL's own image CDN
      cell = reactable_sdv_headshots(sport = "nhl", id_type = "league", height = 40),
      html = TRUE
    )
  )
)
```

------------------------------------------------------------------------

## Integration with reactablefmtr

These helpers compose cleanly with
[`reactablefmtr`](https://kcuilla.github.io/reactablefmtr/), whose
[`embed_img()`](https://kcuilla.github.io/reactablefmtr/reference/embed_img.html)
draws a column that already holds image URLs:

``` r

library(reactablefmtr)

standings |>
  left_join(select(team_reference("nfl"), team_abbr, logo = logo_url), by = "team_abbr") |>
  select(logo, team_abbr, wins, losses, pct) |>
  reactable(
    columns = list(
      logo = colDef(name = "", cell = embed_img(height = 28))
    )
  )
```

[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
holds every team’s logo URLs. For sdvplotR’s variant resolution
(dark/light/alt/classic) and its aliases and historical team mappings
inside the table itself, prefer the `reactable_sdv_*` helpers.

------------------------------------------------------------------------

## Best practices

1.  **Cache reactable outputs** in Shiny apps — image-heavy tables can
    be slow to render on first load.
2.  **Use `variant = "dark"`** when the table sits on a dark background.
3.  **Pair logos with team-colored bars**
    (`reactable_sdv_team_color_bar`) for scannable leaderboards.
4.  **Set `height` consistently** across a single table to keep rows
    aligned.
5.  **Pre-validate teams** with
    [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
    before passing to reactable — it avoids silent fallback images.
