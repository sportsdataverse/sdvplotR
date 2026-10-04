# Render the home page figure, man/figures/README-home.png, which README.Rmd shows near the top.
# It is drawn once from real data and committed, so the home page never waits on a live fetch.
# Rerun it after a change to geom_sdv_logos() or to the NFL logo data.
#
# Run from the package root: Rscript data-raw/home_figure.R

pkgload::load_all(quiet = TRUE)
library(ggplot2)

# 2023 NFL regular season: points scored and allowed per game, one row per team
games <- nflreadr::load_schedules(2023)
games <- games[games$game_type == "REG" & !is.na(games$result), ]
sides <- rbind(
  data.frame(team = games$home_team, scored = games$home_score, allowed = games$away_score),
  data.frame(team = games$away_team, scored = games$away_score, allowed = games$home_score)
)
teams <- aggregate(cbind(scored, allowed) ~ team, data = sides, FUN = mean)
stopifnot(nrow(teams) == 32, all(teams$team %in% valid_team_names("nfl")))

p <- ggplot(teams, aes(x = scored, y = allowed)) +
  geom_hline(yintercept = mean(teams$allowed), linetype = "dashed", colour = "grey65") +
  geom_vline(xintercept = mean(teams$scored), linetype = "dashed", colour = "grey65") +
  geom_sdv_logos(aes(team = team), sport = "nfl", width = 0.06) +
  scale_y_reverse() +
  labs(
    title = "Points scored and allowed per game",
    subtitle = "2023 NFL regular season: the best teams sit top right",
    x = "Points scored per game",
    y = "Points allowed per game (fewer is better)",
    caption = "Data: nflreadr | Logos: sdvplotR::geom_sdv_logos()"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), plot.title.position = "plot")

out <- "man/figures/README-home.png"
ggsave(out, p, width = 8, height = 5.5, dpi = 120, bg = "white")
message(out, ": ", round(file.size(out) / 1024), " KB")
