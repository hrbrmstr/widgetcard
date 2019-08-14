#' Standard HTML Document with Twitter Tags
#'
#' @inheritParams rmarkdown::html_document
#' @export
twitter_document <- function (
  toc = FALSE, toc_depth = 3, toc_float = FALSE, number_sections = FALSE,
  section_divs = TRUE, fig_width = 7, fig_height = 5, fig_retina = 2,
  fig_caption = TRUE, dev = "png", df_print = "default",
  code_folding = c("none", "show", "hide"), code_download = FALSE, smart = TRUE,
  self_contained = TRUE, theme = "default", highlight = "default",
  mathjax = "default", extra_dependencies = NULL,
  css = NULL, includes = NULL, keep_md = FALSE, lib_dir = NULL,
  md_extensions = NULL, pandoc_args = NULL, ...) {


  rmarkdown::html_document(
    template = system.file('rmarkdown/templates/twittercard/default.html', package = 'widgetcard'),
    toc = toc,
    toc_depth = toc_depth,
    toc_float = toc_float,
    number_sections = number_sections,
    section_divs = section_divs,
    fig_width = fig_width,
    fig_height = fig_height,
    fig_retina = fig_retina,
    fig_caption = fig_caption,
    dev = dev,
    df_print = df_print,
    code_folding = code_folding,
    code_download = code_download,
    smart = smart,
    self_contained = self_contained,
    theme = theme,
    highlight = highlight,
    mathjax = mathjax,
    extra_dependencies = extra_dependencies,
    css = css,
    includes = includes,
    keep_md = keep_md,
    lib_dir = lib_dir,
    md_extensions = md_extensions,
    pandoc_args = pandoc_args,
    ...
  )

}