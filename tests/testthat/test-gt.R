library(gt)

html_of <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))

test_that("gt_sdv_logos and wordmarks render img tags and keep unknown text", {
  df <- data.frame(team = c("KC", "nope"), n = 1:2)
  t1 <- gt(df) |> gt_sdv_logos(columns = "team", sport = "nfl", height = 25)
  expect_s3_class(t1, "gt_tbl")
  h <- html_of(t1)
  expect_match(h, paste0("<img src=\"", logo_from_team("KC", "nfl"), "\" style=\"height:25px;\""), fixed = TRUE)
  expect_match(h, "sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/assets/public/sha256/")
  expect_match(h, "nope")
  t2 <- gt(df) |> gt_sdv_wordmarks(columns = "team", sport = "nfl")
  expect_match(html_of(t2), wordmark_from_team("KC", "nfl"), fixed = TRUE)
})

test_that("gt_sdv_logos resolves escaped names and can keep the name", {
  df <- data.frame(team = c("Texas A&M", "St. John's (NY)", "nope"), n = 1:3)
  # gt hands text_transform() "Texas A&amp;M"; it still resolves
  h <- html_of(gt(df) |> gt_sdv_logos(columns = "team", sport = "mbb", height = 20))
  expect_match(h, logo_from_team("Texas A&M", "mbb"), fixed = TRUE)
  expect_match(h, logo_from_team("St. John's (NY)", "mbb"), fixed = TRUE)
  expect_no_match(h, "Texas A&amp;M</td>")
  # include_name keeps the (escaped) text after the logo
  h <- html_of(gt(df) |> gt_sdv_logos(columns = "team", sport = "mbb", height = 20, include_name = TRUE))
  expect_match(
    h,
    paste0(logo_from_team("Texas A&M", "mbb"), "\" style=\"height:20px;vertical-align:middle;margin-right:0.35em;\" alt=\"\">Texas A&amp;M"),
    fixed = TRUE
  )
  expect_match(h, ">St. John's \\(NY\\)</td>")
  expect_match(h, ">nope</td>")
})

test_that("gt_sdv_logos draws a season's marks", {
  df <- data.frame(team = c("QUE", "COL", "nope"), n = 1:3)
  h <- html_of(gt(df) |> gt_sdv_logos(columns = "team", sport = "nhl", season = 1990))
  # the Nordiques' 1979-80 to 1994-95 mark; no 1990 Avalanche era, so today's logo
  expect_match(h, "digitaloceanspaces\\.com/assets/public/sha256/3c/3c28d243dd")
  expect_match(h, logo_from_team("COL", "nhl"), fixed = TRUE)
  expect_match(h, ">nope</td>")
  # without a season, today's marks only: no Nordiques
  expect_no_match(html_of(gt(df) |> gt_sdv_logos(columns = "team", sport = "nhl")), "3c28d243dd")
  expect_error(gt_sdv_logos(gt(df), columns = "team", sport = "nhl", season = 1990:1991), "single season")
})

test_that("gt_sdv_headshots renders headshots and keeps unresolvable ids", {
  local_headshot_map()
  df <- data.frame(id = c("00-0033873", "bad"))
  h <- html_of(gt(df) |> gt_sdv_headshots(columns = "id", sport = "nfl"))
  expect_match(h, "t_headshot_desktop/f_auto/league/wdckwtob1lybvkmxnf7p\\.png")
  expect_no_match(h, "000033873") # the old URL built from the GSIS digits
  expect_match(h, "bad")
})

test_that("gt_sdv_cols_label swaps column labels for images", {
  local_headshot_map()
  df <- data.frame(KC = 1, BUF = 2, other = 3)
  h <- html_of(gt(df) |> gt_sdv_cols_label(columns = everything(), sport = "nfl"))
  expect_match(h, logo_from_team("KC", "nfl"), fixed = TRUE)
  expect_match(h, logo_from_team("BUF", "nfl"), fixed = TRUE)
  expect_match(h, "other")
  h2 <- html_of(gt(data.frame(`00-0033873` = 1, check.names = FALSE)) |>
    gt_sdv_cols_label(sport = "nfl", type = "headshot"))
  expect_match(h2, "league/wdckwtob1lybvkmxnf7p")
})

