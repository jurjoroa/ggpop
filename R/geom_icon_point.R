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
#' @examples
#' \dontrun{
#' # Example 1: Basic scatter with mtcars
#' ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_icon_point(icon = "car", size = 5)
#'
#' # Example 2: Color by group
#' ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
#'   geom_icon_point(icon = "leaf", size = 4)
#'
#' # Example 3: Different icons per group
#' df <- data.frame(
#'   x = rnorm(100),
#'   y = rnorm(100),
#'   type = sample(c("A", "B"), 100, replace = TRUE)
#' )
#' df$icon <- ifelse(df$type == "A", "star", "heart")
#' 
#' ggplot(df, aes(x = x, y = y, icon = icon, color = type)) +
#'   geom_icon_point(size = 5)
#'
#' # Example 4: Vary size by variable
#' ggplot(mtcars, aes(x = wt, y = mpg, size = hp)) +
#'   geom_icon_point(icon = "car-side")
#'
#' # Example 5: Time series
#' df_time <- data.frame(
#'   date = as.Date('2024-01-01') + 0:99,
#'   value = cumsum(rnorm(100)),
#'   category = rep(c("sales", "costs"), 50)
#' )
#' df_time$icon <- ifelse(df_time$category == "sales", "arrow-up", "arrow-down")
#'
#' ggplot(df_time, aes(x = date, y = value, icon = icon, color = category)) +
#'   geom_icon_point(size = 3) +
#'   theme_minimal()
#' }
#'
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, 
                            data = NULL, 
                            stat = "identity",
                            position = "identity", 
                            na.rm = FALSE, 
                            show.legend = NA,
                            inherit.aes = TRUE, 
                            icon = "circle",
                            size = 3,
                            dpi = 50,
                            legend_icons = TRUE,
                            ...) {
  
  # Get plot context
  plot_obj <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot,
    error = function(e) NULL
  )
  
  .missing_size <- missing(size)
  
  # Get data from context if not provided
  if (is.null(data) && !is.null(plot_obj)) {
    data <- plot_obj$data
  }
  
  # Validate we have data
  if (is.null(data) || nrow(data) == 0) {
    stop(
      "[geom_icon_point] No data provided.\n\n",
      "Usage:\n",
      "  ggplot(your_data, aes(x = x_var, y = y_var)) +\n",
      "    geom_icon_point(icon = 'star')\n",
      call. = FALSE
    )
  }
  
  # Parse aesthetics
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # DPI validation
  if (is.numeric(dpi) && dpi < 30) {
    stop("[geom_icon_point] dpi must be >= 30 for clear icons.", call. = FALSE)
  }
  
  # Warn about size conflict
  if ("size" %in% names(mapping_list) && !.missing_size) {
    warning(
      "[geom_icon_point] `size` specified in both aes() and as parameter.\n",
      "The aes() mapping will be used.\n",
      call. = FALSE
    )
  }
  
  # Handle icon specification
  icon_mapped <- "icon" %in% names(mapping_list)
  has_icon_col <- "icon" %in% names(data)
  
  # Add default icon if not specified
  if (!icon_mapped && !has_icon_col) {
    data$icon <- icon
  }
  
  # Prevent direct image mapping
  if ("image" %in% names(mapping_list)) {
    stop("[geom_icon_point] Use 'icon' aesthetic instead of 'image'.", call. = FALSE)
  }
  
  # Add icon to mapping if it exists in data but not in mapping
  if (!icon_mapped && "icon" %in% names(data)) {
    mapping_list[["icon"]] <- as.name("icon")
  }
  
  # Handle size
  if ("size" %in% names(mapping_list)) {
    size_var <- rlang::as_name(mapping_list[["size"]])
    if (!size_var %in% names(data)) {
      stop("[geom_icon_point] Size variable '", size_var, "' not found in data.", call. = FALSE)
    }
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  # Validate icons
  if ("icon" %in% names(data)) {
    bad_icons <- is.na(data$icon) | !nzchar(as.character(data$icon))
    if (any(bad_icons)) {
      stop(
        "[geom_icon_point] Found ", sum(bad_icons), " row(s) with invalid/missing icons.\n",
        "Ensure all rows have valid Font Awesome icon names.\n",
        call. = FALSE
      )
    }
  }
  
  # Generate icon images
  df_final <- data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        cache_dir <- file.path(tempdir(), "ggpop-icons")
        if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
        
        png_path <- file.path(cache_dir, paste0(this_icon, ".png"))
        if (!file.exists(png_path)) {
          fontawesome::fa_png(this_icon, file = png_path, height = dpi)
        }
        png_path
      }
    ) %>%
    dplyr::ungroup()
  
  # Setup legend icons
  .get_mapped_var <- function(aes_name) {
    if (aes_name %in% names(mapping_list)) {
      tryCatch(rlang::as_name(mapping_list[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  # Determine which variable controls the legend
  icon_var <- .get_mapped_var("icon")
  legend_var <- .get_mapped_var("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var("group")
  
  # If icon is mapped, use it for legend; otherwise use color/group variable
  legend_key_var <- if (!is.null(icon_var) && icon_var %in% names(df_final)) {
    icon_var
  } else if (!is.null(legend_var) && legend_var %in% names(df_final)) {
    legend_var
  } else {
    NULL
  }
  
  icon_by_legend <- list()
  
  if (!is.null(legend_key_var) && legend_key_var %in% names(df_final)) {
    icon_by_legend <- df_final %>%
      dplyr::mutate(
        .legend_key = as.character(.data[[legend_key_var]]),
        icon = as.character(icon)
      ) %>%
      dplyr::filter(!is.na(.legend_key), nzchar(.legend_key), !is.na(icon), nzchar(icon)) %>%
      dplyr::group_by(.legend_key) %>%
      dplyr::summarise(
        icon = names(sort(table(icon), decreasing = TRUE))[1],
        .groups = "drop"
      )
    
    icon_by_legend <- stats::setNames(icon_by_legend$icon, icon_by_legend$.legend_key)
  }
  
  # Custom legend key
  key_glyph_pop <- function(key_data, params, size) {
    if (!("colour" %in% names(key_data)) && ("color" %in% names(key_data))) {
      key_data$colour <- key_data$color
    }
    
    if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
    if (!("colour" %in% names(key_data))) key_data$colour <- "black"
    
    # Try to get the legend label
    lbl <- NA_character_
    if ("label" %in% names(key_data)) {
      lbl <- as.character(key_data$label[1])
    }
    
    # Find matching icon from our mapping
    ic <- NA_character_
    if (!is.na(lbl) && nzchar(lbl) && lbl %in% names(icon_by_legend)) {
      ic <- icon_by_legend[[lbl]]
    }
    
    # Fallback: try to match by index or use default
    if (is.na(ic) || !nzchar(ic)) {
      if (length(icon_by_legend) > 0) {
        idx <- 1
        if (".id" %in% names(key_data)) {
          idx <- as.integer(key_data$.id[1])
        } else if ("group" %in% names(key_data)) {
          idx <- as.integer(key_data$group[1])
        }
        idx <- max(1L, min(length(icon_by_legend), idx))
        ic <- unname(icon_by_legend[idx])
      } else {
        ic <- icon  # Use default icon
      }
    }
    
    if (is.na(ic) || !nzchar(ic)) ic <- icon
    
    key_data$icon <- ic
    draw_key_pop_image(key_data, params, size)
  }
  
  # Finalize mapping
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["icon"]] <- NULL
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  # Default key function
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  # Create layer
  layer_out <- ggimage::geom_image(
    mapping = final_mapping,
    data = df_final,
    size = df_final$icon_size,
    stat = stat,
    position = position,
    na.rm = na.rm,
    inherit.aes = inherit.aes,
    by = "height",
    key_glyph = if (legend_icons) key_glyph_pop else key_fn,
    ...
  )
  
  structure(
    list(layer = layer_out, facet_col = NULL),
    class = "ggpop_geom_pop"
  )
}
