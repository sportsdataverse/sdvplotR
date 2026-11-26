# European Hockey Visualizations

On this page

Three charts and a table from two European hockey leagues’ 2025-26
seasons:

- the SHL’s final table, built from every regular-season game;
- the SHL’s points race;
- the SHL’s goals for against goals against;
- the Ligue Magnus table in team colors.

The data comes from
[fastRhockey](https://fastRhockey.sportsdataverse.org), which reads the
SHL’s and the French federation’s own data services. The team codes and
ids they return are the ones sdvplotR’s team index keys these leagues
by. [Leagues and
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

# every 2025-26 SHL regular-season game
shl_games <- fastRhockey::shl_schedule(season = 2026) |>
  filter(state == "post-game") |>
  transmute(
    date = as.Date(start_date_time),
    home = home_team_names_code, away = away_team_names_code,
    home_name = home_team_names_long, away_name = away_team_names_long,
    home_score = home_team_score, away_score = away_team_score, overtime, shootout
  )
# the final 2025-26 Ligue Magnus regular-season table (phase 560)
magnus <- fastRhockey::magnus_standings(phase_id = 560) |>
  select(rank, team_id, team, games_played, wins, ot_wins, ot_losses, losses, points, goals_for, goals_against)
```

These calls are read from a snapshot taken on November 26, 2026
(fastRhockey 1.1.0), because the leagues’ data services are not called
when this site is built. `data-raw/article_fixtures.R` takes it with the
same code.

The SHL codes in the schedule (`FHC`, `SKE`, `ÖRE`) are the index’s
`team_id`s, and so are the Ligue Magnus team ids.
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
confirms that every one is in the index (`TRUE` for both leagues):

``` r

magnus <- mutate(magnus, team_id = as.character(team_id))
shl_teams <- sort(unique(c(shl_games$home, shl_games$away)))
c(
  shl = !anyNA(sdv_resolve(shl_teams, "shl", id_system = "team_id")),
  magnus = !anyNA(sdv_resolve(magnus$team_id, "magnus", id_system = "team_id"))
)
#>    shl magnus 
#>   TRUE   TRUE

caption_shl <- "Data: SHL via fastRhockey | Viz: sdvplotR"
caption_magnus <- "Data: FFHG via fastRhockey | Viz: sdvplotR"
```

## Build the SHL table from the games

The SHL gives three points for a win in regulation, two for a win in
overtime or a shootout, and one for a loss in overtime or a shootout.
One row per team per game, then a sum:

``` r

team_games <- bind_rows(
  transmute(shl_games, date, team = home, name = home_name, gf = home_score, ga = away_score, overtime, shootout),
  transmute(shl_games, date, team = away, name = away_name, gf = away_score, ga = home_score, overtime, shootout)
) |>
  mutate(
    extra = overtime | shootout,
    pts = case_when(gf > ga & !extra ~ 3, gf > ga ~ 2, extra ~ 1, TRUE ~ 0)
  )

shl <- team_games |>
  group_by(team, name) |>
  summarise(
    gp = n(), w = sum(gf > ga & !extra), otw = sum(gf > ga & extra),
    otl = sum(gf < ga & extra), l = sum(gf < ga & !extra),
    pts = sum(pts), gf = sum(gf), ga = sum(ga),
    .groups = "drop"
  ) |>
  mutate(diff = gf - ga) |>
  arrange(desc(pts), desc(diff)) |>
  mutate(rank = row_number())

stopifnot(nrow(shl) == 14, all(shl$gp == 52))
```

## 1. The SHL’s final table

A gt table with
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
for the logos, and
[`gt_cutline()`](https://sdvplotR.sportsdataverse.org/reference/gt_cutline.md)
under sixth place (straight to the quarterfinals) and tenth place (the
last place in the eighth-finals).

``` r

shl |>
  mutate(logo = team) |>
  select(rank, logo, name, gp, w, otw, otl, l, pts, gf, ga, diff) |>
  gt() |>
  gt_sdv_logos(columns = "logo", league = "shl", height = 24) |>
  cols_align(align = "left", columns = name) |>
  cols_label(
    rank = "", logo = "", name = "Team", gp = "GP", w = "W", otw = "OTW", otl = "OTL",
    l = "L", pts = "PTS", gf = "GF", ga = "GA", diff = "DIFF"
  ) |>
  tab_header(
    title = "SHL standings, 2025-26",
    subtitle = "Final regular season, built from all 364 games"
  ) |>
  tab_source_note(caption_shl) |>
  gt_theme_athletic() |>
  gt_cutline(after = 6) |>
  gt_cutline(after = 10)
```

| SHL standings, 2025-26 |  |  |  |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|
| Final regular season, built from all 364 games |  |  |  |  |  |  |  |  |  |  |  |
|  |  | Team | GP | W | OTW | OTL | L | PTS | GF | GA | DIFF |
| 1 | ![Skellefteå AIK](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/27/274e98a4b6976f77d48b7b73d109896c68604a3ebea80b59d1c334354b6d3a6b.svg) | Skellefteå AIK | 52 | 30 | 6 | 6 | 10 | 108 | 182 | 121 | 61 |
| 2 | ![Frölunda HC](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/d4/d40abc8d1a83756b9047f35e2e6b2c20ca3819ad975e997fadd3380e630f1108.svg) | Frölunda HC | 52 | 30 | 4 | 3 | 15 | 101 | 161 | 106 | 55 |
| 3 | ![Växjö Lakers](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/51/5189c79f07dc37374ed40d7a0b2eafb0c1b5bc5fba12f2b3ee044acc43d1d1a2.svg) | Växjö Lakers | 52 | 26 | 6 | 4 | 16 | 94 | 150 | 136 | 14 |
| 4 | ![Rögle BK](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/96/962c5b4d4caf77747ae04237bc9b076ece516833fe08c13af97a33bd55279f4a.svg) | Rögle BK | 52 | 25 | 5 | 8 | 14 | 93 | 155 | 123 | 32 |
| 5 | ![Färjestad BK](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/33/3349ed6ec5d458428cc29e9e861ca13e435781c5e4464c568755556c81542da5.svg) | Färjestad BK | 52 | 21 | 6 | 5 | 20 | 80 | 145 | 131 | 14 |
| 6 | ![Brynäs IF](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/90/90c4c30df1a0111947491ad6f5f6e3ccc8a57db714e3df67dbac366d86c6ace5.svg) | Brynäs IF | 52 | 19 | 8 | 5 | 20 | 78 | 154 | 143 | 11 |
| 7 | ![Luleå Hockey](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/bc/bc239224d8cca806ae4f22311b47596d6936323dcc314fac8ec8685b1fd4cbf8.svg) | Luleå Hockey | 52 | 21 | 5 | 4 | 22 | 77 | 139 | 134 | 5 |
| 8 | ![Malmö Redhawks](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/3c/3cbcaae9b555ea8e902b7a8d7cf3e1fe28b189bc76571bec45cbdaedae418200.svg) | Malmö Redhawks | 52 | 21 | 6 | 2 | 23 | 77 | 143 | 154 | -11 |
| 9 | ![Djurgårdens IF](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/c8/c802a352251fff1518abcaeea772bbfc4b4fac6f029e710501c2fa047fea9b11.svg) | Djurgårdens IF | 52 | 20 | 5 | 3 | 24 | 73 | 136 | 164 | -28 |
| 10 | ![Örebro Hockey](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/57/571535d5e229731de8ce16e0668233f3ecf7bd37696137f3e77d5893dc028320.svg) | Örebro Hockey | 52 | 17 | 4 | 7 | 24 | 66 | 139 | 158 | -19 |
| 11 | ![Linköping HC](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/49/49635a950a4895d5f898649fd95965928fe11eb437a30aabcb99dcfc65c0dfc5.svg) | Linköping HC | 52 | 17 | 4 | 5 | 26 | 64 | 119 | 148 | -29 |
| 12 | ![Timrå IK](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/0a/0a6f5848c13e9137cd20d0bc55342c9acc350863a6186779fb9d438fa83b5143.svg) | Timrå IK | 52 | 17 | 4 | 4 | 27 | 63 | 127 | 148 | -21 |
| 13 | ![HV71](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/cc/ccd25bf4024b023fc5aab9f8bfb889db67d8d713fea357e53fa7831211ae57be.svg) | HV71 | 52 | 15 | 4 | 6 | 27 | 59 | 136 | 172 | -36 |
| 14 | ![Leksands IF](https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/sha256/85/85b2fa413cc31f71310ec59ed79e00770aa9f643289403318ee331f9fbc77eef.svg) | Leksands IF | 52 | 16 | 2 | 7 | 27 | 59 | 112 | 160 | -48 |
| Data: SHL via fastRhockey \| Viz: sdvplotR |  |  |  |  |  |  |  |  |  |  |  |

## 2. The points race

Each team’s points through the season, in its team color from
[`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md).
The logos stand past the last game at each team’s final points, in three
columns so close finishers do not cover each other.

``` r

race <- team_games |>
  arrange(team, date) |>
  group_by(team) |>
  mutate(game = row_number(), points = cumsum(pts)) |>
  ungroup()
# logos rotate through three columns past the last game, so close finishers do not cover each other
ends <- race |>
  filter(game == max(game)) |>
  arrange(desc(points)) |>
  mutate(x = max(game) + c(2.5, 6.5, 10.5)[(row_number() - 1) %% 3 + 1])

# the colour aesthetic goes on the lines only: geom_sdv_logos() would tint the logos with it
ggplot(race, aes(game, points)) +
  geom_line(aes(colour = team), linewidth = 0.8, alpha = 0.85) +
  geom_sdv_logos(aes(x = x, y = points, team = team), data = ends, league = "shl", width = 0.035) +
  scale_color_sdv(league = "shl") +
  scale_x_continuous(breaks = seq(0, 52, 13), limits = c(1, 64)) +
  labs(
    title = "The SHL points race, 2025-26",
    subtitle = "Cumulative points, 3 for a regulation win, 2 for an overtime or shootout win, 1 for an overtime or shootout loss",
    x = "Game",
    y = "Points",
    caption = caption_shl
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold")
  )
```

![Line chart of the 14 SHL teams' cumulative points over the 52 games of
the 2025-26 regular season, each line in its team's color, with the team
logos past the last game at each team's final
points.](euro-hockey-viz_files/figure-html/points-race-1.png)

## 3. Goals for and against

Goals per game for and against, with each team’s logo and the league
averages from
[`geom_mean_lines()`](https://mrcaseb.github.io/ggpath/reference/geom_lines.html).
The y axis is reversed, so the best teams sit top right.

``` r

shl_rates <- mutate(shl, gf_pg = gf / gp, ga_pg = ga / gp)

ggplot(shl_rates, aes(gf_pg, ga_pg)) +
  geom_mean_lines(aes(x0 = gf_pg, y0 = ga_pg), colour = "grey50", linetype = "dashed") +
  geom_sdv_logos(aes(team = team), league = "shl", width = 0.07) +
  scale_y_reverse() +
  labs(
    title = "SHL goals for and against, 2025-26",
    subtitle = "Goals per game, regular season (52 games); better defense is higher",
    x = "Goals scored per game",
    y = "Goals allowed per game",
    caption = caption_shl
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))
```

![Scatter plot of the 14 SHL teams' 2025-26 goals scored per game
against goals allowed per game, each team drawn as its logo, with dashed
lines at the league averages and the goals-allowed axis
reversed.](euro-hockey-viz_files/figure-html/goals-scatter-1.png)

## 4. Ligue Magnus points in team colors

The French league’s final table as bars in each team’s color, with its
logo at the end of the bar.

``` r

magnus_pts <- magnus |>
  arrange(points) |>
  mutate(team_id = factor(team_id, levels = team_id))

ggplot(magnus_pts, aes(points, team_id)) +
  geom_col(aes(fill = team_id), width = 0.75) +
  geom_sdv_logos(aes(x = points + 4, team = team_id), league = "magnus", width = 0.05) +
  scale_fill_sdv(league = "magnus") +
  scale_y_discrete(labels = setNames(magnus_pts$team, magnus_pts$team_id)) +
  labs(
    title = "Ligue Magnus points, 2025-26",
    subtitle = "Regular season, 44 games",
    x = "Points",
    y = NULL,
    caption = caption_magnus
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    plot.title = element_text(face = "bold")
  )
```

![Horizontal bar chart of the 12 Ligue Magnus teams' 2025-26
regular-season points, sorted from most to fewest, each bar in its
team's color with the team logo at the end of the
bar.](euro-hockey-viz_files/figure-html/magnus-points-1.png)

## More leagues

fastRhockey also reads HockeyAllsvenskan (`ha_*()`) and the Czech
Extraliga (`elh_*()`). Their logos are in the index as `"ha"` and
`"elh"`. Three HockeyAllsvenskan clubs’ codes in `ha_standings()`
(`MORA`, `NVIF`, `ÖIK`) differ from the index’s (`MIK`, `NYB`, `OSIK`),
so map those three before plotting, until the index carries both codes.

## Related articles

- [Leagues and
  Identifiers](https://sdvplotR.sportsdataverse.org/articles/leagues-and-identifiers.md)
- [International Basketball
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/intl-basketball-viz.md)
- [NHL
  Visualizations](https://sdvplotR.sportsdataverse.org/articles/nhl-viz.md)
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
