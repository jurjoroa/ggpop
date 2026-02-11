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
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL,
                            position = "identity", na.rm = FALSE,
                            inherit.aes = TRUE, icon = NULL,
                            size = 1, dpi = 50, legend_icons = TRUE, ...) {
  
  extra_args <- list(...)
  
  # ==============================================================================
  # HANDLE COMMON USAGE: geom_icon_point(data, aes(...))
  # ==============================================================================
  if (!is.null(mapping) && !inherits(mapping, "uneval") &&
      (is.data.frame(mapping) || (is.list(mapping) && !inherits(mapping, "uneval")))) {
    temp <- mapping
    mapping <- data
    data <- temp
  }
  
  # ==============================================================================
  # SETUP: Extract plot context and mappings
  # ==============================================================================
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
    data <- tryCatch(
      ggplot2::ggplot_build(ggplot2::last_plot())$plot$data,
      error = function(e) NULL
    )
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
  
  # ==============================================================================
  # ICON HANDLING
  # ==============================================================================
  icon_mapped <- "icon" %in% names(combined_mapping)
  has_icon_param <- !is.null(icon) && nzchar(as.character(icon))
  
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
  
  # Get the icon variable name
  icon_var <- if (icon_mapped) {
    if ("icon" %in% names(mapping_list)) {
      tryCatch(rlang::as_name(mapping_list[["icon"]]), error = function(e) NULL)
    } else if ("icon" %in% names(inherited_mapping_list)) {
      tryCatch(rlang::as_name(inherited_mapping_list[["icon"]]), error = function(e) NULL)
    } else {
      NULL
    }
  } else {
    NULL
  }
  
  # Add icon to data if needed
  if (has_icon_param && is.null(icon_var)) {
    data$icon <- icon
    icon_var <- "icon"
  }
  
  # Validate icon variable exists
  if (!is.null(icon_var) && !icon_var %in% names(data)) {
    cli::cli_abort(c(
      "Icon column not found in data.",
      "x" = "You mapped {.code aes(icon = {icon_var})}, but this column doesn't exist.",
      " " = "",
      "i" = "Available columns:",
      " " = "  {.field {names(data)}}",
      " " = "",
      "i" = "Fix:",
      " " = "  - Check your column name: {.code names(data)}",
      " " = "  - Use the correct column name in {.code aes(icon = ...)}",
      " " = "  - Or add the column to your data before calling {.fn geom_icon_point}"
    ))
  }
  
  # Add icon mapping
  if (!"icon" %in% names(mapping_list)) {
    if ("icon" %in% names(inherited_mapping_list)) {
      mapping_list[["icon"]] <- inherited_mapping_list[["icon"]]
    } else if (!is.null(icon_var)) {
      mapping_list[["icon"]] <- as.name(icon_var)
    } else {
      cli::cli_abort("Internal error: No icon mapping available.")
    }
  }
  
  # Validate icon values
  if (!is.null(icon_var)) {
    validate_icon_column(data, icon_var)
  }
  
  # Rename icon column to "icon"
  if (!is.null(icon_var) && icon_var != "icon") {
    data$icon <- data[[icon_var]]
  }
  
  # ==============================================================================
  # SIZE HANDLING - Prepare size variable name for stat
  # ==============================================================================
  size_var <- if ("size" %in% names(combined_mapping)) {
    if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
  } else {
    NULL
  }
  
  if (!is.null(size_var) && !size_var %in% names(data)) {
    cli::cli_abort("Variable {.field {size_var}} used for size not found in the dataset.")
  }
  
  # Remove size from mapping if present - it will be computed by StatIconPoint
  if (!is.null(size_var)) {
    mapping_list[["size"]] <- NULL
  }
  
  # ==============================================================================
  # ICON RENDERING: Prepare for StatIconPoint
  # ==============================================================================
  # The stat will compute icon_size and image paths
  # We just need to pass parameters
  
  # ==============================================================================
  # LEGEND SETUP
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
    first_icon <- if ("icon" %in% names(data) && nrow(data) > 0) {
      as.character(data$icon[1])
    } else if (has_icon_param) {
      icon
    } else {
      "circle"
    }
    stats::setNames(first_icon, "default")
  }
  
  # ==============================================================================
  # WARNING: Multiple icons per legend group
  # ==============================================================================
  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    is_numeric_scale <- is.numeric(data[[legend_var]])
    if (!is_numeric_scale) {
      warn_multiple_icons_per_group(data, legend_var, "icon")
    }
  }
  
  # ==============================================================================
  # LEGEND KEY GLYPH
  # ==============================================================================
  key_glyph_icon_point <- function(key_data, params, size) {
    if (!("colour" %in% names(key_data)) & ("color" %in% names(key_data))) {
      key_data$colour <- key_data$color
    }
    
    if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
    key_data$alpha[is.na(key_data$alpha)] <- 1
    
    if (!("colour" %in% names(key_data))) key_data$colour <- "black"
    key_data$colour[is.na(key_data$colour)] <- "black"
    
    lbl <- NA_character_
    if ("label" %in% names(key_data)) lbl <- as.character(key_data$label[1])
    if (is.na(lbl) || !nzchar(lbl)) lbl <- NA_character_
    
    icon_by_legend <- params$icon_by_legend
    plot_obj <- params$plot_obj
    
    ic <- NA_character_
    if (!is.na(lbl) && !is.null(icon_by_legend) && lbl %in% names(icon_by_legend)) {
      ic <- icon_by_legend[[lbl]]
    }
    
    if (is.na(ic) || !nzchar(ic)) {
      breaks <- if (!is.null(icon_by_legend)) names(icon_by_legend) else character(0)
      if (!is.null(plot_obj)) {
        sc <- plot_obj$scales$get_scales("colour")
        if (is.null(sc)) sc <- plot_obj$scales$get_scales("color")
        if (!is.null(sc)) {
          br <- sc$get_breaks()
          br <- br[!is.na(br)]
          if (length(br)) breaks <- as.character(br)
        }
      }
      
      if (length(breaks) > 0 && !is.null(icon_by_legend)) {
        icon_levels <- unname(icon_by_legend[breaks])
        
        idx <- NA_integer_
        if (".id" %in% names(key_data)) idx <- as.integer(key_data$.id[1])
        if (is.na(idx) && "group" %in% names(key_data)) idx <- as.integer(key_data$group[1])
        if (is.na(idx)) idx <- 1L
        
        idx <- max(1L, min(length(icon_levels), idx))
        ic <- as.character(icon_levels[idx])
      }
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
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  # Create layer using our custom Geom and Stat
  layer_out <- ggplot2::layer(
    geom         = GeomIconPoint,
    mapping      = final_mapping,
    data         = data,
    stat         = StatIconPoint,
    position     = position,
    show.legend  = NA,
    inherit.aes  = inherit.aes,
    params       = list(
      na.rm      = na.rm,
      by         = "width",
      asp        = 1,
      dpi        = dpi,
      size_param = size,
      size_var   = size_var,
      key_glyph  = if (legend_icons) key_glyph_icon_point else key_fn,
      ...
    )
  )
  
  layer_out$geom_params$icon_by_legend <- icon_by_legend
  layer_out$geom_params$plot_obj <- plot_obj
  layer_out$geom_params$dpi <- dpi
  
  layer_out$ggpop_layer_type <- "icon_point"
  layer_out$ggpop_legend_icons <- isTRUE(legend_icons)
  class(layer_out) <- c("ggpop_icon_point_layer", class(layer_out))
  
  layer_out
}