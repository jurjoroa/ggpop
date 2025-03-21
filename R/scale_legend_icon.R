#' Adjust legend to display custom icons for each group type
#'
#' This helper function extracts the grouping variable (`type`) from the data
#' used in the `geom_pop` object and applies the corresponding
#' icons (stored in the `icon` column) as legend keys. It overrides the default
#' legend keys to use custom icon glyphs (via `draw_key_pop_image`) and sets
#' a specified legend key size.
#'
#' @param size A numeric value specifying the size of the icons in the legend.
#'   Larger values create bigger icons.
#' @param ... Additional parameters passed on to [ggplot2::guide_legend()]. This
#'   lets you control all aspects of the legend, such as `title`, `title.position`,
#'   `label.position`, `label.theme`, and so forth.
#'
#' @return A `guides()` specification that you can add to your ggplot object.
#' 
#' @importFrom ggplot2 aes labs theme ggplot_build last_plot
#'
#' @export
scale_legend_icon <- function(size = 10, ...) {
  # Retrieve the built plot data
  gg_obj <- ggplot2::last_plot()
  
  data <- gg_obj$layers[[1]]$data

  # type
  types <- levels(factor(data$type))
  
  # icon
  icons <- sapply(types, function(t) {
    idx <- which(data$type == t)
    data$icon[idx[1]]
  })
  
  ggplot2::guides(
    color = ggplot2::guide_legend(
      override.aes = list(icon = icons, size = size),
      ...
    )
  )
}

