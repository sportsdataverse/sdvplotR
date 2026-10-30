skip_on_cran()

check_teams <- c(
  nba = "BOS", wnba = "LV", mbb = "DUKE", wbb = "UCONN",
  nfl = "KC", cfb = "TEX", nhl = "COL", mlb = "NYY"
)

test_that("every league returns a ggplot", {
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
  nsh <- sdv_team_colors("nhl", "NSH", which = "all")
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
  expect_error(sdv_surface("nascar"), "No playing surface")
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
  expect_identical(l$data$path, logo_from_team("BOS", "nba"))
  expect_equal(c(l$data$x, l$data$y), c(0, 0))
  expect_identical(l$geom_params$logo_size, 12)

  # dark grass takes ESPN's dark-background logo
  l <- logo_layer(sdv_surface("cfb", "TEX", center_logo = TRUE))
  expect_identical(l$data$path, logo_from_team("TEX", "cfb", variant = "dark"))
  expect_identical(l$geom_params$logo_size, 10)

  # follows sportyR's translate-then-rotate and unit conversion
  l <- logo_layer(sdv_surface("nhl", "COL", center_logo = TRUE, x_trans = 10, rotation = 90, rink_units = "m"))
  expect_equal(c(l$data$x, l$data$y), c(0, 10))
  expect_equal(l$geom_params$logo_size, 24 * 0.3048)

  # a baseball field has no center: the logo goes in shallow center field (tested below)
  expect_no_warning(l <- logo_layer(sdv_surface("mlb", "NYY", center_logo = TRUE)))
  expect_s3_class(l$geom, "GeomSDVsurfaceLogo")
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
  # every key that is not an sdv team league, as in sdvplot-js
  teamless <- setdiff(names(surface_map), sdv_leagues())
  expect_true(all(c("fiba", "atp", "nll", "wcf", "epl", "cfl", "nfhs_football") %in% teamless))
  for (lg in teamless) {
    expect_error(sdv_surface(lg, "BOS"), paste0("No team identities for \"", lg, "\""), info = lg)
  }
})

# the SDV surface-key table, identical to sdvplot-js's src/surfaces.ts (sdvplot, Python, is moving to it)
shared_surfaces <- list(
  nfl = c("geom_football", "nfl"), aaf = c("geom_football", "nfl"), ufl = c("geom_football", "nfl"),
  usfl = c("geom_football", "nfl"), xfl = c("geom_football", "nfl"), cfb = c("geom_football", "ncaa"),
  cfl = c("geom_football", "cfl"), nfhs_football = c("geom_football", "nfhs11"),
  nba = c("geom_basketball", "nba"), nbagl = c("geom_basketball", "nba g league"),
  wnba = c("geom_basketball", "wnba"), mbb = c("geom_basketball", "ncaa"), wbb = c("geom_basketball", "ncaa"),
  fiba = c("geom_basketball", "fiba"), nfhs_basketball = c("geom_basketball", "nfhs"),
  mlb = c("geom_baseball", "mlb"), milb = c("geom_baseball", "milb"), ncaa_baseball = c("geom_baseball", "ncaa"),
  little_league = c("geom_baseball", "little league"), pony = c("geom_baseball", "pony"),
  nfhs_baseball = c("geom_baseball", "nfhs"),
  ncaa_softball = c("geom_softball", "ncaa"),
  nhl = c("geom_hockey", "nhl"), whl = c("geom_hockey", "nhl"), pwhl = c("geom_hockey", "pwhl"),
  ahl = c("geom_hockey", "ahl"), echl = c("geom_hockey", "echl"), ohl = c("geom_hockey", "ohl"),
  qmjhl = c("geom_hockey", "qmjhl"), ushl = c("geom_hockey", "ushl"), phf = c("geom_hockey", "phf"),
  iihf = c("geom_hockey", "iihf"), nwhl = c("geom_hockey", "nwhl"),
  ncaa_mhockey = c("geom_hockey", "ncaa"), ncaa_whockey = c("geom_hockey", "ncaa"),
  soccer = c("geom_soccer", "fifa"), fifa = c("geom_soccer", "fifa"), epl = c("geom_soccer", "epl"),
  mls = c("geom_soccer", "mls"), nwsl = c("geom_soccer", "nwsl"), ncaa_soccer = c("geom_soccer", "ncaa"),
  nll = c("geom_lacrosse", "nll"), pll = c("geom_lacrosse", "pll"),
  world_lacrosse = c("geom_lacrosse", "world lacrosse"), ncaa_mlacrosse = c("geom_lacrosse", "ncaam"),
  ncaa_wlacrosse = c("geom_lacrosse", "ncaaw"), usa_mlacrosse = c("geom_lacrosse", "usam"),
  usa_wlacrosse = c("geom_lacrosse", "usaw"),
  atp = c("geom_tennis", "atp"), wta = c("geom_tennis", "wta"), itf = c("geom_tennis", "itf"),
  ita = c("geom_tennis", "ita"), usta = c("geom_tennis", "usta"), ncaa_tennis = c("geom_tennis", "ncaa"),
  fivb = c("geom_volleyball", "fivb"), usa_volleyball = c("geom_volleyball", "usa volleyball"),
  ncaa_volleyball = c("geom_volleyball", "ncaa"),
  wcf = c("geom_curling", "wcf"), curling_canada = c("geom_curling", "curling canada")
)