test_that("gt_merge_stack_team_color stacks and colours text", {
  df <- data.frame(team = c("KC", "BUF"), mascot = c("Chiefs", "Bills"))
  t <- gt(df) |> gt_merge_stack_team_color(team, mascot, team, sport = "nfl")
  expect_s3_class(t, "gt_tbl")
  h <- html_of(t)
  expect_match(h, "color:#E31837")
  expect_match(h, "Chiefs")
  expect_snapshot(gt_merge_stack_team_color(df, team, mascot, team, sport = "nfl"), error = TRUE)
})

test_that("gt_merge_stack_team_color keeps the team text readable on the cell", {
  ink <- function(h) regmatches(h, regexpr("(?<=font-weight:bold;color:)#[0-9A-Fa-f]{6}", h, perl = TRUE))
  df <- data.frame(team = "MIZ", mascot = "Tigers")
  # Missouri's gold primary measures 1.8:1 on white; its black secondary passes
  h <- html_of(gt(df) |> gt_merge_stack_team_color(team, mascot, team, sport = "cfb"))
  expect_false(grepl("#F1B82D", h, ignore.case = TRUE))
  expect_gte(.theme_contrast(ink(h), "#FFFFFF"), 4.5)
  expect_identical(toupper(ink(h)), toupper(sdv_team_colors("cfb", "MIZ", "secondary")[[1]]))
  # on a dark table the gold passes and stays
  h_dark <- html_of(gt(df) |> gt_merge_stack_team_color(team, mascot, team, sport = "cfb", background = "#1e1e1e"))
  expect_identical(toupper(ink(h_dark)), "#F1B82D")
  # with neither color readable, the primary is darkened until it passes
  expect_gte(.theme_contrast(sdv_readable_ink("#F1B82D", "#FFE08A", "#FFFFFF"), "#FFFFFF"), 4.5)
})

test_that("gt_merge_stack_team_color reads the background of a theme applied first", {
  inks <- function(h) regmatches(h, gregexpr("(?<=font-weight:bold;color:)#[0-9A-Fa-f]{6}", h, perl = TRUE))[[1]]
  df <- data.frame(team = c("MIZ", "WVU"), mascot = c("Tigers", "Mountaineers"))
  for (theme in list(gt_theme_midnight, gt_theme_terminal)) {
    tbl <- theme(gt(df))
    opt <- tbl[["_options"]]
    bg <- opt$value[opt$parameter == "table_background_color"][[1]]
    h <- html_of(gt_merge_stack_team_color(tbl, team, mascot, team, sport = "cfb"))
    ink <- inks(h)
    expect_length(ink, 2)
    # both golds read on the dark table and stay
    expect_identical(toupper(ink), toupper(unname(sdv_team_colors("cfb", c("MIZ", "WVU")))))
    for (i in ink) expect_gte(.theme_contrast(i, bg), 4.5)
  }
})

test_that("gt headshot helpers pass id_type through", {
  df <- data.frame(id = c("2544", "abc"))
  h <- html_of(gt(df) |> gt_sdv_headshots(columns = "id", sport = "nba", id_type = "league"))
  expect_match(h, "https://cdn\\.nba\\.com/headshots/nba/latest/260x190/2544\\.png")
  expect_match(h, ">abc<")
  lab <- html_of(gt(data.frame(`1642286` = 1, check.names = FALSE)) |>
    gt_sdv_cols_label(sport = "wnba", type = "headshot", id_type = "league"))
  expect_match(lab, "cdn\\.wnba\\.com/headshots/wnba/latest/260x190/1642286\\.png")
  expect_error(gt_sdv_headshots(gt(df), columns = "id", sport = "mbb", id_type = "league"), "league player ID")
})

