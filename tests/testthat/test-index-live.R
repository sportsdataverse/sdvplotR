skip_on_cran()
skip_if_offline("sdv.nyc3.cdn.digitaloceanspaces.com")
skip_if(Sys.getenv("SDVPLOTR_LIVE_TESTS") != "1", "set SDVPLOTR_LIVE_TESTS=1 for CDN tests")

test_that("the live CDN index loads and matches the bundled snapshot's version or a newer one", {
  withr::local_options(sdvplotR.offline = FALSE)
  withr::local_envvar(R_USER_CACHE_DIR = withr::local_tempdir())
  forget_index()
  withr::defer(forget_index())
  expect_no_warning(v <- sdv_versions())
  expect_identical(v$index_source, "live")
  expect_identical(v$manifest_source, "live")
  expect_match(v$index_version, "^[0-9a-f]{6,64}$")
})
