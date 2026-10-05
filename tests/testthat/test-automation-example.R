# The social automation example (examples/automation/sdvplotR_social.R) lives outside R/ and is
# not in the built package, so these tests run from a clone only. Everything is offline: the
# Bluesky calls go through a fake transport.

load_script <- function() {
  script <- test_path("..", "..", "examples", "automation", "sdvplotR_social.R")
  skip_if_not(file.exists(script), "the automation example is only in a clone of the repository")
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("httr2")
  env <- new.env()
  sys.source(script, envir = env) # defines the functions; main() runs only under Rscript
  env
}

# A fake transport: answers each XRPC method from `answers` (status + JSON body) and records the
# requests it was sent
fake_bluesky <- function(answers = list()) {
  response <- getExportedValue("httr2", "response")
  sent <- list()
  defaults <- list(
    com.atproto.server.createSession = list(200, list(accessJwt = "jwt", did = "did:plc:test")),
    com.atproto.repo.uploadBlob = list(200, list(blob = list(`$type` = "blob", mimeType = "image/png", size = 10))),
    com.atproto.repo.createRecord = list(200, list(uri = "at://did:plc:test/app.bsky.feed.post/1", cid = "c1"))
  )
  defaults[names(answers)] <- answers # replace whole answers (modifyList would merge them)
  answers <- defaults
  perform <- function(req) {
    sent[[length(sent) + 1]] <<- req
    answer <- answers[[sub(".*/xrpc/", "", req$url)]]
    response(
      status_code = answer[[1]], headers = list(`Content-Type` = "application/json"),
      body = charToRaw(as.character(jsonlite::toJSON(answer[[2]], auto_unbox = TRUE)))
    )
  }
  list(perform = perform, sent = function() sent)
}

write_post <- function(env, dir, key = "nfl-gameday-2026-10-04-1", fresh = TRUE, thread = "nfl-20261004") {
  png <- file.path(dir, paste0(key, ".png"))
  magick::image_write(magick::image_blank(40, 40, "white"), png, format = "png")
  image <- list(path = basename(png), alt = "A final-score card", width = 40, height = 40)
  list(
    key = key, fresh = fresh, thread = thread, league = "nfl", kind = "gameday",
    caption = "NFL final scores, Sunday, Oct 4, 2026.", hashtags = list("NFL", "sdvplotR"), images = list(image)
  )
}

test_that("arguments are parsed and checked", {
  env <- load_script()
  today <- as.Date("2026-10-05")

  args <- env$parse_args(c("leaderboard", "--league", "nfl"), today)
  expect_equal(args$command, "leaderboard")
  expect_equal(args$size, "square")
  expect_equal(args$out, "out")
  expect_null(args$top)

  args <- env$parse_args(c("gameday", "--league=nhl", "--max-games", "3"), today)
  expect_equal(args$date, as.Date("2026-10-04")) # yesterday by default
  expect_equal(args$max_games, 3L)

  args <- env$parse_args(c("post", "--post", "--include-stale"), today)
  expect_true(args$post)
  expect_true(args$include_stale)

  expect_error(env$parse_args(character()), class = "usage_error")
  expect_error(env$parse_args("tweet"), class = "usage_error")
  expect_error(env$parse_args(c("leaderboard", "--league", "xfl")), class = "usage_error")
  expect_error(env$parse_args(c("leaderboard", "--league", "nfl", "--top", "0")), class = "usage_error")
  expect_error(env$parse_args(c("gameday", "--league", "nfl", "--stat", "points")), class = "usage_error")
  expect_error(env$parse_args(c("gameday", "--league", "nfl", "--date", "10/04/2026")), class = "usage_error")
  expect_error(env$parse_args(c("leaderboard", "--league")), class = "usage_error")
})

test_that("seasons follow each league's calendar", {
  env <- load_script()
  expect_equal(env$season_of("nba", as.Date("2026-10-05")), 2027) # named by the year it ends
  expect_equal(env$season_of("nba", as.Date("2026-06-13")), 2026)
  expect_equal(env$season_of("nfl", as.Date("2027-01-10")), 2026)
  expect_equal(env$season_of("wnba", as.Date("2026-04-01")), 2025)
  expect_equal(env$season_label("nhl", 2027), "2026-27")
  expect_equal(env$season_label("mlb", 2026), "2026")
})

