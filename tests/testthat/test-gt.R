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
  df <- data.frame(id = c("00-0033873", "3139477", "bad"))
  h <- html_of(gt(df) |> gt_sdv_headshots(columns = "id", sport = "nfl"))
  expect_match(h, "static\\.www\\.nfl\\.com/image/(private|upload)/t_headshot_desktop/f_auto/league/")
  expect_match(h, "headshots/nfl/players/full/3139477\\.png")
  expect_match(h, "bad")
})

test_that("gt_sdv_cols_label swaps column labels for images", {
  df <- data.frame(KC = 1, BUF = 2, other = 3)
  h <- html_of(gt(df) |> gt_sdv_cols_label(columns = everything(), sport = "nfl"))
  expect_match(h, "kc\\.png")
  expect_match(h, "buf\\.png")
  expect_match(h, "other")
  h2 <- html_of(gt(data.frame(`00-0033873` = 1, check.names = FALSE)) |>
    gt_sdv_cols_label(sport = "nfl", type = "headshot"))
  expect_match(h2, "static\\.www\\.nfl\\.com/image/")
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