test_that("surface_map carries the 59 shared keys with the shared sport and league", {
  expect_length(surface_map, 59L)
  expect_identical(surface_map[order(names(surface_map))], shared_surfaces[order(names(shared_surfaces))])
})

test_that("every key draws its sportyR surface, unchanged", {
  skip_if_not_installed("sportyR")
  for (lg in setdiff(names(surface_map), "soccer")) {
    m <- surface_map[[lg]]
    expected <- getExportedValue("sportyR", m[[1]])(m[[2]])
    p <- sdv_surface(lg)
    expect_identical(surface_data(p), surface_data(expected), info = lg)
    expect_identical(surface_colors(p), surface_colors(expected), info = lg)
  }
})

test_that("pwhl draws the PWHL's own rink, not the NHL's", {
  skip_if_not_installed("sportyR")
  expect_identical(surface_data(sdv_surface("pwhl")), surface_data(sportyR::geom_hockey("pwhl")))
  expect_false(identical(surface_data(sdv_surface("pwhl")), surface_data(sportyR::geom_hockey("nhl"))))
})

test_that("ncaa_softball is a team league and a surface: the field draws and the team resolves", {
  skip_if_not_installed("sportyR")
  plain <- sportyR::geom_softball("ncaa")
  p <- sdv_surface("ncaa_softball", "UCLA")
  # an infield has nothing team-colored: the field stays sportyR's
  expect_identical(surface_data(p), surface_data(plain))
  expect_identical(surface_colors(p), surface_colors(plain))
  expect_false(is.na(sdv_team_colors("ncaa_softball", "UCLA", which = "primary")))
  expect_false(is.na(logo_from_team("UCLA", "ncaa_softball")))
  expect_error(sdv_surface("ncaa_softball", "NOT_A_TEAM"), "is not a \"ncaa_softball\" team")
  expect_no_warning(p <- sdv_surface("ncaa_softball", "UCLA", center_logo = TRUE))
  expect_identical(p$layers[[length(p$layers)]]$data$path, logo_from_team("UCLA", "ncaa_softball", variant = "dark"))
  # color_updates still reach sportyR
  p <- sdv_surface("ncaa_softball", "UCLA", color_updates = list(infield_dirt = "#123456"))
  expect_identical(
    surface_colors(p),
    surface_colors(sportyR::geom_softball("ncaa", color_updates = list(infield_dirt = "#123456")))
  )
})

test_that("an installed sportyR older than 2.4.5 errors through check_installed(), before sportyR runs", {
  skip_if_not_installed("sportyR")
  # rlang's own hook for what is installed: a sportyR that meets no version floor
  withr::local_options(list(`rlang:::is_installed_hook` = function(pkg, ver, cmp) {
    !(pkg == "sportyR" & !is.na(ver))
  }))
  expect_error(sdv_surface("nba"), "sportyR.*2\\.4\\.5")
  expect_error(sdv_surface("ncaa_softball", "UCLA"), "2\\.4\\.5")
})