test_that("post text stays within 300 graphemes and keeps its hashtags", {
  env <- load_script()
  short <- list(caption = "NFL final scores.", hashtags = list("NFL", "sdvplotR"))
  expect_equal(env$post_text(short), "NFL final scores.\n\n#NFL #sdvplotR")

  long <- list(caption = strrep("A long caption. ", 40), hashtags = list("NFL", "sdvplotR"))
  text <- env$post_text(long)
  expect_lte(env$graphemes(text), 300)
  expect_match(text, "…\n\n#NFL #sdvplotR$")

  # a combining accent is part of the letter before it
  expect_equal(env$graphemes("Pérez"), 5)
})

test_that("hashtag facets use UTF-8 byte offsets", {
  env <- load_script()
  text <- "Niño scored.\n\n#NFL #sdvplotR"
  facets <- env$hashtag_facets(text)
  expect_length(facets, 2)
  bytes <- charToRaw(enc2utf8(text))
  first <- facets[[1]]$index
  expect_equal(first$byteStart, 15) # "Niño" is five bytes
  expect_equal(rawToChar(bytes[(first$byteStart + 1):first$byteEnd]), "#NFL")
  expect_equal(facets[[2]]$features[[1]]$tag, "sdvplotR")
  expect_equal(facets[[2]]$features[[1]]$`$type`, "app.bsky.richtext.facet#tag")
  expect_length(env$hashtag_facets("no tags here"), 0)
})

test_that("a re-run replaces its own posts in the manifest", {
  env <- load_script()
  out <- withr::local_tempdir()
  first <- write_post(env, out)
  env$write_manifest(out, list(first, write_post(env, out, key = "nfl-leaderboard", thread = "lb")))
  changed <- first
  changed$caption <- "Updated."
  path <- env$write_manifest(out, list(changed))
  posts <- jsonlite::read_json(path)$posts
  expect_length(posts, 2)
  expect_equal(vapply(posts, `[[`, "", "thread"), c("lb", "nfl-20261004"))
  expect_equal(posts[[2]]$caption, "Updated.")
})

test_that("posts that are posted, pending, stale or after a gap in their thread are skipped", {
  env <- load_script()
  posts <- list(
    list(key = "a", thread = "t", fresh = TRUE),
    list(key = "b", thread = "t", fresh = TRUE),
    list(key = "c", thread = "t", fresh = TRUE),
    list(key = "d", thread = "u", fresh = FALSE)
  )
  ledger <- list(a = list(status = "posted", uri = "at://a"), b = list(status = "pending"))
  reasons <- env$skip_reasons(posts, ledger)
  expect_match(reasons[1], "already posted")
  expect_match(reasons[2], "pending")
  expect_match(reasons[3], "earlier post of its thread")
  expect_match(reasons[4], "stale")
  expect_true(is.na(env$skip_reasons(posts[4], list(), include_stale = TRUE)))
})

test_that("a large PNG is sent as a JPEG under Bluesky's blob limit", {
  env <- load_script()
  path <- withr::local_tempfile(fileext = ".png")
  set.seed(1)
  noise <- grDevices::rgb(stats::runif(1e6), stats::runif(1e6), stats::runif(1e6))
  magick::image_write(magick::image_read(grDevices::as.raster(matrix(noise, 1000))), path, format = "png")
  expect_gt(file.size(path), 1e6)
  bytes <- env$image_bytes(path)
  expect_equal(bytes$type, "image/jpeg")
  expect_lte(length(bytes$data), 1e6)
})

test_that("post is a dry-run unless --post is given", {
  env <- load_script()
  out <- withr::local_tempdir()
  day <- file.path(out, "2026-10-05")
  dir.create(day)
  env$write_manifest(day, list(write_post(env, day)))
  args <- env$parse_args(c("post", "--out", out))
  fake <- fake_bluesky()
  expect_output(env$run_post(args, perform = fake$perform), "would post")
  expect_length(fake$sent(), 0)
  expect_false(file.exists(file.path(out, "posted.json")))
})

