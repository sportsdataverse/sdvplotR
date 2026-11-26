# International Basketball Visualizations

On this page

Three charts and a table from five leagues’ 2025-26 seasons:

- the EuroLeague’s point differential in team colors;
- the B.League’s final standings;
- the top of the EuroLeague, Liga ACB, the ABA League, the KBL and the
  B.League side by side;
- Liga ACB’s offense against defense.

The standings come from [hoopR](https://hoopR.sportsdataverse.org),
which reads each league’s own data service. The team ids those services
return are the ids sdvplotR’s team index keys these leagues by. So the
logos and colors join with no name matching. [Leagues and
Identifiers](https://sdvplotR.sportsdataverse.org/articles/leagues-and-identifiers.md)
lists what each league’s `team_id` is.

``` r

library(sdvplotR)
library(ggplot2)
library(dplyr)
library(gt)
```

## Load the season

``` r

# the 2025-26 final regular-season standings of each league
euroleague <- hoopR::euroleague_standings(competition_code = "E", season_code = "E2025", round = 38) |>
  select(position, club_code, club_name, games_won, games_lost, points_for, points_against, points_difference)
acb <- hoopR::acb_standings(season = 2026) |> # season is the END year (2026 = 2025-26)
  filter(season == 2026) |>
  select(position, club_id, team, wins, losses, points_for, points_against)
aba <- hoopR::aba_standings(season = 2026) |>
  filter(table == "Regular Season 2025/26") |>
  select(rank, team_id, team_name, wins, losses, point_diff)
kbl <- hoopR::kbl_standings(season = 2026) |>
  filter(season == 2026) |>
  select(rank, team_code, team_name, wins, losses, win_rate)
bleague <- hoopR::bleague_standings(season = 2026, tab = 1) |>
  filter(section_en %in% c("East", "West")) |>
  select(conference = section_en, rank, team_id, team, wins, losses, win_pct, games_behind, point_diff)
```

These calls are read from a snapshot taken on November 26, 2026 (hoopR
3.2.0), because the leagues’ data services are not called when this site
is built. `data-raw/article_fixtures.R` takes it with the same code.

Each league’s id column is already the index’s `team_id`. Converting it
to character once gives every join and scale the same type.
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
with `id_system = "team_id"` confirms that every id is in the index
(`TRUE` for each league):

``` r

# the EuroLeague's points_difference comes as text ("+262"): recompute it
euroleague <- mutate(euroleague, team = club_code, points_difference = points_for - points_against)
acb <- mutate(acb, team_id = as.character(club_id))
aba <- mutate(aba, team_id = as.character(team_id))
kbl <- mutate(kbl, team_id = as.character(team_code))
bleague <- mutate(bleague, team_id = as.character(team_id))

c(
  euroleague = !anyNA(sdv_resolve(euroleague$team, "euroleague", id_system = "team_id")),
  acb = !anyNA(sdv_resolve(acb$team_id, "acb", id_system = "team_id")),
  aba = !anyNA(sdv_resolve(aba$team_id, "aba", id_system = "team_id")),
  kbl = !anyNA(sdv_resolve(kbl$team_id, "kbl", id_system = "team_id")),
  bleague = !anyNA(sdv_resolve(bleague$team_id, "bleague", id_system = "team_id"))
)
#> euroleague        acb        aba        kbl    bleague 
#>       TRUE       TRUE       TRUE       TRUE       TRUE

caption <- "Data: league data services via hoopR | Viz: sdvplotR"
```

## 1. EuroLeague point differential in team colors

Bars in each club’s color from
[`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md),
with its crest at the end of the bar from
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md).
The colors are the index’s logo colors, as in every other league.

``` r

diff <- euroleague |>
  arrange(desc(points_difference), team) |>
  mutate(
    team = factor(team, levels = team),
    logo_y = points_difference + if_else(points_difference >= 0, 22, -22)
  )

ggplot(diff, aes(team, points_difference)) +
  geom_col(aes(fill = team), width = 0.75) +
  geom_hline(yintercept = 0, colour = "grey20", linewidth = 0.4) +
  geom_sdv_logos(aes(y = logo_y, team = team), league = "euroleague", width = 0.04) +
  scale_fill_sdv(league = "euroleague") +
  labs(
    title = "EuroLeague point differential, 2025-26",
    subtitle = "Regular season, 38 games: points scored minus points allowed",
    x = NULL,
    y = "Point differential",
    caption = caption
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold")
  )
```

![Bar chart of the 20 EuroLeague clubs' 2025-26 regular-season point
differential, sorted from best to worst, each bar in its club's color
with the club crest at the end of the
bar.](intl-basketball-viz_files/figure-html/team-performance-1.png)

## 2. B.League standings by conference

A gt table grouped by conference, with
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
for the logos. The team names are the B.League’s own full club names, in
Japanese. The index’s B.League names are the short ones (`"A千葉"`), so
this table joins on `team_id`, not on the name.

``` r

bleague |>
  mutate(logo = team_id) |>
  arrange(conference, rank) |>
  select(conference, rank, logo, team, wins, losses, win_pct, games_behind, point_diff) |>
  gt(groupname_col = "conference") |>
  gt_sdv_logos(columns = "logo", league = "bleague", height = 24) |>
  fmt_number(columns = win_pct, decimals = 3) |>
  cols_align(align = "left", columns = team) |>
  cols_label(
    rank = "", logo = "", team = "Team", wins = "W", losses = "L", win_pct = "PCT",
    games_behind = "GB", point_diff = "DIFF"
  ) |>
  tab_header(
    title = "B.League standings, 2025-26",
    subtitle = "B1, final regular season (60 games), by conference"
  ) |>
  tab_source_note(caption) |>
  gt_theme_athletic()
```

| B.League standings, 2025-26 |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|
| B1, final regular season (60 games), by conference |  |  |  |  |  |  |  |
|  |  | Team | W | L | PCT | GB | DIFF |
| East |  |  |  |  |  |  |  |
| 1 | ![宇都宮](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/57/575acad8d534a8cc4e5ccf54c7fef8fd03e843545e50fb0515acd0fd55b95c2a.png) | 宇都宮ブレックス | 45 | 15 | 0.750 | NA | 329 |
| 2 | ![千葉J](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/6f/6fdba0858ce639dc501246274f7854ff22d59a5789784be9782926f14b8d0f07.png) | 千葉ジェッツ | 42 | 18 | 0.700 | 3 | 450 |
| 3 | ![群馬](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/9c/9c5c0d4096575141baa7f773d915b5706211e4878b07cd3e13d91176a49eb00e.png) | 群馬クレインサンダーズ | 42 | 18 | 0.700 | 3 | 609 |
| 4 | ![A東京](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/52/52d2480c36d1ffa0ce19c920536093203c64d8298bf66ab3eedc3e005c9d34d4.png) | アルバルク東京 | 41 | 19 | 0.683 | 4 | 237 |
| 5 | ![北海道](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/4b/4b32dfc366ba46b790014b13b8e132126962723f2c998ea9b686810561e1e47b.png) | レバンガ北海道 | 37 | 23 | 0.617 | 8 | 94 |
| 6 | ![仙台](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/f3/f389747b10b02f38b7a3af0fc4c57449f8fa0ca1f6c7594e9c3cc12111d51646.png) | 仙台89ERS | 35 | 25 | 0.583 | 10 | 177 |
| 7 | ![横浜BC](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/49/49bfe2a51d84f051b69bd2e76d77b72bf01151a8b821fba5d5c27204e1e1d521.png) | 横浜ビー・コルセアーズ | 26 | 34 | 0.433 | 19 | -141 |
| 8 | ![東京SR](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bb/bbbd4582780eeff2d29ee812c419c8909c2c829d20e4db5bd96326b1f1659467.png) | サンロッカーズ渋谷 | 25 | 35 | 0.417 | 20 | -219 |
| 9 | ![越谷](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/1f/1f8cc31296d3d456f9c18d6e50f4841814a88ddb5a554c8d923b33d03ecd23c6.png) | 越谷アルファーズ | 21 | 39 | 0.350 | 24 | -383 |
| 10 | ![茨城](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/be/be4c0a9266bd35c2e375bed43bd4ae1ae08c36b5066b9b47de0157b8a3ede3d5.png) | 茨城ロボッツ | 19 | 41 | 0.317 | 26 | -311 |
| 11 | ![A千葉](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/ad/adfa9f2630941d270225f4298602a08c0514fe0875fd361b889909541f2cba19.png) | アルティーリ千葉 | 19 | 41 | 0.317 | 26 | -317 |
| 12 | ![川崎](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/7e/7e16fcbb0d3b22a47d9262826e6a938dd589abb6d5014cdd19656db0ec8b0f85.png) | 川崎ブレイブサンダース | 16 | 44 | 0.267 | 29 | -488 |
| 13 | ![秋田](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/2d/2d46da53778d1096f0584920bd6068bdbaa14502f4e590436b75b57cff407105.png) | 秋田ノーザンハピネッツ | 10 | 50 | 0.167 | 35 | -736 |
| West |  |  |  |  |  |  |  |
| 1 | ![長崎](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/88/882e50a5cee19aa5e2dcbacd8cd3ce6749bbc77758e8a2234df8f5ae0159261d.png) | 長崎ヴェルカ | 47 | 13 | 0.783 | NA | 690 |
| 2 | ![三河](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/5d/5d78aac583382ab628fb04ce404735f79d980931fa59234bcc8ded6e25013a53.png) | シーホース三河 | 43 | 17 | 0.717 | 4 | 360 |
| 3 | ![琉球](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d6/d6c70f42bedadffaa06b5af24a50a0b3dd9126c2d219d0c89d5f7f5cb3416831.png) | 琉球ゴールデンキングス | 42 | 18 | 0.700 | 5 | 429 |
| 4 | ![名古屋D](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/8f/8feafa6b0e0dc2edc13d2d5f8b45b0317bf19d6f9e275385b7cdf36bbf45afb8.png) | 名古屋ダイヤモンドドルフィンズ | 41 | 19 | 0.683 | 6 | 471 |
| 5 | ![三遠](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3e/3e744ae53f8f7f8c774f074bf321f7c577e173dce6c68f81c6da2cac746de994.png) | 三遠ネオフェニックス | 36 | 24 | 0.600 | 11 | 166 |
| 6 | ![佐賀](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/91/91a4139c82f40c71f3fbe1dff0e2339f92d1e6cc72b0061a15a49d1f0d1321e3.png) | 佐賀バルーナーズ | 32 | 28 | 0.533 | 15 | 35 |
| 7 | ![広島](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/17/1762bf806d8bf0335ffeb12040abd358553d1810e8dfd981612db7e5461961e4.png) | 広島ドラゴンフライズ | 31 | 29 | 0.517 | 16 | 116 |
| 8 | ![島根](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/15/1568110aef1d2cb506d2b53efe2ae22fe44e9e7d0d8df28310f0c53a39258222.png) | 島根スサノオマジック | 28 | 32 | 0.467 | 19 | -98 |
| 9 | ![大阪](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/06/063471e938e093a3d3c5a88083c8fee2a4a251c889b5781f53518408b4fced96.png) | 大阪エヴェッサ | 23 | 37 | 0.383 | 24 | -120 |
| 10 | ![滋賀](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c9/c901f30979433254a347b4ed8402ff8f215485478e4dfaf8527195e45786e2c5.png) | 滋賀レイクス | 23 | 37 | 0.383 | 24 | -278 |
| 11 | ![京都](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/b4/b4f76db54240bee73f2275a8759058773560b68125ec59d22426a7239024e78c.png) | 京都ハンナリーズ | 20 | 40 | 0.333 | 27 | -395 |
| 12 | ![富山](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/75/75b3dea3c6bef1ee6026a2b44fa649614b18a397ce08e5e3ff51c52b7a2801b6.png) | 富山グラウジーズ | 18 | 42 | 0.300 | 29 | -406 |
| 13 | ![FE名古屋](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/67/678fbddf64075ade1b42ae79ce7f81bdb2336beedbf356ae7e2fd5c4870151d5.png) | ファイティングイーグルス名古屋 | 18 | 42 | 0.300 | 29 | -271 |
| Data: league data services via hoopR \| Viz: sdvplotR |  |  |  |  |  |  |  |

## 3. Five leagues, side by side

Each league’s top six by winning percentage, one panel per league. The
ABA League’s regular season is two groups of nine, so its top six comes
from both groups. The bars carry
[`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
which takes one league per layer, so the chart adds one layer for each
league.

``` r

league_names <- c(
  euroleague = "EuroLeague", acb = "Liga ACB", aba = "ABA League", kbl = "KBL", bleague = "B.League"
)
top6 <- bind_rows(
  transmute(euroleague, league = "euroleague", team = as.character(team), wins = games_won, losses = games_lost),
  transmute(acb, league = "acb", team = team_id, wins, losses),
  transmute(aba, league = "aba", team = team_id, wins, losses),
  transmute(kbl, league = "kbl", team = team_id, wins, losses),
  transmute(bleague, league = "bleague", team = team_id, wins, losses)
) |>
  mutate(pct = wins / (wins + losses)) |>
  group_by(league) |>
  slice_max(pct, n = 6, with_ties = FALSE) |>
  mutate(place = row_number()) |>
  ungroup() |>
  mutate(label = factor(league_names[league], levels = league_names))

layers <- lapply(split(top6, top6$league), function(d) {
  geom_sdv_logos(aes(x = place, y = pct + 0.07, team = team), data = d, league = d$league[1], width = 0.13)
})

ggplot(top6, aes(place, pct)) +
  geom_col(fill = "grey80", width = 0.7) +
  layers +
  facet_wrap(~label, nrow = 1) +
  scale_x_continuous(breaks = 1:6) +
  scale_y_continuous(labels = scales::label_percent(), limits = c(0, 1.05), breaks = seq(0, 1, 0.25)) +
  labs(
    title = "The top of five leagues, 2025-26",
    subtitle = "Each league's six best regular-season records",
    x = "Place",
    y = "Winning percentage",
    caption = caption
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold")
  )
```

![Five panels of bar charts, one each for the EuroLeague, Liga ACB, the
ABA League, the KBL and the B.League, each showing the six best 2025-26
regular-season winning percentages with the team logo on top of each
bar.](intl-basketball-viz_files/figure-html/five-leagues-1.png)

## 4. Liga ACB: offense against defense

Points scored and allowed per game, with each club’s logo and the league
averages from
[`geom_mean_lines()`](https://mrcaseb.github.io/ggpath/reference/geom_lines.html).
The y axis is reversed, so the best teams sit top right.

``` r

acb_rates <- acb |>
  mutate(
    games = wins + losses,
    ppg = points_for / games,
    opp_ppg = points_against / games
  )

ggplot(acb_rates, aes(ppg, opp_ppg)) +
  geom_mean_lines(aes(x0 = ppg, y0 = opp_ppg), colour = "grey50", linetype = "dashed") +
  geom_sdv_logos(aes(team = team_id), league = "acb", width = 0.06) +
  scale_y_reverse() +
  labs(
    title = "Liga ACB offense and defense, 2025-26",
    subtitle = "Points per game, regular season (34 games); better defense is higher",
    x = "Points scored per game",
    y = "Points allowed per game",
    caption = caption
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))
```

![Scatter plot of the 18 Liga ACB clubs' 2025-26 points scored per game
against points allowed per game, each club drawn as its logo, with
dashed lines at the league averages and the points-allowed axis
reversed.](intl-basketball-viz_files/figure-html/acb-scatter-1.png)

## More leagues

hoopR has standings, schedules and statistics readers for the other
international leagues in the index too: FEB, KZS, LKL, LBA, VTB, EASL,
IBBA and DataCore’s NBL. Most join the same way, through the reader’s
team id. Two need a note: DataCore’s NBL (`nbl_rosetta_*()`) is the
index’s `"nbl_au"` (league `"nbl"` is ESPN’s NBL, with ESPN ids), and
IBBA joins on `team_uid`, not `team_id`. The Basketball Bundesliga’s
(`"bbl"`) archived logos are a placeholder shield for some teams, so it
is left out of this article.

## Related articles

- [Leagues and
  Identifiers](https://sdvplotR.sportsdataverse.org/articles/leagues-and-identifiers.md)
- [European Hockey
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/euro-hockey-viz.md)
- [NBA
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/nba-viz.md)
- [Getting
  Started](https://sdvplotR.sportsdataverse.org/articles/getting-started.md)

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
