#' Team logo markers on a leaflet map
#'
#' @description Adds a marker per row with the team's logo as its icon. A row
#'   whose team has no logo keeps leaflet's default marker, so no point is
#'   dropped silently.
#' @param map A leaflet map.
#' @param lng,lat Longitudes and latitudes: vectors, or formulas read from `data`.
#' @param team Team identifiers: a vector, or a formula read from `data`.
#' @inheritParams sdv_logo_url
#' @param season `NULL` for today's logo, or a season (or one per row): a
#'   vector, or a formula read from `data`.
#' @param size Icon width and height, in pixels.
#' @param data The data formulas read; defaults to the map's.
#' @param ... Passed to [leaflet::addMarkers()] (`label`, `popup`, `layerId`,
#'   `group`, ...); a vector one per row is split with the rows.
#' @return The map.
#' @export
#' @examples
#' \donttest{
#' if (requireNamespace("leaflet", quietly = TRUE)) {
#'   d <- data.frame(team = c("KC", "BUF"), lon = c(-94.48, -78.79), lat = c(39.05, 42.77))
#'   leaflet::leaflet(d) |>
#'     leaflet::addTiles() |>
#'     addSdvLogoMarkers(~lon, ~lat, ~team, league = "nfl", label = ~team)
#' }
#' }
addSdvLogoMarkers <- function(map, lng, lat, team, league, size = 32, season = NULL, variant = "default",
                              id_system = "auto", strict = FALSE, data = leaflet::getMapData(map), ...) {
  rlang::check_installed("leaflet", reason = "to put team logos on a map.")
  lng <- leaflet::evalFormula(lng, data)
  lat <- leaflet::evalFormula(lat, data)
  team <- leaflet::evalFormula(team, data)
  season <- leaflet::evalFormula(season, data)
  n <- length(team)
  dots <- lapply(list(...), leaflet::evalFormula, data = data)
  # ponytail: only atomic vectors one per row (label, popup, layerId, ...) are split with the rows; lists
  # (options, popupOptions, labelOptions, icons) pass whole, since markerOptions() is a 9-element list
  # that would otherwise be cut on a 9-row map. A scalar-per-row list column would need splitting by hand.
  rows <- function(idx) lapply(dots, function(a) if (is.atomic(a) && length(a) == n && n > 1) a[idx] else a)
  urls <- logo_from_team(team, league, season = season, variant = variant, id_system = id_system, strict = strict)
  has <- !is.na(urls)
  if (any(has)) {
    icon <- leaflet::icons(
      iconUrl = urls[has], iconWidth = size, iconHeight = size, iconAnchorX = size / 2, iconAnchorY = size / 2
    )
    map <- do.call(leaflet::addMarkers, c(list(map, lng = lng[has], lat = lat[has], icon = icon), rows(has)))
  }
  if (any(!has)) {
    map <- do.call(leaflet::addMarkers, c(list(map, lng = lng[!has], lat = lat[!has]), rows(!has)))
  }
  map
}