# alt text: every <img> a table helper writes carries one
img_tags <- function(h) regmatches(h, gregexpr("<img[^>]*>", h))[[1]]
alts_of <- function(h) sub('.*alt="([^"]*)".*', "\\1", img_tags(h))

test_that("gt_sdv_logos and wordmarks alt-name the team, or stay empty beside its name", {
  df <- data.frame(team = c("KC", "nope"), n = 1:2)
  for (f in list(gt_sdv_logos, gt_sdv_wordmarks)) {
    h <- html_of(f(gt(df), columns = "team", sport = "nfl"))
    expect_true(all(grepl('alt="', img_tags(h), fixed = TRUE)))
    expect_identical(alts_of(h), "Kansas City Chiefs")
  }
  # the name is already text beside the logo, so a screen reader reads it once
  h <- html_of(gt(df) |> gt_sdv_logos(columns = "team", sport = "nfl", include_name = TRUE))
  expect_identical(alts_of(h), "")
  # escaped, college names resolve to the full team name
  h <- html_of(gt(data.frame(team = "Texas A&M")) |> gt_sdv_logos(columns = "team", sport = "mbb"))
  expect_identical(alts_of(h), "Texas A&amp;M Aggies")
})

test_that("headshot helpers alt-text an id as Player <id> headshot", {
  local_headshot_map()
  h <- html_of(gt(data.frame(id = c("00-0033873", "bad"))) |> gt_sdv_headshots(columns = "id", sport = "nfl"))
  expect_identical(alts_of(h), "Player 00-0033873 headshot")
  h <- html_of(gt(data.frame(`00-0033873` = 1, check.names = FALSE)) |>
    gt_sdv_cols_label(sport = "nfl", type = "headshot"))
  expect_identical(alts_of(h), "Player 00-0033873 headshot")
})

test_that("gt_sdv_cols_label alt-names the team for logo and wordmark labels", {
  for (type in c("logo", "wordmark")) {
    h <- html_of(gt(data.frame(KC = 1, BUF = 2)) |> gt_sdv_cols_label(sport = "nfl", type = type))
    expect_identical(alts_of(h), c("Kansas City Chiefs", "Buffalo Bills"))
  }
})

test_that("gt_tiers alt-names each entry by the team its image shows", {
  ref <- team_reference("nfl")
  comets <- logo_history$url[logo_history$identity_name == "Houston Comets"][[1]]
  d <- data.frame(
    tier = c("A", "B"),
    `1` = c(ref$logo_url[ref$team_abbr == "KC"], ref$logo_dark_url[ref$team_abbr == "BUF"]),
    `2` = c("https://x/my-team.png", comets),
    `3` = NA_character_,
    check.names = FALSE
  )
  h <- html_of(gt(d) |> gt_tiers(levels = c("A", "B"), colors = c("#1B7837", "#B2182B")))
  # a logo the package knows takes the team's name, anything else its file name
  expect_identical(alts_of(h), c("Kansas City Chiefs", "my-team", "Buffalo Bills", "Houston Comets"))
  h <- html_of(gt(d) |> gt_tiers(c(A = "#1B7837", B = "#B2182B"), alt = function(url) paste("Logo", basename(url))))
  expect_identical(alts_of(h), c("Logo kc.png", "Logo my-team.png", "Logo buf.png", paste("Logo", basename(comets))))
  expect_snapshot(gt(d) |> gt_tiers(c(A = "#1B7837", B = "#B2182B"), alt = "Logo"), error = TRUE)
})

