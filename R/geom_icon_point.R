#' Create a scatter plot with Font Awesome icons instead of points
#'
#' Works exactly like geom_point(), but renders Font Awesome icons instead of dots.
#' Pass any data with x and y variables - no special formatting required.
#'
#' @section Aesthetics:
#' geom_icon_point uses standard ggplot2 scatter plot aesthetics:
#' - **x** - Numeric variable for x-axis
#' - **y** - Numeric variable for y-axis
#' - **icon** - Font Awesome icon name (optional, column or mapped)
#' - **color/colour** - Color grouping
#' - **alpha** - Transparency
#' - **size** - Icon size
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param icon Default Font Awesome icon (default: NULL).
#' @param size Default icon size (default: 1).
#' @param dpi Icon resolution (default: 50).
#' @param legend_icons Show icons in legend (default: TRUE).
#'
#' @return A ggplot layer.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' data <- data.frame(
#'   x = rnorm(20),
#'   y = rnorm(20),
#'   category = sample(c("A", "B", "C"), 20, replace = TRUE),
#'   icon = sample(c("heart", "star", "circle"), 20, replace = TRUE)
#' )
#'
#' # Map icon to a column
#' ggplot(data, aes(x = x, y = y, icon = icon, color = category)) +
#'   geom_icon_point()
#'
#' # Use a fixed icon
#' ggplot(data, aes(x = x, y = y, color = category)) +
#'   geom_icon_point(icon = "star")
#' }
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL, stat = "identity",
                            position = "identity", na.rm = FALSE,
                            inherit.aes = TRUE, icon = NULL,
                            size = 1, dpi = 50, legend_icons = TRUE, ...) {
  
  extra_args <- list(...)
  
  # Handle argument swapping
  swapped <- handle_argument_swap(mapping, data)
  mapping <- swapped$mapping
  data <- swapped$data
  
  # Extract plot context
  context <- extract_plot_context()
  plot_obj <- context$plot_obj
  inherited_mapping_list <- context$inherited_mappings
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # Aesthetic mappings
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # All validation
  validate_geom_icon_point(data, dpi, size, .missing_size, legend_icons, extra_args, mapping_list)
  
  # Warnings
  warn_size_conflict(combined_mapping, .missing_size, size)
  warn_alpha_conflict(combined_mapping, extra_args)
  
  # Icon handling
  icon_info <- resolve_icon_variable(mapping_list, inherited_mapping_list, 
                                     combined_mapping, icon, data)
  icon_var <- icon_info$icon_var
  data <- icon_info$data
  has_icon_param <- icon_info$has_icon_param
  
  # Add icon to mapping
  mapping_list <- add_icon_to_mapping(mapping_list, inherited_mapping_list, icon_var)
  
  # Normalize icon column
  data <- normalize_icon_column(data, icon_var)
  
  # Size handling
  size_result <- handle_size_aesthetic(data, combined_mapping, mapping_list, 
                                       inherited_mapping_list, size)
  data <- size_result$data
  mapping_list <- size_result$mapping_list
  
  # Generate icon images
  data <- add_icon_images(data, dpi)
  
  # Legend setup
  legend_var <- detect_legend_variable(combined_mapping, data)
  icon_by_legend <- create_icon_by_legend(data, legend_var, icon, has_icon_param)
  
  # Warning for multiple icons
  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    if (!is.numeric(data[[legend_var]])) {
      warn_multiple_icons_per_group(data, legend_var, "icon")
    }
  }
  
  # Final mapping
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["icon"]] <- NULL
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  # Create layer
  ggpop_layer <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = data,
    size         = data$icon_size,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_icon_point else ggplot2::draw_key_point,
    ...
  )
  
  # Attach metadata
  ggpop_layer$geom_params$icon_by_legend <- icon_by_legend
  ggpop_layer$geom_params$plot_obj <- plot_obj
  ggpop_layer$geom_params$dpi <- dpi
  
  ggpop_layer$ggpop_layer_type <- "icon_point"
  ggpop_layer$ggpop_legend_icons <- isTRUE(legend_icons)
  class(ggpop_layer) <- c("ggpop_icon_point_layer", class(ggpop_layer))
  
  ggpop_layer
}