library(gt)

html_of <- function(x) as.character(gt::as_raw_html(x, inline_css = FALSE))

test_that("gt_sdv_logos and wordmarks render img tags and keep unknown text", {
  df <- data.frame(team = c("KC", "nope"), n = 1:2)
  t1 <- gt(df) |> gt_sdv_logos(columns = "team", sport = "nfl", height = 25)
  expect_s3_class(t1, "gt_tbl")
  h <- html_of(t1)
  expect_match(h, "<img src=\"https://a\\.espncdn\\.com/i/teamlogos/nfl/500/kc\\.png\" style=\"height:25px;\"")
  expect_match(h, "nope")
  t2 <- gt(df) |> gt_sdv_wordmarks(columns = "team", sport = "nfl")
  expect_match(html_of(t2), "wordmarks/KC\\.png")
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
  expect_match(h, "kc\\.png")
  expect_match(h, "buf\\.png")
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
