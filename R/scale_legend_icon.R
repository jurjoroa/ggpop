#' Legend helper for geom_pop icon legends
#'
#' @param size Numeric. Legend key size in mm (this controls icon size).
#' @param margin ggplot2::margin() for plot margin (defaults to bottom padding).
#' @param ... Additional arguments forwarded to ggplot2::guide_legend()
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

#' @export
#' @importFrom ggplot2 ggplot_add
ggplot_add.ggpop_legend_icon <- function(object, plot, ...) {
  
  if (is.null(object$margin)) object$margin <- ggplot2::margin(0, 0, 30, 0)
  
  key_mm <- object$size
  if (!is.numeric(key_mm) || length(key_mm) != 1 || is.na(key_mm) || key_mm <= 0) key_mm <- 10
  
  # Apply the theme changes now
  plot <- plot +
    ggplot2::theme(
      plot.margin      = object$margin,
      legend.key.size  = grid::unit(key_mm, "mm"),
      legend.key.width = grid::unit(key_mm, "mm"),
      legend.key.height= grid::unit(key_mm, "mm")
    )
  
  plot
}
