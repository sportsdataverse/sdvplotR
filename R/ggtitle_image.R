# Functions for adding an image to the title of a ggplot
# ============================================================================

#' Functions for Adding an Image to the Title of a ggplot
#'
#' @description These functions work together to place an image to the left or
#'   right of the title in a ggplot. [ggtitle_image()] is the main function but
#'   must be used with either [theme_title_image()] or by setting the
#'   `plot.title` argument in [ggplot2::theme()] to [ggtext::element_markdown()].
#'
#' @param title_image The URL of the image to add to the title. If a valid
#'   team abbreviation for the specified sport, the team logo will be used.
#' @param title The text for the title.
#' @param image_height The height of the image in pixels.
#' @param image_side One of `"left"` or `"right"`. Places the image on either
#'   side of the title text.
#' @param subtitle Optional text for the subtitle.
#' @param sport Character string identifying the sport (for team logo resolution).
#' @param ... Other arguments passed on to [ggtext::element_markdown()].
#'
#' @name ggtitle_image
#' @return A ggplot2 labs object (for `ggtitle_image`) or theme object (for `theme_title_image`).
#' @seealso [theme_title_image()]
#' @export
#'
#' @examples
#' \donttest{
#' library(sdvplotR)
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x = hp, y = mpg)) +
#'   geom_point() +
#'   labs(title = "This Title will be overwritten",
#'        subtitle = "This is the Subtitle")
#'
#' if (requireNamespace("ggtext", quietly = TRUE)) {
#'   p +
#'     ggtitle_image(
#'       title_image = "KC",
#'       title = "Kansas City Chiefs Analysis",
#'       image_height = 20,
#'       image_side = "left",
#'       sport = "nfl"
#'     ) +
#'     theme(plot.title = ggtext::element_markdown(size = 20, hjust = 0.5))
#' }
#' }
ggtitle_image <- function(
    title_image = ggplot2::waiver(),
    title = ggplot2::waiver(),
    image_height = 15,
    image_side = c("left", "right"),
    subtitle = ggplot2::waiver(),
    sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
) {
  image_side <- match.arg(image_side)
  sport <- rlang::arg_match0(sport, supported_sports())

  if (inherits(title_image, "waiver")) {
    cli::cli_abort("{.arg title_image} must be a team abbreviation or an image URL.")
  }
  if (inherits(title, "waiver")) title <- ""

  # If title_image is a valid team name, use its logo
  team_check <- clean_team_abbrs(
    title_image,
    sport = sport,
    keep_non_matches = FALSE
  )
  if (!is.na(team_check)) {
    title_image <- logo_from_team(team_check, sport = sport)
  }

  title_image_tag <- paste0(
    "<img src='", title_image,
    "' height='", image_height,
    "' style='vertical-align: middle;'>"
  )

  title <- if (image_side == "right") {
    paste(title, title_image_tag)
  } else {
    paste(title_image_tag, title)
  }

  ggplot2::labs(title = title, subtitle = subtitle)
}

#' @rdname ggtitle_image
#' @export
theme_title_image <- function(...) {
  if (!is_installed("ggtext")) {
    cli::cli_abort(c(
      "Package {.val ggtext} required to use this function.",
      "i" = 'Please install it with {.code install.packages("ggtext")}'
    ))
  }
  loadNamespace("gridtext", versionCheck = list(op = ">=", version = "0.1.4"))
  ggplot2::theme(
    plot.title = ggtext::element_markdown(...)
  )
}
