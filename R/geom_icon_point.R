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
#' @param icon Default Font Awesome icon (default: "circle").
#' @param size Default icon size (default: 3).
#' @param dpi Icon resolution (default: 50).
#' @param legend_icons Show icons in legend (default: TRUE).
#'
#' @return A ggplot layer.
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL,
                            stat = "identity", position = "identity",
                            na.rm = FALSE, show.legend = NA,
                            inherit.aes = TRUE,
                            icon = "circle", size = 3, dpi = 50,
                            legend_icons = TRUE, ...) {
  
  # Get plot object for legend building
  plot_obj <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot())$plot,
                       error = function(e) NULL)
  
  # Convert mapping to list
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # Get inherited mapping from the ggplot object
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) {
    as.list(plot_obj$mapping)
  } else {
    list()
  }
  
  # Combine inherited and layer-specific mappings
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # -------------------------------------------------
  # VALIDATIONS
  # -------------------------------------------------
  
  # Check x and y are present in combined mapping
  if (!"x" %in% names(combined_mapping)) {
    stop("[geom_icon_point] x aesthetic is required.\n\nFix: Use aes(x = <variable>, ...)",
         call. = FALSE)
  }
  if (!"y" %in% names(combined_mapping)) {
    stop("[geom_icon_point] y aesthetic is required.\n\nFix: Use aes(y = <variable>, ...)",
         call. = FALSE)
  }
  
  # Check DPI
  if (is.numeric(dpi) && length(dpi) == 1 && !is.na(dpi) && is.finite(dpi)) {
    if (dpi < 30) {
      stop(
        paste0(
          "[geom_icon_point] dpi = ", dpi, " is too low.\n",
          "Icons will look blurry when rendered with fontawesome::fa_png().\n\n",
          "Fix: Use dpi >= 30 (recommended: 50-200 for crisp icons).\n"
        ),
        call. = FALSE
      )
    }
  }
  
  # -------------------------------------------------
  # DATA PREPARATION
  # -------------------------------------------------
  
  # Get data from plot if not provided
  if (is.null(data)) {
    data <- tryCatch(
      ggplot2::ggplot_build(ggplot2::last_plot())$plot$data,
      error = function(e) {
        stop("[geom_icon_point] No data available. Provide data explicitly or use ggplot(data = ...).",
             call. = FALSE)
      }
    )
  }
  
  # Ensure data is a data frame
  data <- as.data.frame(data)
  
  # Add icon column if not mapped
  icon_mapped <- "icon" %in% names(combined_mapping)
  has_icon_col <- "icon" %in% names(data)
  if (!icon_mapped && !has_icon_col) {
    data$icon <- icon
  }
  
  # Handle size - FIXED VERSION with proper scaling
  size_is_mapped <- "size" %in% names(combined_mapping)
  
  # Scaling factor for geom_image with by="height"
  # This creates reasonable icon sizes similar to geom_point
  SIZE_SCALE <- 0.005
  
  if (size_is_mapped) {
    # Size is mapped to a variable
    size_var <- tryCatch(rlang::as_name(combined_mapping[["size"]]), 
                         error = function(e) NULL)
    if (!is.null(size_var) && size_var %in% names(data)) {
      # Create icon_size column from the mapped variable
      data$icon_size <- data[[size_var]] * SIZE_SCALE
      # Add icon_size to the mapping for geom_image
      mapping_list[["size"]] <- as.name("icon_size")
    } else {
      # Fallback to fixed size
      data$icon_size <- size * SIZE_SCALE
      mapping_list[["size"]] <- NULL
    }
  } else {
    # Fixed size - no mapping needed
    data$icon_size <- size * SIZE_SCALE
    mapping_list[["size"]] <- NULL
  }
  
  # -------------------------------------------------
  # ICON VALIDATION
  # -------------------------------------------------
  
  if ("icon" %in% names(data)) {
    bad_icon <- is.na(data$icon) | !nzchar(as.character(data$icon))
    if (any(bad_icon)) {
      n_bad <- sum(bad_icon)
      stop(
        paste0(
          "[geom_icon_point] Invalid icon values detected.\n\n",
          "Found ", n_bad, " row(s) with missing or empty icon values.\n\n",
          "Fix: Ensure icon is non-missing for all rows.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  # -------------------------------------------------
  # GENERATE PNG PATHS FOR ICONS
  # -------------------------------------------------
  
  data <- data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        if (is.na(this_icon) || !nzchar(this_icon)) {
          NA_character_
        } else {
          cache_dir <- file.path(tempdir(), "ggpop-icons")
          if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
          png_path <- file.path(cache_dir, paste0(this_icon, ".png"))
          if (!file.exists(png_path)) {
            fontawesome::fa_png(this_icon, file = png_path, height = dpi)
          }
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # -------------------------------------------------
  # LEGEND ICON MAPPING
  # -------------------------------------------------
  
  # Helper to get mapped variable name
  .get_mapped_var <- function(aes_name) {
    if (aes_name %in% names(combined_mapping)) {
      tryCatch(rlang::as_name(combined_mapping[[aes_name]]), 
               error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  # Determine which variable to use for legend
  legend_var <- .get_mapped_var("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("group")
  
  if (is.null(legend_var) || !legend_var %in% names(data)) {
    # If no color/group mapping, try to find first categorical variable
    if ("icon" %in% names(data) && dplyr::n_distinct(data$icon) > 1) {
      legend_var <- "icon"
    } else {
      legend_var <- NULL
    }
  }
  
  # Build icon-to-legend mapping
  icon_by_legend <- if (!is.null(legend_var)) {
    data %>%
      dplyr::mutate(
        .legend = as.character(.data[[legend_var]]),
        icon = as.character(icon)
      ) %>%
      dplyr::filter(!is.na(.legend), nzchar(.legend),
                    !is.na(icon), nzchar(icon)) %>%
      dplyr::group_by(.legend) %>%
      dplyr::summarise(
        icon = {
          tab <- sort(table(icon), decreasing = TRUE)
          names(tab)[1]
        },
        .groups = "drop"
      ) %>%
      { stats::setNames(.$icon, .$.legend) }
  } else {
    stats::setNames(icon, "default")
  }
  
  # -------------------------------------------------
  # CUSTOM LEGEND KEY GLYPH
  # -------------------------------------------------
  
  key_glyph_icon_point <- function(key_data, params, size) {
    # Ensure colour exists
    if (!("colour" %in% names(key_data)) && ("color" %in% names(key_data))) {
      key_data$colour <- key_data$color
    }
    if (!("colour" %in% names(key_data))) key_data$colour <- "black"
    key_data$colour[is.na(key_data$colour)] <- "black"
    
    # Ensure alpha exists
    if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
    key_data$alpha[is.na(key_data$alpha)] <- 1
    
    # Get the label for this legend entry
    lbl <- NA_character_
    if ("label" %in% names(key_data)) lbl <- as.character(key_data$label[1])
    if (is.na(lbl) || !nzchar(lbl)) lbl <- NA_character_
    
    # Find corresponding icon
    ic <- NA_character_
    if (!is.na(lbl) && lbl %in% names(icon_by_legend)) {
      ic <- icon_by_legend[[lbl]]
    }
    
    # Fallback logic
    if (is.na(ic) || !nzchar(ic)) {
      icon_levels <- unname(icon_by_legend)
      idx <- NA_integer_
      if (".id" %in% names(key_data)) idx <- as.integer(key_data$.id[1])
      if (is.na(idx) && "group" %in% names(key_data)) idx <- as.integer(key_data$group[1])
      if (is.na(idx)) idx <- 1L
      idx <- max(1L, min(length(icon_levels), idx))
      ic <- as.character(icon_levels[idx])
    }
    
    if (is.na(ic) || !nzchar(ic)) ic <- "circle"
    key_data$icon <- ic
    
    draw_key_pop_image(key_data, params, size)
  }
  
  # -------------------------------------------------
  # UPDATE MAPPING
  # -------------------------------------------------
  
  # Add image mapping (required by geom_image)
  mapping_list[["image"]] <- as.name("image")
  
  # Remove icon from mapping (already converted to image)
  mapping_list[["icon"]] <- NULL
  
  # Create final mapping
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  # -------------------------------------------------
  # CREATE LAYER
  # -------------------------------------------------
  
  # Default key function (fallback)
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  # Prepare arguments for geom_image
  geom_image_args <- list(
    mapping = final_mapping,
    data = data,
    stat = stat,
    position = position,
    na.rm = na.rm,
    inherit.aes = inherit.aes,
    by = "height",
    key_glyph = if (legend_icons) key_glyph_icon_point else key_fn
  )
  
  # Only add fixed size if size is NOT mapped
  if (!size_is_mapped) {
    geom_image_args$size <- data$icon_size[1]  # Use first value as fixed size
  }
  
  # Add any additional arguments
  geom_image_args <- c(geom_image_args, list(...))
  
  layer_out <- do.call(ggimage::geom_image, geom_image_args)
  
  layer_out
}
