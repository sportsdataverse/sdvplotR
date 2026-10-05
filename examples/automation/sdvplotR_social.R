#!/usr/bin/env Rscript
# Social game-day graphics with sdvplotR: season leaderboards, final-score cards and a
# player-of-the-game card, posted to Bluesky.
#
# Subcommands:
#
#   leaderboard  one league's season leaders as a gt table image (headless Chrome)
#   gameday      a final-score card per game on one date, plus a player-of-the-game card (ggplot2)
#   post         post a run's images to Bluesky; prints the would-be posts unless --post is given
#
# Each run writes PNGs to out/<today>/ and adds its posts (image paths, alt text, caption,
# hashtags) to out/<today>/manifest.json, which `post` reads. The data comes from the
# SportsDataverse release files (nflreadr, hoopR, wehoop, fastRhockey) and the MLB Stats API
# (baseballr); nothing needs a key. With no finished games on the date, or no leaders yet for
# the season, it uses the most recent date or season that has them and says so in the caption.
#
# Run from a clone of sdvplotR, with sdvplotR and the data packages installed:
#
#   Rscript examples/automation/sdvplotR_social.R leaderboard --league nfl
#   Rscript examples/automation/sdvplotR_social.R gameday --league nba --date 2026-06-13
#   Rscript examples/automation/sdvplotR_social.R post --manifest out/2026-10-05/manifest.json
#
# `post --post` publishes with the BSKY_HANDLE and BSKY_APP_PASSWORD environment variables (an
# app password, never the account password). See vignettes/automation-social.Rmd.
#
# The script only defines functions when it is source()d, so its pieces can be tested
# (tests/test-sdvplotR_social.R beside it); Rscript runs main().

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x

# league -> hashtag, default leaderboard stat, whether a season spans two calendar years (named
# by the year it ends), the month it starts, and its sdvplotR sport
LEAGUES <- list(
  nfl = list(tag = "NFL", stat = "passing_yards", two_year = FALSE, start = 9),
  nba = list(tag = "NBA", stat = "points", two_year = TRUE, start = 10),
  wnba = list(tag = "WNBA", stat = "points", two_year = FALSE, start = 5),
  mlb = list(tag = "MLB", stat = "homeRuns", two_year = FALSE, start = 3),
  nhl = list(tag = "NHL", stat = "points", two_year = TRUE, start = 9)
)
SIZES <- list(square = c(1080, 1080), landscape = c(1200, 675))
BG <- "#0f1115"
INK <- "#f5f6f7"
MUTED <- "#a3a9b1"
NEUTRAL <- "#3a3f47"
CREDIT <- "Data: SportsDataverse  |  Logos, headshots & colors: sdvplotR"
MAX_IMAGES <- 4 # Bluesky's limits: images per post, graphemes per post, bytes per image
MAX_GRAPHEMES <- 300
MAX_BLOB <- 1000000
GITHUB_REPO <- "sportsdataverse/sdvplotR" # this example never posts from sdvplotR's own CI

no_data <- function(message) {
  structure(class = c("no_data", "error", "condition"), list(message = message, call = NULL))
}
post_error <- function(message, ambiguous = FALSE) {
  structure(
    class = c("post_error", "error", "condition"),
    list(message = message, call = NULL, ambiguous = ambiguous)
  )
}

# ------------------------------------------------------------------------------------------
# Seasons and dates

year_of <- function(day) as.integer(format(day, "%Y"))
month_of <- function(day) as.integer(format(day, "%m"))

# The season a date falls in: the year it ends for the NBA and NHL, else the year it starts
season_of <- function(league, day) {
  lg <- LEAGUES[[league]]
  if (lg$two_year) year_of(day) + (month_of(day) >= lg$start) else year_of(day) - (month_of(day) < lg$start)
}
season_label <- function(league, season) {
  if (LEAGUES[[league]]$two_year) sprintf("%d-%02d", season - 1, season %% 100) else as.character(season)
}
long_date <- function(day) paste0(format(day, "%A, %b "), as.integer(format(day, "%d")), format(day, ", %Y"))
short_date <- function(day) paste0(format(day, "%b "), as.integer(format(day, "%d")), format(day, ", %Y"))
slug <- function(x) gsub("^-|-$", "", gsub("[^a-z0-9]+", "-", tolower(x)))
quietly <- function(expr) tryCatch(suppressWarnings(suppressMessages(expr)), error = function(e) NULL)

# an NHL game id's fifth and sixth digits are its type: 01 preseason, 02 regular season, 03 playoffs
nhl_type <- function(game_id) (as.numeric(game_id) %/% 10000) %% 100

# ------------------------------------------------------------------------------------------
# Leaders: one league's season leaders in one stat

# NBA / WNBA per-game averages and NHL totals that `--stat` can name
BOX_STATS <- list(
  basketball = c("points", "rebounds", "assists", "steals", "blocks", "three_point_field_goals_made"),
  nhl = c("points", "goals", "assists", "shots_on_goal", "hits", "blocked_shots")
)
stat_label <- function(stat) {
  words <- gsub("_", " ", gsub("([a-z])([A-Z])", "\\1 \\2", stat))
  paste0(toupper(substr(words, 1, 1)), tolower(substring(words, 2)))
}

# One season of raw rows for a league's leaders, or NULL when it has none yet
leader_rows <- function(league, season, stat) {
  switch(league,
    nfl = {
      x <- quietly(nflreadr::load_player_stats(season, summary_level = "reg"))
      if (NROW(x) == 0) NULL else x
    },
    nba = ,
    wnba = {
      box <- if (league == "nba") hoopR::load_nba_player_box else wehoop::load_wnba_player_box
      sched <- if (league == "nba") hoopR::load_nba_schedule else wehoop::load_wnba_schedule
      x <- quietly(box(seasons = season))
      if (NROW(x) == 0 || !any(x$season_type == 2)) {
        return(NULL)
      }
      # standard games only: ESPN files the All-Star Game and the cup final as regular season too
      std <- quietly(sched(seasons = season))
      std <- std$game_id[std$season_type == 2 & std$type_abbreviation == "STD"]
      x[x$season_type == 2 & !x$did_not_play & !is.na(x$minutes) & x$game_id %in% std, ]
    },
    nhl = {
      x <- quietly(fastRhockey::load_nhl_player_box(seasons = season))
      if (NROW(x) == 0 || !any(nhl_type(x$game_id) == 2)) NULL else x[nhl_type(x$game_id) == 2, ]
    },
    mlb = {
      group <- if (grepl("^pitching\\.", stat)) "pitching" else "hitting"
      x <- quietly(baseballr::mlb_stats_leaders(
        leader_categories = sub("^(hitting|pitching)\\.", "", stat), season = season,
        sport_id = 1, leader_game_types = "R", limit = 25
      ))
      if (NROW(x)) x <- x[x$stat_group == group, , drop = FALSE]
      if (NROW(x) == 0) NULL else x
    }
  )
}

