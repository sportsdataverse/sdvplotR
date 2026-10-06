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
[`sdv_logo_url()`](https://sdvplotR.sportsdataverse.org/reference/sdv_logo_url.md)
resolves the same nflverse abbreviations the play-by-play uses to each
team’s logo, the SportsDataverse logo archive’s copy of it.

``` r

nfl_wide <- nfl |>
  mutate(logo = sdv_logo_url(team, sport = "nfl")) |>
  pivot_wider(id_cols = tier, names_from = tier_order, values_from = logo, names_sort = TRUE) |>
  arrange(tier)
```

`arrange(tier)` sorts by the factor levels, so the best tier is on top
rather than whichever comes first alphabetically. Each row now holds a
tier name and eight logo URLs:

``` r

nfl_wide[, 1:3]
#> # A tibble: 4 × 3
#>   tier       `1`                                                           `2`  
#>   <fct>      <chr>                                                         <chr>
#> 1 Contenders https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sh… http…
#> 2 Solid      https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sh… http…
#> 3 Shaky      https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sh… http…
#> 4 Rebuilding https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sh… http…
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
| Contenders | ![Los Angeles Rams](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/e2/e289b738a5e1259cccea921bee02eec881d35b4241761a8c4e12fe5964cab75c.png) | ![New England Patriots](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/da/dac19aa9a573dcf9075e2422bee3e35a4955b9ab494bb3191ab3bacfd3609729.png) | ![Seattle Seahawks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/2546b1d4fe5cf6c2d75cda53d3fb56bbc4dd43c6b00200586dab5a85df8fa492.png) | ![Buffalo Bills](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/79/79b71e2f536ee29f9d23834e89828883af2d95bf6968cbd07a505444229cdd20.png) | ![Jacksonville Jaguars](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/15/15cb9a1c77ebfaea885d0d3a34f33dabc4e6a00eb7d5462148fceed641d49397.png) | ![Denver Broncos](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c98bec2be32e27b19f79f5da86ac6ef133c78d75ab78aadb28ef36696c3213e8.png) | ![Houston Texans](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/54b0fe559761860e4953851c197d995b2f9c0c4e278164edda7b608ffd64f39b.png) | ![Philadelphia Eagles](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/28/2875f50f8b756ed5ea3866105b4683f5c603aa542e2c7f7870287e1d3d006100.png) |
| Solid | ![Green Bay Packers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7e/7ea8154cdbff5db84d248f235c1f1c78a1a8b4cb8c14335b5886ec10ee20b00e.png) | ![Indianapolis Colts](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f1/f1f5222a876f810956aa8d4e75d4e6b47bcb3a6d11f876642b674010233c8a97.png) | ![Detroit Lions](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/97/9776b567ebab0bd3640165e915d948d8e736e35967dfc19ce62b967cfe7b4eb1.png) | ![Los Angeles Chargers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/54/5400f85bd93129c056717a771da57a97225e15f39c0022107ce89ef993f15bb0.png) | ![Kansas City Chiefs](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3d/3d77958dc6373768919bb2681cbe1b143f56c07a1f013460def665a5026a7f3d.png) | ![Chicago Bears](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/fd/fd7b5a207b9ad443f950b384d43dba6cb367c5737ad50a51a15e3893fa31753b.png) | ![San Francisco 49ers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/82/82ae812f6c15718ce5abdd402863e8b4553fa9971e4baa5d45ff585c52948a45.png) | ![Baltimore Ravens](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/67796023c172c9aeab5bcdac9204823d3590097246ad1cb92971134b5f26dcc0.png) |
| Shaky | ![Pittsburgh Steelers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/80/806bcb72e75ed184a99bea34df458e6cd87145fc9a863945f3356b01122aeb6f.png) | ![Minnesota Vikings](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/72/72759956b149bc1c9496ea6ebb9a6ae34093dfed371cc6abb425c13f14f53448.png) | ![Tampa Bay Buccaneers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bc/bcc5d267024650938c9f35558077fe00a31913b89c61768d4ebb63d1ea31fbfd.png) | ![Atlanta Falcons](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/fe/fe566e9da6f7986b2bac321571bd751247ff93af15c51ae555486fb1bee90c91.png) | ![New Orleans Saints](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/68/68ddfdf1d7ee8317f1af083a0c6d59142a11e8af4dad73c3c50bbafc338e0a94.png) | ![Dallas Cowboys](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f4/f4ea9a2ec7d7d500f08db94c8c6f1b23f75361ffe39c4d4b480a684a511ce61e.png) | ![New York Giants](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/62/62e361850e7ba3a50dfd09cbb38429e994d1c23b0f999c74421f10e37c7067e7.png) | ![Carolina Panthers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2c/2cebc1bbdcfd89f28c1578b397f440d229d93fa9a30bfa1193cc286482c82298.png) |
| Rebuilding | ![Cleveland Browns](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/9b/9b286fc4286dc39b1b5a6a08aab042b456ba5fdce99e45e49a4d1e2672411fa2.png) | ![Arizona Cardinals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f8/f870b58b43585a5b7717d578dd433b0b1e0c462d64ef4bea2aeb8c03f4ae7854.png) | ![Miami Dolphins](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b9/b9631269a82abda39bd748afc82390679ca67bfc167bc3581665e237407de8e0.png) | ![Cincinnati Bengals](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8e/8e549c0ecac92453140370b2aef3e4a140139b50d16e92507532e8ee49930d4e.png) | ![Washington Commanders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2f/2f67805ef9e385a4c67adb0a9320706bd481a52e3aa0e0faea995dad2b501112.png) | ![Las Vegas Raiders](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/25/25fbb03e972ae872fa024026b73c7b63ef9f23c2f2c51f87d1614d800dcee6e7.png) | ![Tennessee Titans](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/27/27cf283fca5b2e9e1c5e995a465a54223424c157d2013b603a6491f99333cf45.png) | ![New York Jets](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/5d/5de8d029f3602c97ffe02bd636eb2630e55d019d1a37cf819d3b9e39a219487b.png) |
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

A dark table wants dark-mode logos: `variant = "dark"`, which gives the
primary for a team with no dark mark (every team has one; most
conferences don’t).

``` r

acc_wide <- acc_margin |>
  mutate(logo = sdv_logo_url(team, sport = "mbb", variant = "dark")) |>
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
