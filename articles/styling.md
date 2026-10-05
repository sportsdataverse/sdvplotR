# Styling Headers, Legends, and Captions

On this page

Five functions in the package take styling as named lists rather than as
a long tail of arguments.
[`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md)
has `kicker_style`, `title_style`, `subtitle_style`, and `date_style`.
[`gt_legend_continuous()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_continuous.md)
has `title_style` and `labels_style`.
[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md)
has `heading_style`, `subtitle_style`, and `label_style`.
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
and
[`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
each have four, one per piece of their shared header and footer.

They all read the same keys, so what you learn on one carries to the
others. This article dresses one table, the NBA’s best net ratings of
the 2025-26 regular season, step by step: a header block, fonts, a color
legend, a key for a categorical fill, and a grid of two tables under one
header. The games are [`hoopR`](https://hoopR.sportsdataverse.org)’s
ESPN team box scores. The styling functions come from Andrew
Weatherman’s [gtUtils](https://github.com/andreweatherman/gtUtils), and
this article follows his styling guide.

``` r

library(sdvplotR)
library(gt)
library(dplyr)
```

## The data

Net rating is points scored minus points allowed per 100 possessions.
The box scores hold one row per team per game, so joining each row to
its opponent’s row gives the possessions on both ends;
[`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
adds each team’s full name and conference.

``` r

nba_teams <- team_reference("nba")

# the NBA Cup final is filed as a regular-season game but counts in no record or stat
cup_final <- hoopR::load_nba_schedule(2026) |>
  filter(type_abbreviation == "CC") |>
  pull(id)

box <- hoopR::load_nba_team_box(2026) |>
  # regular season; the box scores also hold the All-Star games
  filter(season_type == 2, team_abbreviation %in% nba_teams$team_abbr, !game_id %in% cup_final) |>
  mutate(poss = field_goals_attempted - offensive_rebounds + total_turnovers + 0.44 * free_throws_attempted)

records <- summarise(box, w = sum(team_winner), l = sum(!team_winner), .by = team_abbreviation)

# a box score missing a count gives no possessions, so the rates skip that game
rated <- filter(box, !is.na(poss))

ratings <- rated |>
  inner_join(
    select(rated, game_id, opponent_team_id = team_id, opp_poss = poss),
    by = c("game_id", "opponent_team_id")
  ) |>
  summarise(
    off = 100 * sum(team_score) / sum(poss),
    def = 100 * sum(opponent_team_score) / sum(opp_poss),
    .by = team_abbreviation
  ) |>
  inner_join(records, by = "team_abbreviation") |>
  mutate(
    net = off - def,
    name = nba_teams$team_name[match(team_abbreviation, nba_teams$team_abbr)],
    conf = nba_teams$conference[match(team_abbreviation, nba_teams$team_abbr)]
  ) |>
  arrange(desc(net), team_abbreviation) |>
  select(team = team_abbreviation, name, conf, w, l, off, def, net)

last_day <- max(box$game_date)

top <- slice_head(ratings, n = 8)

base <- function(df) {
  gt(df) |>
    gt_sdv_logos(team, sport = "nba", height = 26) |>
    cols_hide(conf) |>
    fmt_number(c(off, def), decimals = 1) |>
    fmt_number(net, decimals = 1, force_sign = TRUE) |>
    cols_label(team = "", name = "Team", w = "W", l = "L", off = "Off", def = "Def", net = "Net") |>
    cols_align(columns = -name, "center")
}
```

`base()` is the plain table every section starts from: logos from
[`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
the conference kept in the data but hidden, and the ratings formatted.

## The keys

Every style list accepts the same thirteen names. Anything you leave out
keeps its default.

| Key | Takes | Notes |
|----|----|----|
| `font` | A Google font name | Loaded through `gt`, so it survives [`gtsave()`](https://gt.rstudio.com/reference/gtsave.html) |
| `size` | Number or CSS string |  |
| `color` | Hex color |  |
| `weight` | Number or CSS keyword | `600`, `"bold"` |
| `italic` | `TRUE` / `FALSE` |  |
| `spacing` | Number or CSS string | Letter spacing |
| `transform` | CSS string | `"uppercase"`, `"lowercase"` |
| `align` | `"left"`, `"center"`, `"right"` |  |
| `line_height` | Number |  |
| `margin_top`, `margin_bottom` | Number or CSS string |  |
| `padding_top`, `padding_bottom` | Number or CSS string |  |

Any key that takes a length reads a bare number as pixels, so
`size = 30` gives `30px`. Pass a string when you want other units, like
`size = "2rem"` or `spacing = "0.08em"`.

## 1. A header block

[`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md)
builds a header out of four parts, each styled on its own. Only `title`
is required. Start with everything at its default.

``` r

top |>
  base() |>
  gt_theme_broadsheet() |>
  gt_title_header(
    title = "The NBA's best net ratings",
    kicker = "NBA · 2025-26 regular season",
    subtitle = "Points scored and allowed per 100 possessions",
    date = last_day
  )
```

[TABLE]

The kicker arrives with a color and uppercase treatment already set,
since a kicker is nearly always a small colored line above the title. A
`Date` such as the last day of the regular season is formatted as a full
date; any other value passes through as written, so `date = "Week 12"`
renders as `Week 12`.

Now tune it. Each list only has to name the keys you want to change.

``` r

top |>
  base() |>
  gt_theme_broadsheet() |>
  gt_title_header(
    title = "The NBA's best net ratings",
    kicker = "NBA · 2025-26 regular season",
    subtitle = "Points scored and allowed per 100 possessions",
    date = last_day,
    kicker_style = list(color = "#C8102E", spacing = "0.16em", size = "0.7em"),
    title_style = list(
      font = "Oswald", size = 34, weight = 600,
      spacing = "-0.01em", margin_bottom = 2
    ),
    subtitle_style = list(size = "1.05em", color = "#5C574F", italic = TRUE),
    date_style = list(size = "0.75em", transform = "uppercase", spacing = "0.1em")
  )
```

[TABLE]

Because the lists merge over the defaults rather than replacing them,
setting `kicker_style = list(size = 20)` changes the size and leaves the
color and uppercase treatment alone.

## 2. Fonts

Naming a `font` loads it through `gt`’s own font machinery, so it works
in the browser and in a saved image. Leave `font` unset and the element
inherits whatever the theme is using, which is usually what you want for
a title sitting on a themed table. On
[`gt_theme_sdv()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv.md),
the SportsDataverse house theme, that is Chivo.

``` r

top |>
  base() |>
  gt_theme_sdv() |>
  gt_title_header(
    title = "Inherited from the theme",
    subtitle = "No font named, so both pick up the theme's Chivo",
    title_style = list(size = 26),
    subtitle_style = list(size = "0.95em")
  )
```

[TABLE]

## 3. Legend text

The legends read the same keys.
[`gt_color_ranks()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_ranks.md)
colors the net rating column, and
[`gt_legend_continuous()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_continuous.md)
draws its scale, styling the title and the tick labels. The domain is
the league’s whole range, rounded out to whole points, so the colors
place each of the eight against all thirty teams; `reverse = TRUE` puts
the best ratings at the green end.

``` r

net_domain <- c(floor(min(ratings$net)), ceiling(max(ratings$net)))

top |>
  base() |>
  gt_theme_swiss() |>
  gt_color_ranks(net, domain = net_domain, reverse = TRUE) |>
  gt_legend_continuous(
    title = "Net rating",
    title_style = list(
      font = "Oswald", size = 12, transform = "uppercase",
      spacing = "0.12em", color = "#12263F"
    ),
    labels_style = list(size = 11, color = "#5A6B7E")
  )
```

[TABLE]

[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md)
styles a heading, a subtitle, and the swatch labels. Here the team names
are filled by conference with
[`gt_highlight_cells()`](https://sdvplotR.sportsdataverse.org/reference/gt_highlight_cells.md),
which takes a logical grid the same shape as the columns it fills, and
the discrete legend explains the two fills.

``` r

east <- data.frame(name = top$conf == "Eastern")

top |>
  base() |>
  gt_theme_broadsheet() |>
  gt_highlight_cells(name, condition = east, fill = "#D9E5F5") |>
  gt_highlight_cells(name, condition = !east, fill = "#F5DED9") |>
  gt_legend_discrete(
    c("Eastern Conference" = "#D9E5F5", "Western Conference" = "#F5DED9"),
    heading = "Best net ratings",
    subtitle = "The top eight, by conference",
    location = "top",
    heading_style = list(font = "Oswald", size = 22, transform = "uppercase"),
    subtitle_style = list(size = 12, italic = TRUE, color = "#5C574F"),
    label_style = list(size = 12, weight = 500)
  )
```

[TABLE]

One exception worth knowing. With `label_placement = "inside"`, each
label is printed on its own swatch and takes black or white by whichever
contrasts better with that swatch, so a `color` in `label_style` is
ignored in that mode. Every other key still applies.

## 4. Grids and stacks

[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
and
[`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
wrap several tables in a shared header and footer, and style each piece
the same way. Each conference’s top five, side by side:

``` r

conference_table <- function(conference) {
  ratings |>
    filter(conf == conference) |>
    slice_head(n = 5) |>
    base() |>
    cols_hide(c(off, def)) |>
    gt_theme_booktabs()
}

gt_grid(
  list(conference_table("Eastern"), conference_table("Western")),
  ncol = 2,
  labels = c("East", "West"),
  title = "The best net ratings in each conference",
  subtitle = "NBA, 2025-26 regular season, points per 100 possessions",
  caption = "Net rating is points scored minus points allowed per 100 possessions.",
  source_note = "Data: ESPN box scores via hoopR",
  caption_rule = TRUE,
  title_style = list(font = "Oswald", size = 26, transform = "uppercase"),
  subtitle_style = list(size = 13, color = "#5A6B7E", margin_bottom = 18),
  caption_style = list(size = 11, color = "#12263F"),
  source_note_style = list(size = 11, color = "#5A6B7E", italic = TRUE),
  label_style = list(font = "Oswald", size = 12, transform = "uppercase")
)
```

The best net ratings in each conference

NBA, 2025-26 regular season, points per 100 possessions

East

|  | Team | W | L | Net |
|----|----|----|----|----|
| ![Detroit Pistons](https://a.espncdn.com/i/teamlogos/nba/500/det.png) | Detroit Pistons | 60 | 22 | +7.6 |
| ![Boston Celtics](https://a.espncdn.com/i/teamlogos/nba/500/bos.png) | Boston Celtics | 56 | 26 | +7.1 |
| ![New York Knicks](https://a.espncdn.com/i/teamlogos/nba/500/ny.png) | New York Knicks | 53 | 29 | +6.6 |
| ![Cleveland Cavaliers](https://a.espncdn.com/i/teamlogos/nba/500/cle.png) | Cleveland Cavaliers | 52 | 30 | +4.4 |
| ![Toronto Raptors](https://a.espncdn.com/i/teamlogos/nba/500/tor.png) | Toronto Raptors | 46 | 36 | +2.9 |

West

|  | Team | W | L | Net |
|----|----|----|----|----|
| ![Oklahoma City Thunder](https://a.espncdn.com/i/teamlogos/nba/500/okc.png) | Oklahoma City Thunder | 64 | 18 | +11.5 |
| ![San Antonio Spurs](https://a.espncdn.com/i/teamlogos/nba/500/sa.png) | San Antonio Spurs | 62 | 20 | +8.1 |
| ![Denver Nuggets](https://a.espncdn.com/i/teamlogos/nba/500/den.png) | Denver Nuggets | 54 | 28 | +4.7 |
| ![Houston Rockets](https://a.espncdn.com/i/teamlogos/nba/500/hou.png) | Houston Rockets | 52 | 30 | +4.6 |
| ![Minnesota Timberwolves](https://a.espncdn.com/i/teamlogos/nba/500/min.png) | Minnesota Timberwolves | 49 | 33 | +4.0 |

Net rating is points scored minus points allowed per 100 possessions.

Data: ESPN box scores via hoopR

There is one real difference here. A grid is composed HTML rather than a
`gt` table, so it has no theme to inherit from. Elements with no `font`
fall back to a system stack instead of picking up the tables’
typography. Name a `font` on the grid’s own lists when you want the
header to match the blocks under it.
[`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
takes the same four lists for tables stacked top to bottom.

## 5. Ordering

[`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md)
calls
[`gt::tab_header()`](https://gt.rstudio.com/reference/tab_header.html),
which replaces the whole header.
[`gt_legend_continuous()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_continuous.md)
and
[`gt_legend_discrete()`](https://sdvplotR.sportsdataverse.org/reference/gt_legend_discrete.md)
ride in that same header when `location = "top"`. Call
[`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md)
first, or it will overwrite the legend you just added.

``` r

top |>
  base() |>
  gt_theme_almanac() |>
  gt_color_ranks(net, domain = net_domain, reverse = TRUE) |>
  gt_title_header(
    title = "Header first",
    title_style = list(font = "Oswald", size = 24)
  ) |>
  gt_legend_continuous(location = "top")
```

[TABLE]

That last call takes no palette or domain.
[`gt_color_ranks()`](https://sdvplotR.sportsdataverse.org/reference/gt_color_ranks.md)
records the scale it used, and the legend reads it back, so the two
cannot disagree.
