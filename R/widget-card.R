#' Turn an htmlwidget into a web deployable, interactive Twitter card
#'
#' Provide a preview image and a widget, plus Twitter Player card metadata and get pack
#' a packaged up, ready-to-deploy archive to deploy and used on Twitter.
#'
#' You can use [Twitter's Validator](https://cards-dev.twitter.com/validator) to ensure
#' your creation is usable before trying it in a tweet.
#'
#' @param widget an `htmlwidget`
#' @param output_dir the path to save the card-able widget to. If the directory does
#'        not exist it will be created for you (recursively). The value will be
#'        [path.expand()]ed.
#' @param name_prefix the name-prefix for the widget's `.html` file and `preview_img` file.
#' @param preview_img the path to the local preview image for the card-able widget. This
#'        file must exist and will be copied over to the deployable directory and renamed
#'        (see `name_prefix` above). Follow the guidelines
#'        [here](https://sproutsocial.com/insights/social-media-image-sizes-guide/#twitter)
#'        regarding image sizes.
#' @param html_title the title for the `htmlwidget` HTML file's `<title>` tag.
#' @param card_twitter_handle Your twitter handle _including_ the `@@`.
#' @param card_title,card_description The title and description that will be displayed in the tweet
#' @param card_image_url_prefix Prefix URL for where you will be copying the preview image to.
#'        Generally, this wil be the same as `card_player_url_prefix` but you can specify
#'        another URL prefix if storing images on a separate server or separate directory.
#' @param card_player_url_prefix Prefix URL for where you will be copying the `htmlwidget`
#'        HTML and supporting javascript libraries to. Generally, this wil be the same as
#'        `card_image_url_prefix` but you can specify another URL prefix if storing images
#'        on a separate server or separate directory.
#' @param card_player_width,card_player_height the width and height for the player window in-tweet.
#'        These default to 480x480 and you should review the References section for
#'        links to guidelines for Twitter preferred image sizes.
#' @param background `htmlwidget` background coloe. Defaults to `white`. Can be a hashed-prefixed
#'        hex value (if so, will be converted to `rgba()` spec)
#' @param bundle_type either `tgz` for a gzip'd/tar archive or `zip` for a ZIP archive. The
#'        directory named `name_prefix` will be placed into the archive.
#' @return the `path.expand()`ed path to the `bundle_type`. The archive name will be `name_prefix`
#'         plus the `bundle_type` extension.
#' @note  You can and should use [Twitter's Validator](https://cards-dev.twitter.com/validator)
#'        to ensure your creation is usable before trying it in a tweet.
#' @references
#' - <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/player-card.html>
#' - <https://sproutsocial.com/insights/social-media-image-sizes-guide/#twitter>
#' - <https://github.com/twitterdev/cards-player-samples>
#' @export
card_widget <- function(widget,
                        output_dir = ulid::ulid_generate(),
                        name_prefix = "wdgtcrd",
                        preview_img,
                        html_title = class(widget)[[1]],
                        card_twitter_handle = "",
                        card_title = title[[1]],
                        card_description = "",
                        card_image_url_prefix = "",
                        card_player_url_prefix = "",
                        card_player_width = 480,
                        card_player_height = 480,
                        background = "white",
                        bundle_type = c("tgz", "zip")) {

  bundle_type <- match.arg(bundle_type[[1]], c("tgz", "zip"))

  # convert background to rgba spec if hex

  if (grepl("^#", background[[1]], perl = TRUE)) {
    bgcol <- grDevices::col2rgb(background[[1]], alpha = TRUE)
    background <- sprintf(
      "rgba(%d,%d,%d,%f)",
      bgcol[1, 1], bgcol[2, 1], bgcol[3, 1], (bgcol[4, 1] / 255)
    )
  }

  # setup output

  output_dir <- path.expand(output_dir[[1]])
  preview_img <- path.expand(preview_img[[1]])

  stopifnot(file.exists(preview_img)) # can't find preview img

  if (!dir.exists(output_dir)) dir.create(output_dir, recursive=TRUE)

  file.copy(
    from = preview_img,
    to = file.path(
      output_dir,
      sprintf("%s.%s", name_prefix, tools::file_ext(preview_img))
    )
  )

  toHTML(
    x = widgetframe::frameableWidget(widget),
    standalone = FALSE
  ) -> widget_html

  libdir <- paste(tools::file_path_sans_ext(basename(name_prefix)), "_files", sep = "")

  card_image_url_prefix <- sub("/$", "", card_image_url_prefix)
  card_player_url_prefix <- sub("/$", "", card_player_url_prefix)

  file.path(
    card_image_url_prefix,
    sprintf("%s.%s", name_prefix, tools::file_ext(preview_img))
  ) -> card_image_url

  file.path(
    card_player_url_prefix, sprintf("%s.html", name_prefix)
  ) -> card_player_url

  htmltools::tagList(
    htmltools::tags$head(
      htmltools::tags$title(html_title),
      htmltools::tags$meta(name = "twitter:card", content = "player"),
      htmltools::tags$meta(name = "twitter:site", content = card_twitter_handle),
      htmltools::tags$meta(name = "twitter:title", content = card_title),
      htmltools::tags$meta(name = "twitter:description", content = card_description),
      htmltools::tags$meta(name = "twitter:image", content = card_image_url),
      htmltools::tags$meta(name = "twitter:player", content = card_player_url),
      htmltools::tags$meta(name = "twitter:player:width", content = card_player_width),
      htmltools::tags$meta(name = "twitter:player:height", content = card_player_height)
    ),
    widget_html
  ) -> widget_html

  htmltools::save_html(
    html = widget_html,
    file = file.path(output_dir, sprintf("%s.html", name_prefix)),
    libdir = libdir,
    background = background
  )

  cd <- getwd()
  on.exit(setwd(cd), add=TRUE)

  setwd(sprintf("%s/..", output_dir))

  if (bundle_type == "tgz") {
    arc_name <- sprintf("%s.tgz", output_dir)
    utils::tar(
      tarfile = arc_name,
      files = name_prefix,
      compression = "gzip"
    )
  } else {
    arc_name <- sprintf("%s.zip", output_dir)
    utils::zip(
      zipfile = arc_name,
      files = name_prefix
    )
  }

  arc_name

}