test_that("posting logs in, uploads with alt text, creates the post and records it", {
  env <- load_script()
  withr::local_envvar(BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = "app-pass", BSKY_SERVICE = "", GITHUB_REPOSITORY = "")
  out <- withr::local_tempdir()
  day <- file.path(out, "2026-10-05")
  dir.create(day)
  env$write_manifest(day, list(write_post(env, day)))
  args <- env$parse_args(c("post", "--out", out, "--post"))
  fake <- fake_bluesky()
  expect_output(env$run_post(args, perform = fake$perform), "posted at://")

  sent <- fake$sent()
  methods <- sub(".*/xrpc/", "", vapply(sent, `[[`, "", "url"))
  expect_equal(methods, c("com.atproto.server.createSession", "com.atproto.repo.uploadBlob", "com.atproto.repo.createRecord"))
  expect_equal(sent[[1]]$url, "https://bsky.social/xrpc/com.atproto.server.createSession")
  expect_equal(sent[[1]]$body$data$identifier, "me.bsky.social")
  expect_equal(sent[[2]]$body$type, "raw")
  expect_equal(sent[[2]]$body$content_type, "image/png")
  expect_true("Authorization" %in% names(sent[[3]]$headers))
  record <- sent[[3]]$body$data$record
  expect_equal(sent[[3]]$body$data$repo, "did:plc:test")
  expect_equal(record$text, "NFL final scores, Sunday, Oct 4, 2026.\n\n#NFL #sdvplotR")
  expect_equal(record$embed$images[[1]]$alt, "A final-score card")
  expect_equal(record$embed$images[[1]]$aspectRatio$width, 40)
  expect_length(record$facets, 2)

  ledger <- jsonlite::read_json(file.path(out, "posted.json"))
  expect_equal(ledger[["nfl-gameday-2026-10-04-1"]]$status, "posted")

  # a second run finds it in the ledger and does not even log in
  again <- fake_bluesky()
  expect_output(env$run_post(args, perform = again$perform), "already posted")
  expect_length(again$sent(), 0)
})

test_that("a refused post can be retried; an ambiguous one stays pending", {
  env <- load_script()
  withr::local_envvar(BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = "app-pass", BSKY_SERVICE = "", GITHUB_REPOSITORY = "")
  out <- withr::local_tempdir()
  day <- file.path(out, "2026-10-05")
  dir.create(day)
  env$write_manifest(day, list(write_post(env, day)))
  args <- env$parse_args(c("post", "--out", out, "--post"))
  ledger <- file.path(out, "posted.json")

  refused <- fake_bluesky(list(com.atproto.repo.createRecord = list(400, list(error = "InvalidRequest", message = "bad"))))
  err <- expect_error(env$run_post(args, perform = refused$perform), class = "post_error")
  expect_false(err$ambiguous)
  expect_match(conditionMessage(err), "HTTP 400 InvalidRequest")
  expect_no_match(conditionMessage(err), "app-pass") # never the credentials
  expect_length(jsonlite::read_json(ledger), 0)

  failed <- fake_bluesky(list(com.atproto.repo.createRecord = list(502, list(error = "BadGateway"))))
  err <- expect_error(env$run_post(args, perform = failed$perform), class = "post_error")
  expect_true(err$ambiguous)
  expect_equal(jsonlite::read_json(ledger)[["nfl-gameday-2026-10-04-1"]]$status, "pending")
})

test_that("the script refuses to post from sdvplotR's own CI", {
  env <- load_script()
  withr::local_envvar(BSKY_HANDLE = "me", BSKY_APP_PASSWORD = "pw", GITHUB_REPOSITORY = "sportsdataverse/sdvplotR")
  out <- withr::local_tempdir()
  day <- file.path(out, "2026-10-05")
  dir.create(day)
  env$write_manifest(day, list(write_post(env, day)))
  fake <- fake_bluesky()
  expect_error(env$run_post(env$parse_args(c("post", "--out", out, "--post")), perform = fake$perform), "refusing")
  expect_length(fake$sent(), 0)
})