# A league's schedule as one row per game: its date, whether it is a regular-season game, whether
# it has been played, and (MLB) whether it was postponed or cancelled, so never played on that date
standard_schedule <- function(league, raw) {
  switch(league,
    nfl = data.frame(
      date = as.Date(raw$gameday), regular = raw$game_type == "REG", completed = !is.na(raw$result)
    ),
    nba = ,
    wnba = data.frame(
      date = as.Date(raw$game_date), regular = raw$season_type == 2, completed = raw$status_type_completed %in% TRUE,
      # a postponed game keeps its row beside the replay's
      dropped = (raw$status_type_name %||% NA) %in% c("STATUS_POSTPONED", "STATUS_CANCELED")
    ),
    nhl = data.frame(
      date = as.Date(raw$game_date), regular = nhl_type(raw$game_id) == 2,
      completed = raw$game_state %in% c("OFF", "FINAL"), dropped = raw$game_state %in% c("PPD", "CNCL")
    ),
    mlb = data.frame(
      date = as.Date(raw$official_date), regular = raw$game_type == "R",
      completed = raw$status_abstract_game_state %in% "Final",
      dropped = raw$status_detailed_state %in% c("Postponed", "Cancelled")
    )
  )
}

#' Is the regular season still under way (any regular-season game left to play), and the date of
#' its last game played: what a table of it runs "through"
schedule_state <- function(sched) {
  done <- sched$regular & sched$completed
  left <- sched$regular & !sched$completed & !(sched$dropped %||% FALSE)
  list(in_progress = any(left), through = if (any(done)) max(sched$date[done]) else as.Date(NA))
}

season_state <- function(league, season) {
  raw <- switch(league,
    nfl = quietly(nflreadr::load_schedules(season)),
    nba = quietly(hoopR::load_nba_schedule(seasons = season)),
    wnba = quietly(wehoop::load_wnba_schedule(seasons = season)),
    nhl = quietly(fastRhockey::load_nhl_schedule(seasons = season)),
    mlb = quietly(baseballr::mlb_schedule(season = season, level_ids = "1"))
  )
  if (NROW(raw) == 0) {
    return(list(in_progress = FALSE, through = as.Date(NA)))
  }
  schedule_state(standard_schedule(league, raw))
}

#' The top players in one stat: rank, id, name, position, team (an sdvplotR key), display value
fetch_leaders <- function(league, stat = NULL, season = NULL, top = 10, today = Sys.Date()) {
  stat <- stat %||% LEAGUES[[league]]$stat
  sport <- league
  if (league %in% c("nba", "wnba") && !stat %in% BOX_STATS$basketball) {
    stop(no_data(sprintf("--stat for %s is one of: %s", league, paste(BOX_STATS$basketball, collapse = ", "))))
  }
  if (league == "nhl" && !stat %in% BOX_STATS$nhl) {
    stop(no_data(sprintf("--stat for nhl is one of: %s", paste(BOX_STATS$nhl, collapse = ", "))))
  }
  wanted <- season %||% season_of(league, today)
  for (year in c(wanted, wanted - 1, wanted - 2)) {
    rows <- leader_rows(league, year, stat)
    if (!is.null(rows)) break
  }
  if (is.null(rows)) {
    stop(no_data(sprintf("no %s %s leaders for %d or the two seasons before it", league, stat, wanted)))
  }

  if (league == "nfl") {
    if (!stat %in% names(rows) || !is.numeric(rows[[stat]])) {
      numeric <- names(rows)[vapply(rows, is.numeric, logical(1))]
      stop(no_data(sprintf("no NFL stat %s; try one of: %s", stat, paste(utils::head(numeric, 40), collapse = ", "))))
    }
    out <- data.frame(
      id = rows$player_id, name = rows$player_display_name, position = rows$position,
      team = rows$recent_team, value = rows[[stat]], id_type = "gsis"
    )
    out$display <- formatC(out$value, format = "d", big.mark = ",")
  } else if (league %in% c("nba", "wnba")) {
    rows <- rows[order(rows$game_date, rows$game_id), ]
    games <- tapply(rows$game_id, rows$team_abbreviation, function(x) length(unique(x)))
    agg <- do.call(rbind, lapply(split(rows, rows$athlete_id), function(p) {
      data.frame(
        id = as.character(p$athlete_id[1]), name = utils::tail(p$athlete_display_name, 1),
        position = utils::tail(p$athlete_position_abbreviation, 1),
        team = utils::tail(p$team_abbreviation, 1), gp = nrow(p), value = mean(p[[stat]], na.rm = TRUE)
      )
    }))
    out <- agg[agg$gp >= max(games) / 2, ] # half the most games any team has played
    out$id_type <- "espn"
    out$display <- sprintf("%.1f", out$value)
  } else if (league == "nhl") {
    rows <- rows[order(rows$game_date, rows$game_id), ]
    out <- do.call(rbind, lapply(split(rows, rows$player_id), function(p) {
      data.frame(
        id = as.character(p$player_id[1]), name = utils::tail(p$player_name, 1),
        position = utils::tail(p$position, 1), team = utils::tail(p$team_abbrev, 1),
        value = sum(p[[stat]], na.rm = TRUE)
      )
    }))
    full <- quietly(fastRhockey::load_nhl_game_rosters(seasons = year)) # "C. McDavid" -> "Connor McDavid"
    full_name <- full$full_name[match(out$id, as.character(full$player_id))]
    if (NROW(full)) out$name <- ifelse(is.na(full_name), out$name, full_name)
    out$id_type <- "league"
    out$display <- as.character(out$value)
  } else {
    clubs <- quietly(baseballr::mlb_teams(season = year, sport_ids = 1))
    out <- data.frame(
      id = as.character(rows$person_id), name = rows$person_full_name, position = "",
      team = clubs$team_abbreviation[match(rows$team_id, clubs$team_id)],
      value = as.numeric(rows$value), display = sub("^0\\.", ".", rows$value), id_type = "league"
    )
    ascending <- grepl("earnedRunAverage|walksAndHitsPerInningPitched", stat) # lower is better
    out <- out[order(if (ascending) out$value else -out$value), ]
  }
  if (league != "mlb") out <- out[order(-out$value, out$id), ] # the id breaks a tie, so a re-run matches
  out <- utils::head(out, top)
  out$team <- sdvplotR::clean_team_abbrs(out$team, sport = sport)
  out$rank <- match(out$value, out$value) # ties share the better rank
  note <- if (year != wanted) {
    sprintf(
      "No %s regular-season leaders yet, so these are %s.",
      season_label(league, wanted), season_label(league, year)
    )
  }
  label <- stat_label(sub("^(hitting|pitching)\\.", "", stat))
  if (league %in% c("nba", "wnba")) label <- paste(label, "per game")
  state <- season_state(league, year)
  list(
    frame = out, season = year, stat = stat, label = label,
    to_date = state$in_progress, through = state$through, note = note
  )
}

# ------------------------------------------------------------------------------------------
# Finished games on a date

