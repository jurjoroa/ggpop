#' Legend helper for geom_pop icon legends
#'
#' Adds a legend override so legend keys can use the same icons used in the plot,
#' without relying on ggplot2::last_plot() (which breaks under ggplotGrob/cowplot).
#'
#' @param size Numeric. Legend icon size (passed via override.aes).
#' @param margin ggplot2::margin() for plot margin (defaults to bottom padding).
#' @param ... Additional arguments forwarded to ggplot2::guide_legend()
#'   (e.g., nrow, ncol, byrow, title.position, etc.).
#'
#' @inheritParams ggplot2::ggplot_add
#'
#' @return A ggplot2 add-on object. Add it with `+ scale_legend_icon(...)`.
#' @export
scale_legend_icon <- function(size = 10, margin = NULL, ...) {
  structure(
    list(
      size  = size,
      margin = margin,
      guide_args = list(...)
    ),
    class = "ggpop_legend_icon"
  )
}

#' @rdname scale_legend_icon
#' @export
#' @importFrom ggplot2 ggplot_add
ggplot_add.ggpop_legend_icon <- function(object, plot, ...) {
  
  if (is.null(object$margin)) object$margin <- ggplot2::margin(0, 0, 30, 0)
  
  ld <- tryCatch(ggplot2::layer_data(plot, 1), error = function(e) NULL)
  
  if (is.null(ld) || !("type" %in% names(ld)) || !("icon" %in% names(ld))) {
    return(plot + ggplot2::theme(plot.margin = object$margin))
  }
  
  sc <- plot$scales$get_scales("colour")
  if (is.null(sc)) sc <- plot$scales$get_scales("color")
  
  breaks <- NULL
  if (!is.null(sc)) {
    breaks <- sc$get_breaks()
    breaks <- breaks[!is.na(breaks)]
  }
  
  if (is.null(breaks) || length(breaks) == 0) {
    if (is.factor(ld$type)) breaks <- levels(ld$type)
    else breaks <- sort(unique(as.character(ld$type)))
  } else {
    breaks <- as.character(breaks)
  }
  
  ld$type <- as.character(ld$type)
  ld$icon <- as.character(ld$icon)
  
  icon_map <- tapply(ld$icon, ld$type, function(x) {
    x <- x[!is.na(x) & nzchar(x)]
    if (length(x) == 0) return(NA_character_)
    tab <- sort(table(x), decreasing = TRUE)
    names(tab)[1]
  })
  
  icons <- unname(icon_map[breaks])
  icons[is.na(icons) | !nzchar(icons)] <- "user"
  
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
