# Soccer clubs for logo_ref / abbr_mapping, from sdvplot's team index (the
# same 2,631 ESPN clubs and the colors sdvplot sourced in #68: ESPN team
# colors, else colors measured from the logo). Sourced by the sysdata builder.
soccer_from_sdvplot <- function(sdvplot) {
  t <- sdvplot[sdvplot$league == "soccer", ]
  id <- as.character(t$team_id)
  rows <- data.frame(
    sport = "soccer", espn_team_id = as.integer(id), team_abbr = id, team_name = t$name,
    team_short_name = t$short_name, team_location = t$location, team_mascot = NA_character_,
    logo_url = sprintf("https://a.espncdn.com/i/teamlogos/soccer/500/%s.png", id),
    logo_dark_url = sprintf("https://a.espncdn.com/i/teamlogos/soccer/500-dark/%s.png", id),
    logo_scoreboard_url = NA_character_, wordmark_url = NA_character_,
    color1 = toupper(t$color_primary), color2 = toupper(t$color_secondary),
    conference = NA_character_, division = NA_character_, type = "team",
    color_source = t$color_source,
    stringsAsFactors = FALSE
  )
  # ids always resolve; a club name resolves only when no other club shares it
  # (416 of 2,215 names are shared, mostly a men's and a women's side)
  name <- toupper(t$name)
  shared <- name %in% name[duplicated(name)]
  aliases <- stats::setNames(c(id, id[!shared]), c(id, name[!shared]))
  ambiguous <- split(id[shared], name[shared])
  list(rows = rows, aliases = aliases, ambiguous = ambiguous)
}