# One season's finished games: game_id, date, phase, away, home (sdvplotR keys), scores
finals <- function(league, season) {
  g <- switch(league,
    nfl = {
      s <- quietly(nflreadr::load_schedules(season))
      s <- s[!is.na(s$result), ]
      data.frame(
        game_id = s$game_id, date = as.Date(s$gameday), phase = ifelse(s$game_type == "REG", "", "postseason"),
        away = s$away_team, home = s$home_team, away_score = s$away_score, home_score = s$home_score
      )
    },
    nba = ,
    wnba = {
      load <- if (league == "nba") hoopR::load_nba_schedule else wehoop::load_wnba_schedule
      s <- quietly(load(seasons = season))
      s <- s[s$status_type_completed %in% TRUE & s$type_abbreviation != "ALLSTAR", ]
      data.frame(
        game_id = as.character(s$game_id), date = as.Date(s$game_date),
        phase = c("1" = "preseason", "2" = "", "3" = "postseason", "5" = "play-in")[as.character(s$season_type)],
        away = s$away_abbreviation, home = s$home_abbreviation,
        away_score = as.integer(s$away_score), home_score = as.integer(s$home_score)
      )
    },
    nhl = {
      s <- quietly(fastRhockey::load_nhl_schedule(seasons = season))
      s <- s[s$game_state %in% c("OFF", "FINAL"), ]
      data.frame(
        game_id = as.character(s$game_id), date = as.Date(s$game_date),
        phase = c("1" = "preseason", "2" = "", "3" = "postseason")[as.character(nhl_type(s$game_id))],
        away = s$away_team_abbr, home = s$home_team_abbr, away_score = s$away_score, home_score = s$home_score
      )
    },
    mlb = {
      s <- quietly(baseballr::mlb_schedule(season = season, level_ids = "1"))
      s <- s[s$game_type %in% c("R", "F", "D", "L", "W") & s$status_abstract_game_state %in% "Final" &
        !is.na(s$teams_home_score), ]
      clubs <- quietly(baseballr::mlb_teams(season = season, sport_ids = 1))
      abbr <- function(id) clubs$team_abbreviation[match(id, clubs$team_id)]
      data.frame(
        game_id = as.character(s$game_pk), date = as.Date(s$official_date),
        phase = ifelse(s$game_type == "R", "", "postseason"),
        away = abbr(s$teams_away_team_id), home = abbr(s$teams_home_team_id),
        away_score = s$teams_away_score, home_score = s$teams_home_score
      )
    }
  )
  if (NROW(g) == 0) {
    return(NULL)
  }
  g$phase[is.na(g$phase)] <- ""
  g$away <- sdvplotR::clean_team_abbrs(g$away, sport = league, keep_non_matches = FALSE)
  g$home <- sdvplotR::clean_team_abbrs(g$home, sport = league, keep_non_matches = FALSE)
  g <- g[!is.na(g$away) & !is.na(g$home), ] # All-Star and exhibition sides are not franchises
  g[order(g$date, g$game_id), ]
}

#' The finished games on `day`; with none, those of the most recent earlier day that has some,
#' this season or up to two seasons back. Returns list(day, games, note).
fetch_games <- function(league, day) {
  season <- season_of(league, day)
  for (year in c(season, season - 1, season - 2)) {
    g <- finals(league, year)
    if (NROW(g)) g <- g[g$date <= day, , drop = FALSE]
    if (NROW(g)) break
  }
  if (!NROW(g)) stop(no_data(sprintf("no finished %s games on or before %s", league, day)))
  used <- max(g$date)
  note <- if (used != day) {
    sprintf("No %s games finished on %s, so these are from %s.", LEAGUES[[league]]$tag, long_date(day), long_date(used))
  }
  list(day = used, games = g[g$date == used, ], note = note, season = year)
}

# ------------------------------------------------------------------------------------------
# Player of the game: a simple, documented rule per sport (change it to taste)

extra <- function(n, label) if (n > 0) sprintf(" · %d %s", n, label) else "" # " · 2 TD", or nothing
num <- function(df, ...) {
  for (col in c(...)) if (col %in% names(df)) {
    return(as.numeric(ifelse(is.na(df[[col]]), 0, df[[col]])))
  }
  rep(0, nrow(df))
}

# Every player in the games with a rule score and up to three stat lines; NULL for MLB, whose
# box scores have no release file (the cards still post)
fetch_box <- function(league, games, season) {
  ids <- games$game_id
  if (league == "nfl") {
    # standard fantasy points, as nflverse computes them
    p <- quietly(nflreadr::load_player_stats(season, summary_level = "week"))
    p <- p[p$game_id %in% ids, ]
    if (!NROW(p)) {
      return(NULL)
    }
    lines <- lapply(seq_len(nrow(p)), function(i) {
      r <- p[i, ]
      out <- character()
      if (num(r, "attempts") > 0) {
        out <- c(out, sprintf(
          "%d/%d · %d PASS YDS · %d TD%s", num(r, "completions"), num(r, "attempts"), num(r, "passing_yards"),
          num(r, "passing_tds"), extra(num(r, "passing_interceptions"), "INT")
        ))
      }
      if (num(r, "carries") > 0 && (num(r, "rushing_yards") >= 20 || num(r, "rushing_tds") > 0 || !length(out))) {
        out <- c(out, sprintf(
          "%d CAR · %d RUSH YDS%s", num(r, "carries"), num(r, "rushing_yards"), extra(num(r, "rushing_tds"), "TD")
        ))
      }
      if (num(r, "receptions") > 0) {
        out <- c(out, sprintf(
          "%d REC · %d REC YDS%s", num(r, "receptions"), num(r, "receiving_yards"), extra(num(r, "receiving_tds"), "TD")
        ))
      }
      out
    })
    return(data.frame(
      game_id = p$game_id, team = sdvplotR::clean_team_abbrs(p$team, sport = "nfl"), id = p$player_id,
      id_type = "gsis", name = p$player_display_name, position = p$position, score = num(p, "fantasy_points"),
      lines = I(lines)
    ))
  }
  if (league %in% c("nba", "wnba")) {
    load <- if (league == "nba") hoopR::load_nba_player_box else wehoop::load_wnba_player_box
    p <- quietly(load(seasons = season))
    p <- p[p$game_id %in% as.integer(ids) & !p$did_not_play, ]
    if (!NROW(p)) {
      return(NULL)
    }
    # John Hollinger's game score
    score <- num(p, "points") + 0.4 * num(p, "field_goals_made") - 0.7 * num(p, "field_goals_attempted") -
      0.4 * (num(p, "free_throws_attempted") - num(p, "free_throws_made")) + 0.7 * num(p, "offensive_rebounds") +
      0.3 * num(p, "defensive_rebounds") + num(p, "steals") + 0.7 * num(p, "assists") + 0.7 * num(p, "blocks") -
      0.4 * num(p, "fouls") - num(p, "turnovers")
    lines <- lapply(seq_len(nrow(p)), function(i) {
      r <- p[i, ]
      big <- c(STL = num(r, "steals"), BLK = num(r, "blocks"))
      big <- big[big >= 3]
      paste(c(
        sprintf("%d PTS · %d REB · %d AST", num(r, "points"), num(r, "rebounds"), num(r, "assists")),
        sprintf("%d %s", big, names(big))
      ), collapse = " · ")
    })
    return(data.frame(
      game_id = as.character(p$game_id), team = sdvplotR::clean_team_abbrs(p$team_abbreviation, sport = league),
      id = as.character(p$athlete_id), id_type = "espn", name = p$athlete_display_name,
      position = p$athlete_position_abbreviation, score = score, lines = I(lines)
    ))
  }
  if (league == "nhl") {
    p <- quietly(fastRhockey::load_nhl_player_box(seasons = season))
    p <- p[as.character(p$game_id) %in% ids, ]
    if (!NROW(p)) {
      return(NULL)
    }
    full <- quietly(fastRhockey::load_nhl_game_rosters(seasons = season))
    name <- full$full_name[match(p$player_id, full$player_id)]
    # a simplified Dom Luszczyszyn game score: goals, assists, shots and blocks (skaters only)
    g <- num(p, "goals")
    a <- num(p, "assists")
    sog <- num(p, "shots_on_goal")
    return(data.frame(
      game_id = as.character(p$game_id), team = sdvplotR::clean_team_abbrs(p$team_abbrev, sport = "nhl"),
      id = as.character(p$player_id), id_type = "league", name = ifelse(is.na(name), p$player_name, name),
      position = ifelse(p$position %in% c("L", "R"), paste0(p$position, "W"), p$position),
      score = 0.75 * g + 0.7 * a + 0.075 * sog + 0.05 * num(p, "blocked_shots"),
      lines = I(as.list(sprintf("%d G · %d A · %d PTS · %d SOG", g, a, g + a, sog)))
    ))
  }
  NULL
}

