# Bits copied from https://github.com/ramnathv/htmlwidgets/ to avoid :::

.globals <- new.env(parent = emptyenv())


DEFAULT_WIDTH <- 960
DEFAULT_HEIGHT <- 500
DEFAULT_PADDING <- 40
DEFAULT_WIDTH_VIEWER <- 450
DEFAULT_HEIGHT_VIEWER <- 350
DEFAULT_PADDING_VIEWER <- 15

# Copied from shiny 0.14.2
toJSON2 <- function(
  x, ...,  dataframe = "columns", null = "null", na = "null", auto_unbox = TRUE,
  digits = getOption("shiny.json.digits", 16), use_signif = TRUE, force = TRUE,
  POSIXt = "ISO8601", UTC = TRUE, rownames = FALSE, keep_vec_names = TRUE,
  strict_atomic = TRUE
) {
  if (strict_atomic) x <- I(x)
  jsonlite::toJSON(
    x, dataframe = dataframe, null = null, na = na, auto_unbox = auto_unbox,
    digits = digits, use_signif = use_signif, force = force, POSIXt = POSIXt,
    UTC = UTC, rownames = rownames, keep_vec_names = keep_vec_names,
    json_verbatim = TRUE, ...
  )
}

if (requireNamespace('shiny') && packageVersion('shiny') >= '0.12.0') local({
  tryCatch({
    toJSON <- getFromNamespace('toJSON', 'shiny')
    args2 <- formals(toJSON2)
    args1 <- formals(toJSON)
    if (!identical(args1, args2)) {
      warning('Check shiny:::toJSON and make sure htmlwidgets:::toJSON is in sync')
    }
  })
})

toJSON <- function(x) {
  if (!is.list(x) || !('x' %in% names(x))) return(toJSON2(x))
  func <- attr(x$x, 'TOJSON_FUNC', exact = TRUE)
  args <- attr(x$x, 'TOJSON_ARGS', exact = TRUE)
  if (length(args) == 0) args <- getOption('htmlwidgets.TOJSON_ARGS')
  if (!is.function(func)) func <- toJSON2
  res <- if (length(args) == 0) func(x) else do.call(func, c(list(x = x), args))
  # make sure shiny:::toJSON() does not encode it again
  structure(res, class = 'json')
}

`%||%` <- function(x, y){
  if (is.null(x)) y else x
}

prop <- function(x, path) {
  tryCatch({
    for (i in strsplit(path, "$", fixed = TRUE)[[1]]) {
      if (is.null(x))
        return(NULL)
      x <- x[[i]]
    }
    return(x)
  }, error = function(e) {
    return(NULL)
  })
}

any_prop <- function(scopes, path) {
  for (scope in scopes) {
    result <- prop(scope, path)
    if (!is.null(result))
      return(result)
  }
  return(NULL)
}


# Creates a list of keys whose values need to be evaluated on the client-side.
#
# It works by transforming \code{list(foo = list(1, list(bar =
# I('function(){}')), 2))} to \code{list("foo.2.bar")}. Later on the JS side, we
# will split foo.2.bar to ['foo', '2', 'bar'] and evaluate the JSON object
# member. Note '2' (character) should have been 2 (integer) but it does not seem
# to matter in JS: x[2] is the same as x['2'] when all child members of x are
# unnamed, and ('2' in x) will be true even if x is an array without names. This
# is a little hackish.
#
# @param list a list in which the elements that should be evaluated as
#   JavaScript are to be identified
# @author Yihui Xie
JSEvals <- function(list) {
  # the `%||% list()` part is necessary as of R 3.4.0 (April 2017) -- if `evals`
  # is NULL then `I(evals)` results in a warning in R 3.4.0. This is circumvented
  # if we let `evals` be equal to `list()` in those cases
  evals <- names(which(unlist(shouldEval(list)))) %||% list()
  I(evals)  # need I() to prevent toJSON() from converting it to scalar
}

