#' Handle geom_icon_point(data, aes(...)) pattern
#' @keywords internal
#' @noRd
handle_argument_swap <- function(mapping, data) {
  if (!is.null(mapping) && !inherits(mapping, "uneval") &&
      (is.data.frame(mapping) || (is.list(mapping) && !inherits(mapping, "uneval")))) {
    list(mapping = data, data = mapping)
  } else {
    list(mapping = mapping, data = data)
  }
}

#' Extract plot context and inherited mappings
#' @keywords internal
#' @noRd
extract_plot_context <- function() {
  plot_obj <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot,
    error = function(e) NULL
  )
  
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) {
    as.list(plot_obj$mapping)
  } else {
    list()
  }
  
  list(plot_obj = plot_obj, inherited_mappings = inherited_mapping_list)
}

#' Run all parameter validations for geom_icon_point
#' @keywords internal
#' @noRd
validate_geom_icon_point <- function(data, dpi, size, missing_size, legend_icons, 
                                     extra_args, mapping_list, stroke_width = NULL) {
  
  validate_data_is_dataframe(data)
  validate_data_not_empty(data)
  validate_no_reserved_columns(data)
  validate_dpi(dpi)
  validate_size(size, missing_size)
  validate_stroke_width(stroke_width)
  validate_legend_icons(legend_icons)
  validate_no_image_aesthetic(mapping_list)
  # Note: stroke_width validation happens AFTER size calculation
  if ("alpha" %in% names(extra_args)) {
    validate_alpha_parameter(extra_args$alpha)
  }
  
  invisible(TRUE)
}

#' Resolve icon variable from mappings and parameters
#' @keywords internal
#' @noRd
resolve_icon_variable <- function(mapping_list, inherited_mapping_list, combined_mapping, icon, data) {
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
  
  list(icon_var = icon_var, data = data, has_icon_param = has_icon_param)
}

#' Add icon to mapping list if not present
#' @keywords internal
#' @noRd
add_icon_to_mapping <- function(mapping_list, inherited_mapping_list, icon_var) {
  if (!"icon" %in% names(mapping_list)) {
    if ("icon" %in% names(inherited_mapping_list)) {
      mapping_list[["icon"]] <- inherited_mapping_list[["icon"]]
    } else if (!is.null(icon_var)) {
      mapping_list[["icon"]] <- as.name(icon_var)
    } else {
      cli::cli_abort("Internal error: No icon mapping available.")
    }
  }
  mapping_list
}

#' Normalize icon column name and validate values
#' @keywords internal
#' @noRd
normalize_icon_column <- function(data, icon_var) {
  if (!is.null(icon_var)) {
    validate_icon_column(data, icon_var)
  }
  
  if (!is.null(icon_var) && icon_var != "icon") {
    data$icon <- data[[icon_var]]
  }
  
  data
}

#' Handle size aesthetic and parameter
#' @keywords internal
#' @noRd
handle_size_aesthetic <- function(data, combined_mapping, mapping_list, inherited_mapping_list, size) {
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    
    if (!size_var %in% names(data)) {
      cli::cli_abort("Variable {.field {size_var}} used for size not found in the dataset.")
    }
    
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  list(data = data, mapping_list = mapping_list)
}

#' Detect legend variable from combined mapping
#' @keywords internal
#' @noRd
detect_legend_variable <- function(combined_mapping, data) {
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
    } else {
      legend_var <- NULL
    }
  }
  
  legend_var
}

#' Create icon-to-legend mapping
#' @keywords internal
#' @noRd
create_icon_by_legend <- function(data, legend_var, icon, has_icon_param) {
  if (!is.null(legend_var) && legend_var %in% names(data)) {
    data %>%
      dplyr::mutate(
        .legend = as.character(.data[[legend_var]]),
        icon    = as.character(.data$icon)
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
    first_icon <- if (has_icon_param) {
      icon
    } else if ("icon" %in% names(data) && nrow(data) > 0) {
      as.character(data$icon[1])
    } else {
      "circle"
    }
    stats::setNames(first_icon, "default")
  }
}