# ------------------------------------------------------------------------------------------
# Drawing

luminance <- function(color) {
  rgb <- grDevices::col2rgb(color)[, 1] / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  sum(c(0.2126, 0.7152, 0.0722) * lin)
}
contrast <- function(a, b) {
  l <- sort(c(luminance(a), luminance(b)))
  (l[2] + 0.05) / (l[1] + 0.05)
}
on_color <- function(bg) if (contrast("#000000", bg) >= contrast("#ffffff", bg)) "#000000" else "#ffffff"
team_color <- function(sport, team) {
  col <- unname(sdvplotR::sdv_team_colors(sport, team, type = "primary"))
  if (length(col) != 1 || is.na(col)) NEUTRAL else col
}
team_name <- function(sport, team) {
  ref <- sdvplotR::team_reference(sport)
  row <- ref[match(team, ref$team_abbr), ]
  c(location = row$team_location %||% team, mascot = row$team_mascot %||% "")
}

# A text size (in points) that keeps `text` within `width` pixels, from `size` down
# ponytail: average glyph width is a guess (0.58 em, sans bold); measure with systemfonts if it clips
fit <- function(text, width, size) min(size, width / (0.58 * 100 / 72 * max(nchar(text), 1)))

# A canvas whose data coordinates are its pixels, on the dark background
canvas <- function(w, h) {
  ggplot2::ggplot() +
    ggplot2::coord_cartesian(xlim = c(0, w), ylim = c(0, h), expand = FALSE) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = BG, colour = NA),
      plot.margin = ggplot2::margin(0, 0, 0, 0)
    )
}
txt <- function(x, y, label, size, colour = INK, face = "plain", hjust = 0.5, alpha = 1) {
  ggplot2::annotate("text",
    x = x, y = y, label = label, size = size / ggplot2::.pt, colour = colour,
    fontface = face, hjust = hjust, vjust = 0.5, alpha = alpha
  )
}
disc <- function(x, y, r, fill = "#ffffff") {
  t <- seq(0, 2 * pi, length.out = 120)
  ggplot2::annotate("polygon", x = x + r * cos(t), y = y + r * sin(t), fill = fill)
}
# a team-color panel, outlined when the color is too close to the background to show its edge
panel <- function(x0, y0, x1, y1, fill) {
  ggplot2::annotate("rect",
    xmin = x0, ymin = y0, xmax = x1, ymax = y1, fill = fill,
    colour = if (contrast(fill, BG) < 1.5) NEUTRAL else NA, linewidth = 1
  )
}
logo <- function(sport, team, x, y, height, alpha = 1) {
  sdvplotR::geom_sdv_logos(
    data = data.frame(x = x, y = y, team = team), ggplot2::aes(x = x, y = y, team = team),
    sport = sport, height = height, alpha = alpha, inherit.aes = FALSE
  )
}
save_png <- function(plot, path, size) {
  ggplot2::ggsave(path, plot, width = size[1] / 100, height = size[2] / 100, dpi = 100, bg = BG)
  list(path = basename(path), width = size[1], height = size[2])
}
# sdvplotR's id_type: NULL is the sport's default (GSIS ids for the NFL)
as_id_type <- function(x) if (identical(x, "gsis")) NULL else x
phase_label <- function(phase) if (nzchar(phase)) toupper(gsub("-", "", phase)) else ""

score_card <- function(game, league, day, path) {
  size <- SIZES$landscape
  w <- size[1]
  tag <- LEAGUES[[league]]$tag
  header <- paste(c("FINAL", phase_label(game$phase)[nzchar(phase_label(game$phase))]), collapse = "  ·  ")
  p <- canvas(w, size[2]) +
    txt(32, 636, header, 20, face = "bold", hjust = 0) +
    txt(w - 32, 636, paste(tag, " · ", long_date(day)), 15, MUTED, hjust = 1)
  for (side in c("away", "home")) {
    x0 <- if (side == "away") 24 else w / 2 + 12
    pw <- w / 2 - 36
    cx <- x0 + pw / 2
    team <- game[[side]]
    fill <- team_color(league, team)
    ink <- on_color(fill)
    nm <- team_name(league, team)
    other <- if (side == "away") "home" else "away"
    won <- game[[paste0(side, "_score")]] > game[[paste0(other, "_score")]] # a tie bolds neither
    p <- p + panel(x0, 84, x0 + pw, 572, fill) + disc(cx, 464, 92) +
      logo(league, team, cx, 464, 1.25 * 92 / size[2]) +
      txt(cx, 342, nm[["location"]], fit(nm[["location"]], pw - 40, 20), ink) +
      txt(cx, 294, toupper(nm[["mascot"]]), fit(nm[["mascot"]], pw - 40, 30), ink, face = "bold") +
      txt(cx, 172, game[[paste0(side, "_score")]], 104, ink,
        face = if (won) "bold" else "plain", alpha = if (won) 1 else 0.7
      )
  }
  p <- p + txt(32, 40, CREDIT, 12, MUTED, hjust = 0) + txt(w - 32, 40, paste0("#", tag), 12, MUTED, hjust = 1)
  save_png(p, path, size)
}

