# R/scale_legend_icon.R

#' @importFrom ggplot2 ggplot_add
NULL

#' Legend helper for geom_pop icon legends
#'
#' Adds a legend override so legend keys can display the correct Font Awesome
#' icons associated with each group, without relying on `ggplot2::last_plot()`
#' (which breaks under `ggplotGrob()` / cowplot composition).
#'
#' @param size Numeric. Legend icon size (passed via `override.aes`).
#' @param margin A `ggplot2::margin()` object applied to `plot.margin`.
#'   Defaults to `ggplot2::margin(0, 0, 30, 0)` if `NULL`.
#' @param ... Passed to `ggplot2::guide_legend()` (e.g., `nrow`, `byrow`,
#'   `title.position`, etc.).
#'
#' @return A ggplot add-on object. Add it to a plot with `+ scale_legend_icon(...)`.
#' @export
scale_legend_icon <- function(size = 10, margin = NULL, ...) {
  structure(
    list(size = size, margin = margin, guide_args = list(...)),
    class = "ggpop_legend_icon"
  )
}

#' S3 method for adding ggpop_legend_icon objects to ggplot
#'
#' @method ggplot_add ggpop_legend_icon
#' @export
ggplot_add.ggpop_legend_icon <- function(object, plot, object_name) {
  
  if (is.null(object$margin)) object$margin <- ggplot2::margin(0, 0, 30, 0)
  
  # Extract layer-1 data from THIS plot (not last_plot)
  ld <- tryCatch(ggplot2::layer_data(plot, 1), error = function(e) NULL)
  
  # If the plot/layer doesn't expose the expected columns, just apply margin
  if (is.null(ld) || !("type" %in% names(ld)) || !("icon" %in% names(ld))) {
    return(plot + ggplot2::theme(plot.margin = object$margin))
  }
  
  # Determine legend key order from the trained color scale (breaks)
  sc <- plot$scales$get_scales("colour")
  if (is.null(sc)) sc <- plot$scales$get_scales("color")
  
  breaks <- NULL
  if (!is.null(sc)) {
    breaks <- sc$get_breaks()
    breaks <- breaks[!is.na(breaks)]
  }
  
  # Fallback: use factor levels or stable sort
  if (is.null(breaks) || length(breaks) == 0) {
    if (is.factor(ld$type)) breaks <- levels(ld$type)
    else breaks <- sort(unique(as.character(ld$type)))
  } else {
    breaks <- as.character(breaks)
  }
  
  # Build mapping: type -> first non-missing icon
  ld$type <- as.character(ld$type)
  ld$icon <- as.character(ld$icon)
  
  icon_map <- tapply(ld$icon, ld$type, function(x) {
    x <- x[!is.na(x) & nzchar(x)]
    if (length(x) == 0) NA_character_ else x[1]
  })
  
  # Icons in legend order
  icons <- unname(icon_map[breaks])
  icons[is.na(icons) | !nzchar(icons)] <- "user"
  
  # Build guide_legend with forwarded args (nrow/byrow/etc.)
  guide <- do.call(
    ggplot2::guide_legend,
    c(
      list(override.aes = list(icon = icons, size = object$size)),
      object$guide_args
    )
  )
  
  plot +
    ggplot2::guides(color = guide) +
    ggplot2::theme(plot.margin = object$margin)
}

  