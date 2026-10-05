# Creating Tier Lists

On this page

A tier list ranks teams into colored bands, best band on top, each band
a row of logos.
[`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
draws one from a `gt` table, but it needs the data in a particular
shape: one row per tier, a `tier` column naming it, and one column per
slot holding an image URL. This article builds two:

1.  **The 2025 NFL season** in four tiers by EPA per play margin, from
    [`nflfastR`](https://www.nflfastr.com)’s play-by-play, on a light
    ground.
2.  **The ACC’s 2025-26 men’s basketball season** in three tiers by
    efficiency margin, from
    [`hoopR`](https://hoopR.sportsdataverse.org)’s ESPN box scores, on
    the default dark ground.

[`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
and
[`gt_theme_tier()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_tier.md)
come from Andrew Weatherman’s
[gtUtils](https://github.com/andreweatherman/gtUtils), and this article
follows his tier-list example.

``` r

library(sdvplotR)
library(gt)
library(dplyr)
library(tidyr)
```

## 1. NFL teams by EPA per play margin

A team’s EPA per play margin is the expected points it added per
offensive snap minus the expected points it allowed per defensive snap,
over pass and run plays. One season of play-by-play holds both ends.

``` r

pbp <- nflreadr::load_pbp(2025) |>
  filter(season_type == "REG", !is.na(epa), pass == 1 | rush == 1)

nfl <- inner_join(
  summarise(pbp, off_epa = mean(epa), .by = posteam),
  summarise(pbp, def_epa = mean(epa), .by = defteam),
  by = c(posteam = "defteam")
) |>
  rename(team = posteam) |>
  mutate(margin = off_epa - def_epa)
```

### Binning into tiers

Four tiers: the top eight, the next eight, and so on.
[`row_number()`](https://dplyr.tidyverse.org/reference/row_number.html)
ranks the teams with the abbreviation as a tiebreaker, so a rebuild bins
them the same way, and integer division by eight turns the rank into a
tier. `tier_order` is each team’s place within its tier, which becomes
its column.

``` r

nfl_tiers <- c(Contenders = "#1B7837", Solid = "#7FBF7B", Shaky = "#F1B6A8", Rebuilding = "#B2182B")

nfl <- nfl |>
  arrange(desc(margin), team) |>
  mutate(
    rank = row_number(),
    tier = factor(names(nfl_tiers)[(rank - 1) %/% 8 + 1], levels = names(nfl_tiers)),
    tier_order = (rank - 1) %% 8 + 1
  )
```

`nfl_tiers` is a named vector of `tier = color`.
[`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
takes that shape directly, and so does
[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md),
so one object can drive both.

### The image columns

The images come from sdvplotR’s own team table:
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
holds every team’s logo URLs, keyed by the same nflverse abbreviations
the play-by-play uses.

``` r

logos <- team_reference("nfl") |>
  select(team = team_abbr, logo = logo_url)

nfl_wide <- nfl |>
  left_join(logos, by = "team") |>
  pivot_wider(id_cols = tier, names_from = tier_order, values_from = logo, names_sort = TRUE) |>
  arrange(tier)
```

`arrange(tier)` sorts by the factor levels, so the best tier is on top
rather than whichever comes first alphabetically. Each row now holds a
tier name and eight logo URLs:

``` r

nfl_wide[, 1:3]
#> # A tibble: 4 × 3
#>   tier       `1`                                               `2`              
#>   <fct>      <chr>                                             <chr>            
#> 1 Contenders https://a.espncdn.com/i/teamlogos/nfl/500/lar.png https://a.espncd…
#> 2 Solid      https://a.espncdn.com/i/teamlogos/nfl/500/gb.png  https://a.espncd…
#> 3 Shaky      https://a.espncdn.com/i/teamlogos/nfl/500/pit.png https://a.espncd…
#> 4 Rebuilding https://a.espncdn.com/i/teamlogos/nfl/500/cle.png https://a.espncd…
```

### Plotting

[`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
applies
[`gt_theme_tier()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_tier.md)
(dark unless `style = "light"`), renders every column other than `tier`
as an image, clears the column labels, and fills each tier cell with its
color, with black or white text by whichever contrasts more.

``` r

nfl_wide |>
  gt() |>
  gt_tiers(nfl_tiers, style = "light", img_height = "46px") |>
  tab_header(
    title = "The 2025 NFL season in four tiers",
    subtitle = "Ranked by EPA per play margin: offense minus defense, pass and run plays, regular season"
  ) |>
  tab_source_note("Data: nflverse play-by-play via nflfastR")
```

| The 2025 NFL season in four tiers |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Ranked by EPA per play margin: offense minus defense, pass and run plays, regular season |  |  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |  |  |
| Contenders | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/lar.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/ne.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/sea.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/buf.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/jax.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/den.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/hou.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/phi.png) |
| Solid | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/gb.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/ind.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/det.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/lac.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/kc.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/chi.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/sf.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/bal.png) |
| Shaky | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/pit.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/min.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/tb.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/atl.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/no.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/dal.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/nyg.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/car.png) |
| Rebuilding | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/cle.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/ari.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/mia.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/cin.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/wsh.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/lv.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/ten.png) | ![Tier list entry](https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png) |
| Data: nflverse play-by-play via nflfastR |  |  |  |  |  |  |  |  |

