# College Hoops Tiers

On this page

**The brief:** a college basketball account wants an end-of-season Big
Ten tier list, the kind fans argue about, but backed by a power rating
instead of vibes, as a 1200 x 675 post plus a 1080 x 1080 cut. The
rating is the SportsDataverse adjusted efficiency margin for men’s
college basketball through hoopR, and
[`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md),
sdvplotR’s Tiermaker, draws the list.

``` r

library(sdvplotR)
library(ggplot2)
library(dplyr, warn.conflicts = FALSE)

season <- 2026 # the 2025-26 season, named by the year it ends
conference <- "Big Ten"
out_dir <- tempfile("sdvplotR-recipe-") # where the exports go; use your own folder
dir.create(out_dir)
```

## 1. Get the data

One row per team: adjusted offense, defense and their margin (points per
100 possessions better than an average Division I team, adjusted for
opponents). The ratings carry ESPN team ids as text, and so does
[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md),
which adds each team’s conference and abbreviation. The two types are
checked before the join.

``` r

ratings <- hoopR::load_mbb_ratings(season)
teams <- sdv_teams("mbb") |>
  transmute(team_id, team_abbr = abbr, team_short_name = short_name, conference = sub(" Conference$", "", conference))
stopifnot(identical(class(ratings$team_id), class(teams$team_id)))

league <- ratings |>
  inner_join(teams, by = "team_id") |>
  filter(conference == !!conference) |>
  arrange(desc(adj_em), team_abbr) |>
  select(team_abbr, team_short_name, rank, adj_em)
league
#> # A tibble: 18 × 4
#>    team_abbr team_short_name  rank adj_em
#>    <chr>     <chr>           <int>  <dbl>
#>  1 MICH      Michigan            1  47.4 
#>  2 ILL       Illinois            4  40.8 
#>  3 PUR       Purdue              8  37.8 
#>  4 MSU       Michigan St        11  35.2 
#>  5 NEB       Nebraska           17  32.3 
#>  6 IOWA      Iowa               23  29.7 
#>  7 WIS       Wisconsin          24  28.5 
#>  8 OSU       Ohio State         26  28.0 
#>  9 UCLA      UCLA               30  26.5 
#> 10 IU        Indiana            39  24.2 
#> 11 WASH      Washington         50  21.0 
#> 12 NU        Northwestern       59  18.5 
#> 13 USC       USC                71  15.5 
#> 14 MINN      Minnesota          78  15.0 
#> 15 ORE       Oregon             92  12.3 
#> 16 MD        Maryland          121   7.17
#> 17 RUTG      Rutgers           124   6.90
#> 18 PSU       Penn State        130   6.37
```

## 2. The first draft

Five tiers of equal size, straight into
[`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md).

``` r

draft <- league |>
  mutate(team = team_abbr, tier_no = ((row_number() - 1) * 5) %/% n() + 1) # five tiers of (nearly) equal size
sdv_team_tiers(draft, league = "mbb")
```

![First draft: the 18 Big Ten teams split into five equal tiers on the
Tiermaker's dark background, with the default joke tier
labels.](recipe-college-hoops-tiers_files/figure-html/draft-1.png)

It looks like a tier list, but the tiers are wrong. Equal-sized groups
put the best team in the conference in the same tier as a team more than
ten points worse per 100 possessions, and split neighbors less than two
points apart. The default labels (“Elite” … “What are they doing?”) are
jokes, not information.

## 3. Let the ratings draw the lines

Tiers should break where the ratings do. Sorting by rating and measuring
the gap to the team above makes the widest gaps easy to find; cutting at
the four widest gives five tiers whose members are close to each other.

``` r

league <- league |>
  mutate(gap = lag(adj_em) - adj_em)
cut <- sort(league$gap, decreasing = TRUE)[4] # the fourth-widest gap
league <- league |>
  mutate(tier_no = cumsum(coalesce(gap, 0) >= cut) + 1)
league |>
  filter(gap >= cut) |>
  select(team_short_name, adj_em, gap, tier_no)
#> # A tibble: 4 × 4
#>   team_short_name adj_em   gap tier_no
#>   <chr>            <dbl> <dbl>   <dbl>
#> 1 Illinois         40.8   6.57       2
#> 2 Washington       21.0   3.23       3
#> 3 USC              15.5   3.01       4
#> 4 Maryland          7.17  5.09       5
```

