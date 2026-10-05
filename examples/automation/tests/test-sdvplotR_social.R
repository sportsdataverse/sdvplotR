# Offline tests of the social automation example (../sdvplotR_social.R). They live beside the
# script, outside the package (examples/ is build-ignored), and run from a clone with
#   Rscript -e 'testthat::test_file("examples/automation/tests/test-sdvplotR_social.R")'
# The Bluesky calls go through a fake transport.

load_script <- function() {
  script <- test_path("..", "sdvplotR_social.R") # test_file() runs from this file's folder
  skip_if_not(file.exists(script), "sdvplotR_social.R is not beside its tests")
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("httr2")
  env <- new.env()
  sys.source(script, envir = env) # defines the functions; main() runs only under Rscript
  env
}

# A fake transport: answers each XRPC method from `answers` and records the requests it was sent.
# An answer is list(status, body, headers), a string (the request fails with that message), or a
# list of those, used in turn (the last one repeats).
fake_bluesky <- function(answers = list()) {
  response <- getExportedValue("httr2", "response")
  sent <- list()
  defaults <- list(
    com.atproto.server.createSession = list(200, list(accessJwt = "jwt", did = "did:plc:test")),
    com.atproto.repo.uploadBlob = list(200, list(blob = list(`$type` = "blob", mimeType = "image/png", size = 10))),
    com.atproto.repo.createRecord = list(200, list(uri = "at://did:plc:test/app.bsky.feed.post/1", cid = "c1"))
  )
  defaults[names(answers)] <- answers # replace whole answers (modifyList would merge them)
  answers <- lapply(defaults, function(a) if (is.character(a) || is.numeric(a[[1]])) list(a) else a)
  used <- list()
  perform <- function(req) {
    sent[[length(sent) + 1]] <<- req
    method <- sub(".*/xrpc/", "", req$url)
    used[[method]] <<- if (is.null(used[[method]])) 1 else used[[method]] + 1
    steps <- answers[[method]]
    answer <- steps[[min(used[[method]], length(steps))]]
    if (is.character(answer)) stop(answer)
    response(
      status_code = answer[[1]], headers = c(list(`Content-Type` = "application/json"), if (length(answer) > 2) answer[[3]]),
      body = charToRaw(as.character(jsonlite::toJSON(answer[[2]], auto_unbox = TRUE)))
    )
  }
  list(perform = perform, sent = function() sent)
}
methods_sent <- function(fake) sub(".*/xrpc/", "", vapply(fake$sent(), `[[`, "", "url"))

# out/<day>/manifest.json holding `posts` (one fresh game-day post by default); returns `out`
manifest_dir <- function(env, posts = NULL, day = "2026-10-05") {
  out <- withr::local_tempdir(.local_envir = parent.frame())
  dir <- file.path(out, day)
  dir.create(dir)
  env$write_manifest(dir, if (is.null(posts)) list(write_post(env, dir)) else posts)
  out
}
TODAY <- as.Date("2026-10-05")
SECRET <- "app-pass-SECRET-42"

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
  expect_null(env$parse_args(c("gameday", "--league", "nfl"), today)$max_games) # every game by default

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
  out <- manifest_dir(env)
  args <- env$parse_args(c("post", "--out", out))
  fake <- fake_bluesky()
  expect_output(env$run_post(args, perform = fake$perform, today = TODAY), "would post")
  expect_length(fake$sent(), 0)
  expect_false(file.exists(file.path(out, "posted.json")))
})

test_that("posting logs in, uploads with alt text, creates the post and records it", {
  env <- load_script()
  withr::local_envvar(
    BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = SECRET, BSKY_SERVICE = "", GITHUB_REPOSITORY = ""
  )
  out <- manifest_dir(env)
  args <- env$parse_args(c("post", "--out", out, "--post"))
  fake <- fake_bluesky()
  expect_output(env$run_post(args, perform = fake$perform, today = TODAY), "posted at://")

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
  expect_output(env$run_post(args, perform = again$perform, today = TODAY), "already posted")
  expect_length(again$sent(), 0)
})

test_that("a refused post can be retried; an ambiguous one stays pending", {
  env <- load_script()
  withr::local_envvar(
    BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = SECRET, BSKY_SERVICE = "", GITHUB_REPOSITORY = ""
  )
  out <- manifest_dir(env)
  args <- env$parse_args(c("post", "--out", out, "--post"))
  ledger <- file.path(out, "posted.json")

  refused <- fake_bluesky(list(com.atproto.repo.createRecord = list(400, list(error = "InvalidRequest", message = "bad"))))
  err <- expect_error(env$run_post(args, perform = refused$perform, today = TODAY), class = "post_error")
  expect_false(err$ambiguous)
  expect_match(conditionMessage(err), "HTTP 400 InvalidRequest")
  expect_length(jsonlite::read_json(ledger), 0)

  failed <- fake_bluesky(list(com.atproto.repo.createRecord = list(502, list(error = "BadGateway"))))
  err <- expect_error(
    env$run_post(args, perform = failed$perform, sleep = function(s) NULL, today = TODAY),
    class = "post_error"
  )
  expect_true(err$ambiguous)
  expect_equal(sum(methods_sent(failed) == "com.atproto.repo.createRecord"), 1) # never sent twice
  expect_equal(jsonlite::read_json(ledger)[["nfl-gameday-2026-10-04-1"]]$status, "pending")
})

