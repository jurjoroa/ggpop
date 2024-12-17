#' Create a circular representative population chart
#' 
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image.
#' 
#' @section Aesthetics:
#' 
#' geom_pop employs the following aesthetics:
#' 
#' - **sample_size** - The number of individuals to be represented in the chart.
#' - alpha - The transparency of the points.
#' - color - The color of the points.
#' - size - The size of the points.
#' 
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param size The size of the points.
#' @param icon The icon to be used in the chart.
#' @importFrom ggplot2 layer
#' 
#' @export
#' 
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "default", ...) {
  
  # If mapping is provided, convert it to a list for manipulation
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # If the user tries to specify 'image' directly, raise an error
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use only 'icon'.")
  }
  
  # If 'icon' is not specified, use the provided default icon
  if (!"icon" %in% names(mapping_list)) {
    mapping_list[["icon"]] <- icon
  }
  
  # Create the image aesthetic from icon
  icon_expr <- mapping_list[["icon"]]
  mapping_list[["image"]] <- bquote(paste0("man/figures/", .(icon_expr), ".svg"))
  
  # Rebuild the aes mapping
  final_mapping <- do.call(aes_, mapping_list)
  
  ggimage::geom_image(mapping = final_mapping, data = data, stat = stat,
                      position = position, na.rm = na.rm, inherit.aes = inherit.aes, ...)
}




