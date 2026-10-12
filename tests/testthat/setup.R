# Tests run on the bundled index unless they opt into the fixture CDN
# (local_fixture_index()), so they never depend on the live CDN or warn when
# it is unreachable.
withr::local_options(sdvplotR.offline = TRUE, .local_envir = teardown_env())