test_that("gt_tiers alt-names a local image by its path, not the data URI gt embeds", {
  dir <- withr::local_tempdir()
  osu <- file.path(dir, "Ohio State.png")
  mich <- file.path(dir, "Michigan.png")
  magick::image_write(magick::image_blank(4, 4, "red"), osu, format = "png")
  magick::image_write(magick::image_blank(4, 4, "blue"), mich, format = "png")
  # groups render the rows out of data order (y, y, x), and the NA cell stays empty
  d <- data.frame(
    grp = c("y", "x", "y"), tier = c("A", "B", "A"),
    `1` = c(osu, mich, paste(mich, osu, sep = ", ")),
    `2` = c(NA, "https://x/kc.png", osu),
    check.names = FALSE
  )
  tbl <- gt(d, groupname_col = "grp")
  h <- html_of(tbl |> gt_tiers(c(A = "#1B7837", B = "#B2182B"), image_columns = c("1", "2")))
  expect_match(h, "src=\"data:image/png;base64,", fixed = TRUE)
  expect_identical(
    alts_of(h),
    c("Ohio State", "Michigan", "Ohio State", "Ohio State", "Michigan", "kc")
  )
  seen <- NULL
  h <- html_of(tbl |> gt_tiers(c(A = "#1B7837", B = "#B2182B"), image_columns = c("1", "2"), alt = function(x) {
    seen <<- c(seen, x)
    basename(x)
  }))
  expect_setequal(seen, c(osu, mich, "https://x/kc.png"))
  expect_identical(
    alts_of(h),
    c("Ohio State.png", "Michigan.png", "Ohio State.png", "Ohio State.png", "Michigan.png", "kc.png")
  )
})

test_that("the border bars give their image an empty alt", {
  h <- html_of(gt(data.frame(x = 1)) |> gt_border_bars_top(colors = c("#E31837", "#FFB612"), img = "https://x/y.png"))
  expect_identical(alts_of(h), "")
  h <- html_of(gt(data.frame(x = 1)) |> gt_border_bars_bottom(colors = c("#E31837", "#FFB612"), img = "https://x/y.png"))
  expect_identical(alts_of(h), "")
})

test_that("top border bars stay above the table under page CSS", {
  h <- html_of(gt(data.frame(x = 1), id = "bars") |> gt_border_bars_top(colors = "#E31837"))
  # gt reflows the CSS, one declaration per line
  expect_match(h, "#bars caption, #bars \\.gt_caption \\{\\s*caption-side: top !important;")
})

test_that("border bars request the Google font by its bare family name", {
  d <- gt(data.frame(x = 1)) |> gt_theme_scoreboard() |> tab_header("t")
  for (f in list(gt_border_bars_top, gt_border_bars_bottom)) {
    h <- html_of(f(d, colors = c("#E31837", "#FFB612"), text = "x"))
    expect_match(h, "family=Barlow+Condensed:", fixed = TRUE)
    # the family inside the request carries no quote characters
    expect_no_match(h, "family='", fixed = TRUE)
  }
})

test_that("gt_spotlight dims the other rows to a tone that still passes WCAG AA", {
  d <- data.frame(team = c("A", "B", "C"), wins = 1:3)
  # one style attribute per body cell, row by row
  td_styles <- function(h) regmatches(h, gregexpr("<td[^>]*>", h))[[1]]
  td_color <- function(s) regmatches(s, regexpr("#[0-9A-Fa-f]{6}", s))
  for (tbl in list(gt(d), gt_theme_midnight(gt(d)))) {
    bg <- .table_background(tbl)
    s <- td_styles(html_of(gt_spotlight(tbl, rows = 2)))
    # the lit row keeps the theme's own text color and is bolded
    expect_true(all(grepl("font-weight: bold", s[3:4], fixed = TRUE)))
    expect_false(any(grepl("font-weight: bold", s[-(3:4)], fixed = TRUE)))
    dim <- unique(vapply(s[-(3:4)], td_color, ""))
    expect_length(dim, 1)
    expect_gte(.theme_contrast(dim, bg), 4.5)
    # still muted next to full-strength text, so the spotlight reads
    expect_lt(.theme_contrast(dim, bg), .theme_contrast(.theme_on_color(bg), bg) / 2)
  }
  # a color you pass is used as is
  s <- td_styles(html_of(gt_spotlight(gt(d), rows = 2, dim_color = "#BBBBBB")))
  expect_match(s[1], "color: #BBBBBB;", fixed = TRUE)
})