test_that("an older sportyR still loaded after an update asks for a restart", {
  skip_if_not_installed("sportyR")
  local_mocked_bindings(getNamespaceVersion = function(ns) c(version = "2.2.3"), .package = "base")
  expect_error(sdv_surface("nba"), "'sportyR' 2\\.2\\.3 is loaded; restart R")
})

test_that("every league with a surface draws one; others error with the list", {
  skip_if_not_installed("sportyR")
  for (lg in names(surface_map)) {
    expect_s3_class(sdv_surface(lg), "ggplot")
  }
  expect_error(sdv_surface("cricket"), "fiba")
})

test_that("a minor-league team colours its surface", {
  skip_if_not_installed("sportyR")
  t <- sdv_teams("ahl")$team_id[1]
  expect_s3_class(sdv_surface("ahl", team = t), "ggplot")
})

test_that("on a baseball or softball field the logo sits in shallow center field", {
  skip_if_not_installed("sportyR")
  logo_layer <- function(p) p$layers[[length(p$layers)]]
  # x = 0, y = midway between second base (base path * sqrt(2)) and the center-field fence;
  # 0.15 x the center-field distance across
  l <- logo_layer(sdv_surface("mlb", "NYY", center_logo = TRUE))
  expect_equal(c(l$data$x, l$data$y), c(0, (90 * sqrt(2) + 400) / 2), tolerance = 1e-9)
  expect_equal(l$geom_params$logo_size, 0.15 * 400, tolerance = 1e-9)
  # the grass is dark: ESPN's dark-background logo
  expect_identical(l$data$path, logo_from_team("NYY", "mlb", variant = "dark"))

  # field_updates reshape the field, and the logo follows
  l <- logo_layer(sdv_surface("milb", sdv_teams("milb")$team_id[1], center_logo = TRUE, field_updates = list(
    baseline_distance = 80, center_field_distance = 315
  )))
  expect_equal(l$data$y, (80 * sqrt(2) + 315) / 2, tolerance = 1e-9)
  expect_equal(l$geom_params$logo_size, 0.15 * 315, tolerance = 1e-9)

  # follows units, translation and rotation like the other surfaces
  l <- logo_layer(sdv_surface("mlb", "NYY", center_logo = TRUE, field_units = "m", rotation = 90))
  y <- (90 * sqrt(2) + 400) / 2 * 0.3048
  expect_equal(c(l$data$x, l$data$y), c(-y, 0), tolerance = 1e-9)
  expect_equal(l$geom_params$logo_size, 0.15 * 400 * 0.3048, tolerance = 1e-9)

  # a field given in meters through field_updates converts from meters, as sportyR's field does
  l <- logo_layer(sdv_surface("mlb", "NYY", center_logo = TRUE, field_units = "ft", field_updates = list(
    field_units = "m", baseline_distance = 90 * 0.3048, center_field_distance = 400 * 0.3048
  )))
  expect_equal(l$data$y, (90 * sqrt(2) + 400) / 2, tolerance = 1e-6)
  expect_equal(l$geom_params$logo_size, 0.15 * 400, tolerance = 1e-6)

  l <- logo_layer(sdv_surface("ncaa_softball", "UCLA", center_logo = TRUE))
  expect_equal(c(l$data$x, l$data$y), c(0, (60 * sqrt(2) + 220) / 2), tolerance = 1e-9)
  expect_equal(l$geom_params$logo_size, 0.15 * 220, tolerance = 1e-9)
})

test_that("the diamond logo reads its field parameters from sportyR::get_surface_dimensions()", {
  skip_if_not_installed("sportyR")
  local_mocked_bindings(
    get_surface_dimensions = function(sport, league = NULL) list(baseline_distance = 100, center_field_distance = 500),
    .package = "sportyR"
  )
  l <- sdv_surface("mlb", "NYY", center_logo = TRUE)
  l <- l$layers[[length(l$layers)]]
  expect_equal(l$data$y, (100 * sqrt(2) + 500) / 2, tolerance = 1e-9)
  expect_equal(l$geom_params$logo_size, 0.15 * 500, tolerance = 1e-9)
})
