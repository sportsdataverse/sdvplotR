# sportyR draws every feature as polygons with a constant fill and outline
# (aes_params); those constants are the colors the built plot carries.
surface_colors <- function(p) {
  vapply(p$layers, function(l) {
    paste(l$aes_params$fill %||% "-", l$aes_params$colour %||% "-")
  }, character(1))
}
surface_data <- function(p) lapply(p$layers, function(l) l$data)

check_teams <- c(
  nba = "BOS", wnba = "LV", mbb = "DUKE", wbb = "UCONN",
  nfl = "KC", cfb = "TEX", nhl = "COL", mlb = "NYY"
)

test_that("every sport returns a ggplot", {
  skip_if_not_installed("sportyR")
  for (s in names(check_teams)) {
    expect_true(inherits(sdv_surface(s), "ggplot"), info = s)
    expect_true(inherits(sdv_surface(s, check_teams[[s]]), "ggplot"), info = s)
  }
})

test_that("team = NULL is sportyR's regulation surface", {
  skip_if_not_installed("sportyR")
  default <- list(
    nba = sportyR::geom_basketball("nba"), wnba = sportyR::geom_basketball("wnba"),
    mbb = sportyR::geom_basketball("ncaa"), nfl = sportyR::geom_football("nfl"),
    cfb = sportyR::geom_football("ncaa"), nhl = sportyR::geom_hockey("nhl"),
    mlb = sportyR::geom_baseball("mlb")
  )
  for (s in names(default)) {
    p <- sdv_surface(s)
    expect_identical(surface_colors(p), surface_colors(default[[s]]), info = s)
    expect_identical(surface_data(p), surface_data(default[[s]]), info = s)
    expect_equal(p$theme, default[[s]]$theme, info = s)
  }
})

test_that("a team recolors exactly the intended basketball and football features", {
  skip_if_not_installed("sportyR")
  lv <- sdv_team_colors("wnba", "LV")[[1]] # silver: lines in the paint stay black
  duke <- sdv_team_colors("mbb", "DUKE")[[1]] # dark: lines in the paint go white
  kc <- sdv_team_colors("nfl", "KC")[[1]]
  paint <- function(fill, ink) {
    list(
      painted_area = fill, court_apron = fill, restricted_arc = ink,
      free_throw_circle_dash = ink, lane_lower_defensive_box = ink,
      baseline_lower_defensive_box = ink
    )
  }
  cases <- list(
    list(
      sdv_surface("wnba", "LV"), sportyR::geom_basketball("wnba", color_updates = paint(lv, "#000000")),
      sportyR::geom_basketball("wnba"), lv
    ),
    list(
      sdv_surface("mbb", "DUKE"), sportyR::geom_basketball("ncaa", color_updates = paint(duke, "#FFFFFF")),
      sportyR::geom_basketball("ncaa"), duke
    ),
    list(
      sdv_surface("nfl", "KC"),
      sportyR::geom_football("nfl", color_updates = list(offensive_endzone = kc, defensive_endzone = kc)),
      sportyR::geom_football("nfl"), kc
    )
  )
  for (case in cases) {
    got <- surface_colors(case[[1]])
    expect_identical(got, surface_colors(case[[2]]))
    changed <- got != surface_colors(case[[3]])
    expect_true(any(changed))
    # every changed layer carries the team color or the contrast ink
    expect_true(all(grepl(paste0(case[[4]], "|#000000|#FFFFFF"), got[changed])))
  }
})

test_that("hockey team colors land in the built plot; baseball keeps its colors", {
  skip_if_not_installed("sportyR")
  col <- sdv_team_colors("nhl", "COL")[[1]]
  built <- function(p) {
    vapply(ggplot2::ggplot_build(p)$data, function(d) paste(d$fill[1], d$colour[1]), character(1))
  }
  got <- built(sdv_surface("nhl", "COL"))
  default <- built(sportyR::geom_hockey("nhl"))
  expected <- built(sportyR::geom_hockey("nhl", color_updates = list(
    center_line = col, center_faceoff_circle = col, center_faceoff_spot = col, boards = col
  )))
  expect_identical(got, expected)
  expect_true(all(grepl(col, got[got != default])))
  # the ice stays white
  expect_identical(sum(grepl("^#ffffff ", got)), sum(grepl("^#ffffff ", default)))

  # Nashville's gold primary is too pale on white ice: its lines take the navy
  nsh <- sdv_team_colors("nhl", "NSH", type = "all")
  nsh <- strsplit(nsh, ", ")[[1]]
  expect_identical(
    surface_colors(sdv_surface("nhl", "NSH")),
    surface_colors(sportyR::geom_hockey("nhl", color_updates = list(
      center_line = nsh[2], center_faceoff_circle = nsh[2], center_faceoff_spot = nsh[2], boards = nsh[1]
    )))
  )

  # an infield has nothing team-colored: the surface stays sportyR's
  p <- sdv_surface("mlb", "NYY")
  expect_identical(built(p), built(sportyR::geom_baseball("mlb")))
  expect_equal(p$theme, sportyR::geom_baseball("mlb")$theme)
})