#' JSON elements that are character with the class JS_EVAL will be evaluated
#'
#' @noRd
#' @keywords internal
shouldEval <- function(options) {
  if (is.list(options)) {
    if ((n <- length(options)) == 0) return(FALSE)
    # use numeric indices as names (remember JS indexes from 0, hence -1 here)
    if (is.null(names(options)))
      names(options) <- seq_len(n) - 1L
    # Escape '\' and '.' by prefixing them with '\'. This allows us to tell the
    # difference between periods as separators and periods that are part of the
    # name itself.
    names(options) <- gsub("([\\.])", "\\\\\\1", names(options))
    nms <- names(options)
    if (length(nms) != n || any(nms == ''))
      stop("'options' must be a fully named list, or have no names (NULL)")
    lapply(options, shouldEval)
  } else {
    is.character(options) && inherits(options, 'JS_EVAL')
  }
}
# JSEvals(list(list(foo.bar=JS("hi"), baz.qux="bye"))) == "0.foo\\.bar"

resolveSizing <- function(x, sp, standalone, knitrOptions = NULL) {
  if (isTRUE(standalone)) {
    userSized <- !is.null(x$width) || !is.null(x$height)
    viewerScopes <- list(sp$viewer, sp)
    browserScopes <- list(sp$browser, sp)
    # Precompute the width, height, padding, and fill for each scenario.
    return(list(
      runtime = list(
        viewer = list(
          width = x$width %||% any_prop(viewerScopes, "defaultWidth") %||% DEFAULT_WIDTH_VIEWER,
          height = x$height %||% any_prop(viewerScopes, "defaultHeight") %||% DEFAULT_HEIGHT_VIEWER,
          padding = any_prop(viewerScopes, "padding") %||% DEFAULT_PADDING_VIEWER,
          fill = !userSized && any_prop(viewerScopes, "fill") %||% TRUE
        ),
        browser = list(
          width = x$width %||% any_prop(browserScopes, "defaultWidth") %||% DEFAULT_WIDTH,
          height = x$height %||% any_prop(browserScopes, "defaultHeight") %||% DEFAULT_HEIGHT,
          padding = any_prop(browserScopes, "padding") %||% DEFAULT_PADDING,
          fill = !userSized && any_prop(browserScopes, "fill") %||% FALSE
        )
      ),
      width = x$width %||% prop(sp, "defaultWidth") %||% DEFAULT_WIDTH,
      height = x$height %||% prop(sp, "defaultHeight") %||% DEFAULT_HEIGHT
    ))
  } else if (!is.null(knitrOptions)) {
    knitrScopes <- list(sp$knitr, sp)
    isFigure <- any_prop(knitrScopes, "figure")
    figWidth <- if (isFigure) knitrOptions$out.width.px else NULL
    figHeight <- if (isFigure) knitrOptions$out.height.px else NULL
    # Compute the width and height
    return(list(
      width = x$width %||% figWidth %||% any_prop(knitrScopes, "defaultWidth") %||% DEFAULT_WIDTH,
      height = x$height %||% figHeight %||% any_prop(knitrScopes, "defaultHeight") %||% DEFAULT_HEIGHT
    ))
  } else {
    # Some non-knitr, non-print scenario.
    # Just resolve the width/height vs. defaultWidth/defaultHeight
    return(list(
      width = x$width %||% prop(sp, "defaultWidth") %||% DEFAULT_WIDTH,
      height = x$height %||% prop(sp, "defaultHeight") %||% DEFAULT_HEIGHT
    ))
  }
}

