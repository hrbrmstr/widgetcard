#' Generate a Twitter Player card preview image from a ggplot2 plot
#'
#' Takes arguments similar to [ggplot2::ggsave()] and creates a temporary
#' plot file (png) to be used as input to [card_widget()].
#'
#' @param gg ggplot2 plot object
#' @param width,height width and height of the preview image. See References for guidelines
#' @param dpi see [ggplot2::ggsave()]
#' @return path to the preview image tempfile
#' @references
#' - <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/player-card.html>
#' - <https://sproutsocial.com/insights/social-media-image-sizes-guide/#twitter>
#' @export
gg_preview <- function(gg, width=350/72, height=196/72, dpi="retina") {

  preview <- tempfile(fileext = ".png")

  ggsave(
    filename = preview,
    plot = gg,
    width = 350/72, # ~72pts/inch
    height = 196/72,
    dpi = "retina"
  )

  preview

}