test_that("the script refuses to post from sdvplotR's own CI", {
  env <- load_script()
  withr::local_envvar(BSKY_HANDLE = "me", BSKY_APP_PASSWORD = "pw", GITHUB_REPOSITORY = "sportsdataverse/sdvplotR")
  out <- manifest_dir(env)
  fake <- fake_bluesky()
  expect_error(
    env$run_post(env$parse_args(c("post", "--out", out, "--post")), perform = fake$perform, today = TODAY),
    "refusing"
  )
  expect_length(fake$sent(), 0)
})

test_that("a season is in progress while regular-season games are left, and runs through the last one played", {
  env <- load_script()
  state <- function(league, raw) env$schedule_state(env$standard_schedule(league, raw))

  # the NFL: playoff games left do not make the regular season in progress
  nfl <- data.frame(
    gameday = c("2026-12-27", "2027-01-03", "2027-01-10"), game_type = c("REG", "REG", "WC"), result = c(3, -7, NA)
  )
  expect_false(state("nfl", nfl)$in_progress)
  expect_equal(state("nfl", nfl)$through, as.Date("2027-01-03"))
  nfl$result[2] <- NA
  expect_true(state("nfl", nfl)$in_progress)
  expect_equal(state("nfl", nfl)$through, as.Date("2026-12-27"))

  # the NBA and WNBA: the regular season is over when its games are, playoffs or not
  nba <- data.frame(
    game_date = as.Date(c("2026-04-12", "2026-04-20")), season_type = c(2L, 3L), status_type_completed = c(TRUE, FALSE)
  )
  expect_false(state("nba", nba)$in_progress)
  expect_equal(state("wnba", nba)$through, as.Date("2026-04-12"))
  # a postponed game stays in the schedule beside its replay, never completed
  nba$status_type_name <- c("STATUS_FINAL", "STATUS_SCHEDULED")
  postponed <- rbind(nba, data.frame(
    game_date = as.Date("2026-01-25"), season_type = 2L, status_type_completed = FALSE,
    status_type_name = "STATUS_POSTPONED"
  ))
  expect_false(state("nba", postponed)$in_progress)

  # the NHL: a three-week break mid-season is still the season
  nhl <- data.frame(
    game_id = c(2025020001, 2025020002), game_date = c("2026-01-10", "2026-02-01"), game_state = c("OFF", "FUT")
  )
  expect_true(state("nhl", nhl)$in_progress)
  expect_equal(state("nhl", nhl)$through, as.Date("2026-01-10"))

  # MLB: a postponed game is not a game left to play
  mlb <- data.frame(
    official_date = c("2026-09-27", "2026-09-28", "2026-10-04"), game_type = c("R", "R", "F"),
    status_abstract_game_state = c("Final", "Preview", "Preview"),
    status_detailed_state = c("Final", "Postponed", "Scheduled")
  )
  expect_false(state("mlb", mlb)$in_progress)
  expect_equal(state("mlb", mlb)$through, as.Date("2026-09-27"))
})

test_that("a capped slate says how many games it shows", {
  env <- load_script()
  day <- as.Date("2026-10-04")
  expect_equal(env$gameday_caption("NFL", "", day, 14, 14), "NFL final scores, Sunday, Oct 4, 2026.")
  expect_equal(
    env$gameday_caption("NFL", "postseason", day, 8, 14),
    "NFL postseason final scores, Sunday, Oct 4, 2026 (8 of 14 games)."
  )
})

test_that("an old manifest's posts are stale at post time", {
  env <- load_script()
  out <- manifest_dir(env, day = "2026-09-01")
  fake <- fake_bluesky()
  expect_output(env$run_post(env$parse_args(c("post", "--out", out)), perform = fake$perform, today = TODAY), "stale")
  expect_output(
    env$run_post(env$parse_args(c("post", "--out", out, "--include-stale")), perform = fake$perform, today = TODAY),
    "would post"
  )
  # yesterday's manifest is still fresh (a Monday run posts Sunday's games)
  out <- manifest_dir(env, day = "2026-10-04")
  expect_output(env$run_post(env$parse_args(c("post", "--out", out)), perform = fake$perform, today = TODAY), "would post")
})

