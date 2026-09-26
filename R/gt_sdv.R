# gt table helpers for sdvplotR
# ============================================================================

#' Render Logos in 'gt' Tables
#'
#' @description Translate team abbreviations into logos and render these images
#'   in html tables with the 'gt' package.
#'
#' @param gt_object A table object created using [gt::gt()].
#' @param columns The columns for which the image translation should be applied.
#'   Argument has no effect if `locations` is not `NULL`.
#' @param sport Character string identifying the sport.
#' @param height The absolute height (px) of the image in the table cell.
#' @param locations If `NULL` (the default), the function will render logos in
#'   argument `columns`. Otherwise, the cell or set of cells to be associated
#'   with the team name transformation. Only [gt::cells_body()],
#'   [gt::cells_stub()], [gt::cells_column_labels()], and
#'   [gt::cells_row_groups()] helper functions can be used here.
#'
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_wordmarks()], [gt_sdv_headshots()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' teams <- valid_team_names("nfl")[1:8]
#' df <- data.frame(
#'   team = teams,
#'   logo = teams,
#'   wins = sample(1:16, 8)
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_logos(columns = "logo", sport = "nfl")
#' }
gt_sdv_logos <- function(
    gt_object,
    columns,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    height = 30,
    locations = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())

  gt_sdv_image(
    gt_object = gt_object,
    columns = {{ columns }},
    height = height,
    locations = locations,
    sport = sport,
    type = "logo"
  )
}

#' Render Wordmarks in 'gt' Tables
#'
#' @description Translate team abbreviations into wordmarks and render these
#'   images in html tables with the 'gt' package.
#'
#' @inheritParams gt_sdv_logos
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_headshots()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' df <- data.frame(team = c("KC", "BUF", "SF"), wins = c(14, 13, 12))
#' df |>
#'   gt() |>
#'   gt_sdv_wordmarks(columns = "team", sport = "nfl")
#' }
gt_sdv_wordmarks <- function(
    gt_object,
    columns,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    height = 30,
    locations = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())

  gt_sdv_image(
    gt_object = gt_object,
    columns = {{ columns }},
    height = height,
    locations = locations,
    sport = sport,
    type = "wordmark"
  )
}

