# Winningest Franchises in Rolling Windows

On this page

This article builds one table: the NFL’s five winningest franchises in
every ten-year window from 1999-2008 to 2016-2025, each franchise drawn
as its logo and shaded by how many Super Bowls it won inside that
window. The games are nflverse’s schedule file, read with
[`nflreadr`](https://nflreadr.nflverse.com), regular season only.

Eighteen windows give a table six columns wide and eighteen rows tall,
which exports as a narrow strip with empty space on either side.
[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
folds it into two side-by-side blocks that repeat the column labels. The
shading is per-cell, and it is far easier to reason about on the plain
eighteen-row grid than on the folded one, so we color first and fold
second. Along the way the article uses
[`gt_highlight_cells()`](https://sdvplotR.sportsdataverse.org/reference/gt_highlight_cells.md),
[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md)
and
[`gt_538_caption()`](https://sdvplotR.sportsdataverse.org/reference/gt_538_caption.md).

[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
and the other `gt_*` table functions here come from Andrew Weatherman’s
[gtUtils](https://github.com/andreweatherman/gtUtils); this article
follows his rolling-window example, rebuilt on nflverse data.

``` r

library(sdvplotR)
library(gt)
library(dplyr)
library(tidyr)
```

## 1. One row per team per game

`load_schedules()` holds one row per game. `clean_homeaway()` doubles it
into one row per team per game, renaming the `home_*` / `away_*` pairs
to `team_*` / `opponent_*`.

``` r

seasons <- 1999:2025
schedules <- nflreadr::load_schedules(seasons)

games <- schedules |>
  filter(game_type == "REG", !is.na(home_score)) |>
  select(season, home_team, away_team, home_score, away_score) |>
  nflreadr::clean_homeaway() |>
  mutate(franchise = sdv_resolve(team, league = "nfl"))
```

The schedules keep each season’s abbreviation, so the Raiders are `OAK`
before 2020 and `LV` after.
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
maps every relocated abbreviation to today’s franchise key, which is
what lets one franchise’s ten seasons add up.

``` r

sdv_resolve(c("OAK", "SD", "STL"), league = "nfl")
#> [1] "13" "24" "14"
```

Each franchise’s record per season is then one summary:

``` r

records <- games |>
  summarise(
    wins = sum(team_score > opponent_score),
    losses = sum(team_score < opponent_score),
    ties = sum(team_score == opponent_score),
    .by = c(season, franchise)
  )
```

## 2. Rolling windows

A rolling window is a filter and a sum. This function keeps the ten
seasons from a start year and totals each franchise’s record.

``` r

calculate_windows <- function(start_year, data) {
  data |>
    filter(between(season, start_year, start_year + 9)) |>
    summarise(across(c(wins, losses, ties), sum), .by = franchise) |>
    mutate(
      win_pct = (wins + ties / 2) / (wins + losses + ties),
      years = paste(start_year, start_year + 9, sep = "-"),
      begin = start_year
    )
}

starts <- min(seasons):(max(seasons) - 9)

plot_data <- bind_rows(lapply(starts, calculate_windows, records)) |>
  arrange(begin, desc(wins), desc(win_pct), franchise) |>
  mutate(position = row_number(), .by = begin) |>
  filter(position <= 5)
```

The start years stop nine short of the last season, since a window that
starts in 2017 does not have ten seasons in it yet. Ranking happens
inside each window with
[`row_number()`](https://dplyr.tidyverse.org/reference/row_number.html)
after the
[`arrange()`](https://dplyr.tidyverse.org/reference/arrange.html): wins
first, win percentage (a tie counts as half a win) next, and the
franchise key last, so a tie that survives both still sorts the same way
every time the site is built.

## 3. Counting titles

The shading comes from Super Bowls won inside each window. The same
schedule file holds the Super Bowls (`game_type == "SB"`), so the
winners are one more filter, and the windowing logic is the same.

``` r

champions <- schedules |>
  filter(game_type == "SB") |>
  transmute(
    season,
    franchise = sdv_resolve(
      if_else(home_score > away_score, home_team, away_team),
      league = "nfl"
    )
  )

titles <- bind_rows(lapply(starts, function(start_year) {
  champions |>
    filter(between(season, start_year, start_year + 9)) |>
    count(franchise, name = "titles") |>
    mutate(years = paste(start_year, start_year + 9, sep = "-"))
}))

plot_data <- plot_data |>
  left_join(titles, by = c("franchise", "years")) |>
  mutate(titles = case_when(
    is.na(titles) ~ "0",
    titles == 1 ~ "1",
    TRUE ~ "2+"
  ))
```

The join only produces a count for a franchise that won something, so
every other franchise-window comes back `NA`, which the
[`case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
turns into `"0"`. Bucketing into `"0"`, `"1"` and `"2+"` keeps the key
short.

## 4. Two pivots from one ordered frame

We want one row per window and five franchise columns in rank order. The
cells hold the franchise keys themselves;
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
turns them into logos at the end, so the data never carries an image
URL.

[`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html)
spreads one value column, so pivoting on the franchise drops the title
count. The way around it is to pivot twice from the same ordered frame,
once for what you draw and once for what you style by.

``` r

ordered <- arrange(plot_data, begin, position)

# years + five franchises
wide <- ordered |>
  pivot_wider(id_cols = years, names_from = position, values_from = franchise, names_sort = TRUE)

# the shading key, the same shape as the five franchise columns
title_grid <- ordered |>
  pivot_wider(id_cols = years, names_from = position, values_from = titles, names_sort = TRUE) |>
  select(-years)

mask_1 <- title_grid == "1"
mask_2 <- title_grid == "2+"
```

Sorting once, before either pivot, keeps the two frames in step: both
inherit the same row order and the same column order, so cell `[3, 2]`
of `title_grid` describes cell `[3, 2]` of `wide` with no matching
afterwards. Each mask is then a `TRUE`/`FALSE` grid the same shape as
the franchise columns. `"0"` is the base state, so it needs no mask of
its own.

``` r

head(wide, 3)
#> # A tibble: 3 × 6
#>   years     `1`   `2`   `3`   `4`   `5`  
#>   <chr>     <chr> <chr> <chr> <chr> <chr>
#> 1 1999-2008 11    17    23    21    10   
#> 2 2000-2009 11    17    21    23    9    
#> 3 2001-2010 17    11    23    21    9
```

## 5. Color first, then snake

[`gt_highlight_cells()`](https://sdvplotR.sportsdataverse.org/reference/gt_highlight_cells.md)
fills individual cells from a logical grid of the same shape, which is
what the masks are. We run it on the plain, un-snaked table, then fold
it.

``` r

wide |>
  gt(id = "windows-draft") |>
  gt_highlight_cells(-years, condition = mask_1, fill = "#F4D7A4") |>
  gt_highlight_cells(-years, condition = mask_2, fill = "#FFA970") |>
  gt_snake(n_cols = 2) |>
  gt_theme_athletic()
```

| years     | 1   | 2   | 3   | 4   | 5   |     | years     | 1   | 2   | 3   | 4   | 5   |
|-----------|-----|-----|-----|-----|-----|-----|-----------|-----|-----|-----|-----|-----|
| 1999-2008 | 11  | 17  | 23  | 21  | 10  |     | 2008-2017 | 17  | 23  | 9   | 1   | 18  |
| 2000-2009 | 11  | 17  | 21  | 23  | 9   |     | 2009-2018 | 17  | 23  | 9   | 18  | 26  |
| 2001-2010 | 17  | 11  | 23  | 21  | 9   |     | 2010-2019 | 17  | 9   | 23  | 26  | 18  |
| 2002-2011 | 17  | 11  | 23  | 21  | 9   |     | 2011-2020 | 17  | 9   | 26  | 23  | 18  |
| 2003-2012 | 17  | 11  | 23  | 9   | 33  |     | 2012-2021 | 17  | 26  | 12  | 9   | 23  |
| 2004-2013 | 17  | 11  | 23  | 24  | 9   |     | 2013-2022 | 12  | 17  | 26  | 23  | 9   |
| 2005-2014 | 17  | 11  | 23  | 9   | 24  |     | 2014-2023 | 12  | 17  | 23  | 9   | 26  |
| 2006-2015 | 17  | 9   | 11  | 23  | 33  |     | 2015-2024 | 12  | 23  | 2   | 9   | 33  |
| 2007-2016 | 17  | 9   | 23  | 11  | 7   |     | 2016-2025 | 12  | 2   | 33  | 23  | 21  |

[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
rebuilds the table with the rows cut into two blocks side by side, and
it moves any body-cell styling to wherever that cell ended up. A fill on
row 10 of the long grid lands on row one of the second block, because it
is the same cell.

Styles carry through the reshape, but formatting and content transforms
do not: anything from the `fmt_*()` family,
[`text_transform()`](https://gt.rstudio.com/reference/text_transform.html),
or the logo helpers has to come after the snake, and so does the theme.
For a parallel frame you cannot apply before folding,
[`gt_snake_align()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake_align.md)
reshapes it into the same blocks so it still lines up.

[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
puts a real empty column between the blocks rather than padding the
seam, because padding shifts the body cells without shifting the column
labels. `clean_gaps = TRUE`, the default, strips that spacer’s borders
and background so the gap stays blank under any theme.

## 6. Logos after the fold

After the fold each column carries its block number as a suffix, so the
franchise columns run `1_1` through `5_2` and the years are `years_1`
and `years_2`. One
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
call with a
[`matches()`](https://tidyselect.r-lib.org/reference/starts_with.html)
selector takes all ten franchise columns; each logo’s `alt` text is the
team’s full name.

``` r

# ... |>
gt_sdv_logos(columns = matches("^[1-5]_[0-9]+$"), league = "nfl", height = 34)
```

The pattern picks the snaked columns out by name rather than listing ten
of them, so the code survives a change to `n_cols`.

## 7. Spanners, widths and rules

The rest is ordinary `gt`: a spanner over each block, a label and a
fixed width for the years, and a dotted rule between the logos.

``` r

# ... |>
cols_align(columns = everything(), "center") |>
  tab_spanner(columns = matches("^[1-5]_1$"), label = "Most wins in the window", id = "block_1") |>
  tab_spanner(columns = matches("^[1-5]_2$"), label = "Most wins in the window", id = "block_2") |>
  cols_label(starts_with("years") ~ "Years", matches("^[1-5]_") ~ "") |>
  cols_width(starts_with("years") ~ px(92), matches("^[1-5]_") ~ px(48)) |>
  tab_options(table_body.hlines.style = "solid", table_body.hlines.color = "black") |>
  tab_style(
    locations = cells_body(columns = c(starts_with("years"), matches("^[1-5]_"))),
    style = cell_borders(color = "black", sides = "right", weight = px(1.5), style = "dotted")
  )
```

The dotted rule is set to `px(1.5)` because
[`gt_theme_athletic()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_athletic.md)
already draws a thin solid separator on every column, and a lighter rule
loses to it.

## 8. The legend and the caption

[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md)
takes a named vector of `label = color` and draws the key in the header.
`label_placement = "inside"` prints each label on its own swatch and
picks the text color per swatch for contrast, which keeps the white
swatch readable.
[`gt_538_caption()`](https://sdvplotR.sportsdataverse.org/reference/gt_538_caption.md)
takes a top line, which gets a rule under it, and a bottom line for the
source. Apply it after the theme, since it reads the themed table to
borrow a matching rule color.

## The finished table

``` r

title_key <- c(
  "No Super Bowls in window" = "#FFFFFF",
  "1 Super Bowl in window" = "#F4D7A4",
  "2+ Super Bowls in window" = "#FFA970"
)

wide |>
  gt(id = "windows") |>
  gt_highlight_cells(-years, condition = mask_1, fill = "#F4D7A4") |>
  gt_highlight_cells(-years, condition = mask_2, fill = "#FFA970") |>
  gt_snake(n_cols = 2) |>
  gt_theme_athletic() |>
  gt_sdv_logos(columns = matches("^[1-5]_[0-9]+$"), league = "nfl", height = 34) |>
  cols_align(columns = everything(), "center") |>
  tab_spanner(columns = matches("^[1-5]_1$"), label = "Most wins in the window", id = "block_1") |>
  tab_spanner(columns = matches("^[1-5]_2$"), label = "Most wins in the window", id = "block_2") |>
  cols_label(starts_with("years") ~ "Years", matches("^[1-5]_") ~ "") |>
  cols_width(starts_with("years") ~ px(92), matches("^[1-5]_") ~ px(48)) |>
  tab_options(table_body.hlines.style = "solid", table_body.hlines.color = "black") |>
  tab_style(
    locations = cells_body(columns = c(starts_with("years"), matches("^[1-5]_"))),
    style = cell_borders(color = "black", sides = "right", weight = px(1.5), style = "dotted")
  ) |>
  gt_legend_discrete(
    title_key,
    location = "top", label_placement = "inside", shape = "square",
    gap = 8, swatch_size = 20, border_width = 1.5, border_color = "black",
    heading = "The NFL's winningest franchises",
    subtitle = paste0(
      "Regular-season wins in each 10-year window, ", min(seasons), "-", max(seasons),
      ". Ties in the ranking go to win percentage."
    ),
    heading_style = list(
      font = "Spline Sans Mono", size = 22, weight = 600,
      transform = "uppercase", margin_bottom = 2, align = "center"
    ),
    subtitle_style = list(
      font = "Spline Sans Mono", size = 12, margin_bottom = 6,
      align = "center", color = "black"
    ),
    label_style = list(font = "Spline Sans Mono", size = 12, margin_bottom = 12)
  ) |>
  gt_538_caption(
    "Relocated franchises count as one: the Raiders, Chargers and Rams across their moves.",
    "Data: nflverse schedules via nflreadr"
  )
```

[TABLE]

Three franchises hold the top spot between them: the Colts in the first
two windows, the Patriots in every window from 2001-2010 to 2012-2021,
and the Chiefs in every window since.

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