potg_card <- function(player, game, league, day, path) {
  size <- SIZES$square
  w <- size[1]
  tag <- LEAGUES[[league]]$tag
  team <- player$team
  nm <- team_name(league, team)
  p <- canvas(w, size[2]) +
    txt(60, 1010, "PLAYER OF THE GAME", 30, face = "bold", hjust = 0) +
    txt(w - 60, 1010, paste(tag, " · ", short_date(day)), 17, MUTED, hjust = 1) +
    panel(60, 460, w - 60, 950, team_color(league, team)) +
    logo(league, team, w - 250, 705, 0.36, alpha = 0.22) +
    # ESPN and the leagues serve their headshots at 600 x 436 or so: this draws them near full size
    sdvplotR::geom_sdv_headshots(
      data = data.frame(x = 400, y = 460 + 0.42 * size[2] / 2, id = player$id),
      ggplot2::aes(x = x, y = y, player_id = id), sport = league, id_type = as_id_type(player$id_type),
      height = 0.42, inherit.aes = FALSE
    )
  meta <- c(player$position, paste(nm[["location"]], nm[["mascot"]]))
  meta <- paste(meta[!is.na(meta) & nzchar(meta)], collapse = "  ·  ")
  p <- p + txt(60, 380, player$name, fit(player$name, w - 120, 64), face = "bold", hjust = 0) +
    txt(62, 312, meta, fit(meta, w - 120, 24), MUTED, hjust = 0)
  lines <- utils::head(unlist(player$lines), 3)
  for (i in seq_along(lines)) {
    p <- p + txt(62, 244 - 46 * (i - 1), lines[i], fit(lines[i], w - 120, 30), face = "bold", hjust = 0)
  }
  result <- sprintf("%s %d, %s %d  ·  Final", game$away, game$away_score, game$home, game$home_score)
  p <- p + txt(62, 82, result, 19, MUTED, hjust = 0) +
    txt(62, 34, CREDIT, 12, MUTED, hjust = 0) + txt(w - 60, 34, paste0("#", tag), 12, MUTED, hjust = 1)
  save_png(p, path, size)
}

leaderboard_image <- function(leaders, league, size, today, path) {
  f <- leaders$frame
  tag <- LEAGUES[[league]]$tag
  table <- data.frame(
    rank = f$rank, headshot = f$id, name = f$name,
    sub = trimws(paste(ifelse(nzchar(f$position), paste(f$position, "·"), ""), f$team)),
    team = f$team, logo = f$team, display = f$display
  )
  when <- if (leaders$to_date) paste("through", sub(", \\d{4}$", "", short_date(leaders$through))) else "final"
  gt <- gt::gt(table, id = "leaders") |>
    gt::tab_header(
      title = paste(tag, tolower(leaders$label), "leaders"),
      subtitle = paste(season_label(league, leaders$season), "regular season,", when)
    ) |>
    gt::cols_label(rank = "", headshot = "", name = "Player", logo = "", display = leaders$label) |>
    gt::cols_align("center", c(rank, logo, display)) |>
    gt::tab_source_note(CREDIT)
  if (!is.null(leaders$note)) gt <- gt::tab_source_note(gt, leaders$note)
  gt <- gt |>
    sdvplotR::gt_merge_stack_team_color(name, sub, team, sport = league) |>
    gt::cols_hide(team) |>
    sdvplotR::gt_sdv_headshots(headshot, sport = league, id_type = as_id_type(f$id_type[1]), height = 52) |>
    sdvplotR::gt_sdv_logos(logo, sport = league, height = 40) |>
    sdvplotR::gt_theme_sdv_team(team = f$team[1], sport = league, density = "social", table.width = gt::px(760))
  px <- SIZES[[size]]
  sdvplotR::gt_social_crop(gt, path,
    aspect_ratio = paste(px, collapse = ":"), bg = team_color(league, f$team[1]),
    whitespace = 48, width = px[1]
  )
  dims <- dim(magick::image_read(path))[2:3] # an even ratio can still round a pixel off
  list(path = basename(path), width = dims[1], height = dims[2])
}

# ------------------------------------------------------------------------------------------
# Manifest

write_manifest <- function(out, posts) {
  path <- file.path(out, "manifest.json")
  old <- if (file.exists(path)) jsonlite::read_json(path)$posts else list()
  threads <- vapply(posts, `[[`, "", "thread")
  keep <- Filter(function(p) !p$thread %in% threads, old) # a re-run replaces its own posts
  manifest <- list(version = 1, date = basename(out), posts = c(keep, posts))
  jsonlite::write_json(manifest, path, auto_unbox = TRUE, pretty = TRUE)
  path
}

run_leaderboard <- function(args, today = Sys.Date()) {
  league <- args$league
  top <- args$top %||% if (args$size == "square") 10 else 5
  leaders <- fetch_leaders(league, args$stat, args$season, top, today)
  out <- file.path(args$out, format(today))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  name <- sprintf("%s-leaders-%s-%s", league, slug(leaders$stat), args$size)
  image <- leaderboard_image(leaders, league, args$size, today, file.path(out, paste0(name, ".png")))
  tag <- LEAGUES[[league]]$tag
  label <- season_label(league, leaders$season)
  f <- leaders$frame
  image$alt <- sprintf(
    "Table of the %s %s leaders, %s regular season: %s.", tag, tolower(leaders$label), label,
    paste(sprintf("%d. %s %s", f$rank, f$name, f$display), collapse = "; ")
  )
  when <- if (leaders$to_date) paste("through", sub(", \\d{4}$", "", short_date(leaders$through))) else "final"
  caption <- sprintf(
    "%s %s leaders, %s regular season (%s): %s leads with %s.%s", tag, tolower(leaders$label), label, when,
    f$name[1], f$display[1], if (is.null(leaders$note)) "" else paste0(" ", leaders$note)
  )
  # fresh while the season is under way (a new date each run); a final season is the same table every week
  key <- sprintf(
    "%s-leaderboard-%s-%s-%d%s", league, slug(leaders$stat), args$size, leaders$season,
    if (leaders$to_date) paste0("-", leaders$through) else ""
  )
  post <- list(
    key = key, fresh = leaders$to_date, thread = name, league = league, kind = "leaderboard",
    caption = caption, hashtags = list(tag, "sdvplotR"), images = list(image)
  )
  write_manifest(out, list(post))
}

#' The first post's caption; a slate cut by --max-games says how many of its games it shows
gameday_caption <- function(tag, phase, day, drawn, total) {
  sprintf(
    "%s %sfinal scores, %s%s.", tag, if (nzchar(phase)) paste0(phase, " ") else "", long_date(day),
    if (drawn < total) sprintf(" (%d of %d games)", drawn, total) else ""
  )
}

winners <- function(game) {
  c(if (game$away_score >= game$home_score) game$away, if (game$home_score >= game$away_score) game$home)
}

