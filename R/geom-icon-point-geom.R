#' Custom Geom for Icon Points
#' 
#' This extends ggimage::GeomImage to handle icon_size extraction from data.
#' The StatIconPoint computes icon_size and adds it to the data.
#' This geom extracts it and passes it to the parent GeomImage without
#' letting it appear in legends.
#' 
#' @importFrom ggplot2 ggproto
#' @keywords internal
GeomIconPoint <- ggplot2::ggproto(
  "GeomIconPoint", ggimage::GeomImage,
  
  draw_panel = function(data, panel_params, coord, by = "width", ...) {
    # Extract icon_size from data if present
    if ("icon_size" %in% names(data)) {
      size_vec <- data$icon_size
      # Remove from data to prevent legend issues
      data$icon_size <- NULL
    } else {
      size_vec <- 0.05  # default
    }
    
    # Call parent's draw_panel with size parameter
    ggimage::GeomImage$draw_panel(data, panel_params, coord, by = by, size = size_vec, ...)
  }
)