test_that("the app password never reaches output or errors", {
  env <- load_script()
  withr::local_envvar(
    BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = SECRET, BSKY_SERVICE = "", GITHUB_REPOSITORY = ""
  )
  out <- manifest_dir(env)
  args <- env$parse_args(c("post", "--out", out, "--post"))
  no_secret <- function(fake) {
    err <- NULL
    printed <- capture.output(
      err <- tryCatch(
        env$run_post(args, perform = fake$perform, sleep = function(s) NULL, today = TODAY),
        error = function(e) e
      ),
      type = "output"
    )
    printed <- c(printed, capture.output(print(err)), conditionMessage(err))
    expect_s3_class(err, "post_error")
    expect_false(any(grepl(SECRET, printed, fixed = TRUE)))
    err
  }
  # a rejected login
  err <- no_secret(fake_bluesky(list(com.atproto.server.createSession = list(
    401, list(error = "AuthenticationRequired", message = "Invalid identifier or password")
  ))))
  expect_match(conditionMessage(err), "HTTP 401 AuthenticationRequired")
  # a transport error whose message carries the request body
  err <- no_secret(fake_bluesky(list(
    com.atproto.server.createSession = paste("Failed to connect; body: password", SECRET)
  )))
  expect_match(conditionMessage(err), "createSession: network error")
})

test_that("rate limits and server errors are retried; creating a post is not after a 5xx", {
  env <- load_script()
  withr::local_envvar(
    BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = SECRET, BSKY_SERVICE = "", GITHUB_REPOSITORY = ""
  )
  args <- function(out) env$parse_args(c("post", "--out", out, "--post"))
  waits <- numeric()
  sleep <- function(s) waits <<- c(waits, s)

  reset <- as.character(floor(as.numeric(Sys.time())) + 5)
  fake <- fake_bluesky(list(
    com.atproto.repo.uploadBlob = list(
      list(429, list(error = "RateLimitExceeded"), list(`ratelimit-reset` = reset)),
      list(503, list(error = "Unavailable")),
      "connection reset",
      list(200, list(blob = list(`$type` = "blob")))
    ),
    com.atproto.repo.createRecord = list(
      list(429, list(error = "RateLimitExceeded")),
      list(200, list(uri = "at://p/1", cid = "c1"))
    )
  ))
  expect_output(
    env$run_post(args(manifest_dir(env)), perform = fake$perform, sleep = sleep, today = TODAY),
    "posted at://p/1"
  )
  expect_equal(sum(methods_sent(fake) == "com.atproto.repo.uploadBlob"), 4)
  # a 429 was refused, so creating the post can be sent again
  expect_equal(sum(methods_sent(fake) == "com.atproto.repo.createRecord"), 2)
  expect_length(waits, 4)
  expect_true(waits[1] >= 1 && waits[1] <= 60) # until Bluesky's reset time, at most a minute
  expect_equal(waits[2:3], c(2, 4)) # then backing off

  # four 429s in a row end the call
  fake <- fake_bluesky(list(com.atproto.repo.uploadBlob = list(429, list(error = "RateLimitExceeded"))))
  expect_error(
    env$run_post(args(manifest_dir(env)), perform = fake$perform, sleep = sleep, today = TODAY),
    "HTTP 429"
  )
  expect_equal(sum(methods_sent(fake) == "com.atproto.repo.uploadBlob"), 4)

  # a network error on createRecord is never retried
  fake <- fake_bluesky(list(com.atproto.repo.createRecord = "timeout"))
  err <- expect_error(
    env$run_post(args(manifest_dir(env)), perform = fake$perform, sleep = sleep, today = TODAY),
    class = "post_error"
  )
  expect_true(err$ambiguous)
  expect_equal(sum(methods_sent(fake) == "com.atproto.repo.createRecord"), 1)
})

test_that("a half-posted thread resumes, replying to the post already made", {
  env <- load_script()
  withr::local_envvar(
    BSKY_HANDLE = "me.bsky.social", BSKY_APP_PASSWORD = SECRET, BSKY_SERVICE = "", GITHUB_REPOSITORY = ""
  )
  out <- withr::local_tempdir()
  dir <- file.path(out, "2026-10-05")
  dir.create(dir)
  env$write_manifest(dir, list(
    write_post(env, dir, key = "nfl-gameday-2026-10-04-1"),
    write_post(env, dir, key = "nfl-gameday-2026-10-04-2")
  ))
  first <- list(
    status = "posted", uri = "at://did:plc:test/app.bsky.feed.post/first", cid = "cid-first",
    at = "2026-10-05T14:00:00Z"
  )
  jsonlite::write_json(list(`nfl-gameday-2026-10-04-1` = first), file.path(out, "posted.json"), auto_unbox = TRUE)

  fake <- fake_bluesky()
  expect_output(
    env$run_post(env$parse_args(c("post", "--out", out, "--post")), perform = fake$perform, today = TODAY),
    "already posted"
  )
  creates <- Filter(function(r) grepl("createRecord$", r$url), fake$sent())
  expect_length(creates, 1)
  reply <- creates[[1]]$body$data$record$reply
  expect_equal(reply$root$uri, first$uri)
  expect_equal(reply$parent$cid, first$cid)
  ledger <- jsonlite::read_json(file.path(out, "posted.json"))
  expect_equal(ledger[["nfl-gameday-2026-10-04-2"]]$status, "posted")
})
