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
#' @param size Default icon size (default: 3).
#' @param dpi Icon resolution (default: 50).
#' @param legend_icons Show icons in legend (default: TRUE).
#'
#' @return A ggplot layer.
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL, stat = "identity",
                            position = "identity", na.rm = FALSE,
                            inherit.aes = TRUE, icon = NULL,
                            size = 3, dpi = 50, legend_icons = TRUE, ...) {
  
  extra_args <- list(...)
  
  # ==============================================================================
  # HANDLE COMMON USAGE: geom_icon_point(data, aes(...))
  # ==============================================================================
  if (!is.null(mapping) && !inherits(mapping, "uneval") &&
      (is.data.frame(mapping) || (is.list(mapping) && !inherits(mapping, "uneval")))) {
    # User did: geom_icon_point(df, aes(...))
    # Swap them
    temp <- mapping
    mapping <- data
    data <- temp
  }
  
  # ==============================================================================
  # SETUP: Extract plot context and mappings
  # ==============================================================================
  inherited_data <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot$data,
    error = function(e) NULL
  )
  
  plot_obj <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot,
    error = function(e) NULL
  )
  
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) {
    as.list(plot_obj$mapping)
  } else {
    list()
  }
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # ==============================================================================
  # VALIDATION: Data
  # ==============================================================================
  validate_data_is_dataframe(data)
  validate_data_not_empty(data)
  validate_no_reserved_columns(data)
  
  # ==============================================================================
  # VALIDATION: Parameters
  # ==============================================================================
  validate_dpi(dpi)
  validate_size(size, .missing_size)
  validate_legend_icons(legend_icons)
  
  # Validate alpha parameter if provided
  if ("alpha" %in% names(extra_args)) {
    validate_alpha_parameter(extra_args$alpha)
  }
  
  # ==============================================================================
  # AESTHETIC MAPPINGS
  # ==============================================================================
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # ==============================================================================
  # VALIDATION: Aesthetics
  # ==============================================================================
  validate_no_image_aesthetic(mapping_list)
  
  # ==============================================================================
  # WARNINGS: Conflicts
  # ==============================================================================
  warn_size_conflict(combined_mapping, .missing_size, size)
  warn_alpha_conflict(combined_mapping, extra_args)
  warn_mixed_legend_icons(legend_icons)
  
  # ==============================================================================
  # ICON HANDLING
  # ==============================================================================
  icon_mapped <- "icon" %in% names(combined_mapping)
  has_icon_param <- !is.null(icon) && nzchar(as.character(icon))
  
  # Icon must be EXPLICITLY mapped or provided as parameter
  if (!icon_mapped && !has_icon_param) {
    cli::cli_abort(c(
      "No icon specified.",
      "x" = "You must EXPLICITLY specify an icon",
      " " = "",
      "i" = "Option 1: Map to a column:",
      " " = "  {.code ggplot(data, aes(x = x, y = y, icon = icon_column)) +}",
      " " = "  {.code   geom_icon_point()}",
      " " = "",
      "i" = "Option 2: Provide a parameter:",
      " " = "  {.code ggplot(data, aes(x = x, y = y)) +}",
      " " = "  {.code   geom_icon_point(icon = 'circle')}",
      " " = "",
      "!" = "Note: Having an 'icon' column in your data is NOT enough.",
      " " = "      You must explicitly map it with {.code aes(icon = icon)}."
    ))
  }
  
  # Add icon to data ONLY if parameter was provided
  if (has_icon_param && !"icon" %in% names(data)) {
    data$icon <- icon
  }
  
  # Add icon mapping
  if (!"icon" %in% names(mapping_list)) {
    if ("icon" %in% names(inherited_mapping_list)) {
      mapping_list[["icon"]] <- inherited_mapping_list[["icon"]]
    } else if (has_icon_param) {
      mapping_list[["icon"]] <- as.name("icon")
    } else {
      cli::cli_abort("Internal error: No icon mapping available.")
    }
  }
  
  # Validate icon column has valid values
  if ("icon" %in% names(data)) {
    icon_var <- "icon"
    validate_icon_column(data, icon_var)
  }
  
  # ==============================================================================
  # SIZE HANDLING
  # ==============================================================================
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    
    if (!size_var %in% names(data)) {
      cli::cli_abort("Variable {.field {size_var}} used for size not found in the dataset.")
    }
    
    data$icon_size <- data[[size_var]] * 0.0075
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.0075
  }
  
  # ==============================================================================
  # ICON RENDERING: Generate PNG paths with caching
  # ==============================================================================
  
  # Capture DPI in local scope BEFORE rowwise
  local_dpi <- dpi
  
  data <- data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        if (is.na(this_icon) || !nzchar(this_icon)) {
          NA_character_
        } else {
          # Get color from aes mapping
          this_color <- if ("colour" %in% names(.)) {
            as.character(.data$colour)
          } else if ("color" %in% names(.)) {
            as.character(.data$color)
          } else {
            "black"
          }
          
          # Get alpha from aes mapping
          this_alpha <- if ("alpha" %in% names(.)) {
            as.numeric(.data$alpha)
          } else {
            1.0
          }
          
          # Convert color to hex
          this_color <- tryCatch({
            if (is.na(this_color) || !nzchar(this_color)) {
              "#000000"
            } else {
              rgb_vals <- grDevices::col2rgb(this_color) / 255
              grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
            }
          }, error = function(e) "#000000")
          
          # Apply alpha to color
          rgb_vals <- grDevices::col2rgb(this_color) / 255
          rgba_color <- grDevices::rgb(
            rgb_vals[1],
            rgb_vals[2],
            rgb_vals[3],
            alpha = this_alpha
          )
          
          cache_dir <- file.path(tempdir(), "ggpop-icons")
          if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
          
          # Build cache key with color, alpha, AND DPI
          color_hex <- gsub("#", "", this_color)
          alpha_str <- sprintf("%.2f", this_alpha)
          dpi_str <- sprintf("%.0f", local_dpi)
          
          cache_parts <- c(
            this_icon,
            paste0("c", color_hex),
            paste0("a", alpha_str),
            paste0("d", dpi_str)
          )
          
          png_path <- file.path(
            cache_dir,
            paste0(paste(cache_parts, collapse = "_"), ".png")
          )
          
          # Generate PNG if not cached
          if (!file.exists(png_path)) {
            fontawesome::fa_png(
              this_icon,
              file = png_path,
              height = local_dpi,
              fill = rgba_color
            )
          }
          
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # ==============================================================================
  # LEGEND SETUP: Map icons by legend variable
  # ==============================================================================
  
  .get_mapped_var_combined <- function(aes_name) {
    if (aes_name %in% names(combined_mapping)) {
      tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  legend_var <- .get_mapped_var_combined("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var_combined("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var_combined("group")
  
  # Fallback to icon if we have multiple icons
  if (is.null(legend_var) || !legend_var %in% names(data)) {
    if ("icon" %in% names(data) && dplyr::n_distinct(data$icon) > 1) {
      legend_var <- "icon"
    } else {
      legend_var <- NULL
    }
  }
  
  icon_by_legend <- if (!is.null(legend_var) && legend_var %in% names(data)) {
    data %>%
      dplyr::mutate(
        .legend = as.character(.data[[legend_var]]),
        icon    = as.character(icon)
      ) %>%
      dplyr::filter(!is.na(.legend), nzchar(.legend), !is.na(icon), nzchar(icon)) %>%
      dplyr::group_by(.legend) %>%
      dplyr::summarise(
        icon = {
          tab <- sort(table(icon), decreasing = TRUE)
          names(tab)[1]
        },
        .groups = "drop"
      ) %>%
      {
        stats::setNames(.$icon, .$.legend)
      }
  } else {
    # Fallback: use first icon from data or parameter
    first_icon <- if ("icon" %in% names(data) && nrow(data) > 0) {
      as.character(data$icon[1])
    } else if (has_icon_param) {
      icon
    } else {
      "circle" # Ultimate fallback
    }
    stats::setNames(first_icon, "default")
  }
  
  # ==============================================================================
  # WARNING: Multiple icons per legend group
  # ==============================================================================
  
  # Only warn if legend_icons is TRUE and we have a valid legend variable
  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    # Check if the legend variable is numeric (continuous scale)
    is_numeric_scale <- is.numeric(data[[legend_var]])
    
    if (!is_numeric_scale) {
      # Use the existing validator
      warn_multiple_icons_per_group(data, legend_var, "icon")
    }
  }
  
  # ==============================================================================
  # LEGEND KEY GLYPH: Custom icon rendering
  # ==============================================================================
  
  key_glyph_icon_point <- function(key_data, params, size) {
    if (!("colour" %in% names(key_data)) && ("color" %in% names(key_data))) {
      key_data$colour <- key_data$color
    }
    
    if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
    key_data$alpha[is.na(key_data$alpha)] <- 1
    
    if (!("colour" %in% names(key_data))) key_data$colour <- "black"
    key_data$colour[is.na(key_data$colour)] <- "black"
    
    lbl <- NA_character_
    if ("label" %in% names(key_data)) lbl <- as.character(key_data$label[1])
    if (is.na(lbl) || !nzchar(lbl)) lbl <- NA_character_
    
    # Get icon_by_legend from params
    icon_by_legend <- params$icon_by_legend
    plot_obj <- params$plot_obj
    
    ic <- NA_character_
    if (!is.na(lbl) && lbl %in% names(icon_by_legend)) {
      ic <- icon_by_legend[[lbl]]
    }
    
    if (is.na(ic) || !nzchar(ic)) {
      breaks <- names(icon_by_legend)
      
      if (!is.null(plot_obj)) {
        sc <- plot_obj$scales$get_scales("colour")
        if (is.null(sc)) sc <- plot_obj$scales$get_scales("color")
        if (!is.null(sc)) {
          br <- sc$get_breaks()
          br <- br[!is.na(br)]
          if (length(br)) breaks <- as.character(br)
        }
      }
      
      icon_levels <- unname(icon_by_legend[breaks])
      
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
  
  # ==============================================================================
  # FINAL MAPPING & LAYER CONSTRUCTION
  # ==============================================================================
  
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["icon"]] <- NULL
  # Keep x and y as they are (from user's aes)
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  size_internal <- data$icon_size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  layer_out <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = data,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_icon_point else key_fn,
    ...
  )
  
  # Pass params to layer for key glyph access
  layer_out$geom_params$icon_by_legend <- icon_by_legend
  layer_out$geom_params$plot_obj <- plot_obj
  layer_out$geom_params$dpi <- dpi
  
  layer_out
}
