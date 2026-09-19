# Package index

## Logos, Wordmarks & Headshots

ggplot2 geoms and ggproto objects for rendering team logos, wordmarks
and player headshots on plots. Every geom takes a `sport` argument.

- [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
  [`GeomSDVlogo`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md)
  : ggplot2 Layer for Visualizing Sports Team Logos
- [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md)
  [`GeomSDVwordmark`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md)
  : ggplot2 Layer for Visualizing Sports Team Wordmarks
- [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
  [`GeomSDVheadshot`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
  : ggplot2 Layer for Visualizing Player Headshots

## Theme Elements

Image-based ggplot2 theme elements for axis text — replace tick labels
with team logos, wordmarks or player headshots.

- [`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  [`element_sdv_wordmark()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  [`element_sdv_headshot()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  [`element_sdv_raster()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  : Theme Elements for Image Grobs

## Scales & Axes

Team color / fill scales, logo and headshot axis scales, and the
matching theme helpers.

- [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  [`scale_colour_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  : Scales for Sports Team Colors
- [`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  [`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  [`scale_x_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  [`scale_y_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  : Axis Scales for Sports Team Logos
- [`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  [`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  : Theme Helpers for SDV Axis Labels

## gt Table Helpers

Embed team logos, wordmarks and player headshots inside gt table cells
or column labels, and stack team-colored text.

- [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md)
  : Render Logos in 'gt' Tables
- [`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md)
  : Render Wordmarks in 'gt' Tables
- [`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md)
  : Render Player Headshots in 'gt' Tables
- [`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)
  : Render Logos in 'gt' Table Column Labels
- [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  : Merge and Stack Text in gt Tables with Team Colors

## reactable Table Helpers

Cell renderers, column headers and team-colored cell styles for
reactable tables.

- [`reactable_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md)
  [`reactable_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md)
  [`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md)
  : Render Team Logos, Wordmarks and Headshots in 'reactable' Tables
- [`reactable_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_cols_label.md)
  : Replace 'reactable' Column Headers with Team Logos
- [`reactable_sdv_team_color_bar()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  [`reactable_sdv_team_color_bg()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  : Team-Colored Cell Styles for 'reactable' Tables

## Team Utilities

Validate, clean and factor-order team abbreviations; look up team
reference data and colors; control the image cache.

- [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md)
  : Supported Sports
- [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md)
  : Output Valid Team Names
- [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
  : Get Team Reference Data
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  : Standardize Team Abbreviations
- [`resolve_historical_abbr()`](https://sdvplotR.sportsdataverse.org/reference/resolve_historical_abbr.md)
  : Resolve Historical Team Abbreviations
- [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md)
  : Get Team Colors
- [`sdv_color_palette()`](https://sdvplotR.sportsdataverse.org/reference/sdv_color_palette.md)
  : Get Team Color Palette
- [`sdv_team_factor()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_factor.md)
  : Order Team Names as a Factor
- [`sdvplotR_clear_cache()`](https://sdvplotR.sportsdataverse.org/reference/sdvplotR_clear_cache.md)
  : Clear the sdvplotR Image Cache

## Premade Plots

High-level functions that build complete branded plots.

- [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  : Create Team Tier Plots

## Plot Titles

Add a logo or image next to a ggplot2 title.

- [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  [`theme_title_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  : Functions for Adding an Image to the Title of a ggplot

## Re-exported from ggpath

Generic image geoms and theme elements provided by the ggpath backend.

- [`reexports`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`geom_from_path`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`GeomFromPath`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`element_path`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`element_raster`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`geom_mean_lines`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`geom_median_lines`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  [`GeomRefLines`](https://sdvplotR.sportsdataverse.org/reference/reexports.md)
  : Objects exported from other packages