run_gameday <- function(args, today = Sys.Date()) {
  league <- args$league
  tag <- LEAGUES[[league]]$tag
  found <- fetch_games(league, args$date)
  day <- found$day
  games <- found$games
  out <- file.path(args$out, format(today))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  stem <- sprintf("%s-%s", league, format(day, "%Y%m%d"))
  drawn <- min(nrow(games), args$max_games %||% nrow(games)) # every game unless --max-games caps it
  cards <- lapply(seq_len(drawn), function(i) {
    g <- games[i, ]
    file <- sprintf("%s-%s-at-%s-%s.png", stem, slug(g$away), slug(g$home), slug(g$game_id)) # the id: doubleheaders
    image <- score_card(g, league, day, file.path(out, file))
    a <- team_name(league, g$away)
    h <- team_name(league, g$home)
    image$alt <- sprintf(
      "Final score card, %s, %s: %s %s %d, %s %s %d, with both team logos.", tag, long_date(day),
      a[["location"]], a[["mascot"]], g$away_score, h[["location"]], h[["mascot"]], g$home_score
    )
    image
  })
  box <- fetch_box(league, games, found$season) # every final, drawn or not
  best <- NULL # the best rule score on a team that did not lose, across all of the day's finals
  if (NROW(box)) {
    for (i in seq_len(nrow(games))) {
      g <- games[i, ]
      b <- box[box$game_id == g$game_id & box$team %in% winners(g), ]
      b <- b[order(-b$score, b$id), ]
      if (NROW(b) && (is.null(best) || b$score[1] > best$player$score)) best <- list(player = b[1, ], game = g)
    }
  }
  phase <- games$phase[1]
  caption <- gameday_caption(tag, phase, day, drawn, nrow(games))
  images <- cards
  if (!is.null(best)) {
    pl <- best$player
    g <- best$game
    potg <- potg_card(pl, g, league, day, file.path(out, paste0(stem, "-player-of-the-game.png")))
    line <- paste(unlist(pl$lines), collapse = "; ")
    potg$alt <- sprintf(
      "Player of the game card with a headshot: %s, %s, %s: %s. Final: %s %d, %s %d.",
      pl$name, pl$position, paste(team_name(league, pl$team), collapse = " "), line,
      g$away, g$away_score, g$home, g$home_score
    )
    images <- c(list(potg), cards)
    caption <- paste0(caption, sprintf(" Player of the game: %s, %s.", pl$name, line))
  }
  if (!is.null(found$note)) caption <- paste(caption, found$note)
  chunks <- split(images, ceiling(seq_along(images) / MAX_IMAGES))
  posts <- lapply(seq_along(chunks), function(i) {
    list(
      key = sprintf("%s-gameday-%s-%d", league, day, i),
      fresh = is.null(found$note), # a substituted date (the offseason) is old news
      thread = stem, league = league, kind = "gameday",
      caption = if (i == 1) {
        caption
      } else {
        sprintf("More %s final scores, %s (%d/%d).", tag, long_date(day), i, length(chunks))
      },
      hashtags = list(tag, "sdvplotR"), images = unname(chunks[[i]])
    )
  })
  write_manifest(out, posts)
}

# ------------------------------------------------------------------------------------------
# Posting

# Approximate grapheme count: combining marks, variation selectors and joiners do not count.
# ponytail: overcounts emoji ZWJ sequences, so the 300 limit errs safe; use stringi's
# grapheme boundaries if captions carry many emoji
NOT_GRAPHEMES <- paste0("[\\p{M}", "‍︎️", "]") # non-ASCII, so PCRE runs in UTF-8 mode
graphemes <- function(text) nchar(gsub(NOT_GRAPHEMES, "", enc2utf8(text), perl = TRUE), type = "chars")

post_text <- function(post) {
  tags <- paste0("#", unlist(post$hashtags), collapse = " ")
  caption <- post$caption
  if (graphemes(paste0(caption, "\n\n", tags)) > MAX_GRAPHEMES) {
    caption <- paste0(trimws(substr(caption, 1, max(0, MAX_GRAPHEMES - graphemes(tags) - 3)), "right"), "…")
  }
  trimws(paste0(caption, "\n\n", tags))
}

check_post <- function(post, base) {
  images <- post$images
  if (length(images) < 1 || length(images) > MAX_IMAGES) {
    stop(sprintf("post '%s' has %d images; Bluesky takes 1 to %d", post$key, length(images), MAX_IMAGES), call. = FALSE)
  }
  for (image in images) {
    if (!file.exists(file.path(base, image$path))) {
      stop(sprintf("image '%s' is not in %s", image$path, base), call. = FALSE)
    }
    if (!nzchar(image$alt %||% "")) stop(sprintf("image '%s' has no alt text", image$path), call. = FALSE)
  }
  if (graphemes(post_text(post)) > MAX_GRAPHEMES) {
    stop(sprintf("post '%s' is over %d graphemes even shortened", post$key, MAX_GRAPHEMES), call. = FALSE)
  }
  invisible(TRUE)
}

#' Rich-text facets that make each #tag a link: byte offsets into the UTF-8 text
hashtag_facets <- function(text) {
  text <- enc2utf8(text)
  m <- gregexpr("(?:^|\\s)(#[A-Za-z][A-Za-z0-9_]*)", text, perl = TRUE, useBytes = TRUE)[[1]]
  if (m[1] == -1) {
    return(list())
  }
  start <- attr(m, "capture.start")[, 1] - 1L # 0-based
  len <- attr(m, "capture.length")[, 1]
  bytes <- charToRaw(text)
  lapply(seq_along(start), function(i) {
    list(
      index = list(byteStart = start[i], byteEnd = start[i] + len[i]),
      features = list(list(
        `$type` = "app.bsky.richtext.facet#tag",
        tag = rawToChar(bytes[(start[i] + 2):(start[i] + len[i])]) # skip the "#"
      ))
    )
  })
}

#' The image as PNG bytes, or re-encoded as a JPEG when the PNG is over Bluesky's 1 MB blob limit
image_bytes <- function(path) {
  if (file.size(path) <= MAX_BLOB) {
    return(list(data = readBin(path, "raw", file.size(path)), type = "image/png"))
  }
  img <- magick::image_background(magick::image_read(path), "white")
  for (quality in c(92, 85, 75, 65)) {
    data <- magick::image_write(img, format = "jpeg", quality = quality)
    if (length(data) <= MAX_BLOB) {
      return(list(data = data, type = "image/jpeg"))
    }
  }
  stop(sprintf("%s is over 1 MB even as a JPEG", basename(path)), call. = FALSE)
}

TRIES <- 4 # attempts per Bluesky call

# How long to wait after a 429: until Bluesky's ratelimit-reset (else its retry-after, else 5 s),
# at least a second and at most a minute
rate_limit_wait <- function(resp) {
  reset <- httr2::resp_header(resp, "ratelimit-reset")
  wait <- if (is.null(reset)) {
    as.numeric(httr2::resp_header(resp, "retry-after") %||% 5)
  } else {
    as.numeric(reset) - as.numeric(Sys.time())
  }
  min(max(wait, 1), 60)
}

