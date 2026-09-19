# reactable Integration

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

------------------------------------------------------------------------

## Basic: Team logos in a standings table

``` r
library(reactable)
library(sdvplotR)
library(nflfastR)   # companion

season <- nflreadr::most_recent_season()
standings <- nflreadr::load_standings(seasons = season) |>\
  dplyr::arrange(desc(pct), desc(div_wins)) |>\
  dplyr::slice_head(n = 16) |>\
  dplyr::select(team_abbr, wins, losses, pct, div_rank)

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

library(nflverseR)

# Example: per-team EPA/play in a wide table
team_cols <- c("KC", "BUF", "SF", "DAL", "PHI", "MIA")

wide_df <- data.frame(
  week = 1:4,
  KC  = runif(4), BUF = runif(4), SF  = runif(4),
  DAL = runif(4), PHI = runif(4), MIA = runif(4)
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
helper across all sports:

``` r
library(nflreadr)

roster <- nflreadr::load_roster(seasons = 2024) |>\
  dplyr::filter(team %in% c("KC", "BUF", "SF")) |>\
  dplyr::slice_sample(n = 15) |>\
  dplyr::select(player_name, team, position, gsis_id)

reactable(
  roster,
  columns = list(
    player_name = colDef(name = "Player"),
    team = colDef(cell = reactable_sdv_logos(sport = "nfl", height = 24)),
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
library(hoopR)
nba_standings <- hoopR::get_nba_standings(season = 2024) |>\
  dplyr::slice_head(n = 10)

reactable(
  nba_standings,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "nba", height = 28))
  )
)
```

### CFB rankings (cfbfastR)

``` r
library(cfbfastR)
cfb_ranks <- cfbfastR::cfbd_ratings_sp(year = 2024) |>\
  dplyr::slice_head(n = 25)

reactable(
  cfb_ranks,
  columns = list(
    team = colDef(cell = reactable_sdv_logos(sport = "cfb", height = 28))
  )
)
```

### NHL skater stats (fastRhockey)

``` r
library(fastRhockey)
nhl_skaters <- fastRhockey::load_nhl_player_stats(season = 2024) |>\
  dplyr::slice_head(n = 20)

reactable(
  nhl_skaters,
  columns = list(
    team_abbrev = colDef(cell = reactable_sdv_logos(sport = "nhl", height = 28))
  )
)
```

------------------------------------------------------------------------

## Integration with reactablefmtr

These helpers compose cleanly with
[`reactablefmtr`](https://kentjohnson.github.io/reactablefmtr/):

``` r
library(reactablefmtr)

reactable(standings) |>\
  generate_img(
    columns = "team_abbr",
    img_location = "https://a.espncdn.com/i/teamlogos/nfl/500/${team_abbr}.png",
    height = 28
  )
```

For sdvplotR’s richer variant resolution (dark/light/alt/classic),
prefer the `reactable_sdv_*` helpers which handle URL resolution,
historical team mappings, and variant fallbacks internally.

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