toHTML <- function(x, standalone = FALSE, knitrOptions = NULL) {

  sizeInfo <- resolveSizing(x, x$sizingPolicy, standalone = standalone, knitrOptions = knitrOptions)

  if (!is.null(x$elementId))
    id <- x$elementId
  else
    id <- paste("htmlwidget", createWidgetId(), sep="-")

  w <- validateCssUnit(sizeInfo$width)
  h <- validateCssUnit(sizeInfo$height)

  # create a style attribute for the width and height
  style <- paste(
    "width:", w, ";",
    "height:", h, ";",
    sep = "")

  x$id <- id

  container <- if (isTRUE(standalone)) {
    function(x) {
      div(id="htmlwidget_container", x)
    }
  } else {
    identity
  }

  html <- htmltools::tagList(
    container(
      htmltools::tagList(
        x$prepend,
        widget_html(
          name = class(x)[1],
          package = attr(x, "package"),
          id = id,
          style = style,
          class = paste(class(x)[1], "html-widget"),
          width = sizeInfo$width,
          height = sizeInfo$height
        ),
        x$append
      )
    ),
    widget_data(x, id),
    if (!is.null(sizeInfo$runtime)) {
      tags$script(type="application/htmlwidget-sizing", `data-for` = id,
                  toJSON(sizeInfo$runtime)
      )
    }
  )
  html <- htmltools::attachDependencies(html,
                                        c(widget_dependencies(class(x)[1], attr(x, 'package')),
                                          x$dependencies)
  )

  htmltools::browsable(html)

}

# create a new unique widget id
createWidgetId <- function(bytes = 10) {

  # Note what the system's random seed is before we start, so we can restore it after
  sysSeed <- .GlobalEnv$.Random.seed
  # Replace system seed with our own seed
  if (!is.null(.globals$idSeed)) {
    .GlobalEnv$.Random.seed <- .globals$idSeed
  }
  on.exit({
    # Change our own seed to match the current seed
    .globals$idSeed <- .GlobalEnv$.Random.seed
    # Restore the system seed--we were never here
    if(!is.null(sysSeed))
      .GlobalEnv$.Random.seed <- sysSeed
    else
      rm(".Random.seed", envir = .GlobalEnv)
  })

  paste(
    format(as.hexmode(sample(256, bytes, replace = TRUE)-1), width=2),
    collapse = "")
}

widget_html <- function(name, package, id, style, class, inline = FALSE, ...){

  # attempt to lookup custom html function for widget
  fn <- tryCatch(get(paste0(name, "_html"),
                     asNamespace(package),
                     inherits = FALSE),
                 error = function(e) NULL)

  # call the custom function if we have one, otherwise create a div
  if (is.function(fn)) {
    fn(id = id, style = style, class = class, ...)
  } else if (inline) {
    tags$span(id = id, style = style, class = class)
  } else {
    tags$div(id = id, style = style, class = class)
  }
}

widget_data <- function(x, id, ...){
  # It's illegal for </script> to appear inside of a script tag, even if it's
  # inside a quoted string. Fortunately we know that in JSON, the only place
  # the '<' character can appear is inside a quoted string, where a Unicode
  # escape has the same effect, without confusing the browser's parser. The
  # repro for the bug this gsub fixes is to have the string "</script>" appear
  # anywhere in the data/metadata of a widget--you will get a syntax error
  # instead of a properly rendered widget.
  #
  # Another issue is that if </body></html> appears inside a quoted string,
  # then when pandoc coverts it with --self-contained, the escaping gets messed
  # up. There may be other patterns that trigger this behavior, so to be safe
  # we can replace all instances of "</" with "\\u003c/".
  payload <- toJSON(createPayload(x))
  payload <- gsub("</", "\\u003c/", payload, fixed = TRUE)
  tags$script(type = "application/json", `data-for` = id, HTML(payload))
}

createPayload <- function(instance){
  if (!is.null(instance$preRenderHook)){
    instance <- instance$preRenderHook(instance)
    instance$preRenderHook <- NULL
  }
  x <- .subset2(instance, "x")
  list(x = x, evals = JSEvals(x), jsHooks = instance$jsHooks)
}

widget_dependencies <- function(name, package){
  getDependency(name, package)
}