#' A Bluesky (AT Protocol) client: the three calls a post needs, over httr2. `perform` sends a
#' request and `sleep` waits between tries; tests pass fakes of both.
bluesky <- function(service = "https://bsky.social", perform = httr2::req_perform, sleep = Sys.sleep) {
  env <- new.env()
  env$service <- sub("/+$", "", service)
  env$jwt <- NULL
  env$did <- NULL

  # A 429 means the request was refused, so a retry is always safe: it waits out the rate limit.
  # With `retry`, 5xx answers and dropped or timed-out connections are retried too, after 1, 2 and
  # 4 s; without it (createRecord) they end the call as ambiguous, since the post may exist.
  env$call <- function(method, json = NULL, raw = NULL, type = NULL, retry = TRUE) {
    req <- httr2::request(paste0(env$service, "/xrpc/", method)) |>
      httr2::req_method("POST") |>
      httr2::req_timeout(60) |>
      httr2::req_error(is_error = function(resp) FALSE)
    if (!is.null(env$jwt)) req <- httr2::req_auth_bearer_token(req, env$jwt)
    req <- if (is.null(raw)) {
      httr2::req_body_json(req, json, auto_unbox = TRUE)
    } else {
      httr2::req_body_raw(req, raw, type = type)
    }
    maybe <- "; it may have been posted: check the account before posting it again"
    for (attempt in seq_len(TRIES)) {
      last <- attempt == TRIES
      # a failed request's message can name hosts or carry the body, so it is never shown
      resp <- tryCatch(perform(req), error = function(e) NULL)
      if (is.null(resp)) {
        if (retry && !last) {
          sleep(2^(attempt - 1))
          next
        }
        stop(post_error(
          paste0(method, ": network error", if (retry) sprintf(" after %d tries", TRIES) else maybe),
          ambiguous = !retry
        ))
      }
      status <- httr2::resp_status(resp)
      if (status == 429 && !last) {
        wait <- rate_limit_wait(resp)
        message(sprintf("rate limited by Bluesky; waiting %.0f s", wait))
        sleep(wait)
        next
      }
      if (status >= 500 && retry && !last) {
        sleep(2^(attempt - 1))
        next
      }
      break
    }
    if (status >= 400) {
      body <- tryCatch(httr2::resp_body_json(resp), error = function(e) list())
      ambiguous <- status >= 500 && !retry
      stop(post_error(trimws(paste0(
        method, ": HTTP ", status, " ", body$error %||% "", " ", body$message %||% "", if (ambiguous) maybe else ""
      )), ambiguous = ambiguous))
    }
    httr2::resp_body_json(resp)
  }
  env$login <- function(handle, app_password) {
    out <- env$call("com.atproto.server.createSession", json = list(identifier = handle, password = app_password))
    env$jwt <- out$accessJwt
    env$did <- out$did
    invisible(env)
  }
  # upload a post's images; their embeds carry the alt text and aspect ratio
  env$upload <- function(images, base) {
    lapply(images, function(image) {
      bytes <- image_bytes(file.path(base, image$path))
      blob <- env$call("com.atproto.repo.uploadBlob", raw = bytes$data, type = bytes$type)$blob
      list(image = blob, alt = image$alt, aspectRatio = list(width = image$width, height = image$height))
    })
  }
  # create the post; `reply` = list(root, parent) refs. Never retried after an ambiguous failure.
  env$create <- function(text, embeds, reply = NULL) {
    record <- list(
      `$type` = "app.bsky.feed.post", text = text, facets = hashtag_facets(text), langs = list("en"),
      createdAt = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3Z", tz = "UTC"),
      embed = list(`$type` = "app.bsky.embed.images", images = embeds)
    )
    if (!is.null(reply)) record$reply <- list(root = reply[[1]], parent = reply[[2]])
    out <- env$call("com.atproto.repo.createRecord",
      json = list(repo = env$did, collection = "app.bsky.feed.post", record = record), retry = FALSE
    )
    list(uri = out$uri, cid = out$cid)
  }
  env
}

newest_manifest <- function(out) {
  found <- sort(Sys.glob(file.path(out, "*", "manifest.json")))
  if (!length(found)) stop(post_error(sprintf("no manifest.json under %s; run leaderboard or gameday first", out)))
  found[length(found)]
}

#' Why each post is skipped, or NA to post it. A thread with a post left out stops there.
#' `expired`: the manifest is old, so even its fresh posts are stale now.
skip_reasons <- function(posts, ledger, include_stale = FALSE, expired = FALSE) {
  broken <- character()
  vapply(posts, function(post) {
    entry <- ledger[[post$key]]
    reason <- NA_character_
    if (identical(entry$status, "posted")) {
      reason <- sprintf("already posted (%s)", entry$uri)
    } else if (!is.null(entry)) {
      reason <- sprintf(paste(
        "pending (an earlier attempt may have posted it; check the account, then delete '%s'",
        "from the ledger to try again)"
      ), post$key)
    } else if (post$thread %in% broken) {
      reason <- "an earlier post of its thread was not posted"
    } else if ((expired || !isTRUE(post$fresh)) && !include_stale) {
      reason <- paste0("stale", if (expired) " (an old manifest)" else "", "; pass --include-stale to post it")
    }
    if (!is.na(reason) && !identical(entry$status, "posted")) broken <<- c(broken, post$thread)
    reason
  }, character(1))
}

write_ledger <- function(path, ledger) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (!length(ledger)) ledger <- structure(list(), names = character()) # {} rather than []
  jsonlite::write_json(ledger, path, auto_unbox = TRUE, pretty = TRUE)
}

