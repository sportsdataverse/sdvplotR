# Changelog

## sdvplotR 0.1.0

Initial release: one plotting package for team logos, wordmarks, player
headshots and team colors across eight leagues (NFL, NBA, WNBA, MLB,
NHL, college football, men’s and women’s college basketball), built on
‘ggpath’ and following the conventions of ‘nflplotR’, ‘cfbplotR’,
‘nbaplotR’ and ‘mlbplotR’.

- Team reference data covers every current franchise in the five pro
  leagues plus all FBS and FCS football programs and all Division I
  basketball programs, with ESPN ids, primary / dark logo variants,
  official colors and conference / division. NFL rows carry nflverse
  wordmarks.
- [`clean_team_abbrs()`](https://sdvplotR.sportsdataverse.org/reference/clean_team_abbrs.md)
  maps full team names, alternate provider abbreviations (`"WSH"` /
  `"WAS"`, `"GSW"` / `"GS"`, …) and historical abbreviations of
  relocated franchises to one canonical key per sport;
  [`resolve_historical_abbr()`](https://sdvplotR.sportsdataverse.org/reference/resolve_historical_abbr.md)
  exposes the relocation table.
- [`geom_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_logos.md),
  [`geom_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_wordmarks.md)
  and
  [`geom_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/geom_sdv_headshots.md)
  draw images at x / y positions.
- [`element_sdv_logo()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md),
  [`element_sdv_wordmark()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  and
  [`element_sdv_headshot()`](https://sdvplotR.sportsdataverse.org/reference/element_sdv.md)
  replace axis text with images;
  [`scale_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md),
  [`scale_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_axes_sdv.md)
  and the headshot variants do the same through
  [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
  with
  [`theme_x_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md)
  /
  [`theme_y_sdv()`](https://sdvplotR.sportsdataverse.org/reference/theme_sdv.md).
- [`scale_color_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  and
  [`scale_fill_sdv()`](https://sdvplotR.sportsdataverse.org/reference/scale_sdv.md)
  map teams to their primary or secondary colors;
  [`sdv_team_colors()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_colors.md),
  [`sdv_color_palette()`](https://sdvplotR.sportsdataverse.org/reference/sdv_color_palette.md)
  and
  [`sdv_team_factor()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_factor.md)
  expose the same data outside ggplot2.
- [`gt_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_logos.md),
  [`gt_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_wordmarks.md),
  [`gt_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_headshots.md),
  [`gt_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/gt_sdv_cols_label.md)
  and
  [`gt_merge_stack_team_color()`](https://sdvplotR.sportsdataverse.org/reference/gt_merge_stack_team_color.md)
  render images and team-colored text inside ‘gt’ tables.
- [`reactable_sdv_logos()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_wordmarks()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_headshots()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_images.md),
  [`reactable_sdv_cols_label()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_cols_label.md),
  [`reactable_sdv_team_color_bar()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  and
  [`reactable_sdv_team_color_bg()`](https://sdvplotR.sportsdataverse.org/reference/reactable_sdv_team_color.md)
  do the same for ‘reactable’ tables.
- [`sdv_team_tiers()`](https://sdvplotR.sportsdataverse.org/reference/sdv_team_tiers.md)
  builds tier charts, and
  [`ggtitle_image()`](https://sdvplotR.sportsdataverse.org/reference/ggtitle_image.md)
  places a logo next to a plot title.
- [`valid_team_names()`](https://sdvplotR.sportsdataverse.org/reference/valid_team_names.md),
  [`team_reference()`](https://sdvplotR.sportsdataverse.org/reference/team_reference.md)
  and
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md)
  expose the reference data.
