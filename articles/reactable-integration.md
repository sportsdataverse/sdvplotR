# reactable Integration

On this page

## Overview

`sdvplotR` provides a family of helpers for embedding team logos,
wordmarks, player headshots, and team-colored bars in
[`reactable`](https://glin.github.io/reactable/) tables. These
complement the existing `gt` helpers
([`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
et al.) and are designed for interactive / web-first dashboards.

All functions follow the same **league / variant / size** contract as
their `ggplot2` and `gt` counterparts:

| Argument | Purpose |
|----|----|
| `league` | One of [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md) |
| `variant` | `"default"`, `"dark"` or a named variant of the league’s marks ([`sdv_marks()`](https://sdvplotR.sportsdataverse.org/reference/sdv_marks.md) lists them) |
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
      cell = reactable_sdv_logos(league = "nfl", height = 28),
      html = TRUE
    ),
    pct = colDef(
      format = colFormat(digits = 3),
      style = reactable_sdv_team_color_bar(
        standings,
        team_col = "team_abbr",
        league = "nfl",
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
      cell = reactable_sdv_logos(league = "nfl", variant = "dark", height = 28),
      html = TRUE
    ),
    pct = colDef(format = colFormat(digits = 3))
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
    league = "nfl",
    variant = "default",
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
      cell = reactable_sdv_logos(league = "nfl", height = 28),
      html = TRUE
    ),
    wins    = colDef(style = reactable_sdv_team_color_bg(standings, "team_abbr", league = "nfl")),
    losses  = colDef(style = reactable_sdv_team_color_bg(standings, "team_abbr", league = "nfl")),
    pct     = colDef(
      format = colFormat(digits = 3),
      style = reactable_sdv_team_color_bg(standings, "team_abbr", league = "nfl")
    )
  )
)
```

------------------------------------------------------------------------

## Player headshots

Headshots use the same
[`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md)
helper across all leagues. NFL headshots take GSIS IDs, the `gsis_id` in
nflreadr’s rosters:

``` r

roster <- nflreadr::load_rosters(seasons = season) |>
  filter(team %in% c("KC", "BUF", "SF"), position == "QB", !is.na(gsis_id)) |>
  select(full_name, team, position, gsis_id)

reactable(
  roster,
  columns = list(
    full_name = colDef(name = "Player"),
    team = colDef(cell = reactable_sdv_logos(league = "nfl", height = 24), html = TRUE),
    gsis_id = colDef(
      name = "Headshot",
      cell = reactable_sdv_headshots(league = "nfl", id_system = "gsis", height = 40),
      html = TRUE
    )
  )
)
```

------------------------------------------------------------------------

## Cross-league examples

All helpers work identically across leagues — only the `league` argument
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
    team = colDef(cell = reactable_sdv_logos(league = "nba", height = 28), html = TRUE),
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
    team = colDef(cell = reactable_sdv_logos(league = "cfb", height = 28), html = TRUE),
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
    team = colDef(cell = reactable_sdv_logos(league = "nhl", height = 28), html = TRUE),
    player_id = colDef(
      name = "Headshot",
      # NHL API player ids: the NHL's own image CDN
      cell = reactable_sdv_headshots(league = "nhl", id_system = "league", height = 40),
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
  mutate(logo = sdv_logo_url(team_abbr, league = "nfl")) |>
  select(logo, team_abbr, wins, losses, pct) |>
  reactable(
    columns = list(
      logo = colDef(
        name = "",
        # embed_img() writes no alt: give each logo its team abbreviation
        cell = function(value, index, name) {
          htmltools::tagQuery(embed_img(height = 28)(value, index, name))$
            find("img")$
            addAttrs(alt = standings$team_abbr[[index]])$
            allTags()
        }
      ),
      pct = colDef(format = colFormat(digits = 3))
    )
  )
```

[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)
gives the URL the sdvplotR helpers draw: the SportsDataverse logo
archive’s copy of the mark, an immutable content-addressed file
(`.../sha256/<ab>/<sha256>.png`), so a table built today still renders
when ESPN drops or replaces a file. For the variant resolution, the
aliases and the season marks inside the table itself, prefer the
`reactable_sdv_*` helpers; their `<img>` tags also swap to the primary
logo in the browser if a variant’s file ever fails to load.

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
    [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
    before passing to reactable — it avoids silent fallback images.

## **Our Authors**

- [Saiem Gilani](https://x.com/saiemgilani)  
  [![@saiemgilani](https://img.shields.io/twitter/follow/saiemgilani?color=blue&label=%40saiemgilani&logo=x&style=for-the-badge)](https://x.com/saiemgilani)
  [![@saiemgilani](https://img.shields.io/github/followers/saiemgilani?color=eee&logo=Github&style=for-the-badge)](https://github.com/saiemgilani)
- [Sebastian Carl](https://x.com/mrcaseb)  
  [![@mrcaseb](https://img.shields.io/twitter/follow/mrcaseb?color=blue&label=%40mrcaseb&logo=x&style=for-the-badge)](https://x.com/mrcaseb)
  [![@mrcaseb](https://img.shields.io/github/followers/mrcaseb?color=eee&logo=Github&style=for-the-badge)](https://github.com/mrcaseb)
- [Jared Lee](https://github.com/Kazink36)  
  [![@Kazink36](https://img.shields.io/github/followers/Kazink36?color=eee&logo=Github&style=for-the-badge)](https://github.com/Kazink36)
- [Camden Kay](https://x.com/camdenkay)  
  [![@camdenkay](https://img.shields.io/twitter/follow/camdenkay?color=blue&label=%40camdenkay&logo=x&style=for-the-badge)](https://x.com/camdenkay)
  [![@camdenk](https://img.shields.io/github/followers/camdenk?color=eee&logo=Github&style=for-the-badge)](https://github.com/camdenk)
- [Andrew Weatherman](https://github.com/andreweatherman) (gtUtils)  
  [![@andreweatherman](https://img.shields.io/github/followers/andreweatherman?color=eee&logo=Github&style=for-the-badge)](https://github.com/andreweatherman)

## **Citation**

To cite the [**`sdvplotR`**](https://sdvplotR.sportsdataverse.org/) R
package in publications, use:

BibTeX Citation

``` bibtex
@misc{gilani_carl_lee_kay_weatherman_sdvplotR,
  author = {Gilani, Saiem and Carl, Sebastian and Lee, Jared and Kay, Camden and Weatherman, Andrew},
  title = {sdvplotR: The SportsDataverse's R Package for Multi-League Sports Plotting.},
  url = {https://sdvplotR.sportsdataverse.org},
  year = {2026}
}
```

## **Related SportsDataverse packages**

- [**sdvplot**](https://sdvplot.sportsdataverse.org/) - the Python
  plotting package
- [**sdvplot-js**](https://plot.sportsdataverse.org/) - the JavaScript /
  TypeScript plotting packages
- [**cfbfastR**](https://cfbfastR.sportsdataverse.org/) - college
  football
- [**hoopR**](https://hoopR.sportsdataverse.org/) - men’s basketball
- [**wehoop**](https://wehoop.sportsdataverse.org/) - women’s basketball
- [**baseballr**](https://baseballr.sportsdataverse.org/) - baseball
- [**fastRhockey**](https://fastRhockey.sportsdataverse.org/) - hockey
- [**oddsapiR**](https://oddsapiR.sportsdataverse.org/) - betting odds
- [**sportyR**](https://sportyR.sportsdataverse.org/) - playing surfaces
- [**sportsdataverse-py**](https://py.sportsdataverse.org/) - the Python
  package
- [**sportsdataverse-R**](https://r.sportsdataverse.org/) - the R
  meta-package