test_that("color_updates in ... override the team colors", {
  skip_if_not_installed("sportyR")
  bos <- sdv_team_colors("nba", "BOS")[[1]]
  p <- sdv_surface("nba", "BOS", color_updates = list(painted_area = "#123456"))
  expected <- sportyR::geom_basketball("nba", color_updates = list(
    painted_area = "#123456", court_apron = bos, restricted_arc = "#FFFFFF",
    free_throw_circle_dash = "#FFFFFF", lane_lower_defensive_box = "#FFFFFF",
    baseline_lower_defensive_box = "#FFFFFF"
  ))
  expect_identical(surface_colors(p), surface_colors(expected))
})

test_that("bad teams and arguments error clearly", {
  skip_if_not_installed("sportyR")
  expect_error(sdv_surface("nba", "NOT_A_TEAM"), "is not a \"nba\" team")
  expect_error(sdv_surface("nba", c("BOS", "LAL")), "one team")
  expect_error(sdv_surface("nba", center_logo = TRUE), "needs a `team`")
  expect_error(sdv_surface("nascar"), "must be one of")
})

test_that("a missing sportyR is an informative error", {
  local_mocked_bindings(
    check_installed = function(pkg, reason = NULL, ...) stop("need ", pkg, " ", reason),
    .package = "rlang"
  )
  expect_error(sdv_surface("nba"), "need sportyR to draw playing surfaces")
})

test_that("center_logo places the team logo at the surface's center", {
  skip_if_not_installed("sportyR")
  logo_layer <- function(p) p$layers[[length(p$layers)]]

  l <- logo_layer(sdv_surface("nba", "BOS", center_logo = TRUE))
  expect_s3_class(l$geom, "GeomSDVsurfaceLogo")
  expect_identical(l$data$path, resolve_logo_url("BOS", "nba"))
  expect_equal(c(l$data$x, l$data$y), c(0, 0))
  expect_identical(l$geom_params$logo_size, 12)

  # dark grass takes ESPN's dark-background logo
  l <- logo_layer(sdv_surface("cfb", "TEX", center_logo = TRUE))
  expect_identical(l$data$path, resolve_logo_url("TEX", "cfb", variant = "dark"))
  expect_identical(l$geom_params$logo_size, 10)

  # follows sportyR's translate-then-rotate and unit conversion
  l <- logo_layer(sdv_surface("nhl", "COL", center_logo = TRUE, x_trans = 10, rotation = 90, rink_units = "m"))
  expect_equal(c(l$data$x, l$data$y), c(0, 10))
  expect_equal(l$geom_params$logo_size, 24 * 0.3048)

  expect_warning(p <- sdv_surface("mlb", "NYY", center_logo = TRUE), "ignored")
  expect_false(any(vapply(p$layers, function(l) inherits(l$geom, "GeomSDVsurfaceLogo"), logical(1))))
})

test_that("the center logo is sized in surface units when drawn", {
  skip_if_not_installed("sportyR")
  img <- withr::local_tempfile(fileext = ".png")
  grDevices::png(img, width = 20, height = 20)
  grid::grid.rect(gp = grid::gpar(fill = "red"))
  grDevices::dev.off()

  p <- sdv_surface("nhl", "COL", center_logo = TRUE)
  p$layers[[length(p$layers)]]$data$path <- img
  ranges <- ggplot2::ggplot_build(p)$layout$panel_params[[1]]
  grob <- ggplot2::layer_grob(p, length(p$layers))[[1]]$children[[1]]
  expect_equal(as.numeric(grob$vp$width), 24 / diff(ranges$x.range))
  expect_equal(as.numeric(grob$vp$height), 24 / diff(ranges$y.range))
})

test_that("soccer draws a 105 x 68 pitch by default, and pitch_updates win key by key", {
  skip_if_not_installed("sportyR")
  expect_true(inherits(sdv_surface("soccer"), "ggplot"))
  regulation <- sportyR::geom_soccer("fifa", pitch_updates = list(pitch_length = 105, pitch_width = 68))
  expect_identical(surface_data(sdv_surface("soccer")), surface_data(regulation))
  longer <- sportyR::geom_soccer("fifa", pitch_updates = list(pitch_length = 110, pitch_width = 68))
  expect_identical(surface_data(sdv_surface("soccer", pitch_updates = list(pitch_length = 110))), surface_data(longer))
})

test_that("fiba draws sportyR's FIBA court", {
  skip_if_not_installed("sportyR")
  expect_identical(surface_data(sdv_surface("fiba")), surface_data(sportyR::geom_basketball("fiba")))
})

test_that("surfaces without team identities refuse a team", {
  skip_if_not_installed("sportyR")
  expect_error(sdv_surface("fiba", "ESP"), "No team identities")
  expect_error(sdv_surface("soccer", "359"), "No team identities") # until soccer identities land (Task 11)
})
