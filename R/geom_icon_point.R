#' Create a scatter plot with Font Awesome icons instead of points
#'
#' Works exactly like geom_point(), but renders Font Awesome icons instead of dots.
#' Pass any data with x and y variables - no special formatting required.
#'
#' @section Aesthetics:
#' geom_icon_point uses standard ggplot2 scatter plot aesthetics:
#' - x - Numeric variable for x-axis
#' - y - Numeric variable for y-axis
#' - icon - Font Awesome icon name (optional, column or mapped)
#' - color/colour - Color grouping
#' - alpha - Transparency
#' - size - Icon size
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @param icon Default Font Awesome icon (default: NULL).
#' @param size Default icon size (default: 3).
#' @param dpi Icon resolution (default: 50).
#' @param legend_icons Show icons in legend (default: TRUE).
#'
#' @return A ggplot layer.
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL,
                            position = "identity", na.rm = FALSE,
                            inherit.aes = TRUE, icon = NULL,
                            size = 1, dpi = 50, legend_icons = TRUE, ...) {
  
  validate_dpi(dpi)
  validate_size(size, missing(size))
  validate_legend_icons(legend_icons)
  
  build_id <- paste0("ggpop_", as.integer(Sys.time()), "_",
                     paste(sample(c(letters, 0:9), 8, TRUE), collapse = ""))
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # CHECK FOR SIZE CONFLICT BEFORE HANDLING
  user_mapped_size_in_layer <- "size" %in% names(mapping_list)
  
  if (user_mapped_size_in_layer && !missing(size)) {
    cli::cli_warn(c(
      "size specified both in {.code aes()} and as a parameter.",
      " " = "",
      "!" = "What happens:",
      " " = "  - {.code aes(size = <variable>)} would control icon size per point",
      " " = "  - But the parameter {.code size = {size}} will OVERRIDE it",
      " " = "",
      "i" = "Fix - choose one approach:",
      " " = "  Option 1: Data-driven sizes (remove size parameter)",
      " " = "    {.code geom_icon_point(aes(icon = icon, size = point_size))}",
      " " = "",
      " " = "  Option 2: Fixed size (remove size from aes)",
      " " = "    {.code geom_icon_point(aes(icon = icon), size = 2)}"
    ))
  }
  
  # ============================================================================
  # SIZE HANDLING - Only if data is provided AND size is mapped
  # ============================================================================
  
  size_internal <- NULL  # Default: let geom_image handle it
  
  if (!is.null(data) && "size" %in% names(mapping_list)) {
    # User mapped size aesthetic and we have data
    size_var <- rlang::as_name(mapping_list[["size"]])
    
    if (!size_var %in% names(data)) {
      cli::cli_abort("Variable {.field {size_var}} used for size not found in the dataset.")
    }
    
    # Compute icon_size from the mapped variable
    data$icon_size <- data[[size_var]] * 0.03
    
    # Create the size vector to pass to geom_image
    size_internal <- data$icon_size
    
    # Remove size from mapping so it doesn't interfere
    mapping_list[["size"]] <- NULL
    
  } else if (!is.null(data)) {
    # No size mapping - use fixed parameter
    data$icon_size <- size * 0.03
    size_internal <- data$icon_size
  }
  
  # If data is NULL, size handling will happen in StatIconPoint's compute_panel
  # Pass the size parameter for the Stat to use
  
  # ============================================================================
  # Store original color/category for legend lookup
  # ============================================================================
  if ("colour" %in% names(mapping_list)) {
    mapping_list[["ggpop_cat"]] <- mapping_list[["colour"]]
  } else if ("color" %in% names(mapping_list)) {
    mapping_list[["ggpop_cat"]] <- mapping_list[["color"]]
  }
  
  # Image is computed by StatIconPoint
  mapping_list[["image"]] <- rlang::expr(ggplot2::after_stat(image))
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  layer_out <- ggimage::geom_image(
    mapping     = final_mapping,
    data        = data,
    stat        = StatIconPoint,
    size        = if (!is.null(size_internal)) size_internal else size * 0.03,
    position    = position,
    na.rm       = na.rm,
    inherit.aes = inherit.aes,
    by          = "width",
    asp         = 1,
    key_glyph   = if (legend_icons) key_glyph_icon_point else ggplot2::draw_key_point,
    
    # params forwarded into StatIconPoint + key glyph
    icon         = icon,
    size_param   = size,  # Pass original size parameter for Stat to use
    dpi          = dpi,
    legend_icons = legend_icons,
    build_id     = build_id,
    
    ...
  )
  
  # tag for your mixed legend_icons ggplot_add check
  layer_out$ggpop_layer_type <- "icon_point"
  layer_out$ggpop_legend_icons <- isTRUE(legend_icons)
  class(layer_out) <- c("ggpop_icon_point_layer", class(layer_out))
  
  layer_out
}