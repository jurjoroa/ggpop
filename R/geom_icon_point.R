#' Create a scatter plot with Font Awesome icons instead of points
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
  
  # Handle common usage: geom_icon_point(data, aes(...))
  if (!is.null(mapping) && !inherits(mapping, "uneval") &&
      (is.data.frame(mapping) || (is.list(mapping) && !inherits(mapping, "uneval")))) {
    temp <- mapping
    mapping <- data
    data <- temp
  }
  
  # Get plot context
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
  
  # Validation
  validate_data_is_dataframe(data)
  validate_data_not_empty(data)
  validate_no_reserved_columns(data)
  validate_dpi(dpi)
  validate_size(size, .missing_size)
  validate_legend_icons(legend_icons)
  
  if ("alpha" %in% names(extra_args)) {
    validate_alpha_parameter(extra_args$alpha)
  }
  
  # Aesthetic mappings
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  validate_no_image_aesthetic(mapping_list)
  warn_size_conflict(combined_mapping, .missing_size, size)
  warn_alpha_conflict(combined_mapping, extra_args)
  
  # Icon handling
  icon_mapped <- "icon" %in% names(combined_mapping)
  has_icon_param <- !is.null(icon) && nzchar(as.character(icon))
  
  if (!icon_mapped && !has_icon_param) {
    cli::cli_abort(c(
      "No icon specified.",
      "x" = "You must EXPLICITLY specify an icon",
      " " = "",
      "i" = "Option 1: Map to a column: {.code aes(icon = icon_column)}",
      "i" = "Option 2: Provide a parameter: {.code geom_icon_point(icon = 'circle')}"
    ))
  }
  
  # Get icon variable
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
  
  if (has_icon_param && is.null(icon_var)) {
    data$icon <- icon
    icon_var <- "icon"
  }
  
  if (!is.null(icon_var) && !icon_var %in% names(data)) {
    cli::cli_abort("Icon column {.field {icon_var}} not found in data.")
  }
  
  if (!"icon" %in% names(mapping_list)) {
    if ("icon" %in% names(inherited_mapping_list)) {
      mapping_list[["icon"]] <- inherited_mapping_list[["icon"]]
    } else if (!is.null(icon_var)) {
      mapping_list[["icon"]] <- as.name(icon_var)
    }
  }
  
  if (!is.null(icon_var)) {
    validate_icon_column(data, icon_var)
  }
  
  if (!is.null(icon_var) && icon_var != "icon") {
    data$icon <- data[[icon_var]]
  }
  
  # Size handling
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    
    if (!size_var %in% names(data)) {
      cli::cli_abort("Variable {.field {size_var}} not found in data.")
    }
    
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  # Generate icon images (CLEANED UP!)
  data <- add_icon_images(data, dpi)
  
  # Legend setup
  .get_mapped_var <- function(aes_name) {
    if (aes_name %in% names(combined_mapping)) {
      tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  legend_var <- .get_mapped_var("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("group")
  
  if (is.null(legend_var) || !legend_var %in% names(data)) {
    if ("icon" %in% names(data) && dplyr::n_distinct(data$icon) > 1) {
      legend_var <- "icon"
    }
  }
  
  icon_by_legend <- if (!is.null(legend_var) && legend_var %in% names(data)) {
    data %>%
      dplyr::mutate(.legend = as.character(.data[[legend_var]]), icon = as.character(icon)) %>%
      dplyr::filter(!is.na(.legend), !is.na(icon)) %>%
      dplyr::group_by(.legend) %>%
      dplyr::summarise(icon = names(sort(table(icon), decreasing = TRUE))[1], .groups = "drop") %>%
      {stats::setNames(.$icon, .$.legend)}
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
  
  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    if (!is.numeric(data[[legend_var]])) {
      warn_multiple_icons_per_group(data, legend_var, "icon")
    }
  }
  
  
  # Final mapping
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["icon"]] <- NULL
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  size_internal <- data$icon_size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  # Create layer - calls external key_glyph_icon_point
  layer_out <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = data,
    size         = size_internal,
    stat         = StatIconIdentity,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_icon_point else key_fn,
    ...
  )
  
  # Attach params for key glyph
  layer_out$geom_params$icon_by_legend <- icon_by_legend
  layer_out$geom_params$plot_obj <- plot_obj
  layer_out$geom_params$dpi <- dpi
  
  layer_out$ggpop_layer_type <- "icon_point"
  layer_out$ggpop_legend_icons <- isTRUE(legend_icons)
  class(layer_out) <- c("ggpop_icon_point_layer", class(layer_out))
  
  layer_out
}