run_post <- function(args, perform = NULL, sleep = Sys.sleep, today = Sys.Date()) {
  manifest_path <- args$manifest %||% newest_manifest(args$out)
  base <- dirname(manifest_path)
  ledger_path <- args$ledger %||% file.path(dirname(base), "posted.json")
  ledger <- if (file.exists(ledger_path)) jsonlite::read_json(ledger_path) else list()
  manifest <- jsonlite::read_json(manifest_path)
  posts <- manifest$posts
  for (post in posts) check_post(post, base)
  # a manifest made before yesterday is old news, however fresh its posts were then
  made <- as.Date(manifest$date %||% NA_character_, optional = TRUE)
  expired <- is.na(made) || made < today - 1
  reasons <- skip_reasons(posts, ledger, args$include_stale, expired)
  if (!args$post) {
    cat(sprintf("[dry-run] %d post(s) from %s; nothing sent (add --post to publish)\n", length(posts), manifest_path))
    for (i in seq_along(posts)) {
      post <- posts[[i]]
      text <- post_text(post)
      cat(sprintf(
        "\n--- post %d/%d, %s: %s (%d/%d graphemes)\n%s\n", i, length(posts), post$key,
        if (is.na(reasons[i])) "would post" else paste("skipped:", reasons[i]), graphemes(text), MAX_GRAPHEMES, text
      ))
      for (image in post$images) {
        cat(sprintf(
          "  [image] %s %dx%d %.0f KB\n    alt: %s\n", image$path, image$width, image$height,
          file.size(file.path(base, image$path)) / 1000, image$alt
        ))
      }
    }
    return(invisible(reasons))
  }
  for (i in which(!is.na(reasons))) cat(sprintf("%s: skipped: %s\n", posts[[i]]$key, reasons[i]))
  if (all(!is.na(reasons))) {
    return(invisible(reasons)) # nothing to post: no login
  }
  if (identical(Sys.getenv("GITHUB_REPOSITORY"), GITHUB_REPO)) {
    stop(post_error(sprintf(
      "refusing to post from %s's own GitHub Actions; copy the template to your repository", GITHUB_REPO
    )))
  }
  handle <- Sys.getenv("BSKY_HANDLE")
  password <- Sys.getenv("BSKY_APP_PASSWORD")
  if (!nzchar(handle) || !nzchar(password)) {
    stop(post_error("set BSKY_HANDLE and BSKY_APP_PASSWORD (a Bluesky app password) to post"))
  }
  service <- Sys.getenv("BSKY_SERVICE")
  client <- bluesky(if (nzchar(service)) service else "https://bsky.social", perform %||% httr2::req_perform, sleep)
  client$login(handle, password)
  threads <- list() # thread -> list(root, latest) refs
  for (i in seq_along(posts)) {
    post <- posts[[i]]
    key <- post$key
    if (!is.na(reasons[i])) {
      entry <- ledger[[key]]
      if (identical(entry$status, "posted")) { # a later post of this thread replies to it
        ref <- list(uri = entry$uri, cid = entry$cid)
        threads[[post$thread]] <- list(threads[[post$thread]][[1]] %||% ref, ref)
      }
      next
    }
    embeds <- client$upload(post$images, base)
    now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    ledger[[key]] <- list(status = "pending", at = now) # recorded first, so an unclear failure is never re-sent
    write_ledger(ledger_path, ledger)
    ref <- tryCatch(client$create(post_text(post), embeds, threads[[post$thread]]), post_error = function(e) {
      if (!isTRUE(e$ambiguous)) { # Bluesky refused it: nothing was posted, so a re-run may try again
        ledger[[key]] <<- NULL
        write_ledger(ledger_path, ledger)
      }
      stop(e)
    })
    ledger[[key]] <- list(status = "posted", uri = ref$uri, cid = ref$cid, at = now)
    write_ledger(ledger_path, ledger) # after every post, so a thread that fails partway resumes there
    threads[[post$thread]] <- list(threads[[post$thread]][[1]] %||% ref, ref)
    cat(sprintf("%s: posted %s\n", key, ref$uri))
  }
  invisible(reasons)
}

# ------------------------------------------------------------------------------------------
# CLI

USAGE <- paste(
  "usage: Rscript sdvplotR_social.R <command> [options]",
  "",
  "commands:",
  "  leaderboard  --league L [--stat S] [--season N] [--top N] [--size square|landscape]",
  "  gameday      --league L [--date YYYY-MM-DD] [--max-games N]",
  "  post         [--manifest PATH] [--ledger PATH] [--post] [--include-stale]",
  "",
  "every command takes --out DIR (default out); files go to <out>/<today>/",
  "leagues: nfl, nba, wnba, mlb, nhl",
  sep = "\n"
)
OPTIONS <- list(
  leaderboard = c("league", "stat", "season", "top", "size", "out"),
  gameday = c("league", "date", "max-games", "out"),
  post = c("manifest", "ledger", "post", "include-stale", "out", "network")
)
FLAGS <- c("post", "include-stale")

usage_error <- function(message) {
  structure(class = c("usage_error", "error", "condition"), list(message = message, call = NULL))
}

parse_args <- function(argv, today = Sys.Date()) {
  if (!length(argv) || argv[1] %in% c("-h", "--help")) stop(usage_error(USAGE))
  command <- argv[1]
  if (!command %in% names(OPTIONS)) stop(usage_error(sprintf("unknown command '%s'\n%s", command, USAGE)))
  opts <- list()
  rest <- argv[-1]
  i <- 1
  while (i <= length(rest)) {
    arg <- rest[i]
    if (!startsWith(arg, "--")) stop(usage_error(sprintf("unexpected argument '%s'", arg)))
    name <- sub("^--", "", sub("=.*$", "", arg))
    if (!name %in% OPTIONS[[command]]) stop(usage_error(sprintf("%s does not take --%s", command, name)))
    if (name %in% FLAGS) {
      opts[[name]] <- TRUE
    } else if (grepl("=", arg)) {
      opts[[name]] <- sub("^[^=]*=", "", arg)
    } else {
      if (i == length(rest)) stop(usage_error(sprintf("--%s needs a value", name)))
      i <- i + 1
      opts[[name]] <- rest[i]
    }
    i <- i + 1
  }
  count <- function(name, default = NULL) {
    if (is.null(opts[[name]])) {
      return(default)
    }
    n <- suppressWarnings(as.integer(opts[[name]]))
    if (is.na(n) || n < 1) stop(usage_error(sprintf("--%s must be a whole number of at least 1", name)))
    n
  }
  args <- list(
    command = command, out = opts$out %||% "out", league = opts$league, stat = opts$stat,
    season = count("season"), top = count("top"), size = opts$size %||% "square",
    max_games = count("max-games"), manifest = opts$manifest, ledger = opts$ledger,
    post = isTRUE(opts$post), include_stale = isTRUE(opts[["include-stale"]])
  )
  if (command != "post" && !isTRUE(args$league %in% names(LEAGUES))) {
    stop(usage_error(sprintf("--league must be one of: %s", paste(names(LEAGUES), collapse = ", "))))
  }
  if (!args$size %in% names(SIZES)) stop(usage_error("--size must be square or landscape"))
  if (!is.null(opts$network) && opts$network != "bluesky") stop(usage_error("--network must be bluesky"))
  args$date <- if (is.null(opts$date)) {
    today - 1
  } else {
    tryCatch(as.Date(opts$date, format = "%Y-%m-%d"), error = function(e) NA)
  }
  if (is.na(args$date)) stop(usage_error("--date must be YYYY-MM-DD"))
  args
}

main <- function(argv = commandArgs(trailingOnly = TRUE)) {
  t0 <- Sys.time()
  status <- tryCatch(
    {
      args <- parse_args(argv)
      if (args$command == "post") {
        run_post(args)
      } else {
        manifest <- if (args$command == "leaderboard") run_leaderboard(args) else run_gameday(args)
        cat(sprintf("wrote %s (%.1f s)\n", manifest, as.numeric(difftime(Sys.time(), t0, units = "secs"))))
      }
      0L
    },
    usage_error = function(e) {
      message(conditionMessage(e))
      if (length(argv) && argv[1] %in% c("-h", "--help")) 0L else 2L
    },
    error = function(e) {
      message("error: ", conditionMessage(e))
      1L
    }
  )
  invisible(status)
}

if (sys.nframe() == 0L) quit(status = main(), save = "no")