## 2. The ACC by efficiency margin

For the second list we rank the ACC’s men’s basketball teams by
efficiency margin: points scored minus points allowed per 100
possessions over the 2025-26 season, tournaments included.
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
lists the conference’s members, with their ESPN ids and logos. The box
scores hold one row per team per game; joining each row to its
opponent’s row gives the possessions on both sides.

``` r

acc <- team_reference("mbb") |>
  filter(conference == "ACC")

# possessions estimated from the box score
box <- hoopR::load_mbb_team_box(seasons = 2026) |>
  mutate(poss = field_goals_attempted - offensive_rebounds + total_turnovers + 0.475 * free_throws_attempted)

acc_margin <- box |>
  filter(team_id %in% acc$espn_team_id) |>
  inner_join(
    select(box, game_id, opponent_team_id = team_id, opp_poss = poss),
    by = c("game_id", "opponent_team_id")
  ) |>
  summarise(
    eff_margin = 100 * sum(team_score - opponent_team_score) / sum((poss + opp_poss) / 2),
    .by = team_id
  ) |>
  mutate(team = acc$team_abbr[match(team_id, acc$espn_team_id)])
```

This time the tiers are uneven: the top quarter, the middle half and the
bottom quarter. [`cut()`](https://rdrr.io/r/base/cut.html) divides the
ranks at their 25th and 75th percentiles.

``` r

acc_tiers <- c(Elite = "#FF7F7F", Average = "#FFDF7F", Poor = "#BFFF7F")

acc_margin <- acc_margin |>
  arrange(desc(eff_margin), team) |>
  mutate(
    rank = row_number(),
    tier = cut(rank,
      breaks = quantile(rank, probs = c(0, 0.25, 0.75, 1)),
      labels = names(acc_tiers),
      include.lowest = TRUE
    )
  ) |>
  mutate(tier_order = row_number(), .by = tier)
```

A dark table wants dark-mode logos.
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
carries both, so we take the dark one and fall back to the primary where
ESPN has no dark version.

``` r

acc_wide <- acc_margin |>
  left_join(select(acc, team = team_abbr, logo_dark_url, logo_url), by = "team") |>
  mutate(logo = coalesce(logo_dark_url, logo_url)) |>
  pivot_wider(id_cols = tier, names_from = tier_order, values_from = logo, names_sort = TRUE) |>
  arrange(tier)
```

``` r

acc_wide |>
  gt() |>
  gt_tiers(acc_tiers, img_height = "48px") |>
  tab_header(
    title = "The ACC in three tiers",
    subtitle = "Efficiency margin per 100 possessions, 2025-26 men's basketball"
  ) |>
  tab_source_note("Data: ESPN box scores via hoopR")
```

[TABLE]

The middle tier holds half the conference, so it runs the widest.
[`gt_tiers()`](https://sdvplotR.sportsdataverse.org/reference/gt_tiers.md)
does not wrap a long row; shrink `img_height` or split the tier when a
row gets too wide for where the table is going.
