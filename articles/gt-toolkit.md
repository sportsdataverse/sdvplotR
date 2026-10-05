# Team Tables with the gt Toolkit

On this page

sdvplotR has two kinds of `gt` helpers, and this article uses both on
one table.

- **The team layer** turns team keys into logos, headshots and team
  colors
  ([`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
  [`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)).
  It resolves every abbreviation, alias and relocated franchise through
  [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md).
- **The table toolkit**, ported from Andrew Weatherman’s
  [gtUtils](https://github.com/andreweatherman/gtUtils), handles the
  editorial side: cut lines, colored ranks, captions, legends, grids of
  tables, themes, and saving images sized for posting.

Every one of these functions takes a `gt` table and returns one, so they
chain in any order. Having both in one package means one install, and
one set of conventions for how a sports table is built.

``` r

library(sdvplotR)
library(gt)
```

## The data

The final 2025 standings.
[`nflseedR::nfl_standings()`](https://nflseedr.com/reference/nfl_standings.html)
computes them from nflverse’s schedule, read with `nflreadr`, NFL
tiebreakers included; its `conf_rank` is each team’s place in its
conference, so ranks 1-7 are the playoff seeds. The seeds come first in
seed order, followed by the rest.

``` r

standings <- nflseedR::nfl_standings(nflreadr::load_schedules(2025), verbosity = "NONE")

conference_standings <- function(conference) {
  s <- standings[standings$conf == conference, ]
  s <- s[order(s$conf_rank), ]
  data.frame(
    team = s$team,
    seed = ifelse(s$conf_rank <= 7, s$conf_rank, NA),
    w = s$true_wins,
    l = s$losses,
    pct = s$win_pct
  )
}

afc <- conference_standings("AFC")
```

## Step by step

Start with logos, labels and a box-score win percentage (`.765`, not
`0.765`).

``` r

base <- function(df, conference) {
  gt(df) |>
    gt_sdv_logos(columns = "team", sport = "nfl", height = 24) |>
    cols_label(team = "", seed = "Seed", w = "W", l = "L", pct = "Win pct") |>
    sub_missing(columns = "seed", missing_text = "") |>
    fmt(columns = "pct", fns = function(x) sub("^0", "", sprintf("%.3f", x))) |>
    tab_header(paste(conference, "playoff picture"), "Final 2025 standings")
}
base(afc, "AFC")
```

[TABLE]

A standings table is read around one question: who is in?
[`gt_cutline()`](https://sdvplotR.sportsdataverse.org/reference/gt_cutline.md)
draws the answer as a line after the seventh row, with a label, so
readers don’t have to count seeds.

``` r

base(afc, "AFC") |>
  gt_cutline(after = 7, label = "Playoff line")
```

[TABLE]

[`gt_color_ranks()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_ranks.md)
colors a column by its values, which shows where the wins cluster faster
than reading the numbers; `reverse = TRUE` puts the most wins at the
green end. The cut line’s label sits in the row below the line and
clears that row’s cell colors, so with colored cells, keep the line
unlabeled and say what it means in the caption.
[`gt_538_caption()`](https://sdvplotR.sportsdataverse.org/reference/gt_538_caption.md)
separates that note from the source line.
[`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md)
goes last so it styles everything added before it, and `density` is
passed through for the saved version below.

``` r

playoff_table <- function(df, conference, density = "comfortable") {
  base(df, conference) |>
    gt_cutline(after = 7) |>
    gt_color_ranks(columns = "w", reverse = TRUE) |>
    gt_538_caption(
      top_caption = "Above the line: playoff teams.",
      bottom_caption = "Data: nflverse via nflreadr and nflseedR"
    ) |>
    gt_theme_sdv(density = density)
}
playoff_table(afc, "AFC")
```

[TABLE]

## Both conferences at once

[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
lays several finished tables out under one shared title and source line.
Each table keeps its own theme and cut line; a note that applies to both
goes in the grid’s `caption`, so each table’s own caption stays short
and the tables stay narrow enough to sit side by side.

``` r

nfc <- conference_standings("NFC")

gt_grid(
  list(playoff_table(afc, "AFC"), playoff_table(nfc, "NFC")),
  ncol = 2,
  title = "The 2025 NFL playoff field",
  subtitle = "Final regular-season standings",
  caption = "Seeds 1-4 won their division; 5-7 are wild cards.",
  title_style = list(font = "Chivo", weight = 800)
)
```

The 2025 NFL playoff field

Final regular-season standings

[TABLE]

[TABLE]

Seeds 1-4 won their division; 5-7 are wild cards.

On a narrow screen the grid scrolls sideways inside its own box, so the
page around it stays in place.

## Posting it

[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md)
saves a single table, trimmed and padded;
[`gt_social_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_social_crop.md)
pads it to a platform’s aspect ratio. Use the theme’s background from
`theme_bg` so the padding blends with the table.
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
saves the whole grid when you give it a `file`. Saving drives a headless
Chrome through `webshot2`, so these lines are not run here.

``` r

bg <- theme_bg$bg[theme_bg$theme == "gt_theme_sdv" & theme_bg$has_style == "light"]

playoff_table(afc, "AFC", density = "social") |>
  gt_social_crop("afc-playoffs.png", aspect_ratio = "4:5", bg = bg)

gt_grid(
  list(playoff_table(afc, "AFC"), playoff_table(nfc, "NFC")),
  title = "The 2025 NFL playoff field",
  file = "playoff-field.png"
)
```

## Where to go next

- [SportsDataverse Table
  Themes](https://sdvplotR.sportsdataverse.org/articles/sdv-table-themes.md)
  covers the house theme, the dark style and team colors.
- The rest of the Tables cookbook goes deeper on single tools: [styling
  headers, legends and
  captions](https://sdvplotR.sportsdataverse.org/articles/styling.md),
  [percentile bars and cut
  lines](https://sdvplotR.sportsdataverse.org/articles/delay_tables.md),
  [faceted
  tables](https://sdvplotR.sportsdataverse.org/articles/grid_tables.md),
  [tier
  lists](https://sdvplotR.sportsdataverse.org/articles/tier_list.md),
  [border
  bars](https://sdvplotR.sportsdataverse.org/articles/border_bars.md),
  [schedule
  matrices](https://sdvplotR.sportsdataverse.org/articles/schedule_matrix.md),
  [rolling
  windows](https://sdvplotR.sportsdataverse.org/articles/window_wins.md)
  and [saving and
  posting](https://sdvplotR.sportsdataverse.org/articles/saving_tables.md).