Each row above starts a new tier, and the size of its gap is the size of
the step down from the tier before.

## 4. Labels that say something

Each tier’s label becomes the rating range of its members, so the list
carries its own evidence, and the title states the finding. `tier_rank`
keeps teams in rating order inside a tier. The subtitle explains the
rating and the rule for the cuts; the caption names the data.

``` r

ranges <- league |>
  group_by(tier_no) |>
  summarise(hi = max(adj_em), lo = min(adj_em)) |>
  mutate(desc = if_else(hi == lo, sprintf("%+.1f", hi), sprintf("%+.1f to %+.1f", hi, lo)))
tier_desc <- setNames(ranges$desc, ranges$tier_no)

top_tier <- filter(league, tier_no == 1)
title <- if (nrow(top_tier) == 1) {
  paste(top_tier$team_short_name, "stood alone in the", conference)
} else {
  paste(nrow(top_tier), "teams made up the", conference, "top tier")
}

tiers <- league |>
  group_by(tier_no) |>
  mutate(tier_rank = row_number()) |>
  ungroup() |>
  select(team = team_abbr, tier_no, tier_rank)

tier_list <- function(width = 0.075, alpha = 0.8, theme = "dark") {
  sdv_team_tiers(
    tiers,
    league = "mbb",
    title = title,
    subtitle = paste0(
      "Tiers by adjusted efficiency margin, ", season - 1, "-", season %% 100,
      ". A new tier starts at each of the four widest gaps."
    ),
    caption = paste(
      "Margin: points per 100 possessions better than an average D-I team.",
      "Data: SportsDataverse ratings via hoopR  |  sdvplotR Tiermaker",
      sep = "\n"
    ),
    tier_desc = tier_desc,
    width = width,
    alpha = alpha,
    theme = theme
  )
}

tier_list()
```

![The Big Ten tier list with tiers cut at the four widest rating gaps,
each tier labelled with its rating range, still on the dark
background.](recipe-college-hoops-tiers_files/figure-html/labels-1.png)

## 5. Light or dark

On the Tiermaker’s dark background,
[`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
draws each school’s dark-background logo (its default
`variant = "auto"`), so Iowa’s hawk is gold, Michigan State’s Spartan
white and Penn State’s lion outlined instead of fading into the
background. A light background suits a page or feed that is white
anyway: `theme = "light"` draws the list on white, with the text and
tier lines turned dark, and each school’s usual logo. The logos go to
full opacity too (`alpha = 1`); the default 0.8 softens them against the
dark background but washes them out on white. The exports below use the
light one.

``` r

tier_list(alpha = 1, theme = "light")
```

![The finished tier list on a white background, logos at full strength,
tiers labelled with rating
ranges.](recipe-college-hoops-tiers_files/figure-html/light-1.png)

## 6. Export at social sizes

[`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
re-lays the same plot at each export size. `width` is a share of the
panel’s width, and the square’s panel is narrower than the wide cut’s,
so the square gets a slightly larger share to keep the logos the same
size. The widest tier holds the most logos side by side, which is why
the wide 1200 x 675 cut is the better post here.

``` r

wide <- file.path(out_dir, "big_ten_tiers_1200x675.png")
square <- file.path(out_dir, "big_ten_tiers_1080x1080.png")
ggsave(wide, tier_list(alpha = 1, theme = "light"), width = 8, height = 4.5, dpi = 150)
ggsave(square, tier_list(width = 0.085, alpha = 1, theme = "light"), width = 7.2, height = 7.2, dpi = 150)
magick::image_info(magick::image_read(c(wide, square)))[c("width", "height")]
#> # A tibble: 2 × 2
#>   width height
#>   <int>  <int>
#> 1  1200    675
#> 2  1080   1080
magick::image_read(wide)
```

![The finished Big Ten tier list exported at 1200 by 675
pixels.](recipe-college-hoops-tiers_files/figure-html/export-1.png)

The 1080 x 1080 cut:

``` r

magick::image_read(square)
```

![The same tier list exported at 1080 by 1080
pixels.](recipe-college-hoops-tiers_files/figure-html/export-square-1.png)

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
