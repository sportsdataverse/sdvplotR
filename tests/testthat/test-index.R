skip_on_cran()

test_that("the live index reads the CDN layout and caches it on disk", {
  local_fixture_index()
  t <- index_teams()
  expect_setequal(unique(t$league), c("nfl", "nhl"))
  expect_identical(index_cache$source, "live")
  expect_identical(index_cache$version, snapshot_meta$index_version)
  expect_true(file.exists(file.path(tools::R_user_dir("sdvplotR", "cache"), "index", "latest.txt")))
  expect_type(index_aliases()$valid_from, "integer")
})

test_that("a fresh disk cache is used without the network", {
  local_fixture_index()
  index_teams()
  forget_index()
  withr::local_options(sdvplotR.index_url = "file:///nonexistent/index")
  expect_no_warning(index_teams())
  expect_identical(index_cache$source, "live")
})

test_that("a failed refresh with a stale cache warns once and uses the cache", {
  local_fixture_index(ttl = 0)
  index_teams()
  forget_index()
  withr::local_options(sdvplotR.index_url = "file:///nonexistent/index")
  expect_warning(index_teams(), class = "sdvplotR_fallback")
  expect_identical(index_cache$source, "cache")
  expect_no_warning(index_aliases())
})

test_that("no network and no cache falls back to the snapshot with a warning", {
  local_fixture_index()
  withr::local_options(sdvplotR.index_url = "file:///nonexistent/index")
  expect_warning(t <- index_teams(), class = "sdvplotR_fallback")
  expect_identical(index_cache$source, "snapshot")
  expect_gt(length(unique(t$league)), 20)
})

test_that("a corrupt cached file or a bad version pointer falls back to the snapshot (teams + aliases together)", {
  fx <- local_fixture_index()
  index_teams()
  ver <- snapshot_meta$index_version
  cached <- file.path(tools::R_user_dir("sdvplotR", "cache"), "index", ver, "aliases.csv.gz")
  writeBin(as.raw(c(0x1f, 0x8b, 0x08, 0x00)), cached) # a truncated gzip header
  forget_index()
  expect_warning(index_teams(), class = "sdvplotR_fallback")
  expect_identical(index_cache$source, "snapshot")
  expect_identical(nrow(index_aliases()), nrow(snapshot_aliases))

  forget_index()
  writeLines("../../etc", file.path(tools::R_user_dir("sdvplotR", "cache"), "index", "latest.txt"))
  expect_warning(index_teams(), "index version", class = "sdvplotR_fallback")
})

test_that("under a CRAN check the snapshot is used and nothing is written", {
  local_fixture_index()
  withr::local_envvar("_R_CHECK_THINGS_IN_OTHER_DIRS_" = "true")
  expect_no_warning(index_teams())
  expect_identical(index_cache$source, "snapshot")
  expect_false(dir.exists(tools::R_user_dir("sdvplotR", "cache")))
})

test_that("sdvplotR.offline uses the snapshot silently", {
  local_snapshot_index()
  expect_no_warning(index_marks())
  expect_identical(index_cache$source, "snapshot")
  expect_match(index_marks()$archive_url[1], "^https://sdv\\.nyc3\\.cdn\\.digitaloceanspaces\\.com/assets/public/sha256/[0-9a-f]{2}/[0-9a-f]{64}\\.")
})

test_that("the live manifest drops rows whose archive_url is not a plain https URL", {
  fx <- local_fixture_index()
  m <- utils::read.csv(file.path(fx, "marks.csv"), colClasses = "character")
  m$archive_url[1] <- "javascript:alert(1)"
  bad <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(m, bad, row.names = FALSE)
  withr::local_options(sdvplotR.manifest_url = paste0("file:///", sub("^/", "", normalizePath(bad, winslash = "/"))))
  expect_warning(marks <- index_marks(), "archive_url")
  expect_identical(nrow(marks), nrow(m) - 1L)
})

test_that("sdv_versions() reports the source and version", {
  local_snapshot_index()
  v <- sdv_versions()
  expect_identical(v$index_source, "snapshot")
  expect_identical(v$index_version, snapshot_meta$index_version)
  expect_identical(v$package, as.character(utils::packageVersion("sdvplotR")))
})

test_that("a cached file cut off mid-row falls back to the snapshot, not a shortened table", {
  fx <- local_fixture_index()
  index_teams()
  ver <- snapshot_meta$index_version
  cached <- file.path(tools::R_user_dir("sdvplotR", "cache"), "index", ver, "aliases.csv.gz")
  txt <- readLines(file.path(fx, "index", ver, "aliases.csv.gz"), warn = FALSE)
  cut <- substr(paste(txt, collapse = "\n"), 1, 2000) # ends mid-row
  con <- gzfile(cached, "wb")
  writeChar(cut, con, eos = NULL)
  close(con)
  forget_index()
  expect_warning(index_teams(), class = "sdvplotR_fallback")
  expect_identical(index_cache$source, "snapshot")
  expect_identical(nrow(index_aliases()), nrow(snapshot_aliases))
})

test_that("a failed manifest refresh with a stale cache warns and reports the cache", {
  local_fixture_index(ttl = 0)
  index_marks()
  expect_identical(index_cache$marks_source, "live")
  forget_index()
  withr::local_options(sdvplotR.manifest_url = "file:///nonexistent/marks.csv")
  expect_warning(index_marks(), class = "sdvplotR_fallback")
  expect_identical(index_cache$marks_source, "cache")
  expect_true("archive_url" %in% names(index_marks()))
})
