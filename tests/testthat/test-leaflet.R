skip_on_cran()
skip_if_not_installed("leaflet")

calls <- function(m) Filter(function(cl) cl$method == "addMarkers", m$x$calls)

test_that("logo markers carry each team's logo; a team without one keeps the default marker", {
  expect_warning(
    m <- addSdvLogoMarkers(leaflet::leaflet(), lng = c(-94.5, -78.8, 0), lat = c(39.0, 42.8, 0),
                           team = c("KC", "BUF", "nope"), league = "nfl", label = c("a", "b", "c")),
    class = "sdvplotR_unresolved_warning"
  )
  cl <- calls(m)
  expect_length(cl, 2L)
  icon <- cl[[1]]$args[[3]]
  # leaflet packs repeated strings as list(data, index), index 0-based
  expect_identical(icon$iconUrl$data[icon$iconUrl$index + 1], sdv_logo_url(c("KC", "BUF"), "nfl"))
  expect_identical(cl[[1]]$args[[1]], c(39.0, 42.8)) # leaflet stores lat first
  expect_null(cl[[2]]$args[[3]])
  expect_identical(cl[[2]]$args[[1]], 0)
})

test_that("formulas read from the map's data", {
  d <- data.frame(lon = -94.5, lat = 39.0, team = "KC")
  m <- addSdvLogoMarkers(leaflet::leaflet(d), ~lon, ~lat, ~team, league = "nfl")
  expect_length(calls(m), 1L)
})
