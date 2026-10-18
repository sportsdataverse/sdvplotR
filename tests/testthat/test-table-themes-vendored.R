skip_on_cran()

# Guards a hand-edited JSON only; editing both the JSON and its .sha256 together is caught only by re-running
# sdvplot-js/tools/sync-table-themes.mjs (the canonical copy lives in sdvplot-js).
test_that("vendored table_themes.json matches its sha256 sidecar", {
  skip_if(getRversion() < "4.5.0", "tools::sha256sum needs R >= 4.5.0")
  hint <- "run sdvplot-js/tools/sync-table-themes.mjs"
  js <- system.file("extdata", "table_themes.json", package = "sdvplotR")
  sidecar <- system.file("extdata", "table_themes.json.sha256", package = "sdvplotR")
  if (!nzchar(js) || !nzchar(sidecar)) {
    fail(paste("vendored registry missing:", hint))
    return(invisible())
  }
  actual <- unname(tools::sha256sum(js))
  expected <- trimws(readLines(sidecar, warn = FALSE)[1])
  expect_identical(actual, expected, info = paste("table_themes.json drifted from its .sha256:", hint))
})
