# Functions for adding an image to the title of a ggplot
# ============================================================================

#' Functions for Adding an Image to the Title of a ggplot
#'
#' @description These functions work together to place an image to the left or
#'   right of the title in a ggplot. [ggtitle_image()] is the main function but
#'   must be used with [theme_title_image()], which renders the title as
#'   markdown and centers the image on the title text.
#'
#' @details The title is markdown with an inline `<img>` tag. 'gridtext' draws
#'   inline images on the text baseline and ignores CSS `vertical-align`, so a
#'   logo taller than the text would rise above it (ESPN's marks, padded with
#'   transparent space, can sit wholly above the title). [theme_title_image()]
#'   lines the middle of each image up with the middle of the capital letters
#'   on its line. Setting `plot.title` to a plain [ggtext::element_markdown()]
#'   instead also renders the image, on the baseline.
#'
#'   Style the title through `theme_title_image(...)` (`size`, `face`,
#'   `hjust`, ...), never with a later `theme(plot.title = ...)`: adding
#'   `theme(plot.title = ggtext::element_markdown(hjust = 0.5))` after it
#'   replaces the centering element with a plain markdown one, so the image
#'   drops back to the baseline, and `theme(plot.title = element_text(...))`
#'   is an error. Add [theme_title_image()] after any complete theme such as
#'   [ggplot2::theme_minimal()], which replaces every element.
#'
#' @param title_image The URL of the image to add to the title. If a valid
#'   team abbreviation for the specified sport, the team logo will be used.
#' @param title The text for the title.
#' @param image_height The height of the image in pixels.
#' @param image_side One of `"left"` or `"right"`. Places the image on either
#'   side of the title text.
#' @param subtitle Optional text for the subtitle.
#' @param sport Character string identifying the sport (for team logo resolution).
#' @param ... Other arguments passed on to [ggtext::element_markdown()], such
#'   as `size`, `face` and `hjust`.
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
#'     theme_title_image(size = 20, hjust = 0.5)
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

  # gridtext ignores CSS vertical-align; theme_title_image() centers the image
  title_image_tag <- paste0("<img src='", title_image, "' height='", image_height, "'>")

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
  title <- ggtext::element_markdown(...)
  class(title) <- c("element_sdv_title_image", class(title))
  ggplot2::theme(plot.title = title)
}

#' @export
element_grob.element_sdv_title_image <- function(element, ...) {
  center_inline_images(NextMethod())
}

# gridtext puts an inline image's bottom on the baseline of its line. Line its
# middle up with the middle of the capital letters there instead, by raising
# the text (a tall image) or the image (a short one): either way the content
# stays inside the line box gridtext measured, so the title keeps its size.
center_inline_images <- function(grob) {
  if (!inherits(grob, "richtext_grob")) return(grob)
  pt <- function(u) grid::convertUnit(u, "pt", valueOnly = TRUE)
  cap <- pt(grid::grobHeight(grid::textGrob("H", gp = grob$gp)))
  boxes <- lapply(grob$children, function(box) {
    kids <- box$children
    for (i in which(vapply(kids, inherits, logical(1), "rastergrob"))) {
      base <- pt(kids[[i]]$y)
      shift <- grid::unit((pt(kids[[i]]$height) - cap) / 2, "pt")
      if (as.numeric(shift) < 0) {
        kids[[i]]$y <- kids[[i]]$y - shift
        next
      }
      for (j in seq_along(kids)) {
        if (inherits(kids[[j]], "text") && abs(pt(kids[[j]]$y) - base) < 1e-6) {
          kids[[j]]$y <- kids[[j]]$y + shift
        }
      }
    }
    grid::setChildren(box, do.call(grid::gList, kids))
  })
  grid::setChildren(grob, do.call(grid::gList, boxes))
}
