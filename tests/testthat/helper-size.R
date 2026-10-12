# Where a serialized object's bytes go: each top-level component's size and,
# for the environments its closures reach (up to a namespace or global), each
# environment's size and largest bindings. Used in failure labels, so a size
# regression on CI names its cause.
size_report <- function(x, top = 3) {
  sz <- function(o) length(serialize(o, NULL))
  parts <- vapply(x, sz, numeric(1))
  big <- utils::head(sort(parts, decreasing = TRUE), top)
  envs <- list()
  walk <- function(o, depth = 0) {
    if (depth > 6) return()
    if (is.function(o)) {
      e <- environment(o)
      while (!is.null(e) && !identical(e, emptyenv()) && !isNamespace(e) &&
             !identical(e, globalenv()) && !identical(e, baseenv())) {
        key <- format(e)
        if (is.null(envs[[key]])) {
          # size the environment first: get() forces its promises, and an
          # unforced promise is exactly what can make it large
          env_size <- sz(e)
          vars <- ls(e, all.names = TRUE)
          vs <- vapply(vars, function(v) sz(get(v, envir = e)), numeric(1))
          envs[[key]] <<- list(size = env_size, name = environmentName(e),
                               vars = utils::head(sort(vs, decreasing = TRUE), 3))
        }
        e <- parent.env(e)
      }
    } else if (is.list(o)) {
      for (el in o) walk(el, depth + 1)
    }
  }
  walk(x)
  env_txt <- vapply(envs, function(v) {
    paste0(v$name, "=", round(v$size / 1e6, 2), "MB[",
           paste0(names(v$vars), ":", round(v$vars / 1e6, 2), collapse = ","), "]")
  }, character(1))
  env_txt <- utils::head(env_txt[order(-vapply(envs, `[[`, numeric(1), "size"))], top)
  paste0(
    "parts: ", paste0(names(big), "=", round(big / 1e6, 2), "MB", collapse = ", "),
    "; envs: ", paste(env_txt, collapse = " | ")
  )
}
