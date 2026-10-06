# ---------------------------------------------------------------------------
# Landmark frames
# ---------------------------------------------------------------------------

pitch_fixed_providers <- c("opta", "wyscout", "statsbomb", "uefa", "impect")
pitch_physical_providers <- c("tracab", "skillcorner", "secondspectrum", "metrica")
pitch_provider_aliases <- c(statsperform = "opta")

# The landmarks of a fixed-frame provider, from the shared table: x from the
# defended goal line to the attacked one, y from the attacker's right touchline
# to the left one (so a top-origin provider's y values descend).
pitch_landmarks <- function(provider) {
  path <- system.file("extdata", "pitch_landmarks.csv", package = "sdvplotR", mustWork = TRUE)
  tab <- utils::read.csv(path, comment.char = "#")
  rows <- tab[tab$provider == provider, ]
  axis <- function(a) {
    r <- rows[rows$axis == a, ]
    r$value[order(r$i)]
  }
  list(x = axis("x"), y = axis("y"))
}

# Tracking providers draw the venue's real pitch, so their landmarks come from
# the Laws of the Game's fixed distances (six-yard line 5.5 m, penalty spot
# 11 m, box 16.5 m deep; goal 7.32 m, six-yard box 18.32 m and box 40.32 m
# wide) placed on a `length` x `width` meter pitch, in the provider's units.
physical_landmarks <- function(provider, length, width) {
  along <- c(0, 5.5, 11, 16.5, length / 2, length - 16.5, length - 11, length - 5.5, length)
  half <- width / 2
  across <- c(0, half - 20.16, half - 9.16, half - 3.66, half + 3.66, half + 9.16, half + 20.16, width)
  switch(provider,
    tracab = list(x = (along - length / 2) * 100, y = (across - half) * 100),
    skillcorner = ,
    secondspectrum = list(x = along - length / 2, y = across - half),
    metrica = list(x = along / length, y = 1 - across / width)
  )
}

# Piecewise-linear from `from` to `to`, extending the end segments beyond both
# ends (stats::approx() would give NA or clamp). sdvplot's _interp() uses the
# same index and the same arithmetic, so the two packages agree to the last bit.
interp_landmarks <- function(v, from, to) {
  o <- order(from)
  from <- from[o]
  to <- to[o]
  j <- pmin(pmax(findInterval(v, from), 1L), length(from) - 1L)
  to[j] + (to[j + 1L] - to[j]) * ((v - from[j]) / (from[j + 1L] - from[j]))
}