#' Render Player Headshots in 'gt' Tables
#'
#' @description Translate player IDs to player headshots and render these
#'   images in html tables with the 'gt' package. IDs are GSIS IDs for the NFL
#'   (`"00-0033873"`, resolved through the headshot map sdvplotR publishes from
#'   nflverse rosters to the player's NFL.com headshot) and ESPN athlete IDs for
#'   every other sport, or as `id_type` says. IDs that resolve to no headshot
#'   are left as text.
#'
#' @inheritParams gt_sdv_logos
#' @inheritParams geom_sdv_headshots
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_wordmarks()], [gt_sdv_cols_label()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   player_id = c("00-0033873", "00-0026498", "00-0035228"),
#'   player_name = c("P.Mahomes", "M.Stafford", "K.Murray")
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_headshots(columns = "player_id", sport = "nfl")
#' }
gt_sdv_headshots <- function(
    gt_object,
    columns,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    height = 30,
    locations = NULL,
    id_type = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  id_type <- check_id_type(id_type, sport)

  if (is.null(locations)) {
    locations <- gt::cells_body({{ columns }})
  }

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::text_transform(
    data = gt_object,
    locations = locations,
    fn = function(x) {
      image_urls <- headshot_from_id(x, sport = sport, id_type = id_type)
      missing <- is.na(image_urls)

      # web_image() needs a URL for every cell; IDs with none stay as text
      image_urls[missing] <- headshot_placeholder
      img_tags <- gt::web_image(image_urls, height = height)
      img_tags[missing] <- x[missing]

      img_tags
    }
  )
}

#' Render Logos in 'gt' Table Column Labels
#'
#' @description Translate team abbreviations into logos and render these images
#'   in column labels of 'gt' tables.
#'
#' @param gt_object A table object created using [gt::gt()].
#' @param columns The columns whose labels should be replaced with logos.
#' @param sport Character string identifying the sport.
#' @param height The absolute height (px) of the image.
#' @param type One of `"logo"`, `"wordmark"` or `"headshot"`: whether the column
#'   names are team abbreviations (logo / wordmark) or player IDs (headshot).
#' @inheritParams geom_sdv_headshots
#'
#' @return An object of class `gt_tbl`.
#' @seealso [gt_sdv_logos()], [gt_sdv_wordmarks()], [gt_sdv_headshots()]
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   KC = 1:3,
#'   BUF = 4:6,
#'   SF = 7:9
#' )
#'
#' df |>
#'   gt() |>
#'   gt_sdv_cols_label(columns = c("KC", "BUF", "SF"), sport = "nfl")
#' }
gt_sdv_cols_label <- function(
    gt_object,
    columns = gt::everything(),
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    height = 30,
    type = c("logo", "wordmark", "headshot"),
    id_type = NULL
) {
  sport <- rlang::arg_match0(sport, supported_sports())
  type <- rlang::arg_match0(type, c("logo", "wordmark", "headshot"))
  id_type <- check_id_type(id_type, sport)

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::cols_label_with(
    data = gt_object,
    columns = {{ columns }},
    fn = function(x) {
      if (type == "headshot") {
        image_url <- headshot_from_id(x, sport = sport, id_type = id_type)
        out <- gt::web_image(image_url, height = height)
        out[is.na(image_url)] <- x[is.na(image_url)]
      } else {
        team_abbr <- clean_team_abbrs(
          as.character(x),
          sport = sport,
          keep_non_matches = FALSE
        )

        if (type == "logo") {
          img_url <- logo_from_team(team_abbr, sport = sport)
        } else {
          img_url <- wordmark_from_team(team_abbr, sport = sport)
        }

        # Generate the HTML img tag
        out <- paste0(
          "<img src=\"",
          img_url,
          "\" style=\"height:",
          height,
          ";\" alt=\"The ",
          team_abbr,
          " logo\">"
        )

        # If the image url is NA we didn't find a match. Return the actual value
        out[is.na(img_url)] <- x[is.na(img_url)]
      }
      gt::html(out)
    }
  )
}


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

gt_sdv_image <- function(
    gt_object,
    columns,
    height = 30,
    locations = NULL,
    sport = "nfl",
    type = c("logo", "wordmark")
) {
  type <- match.arg(type)

  if (is.null(locations)) {
    locations <- gt::cells_body({{ columns }})
  }

  if (is.numeric(height)) {
    height <- paste0(height, "px")
  }

  gt::text_transform(
    data = gt_object,
    locations = locations,
    fn = function(x) {
      team_abbr <- clean_team_abbrs(
        as.character(x),
        sport = sport,
        keep_non_matches = FALSE
      )

      if (type == "logo") {
        img_url <- logo_from_team(team_abbr, sport = sport)
      } else {
        img_url <- wordmark_from_team(team_abbr, sport = sport)
      }

      # Generate the HTML img tag
      out <- paste0(
        "<img src=\"",
        img_url,
        "\" style=\"height:",
        height,
        ";\" alt=\"The ",
        team_abbr,
        " logo\">"
      )

      out <- lapply(out, gt::html)

      # If the image url is NA we didn't find a match. Return the actual value
      # to allow the user to call gt::sub_missing()
      out[is.na(img_url)] <- x[is.na(img_url)]
      out
    }
  )
}


# ---------------------------------------------------------------------------
# Team stacking for gt tables (from cfbplotR)
# ---------------------------------------------------------------------------

#' Merge and Stack Text in gt Tables with Team Colors
#'
#' @description Takes an existing `gt` table and merges column 1 and column 2,
#'   stacking column 1's text on top of column 2's. Top text is in all caps with
#'   black bold text, while the lower text is smaller and colored by the team name.
#'
#' @param gt_object An existing gt table object of class `gt_tbl`.
#' @param col1 The column to stack on top. Will be all caps, black bold text.
#' @param col2 The column to merge and place below. Will be smaller and colored.
#' @param team_col The column of team names for the color of the bottom text.
#' @param sport Character string identifying the sport.
#' @param font_size_top Font size for the top text.
#' @param font_size_bottom Font size for the bottom text.
#' @param color The color for the top text.
#'
#' @return An object of class `gt_tbl`.
#' @export
#' @examples
#' \donttest{
#' library(gt)
#' library(sdvplotR)
#'
#' df <- data.frame(
#'   team = c("KC", "BUF", "SF"),
#'   mascot = c("Chiefs", "Bills", "49ers"),
#'   wins = c(11, 10, 12)
#' )
#'
#' df |>
#'   gt() |>
#'   gt_merge_stack_team_color(team, mascot, team, sport = "nfl")
#' }
gt_merge_stack_team_color <- function(
    gt_object,
    col1,
    col2,
    team_col,
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb"),
    font_size_top = 14,
    font_size_bottom = 12,
    color = "black"
) {
  sport <- rlang::arg_match0(sport, supported_sports())

  stopifnot(
    "'gt_object' must be a 'gt_tbl', have you accidentally passed raw data?" =
      "gt_tbl" %in% class(gt_object)
  )

  team <- rlang::enexpr(team_col) |> rlang::as_string()
  team_bare <- gt_object[["_data"]][[team]]

  if (is.null(team_bare)) {
    cli::cli_abort("Must include a column of team names, `team_col` is NULL")
  }

  # Get team colors
  team_color <- sdv_team_colors(sport = sport, team = team_bare, type = "primary")
  team_color[is.na(team_color)] <- "grey"

  col1_bare <- rlang::enexpr(col1) |> rlang::as_string()
  row_name_var <- gt_object[["_boxbox"]][["var"]][which(gt_object[["_boxbox"]][["type"]] == "stub")]
  col2_bare <- rlang::enexpr(col2) |> rlang::as_string()
  data_in <- gt_object[["_data"]][[col2_bare]]

  gt_object |>
    gt::text_transform(
      locations = if (isTRUE(row_name_var == col1_bare)) {
        gt::cells_stub(rows = gt::everything())
      } else {
        gt::cells_body(columns = {{ col1 }})
      },
      fn = function(x) {
        glue::glue(
          "<div style='line-height:{font_size_top - 2}px'>",
          "<span style='font-weight:bold;font-variant:small-caps;color:{color};font-size:{font_size_top}px'>",
          "{x}</span></div>\n",
          "<div style='line-height:{font_size_bottom - 2}px'>",
          "<span style='font-weight:bold;color:{team_color};font-size:{font_size_bottom}px'>",
          "{data_in}</span></div>"
        )
      }
    ) |>
    gt::cols_hide(columns = {{ col2 }})
}
