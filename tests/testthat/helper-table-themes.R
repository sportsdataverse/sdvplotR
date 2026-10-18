# the 20 registry shortcuts (data-raw/gen_gt_shortcuts.R CURATED)
curated_themes <- c(
  "basketball-reference", "datagolf", "fivethirtyeight-site", "wikipedia", "cleaning-the-glass",
  "bbc-sport", "opta-analyst", "our-world-in-data", "bloomberg-markets", "aer", "nzz", "guardian",
  "barttorvik", "espn-site", "gov-uk", "washington-post", "reuters-graphics", "formula1",
  "dunks-and-threes", "economist"
)

# gt_theme_* exports that are not house themes: they take a registry name and have no `...`
# or theme_bg row, so the loops over the house themes leave them out
registry_theme_fns <- c("gt_theme_source", paste0("gt_theme_", gsub("-", "_", curated_themes)))
