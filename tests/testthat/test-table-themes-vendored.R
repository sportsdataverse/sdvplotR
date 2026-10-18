skip_on_cran()

test_that("vendored table_themes.json matches its sha256 sidecar", {
  skip_if(getRversion() < "4.5.0", "tools::sha256sum needs R >= 4.5.0")
  hint <- "run sdvplot-js/tools/sync-table-themes.mjs"
  js <- system.file("extdata", "table_themes.json", package = "sdvplotR")
  sidecar <- system.file("extdata", "table_themes.json.sha256", package = "sdvplotR")
  expect_true(nzchar(js) && nzchar(sidecar), info = paste("vendored registry missing:", hint))
  actual <- unname(tools::sha256sum(js))
  expected <- trimws(readLines(sidecar, warn = FALSE)[1])
  expect_identical(actual, expected, info = paste("table_themes.json drifted from its .sha256:", hint))
})
