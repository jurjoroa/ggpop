#' Create a circular representative population chart
#' #' 
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image with a given icon. 
#' 
#' @section Aesthetics:
#' geom_pop employs the following aesthetics:
#' 
#' - **sample_size** - The number of individuals to be represented in the chart.
#' - **alpha** - The transparency of the points.
#' - **color** - The color of the points.
#' - **size** - The size of the points.
#' 
#' @inheritParams ggplot2::layer
#' @inheritParams ggimage::geom_image
#' @inheritParams fontawesome::fa
#' @param size The size of the points.
#' @param icon The icon to be used in the chart.
#' @param quality Height (in **pixels**) of the PNG icon when rendered with `fontawesome::fa_png()`.
#'        Higher values produce sharper icons. Defaults to 50. This affects **image quality**, not icon size in the plot.
#' @param group_var The variable used to group individuals.
#' @param sample_size The total number of individuals (points) to be drawn.
#' @param arrange Logical; if TRUE, the output data is arranged by group.
#' @param sum_var Optional variable to sum over instead of counting.
#' @param facet Optional facetting variable.
#' @param legend_icons Logical; if TRUE, the legend will display the selected icons by the user.
#' 
#' @return A ggplot object with a circular representative population chart.
#' 
#' @import dplyr
#' 
#' @export
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "ggmale",
                     group_var = NULL, sample_size = NULL, arrange = FALSE, sum_var = NULL,
                     facet = NULL,
                     size = 3,
                     quality = 50,
                     legend_icons = TRUE,
                     ...) {
  
  
  # Capture data passed to ggplot() (if any)
  inherited_data <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot())$plot$data, 
                             error = function(e) NULL)
  
  plot_obj <- tryCatch(ggplot_build(last_plot())$plot, error = function(e) NULL)
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) as.list(plot_obj$mapping) else list()
  
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot_build(last_plot())$plot$data
  }
  
  # --- facet handling (facet is OPTIONAL; supports facet = sex or facet = "sex") ---
  # --- facet handling (facet is OPTIONAL; supports facet = sex or facet = "sex") ---
  facet_expr <- rlang::enexpr(facet)
  
  if (rlang::is_missing(facet_expr) || rlang::is_null(facet_expr)) {
    has_facet <- FALSE
    facet_col <- NULL
  } else {
    has_facet <- TRUE
    
    if (rlang::is_symbol(facet_expr)) {
      facet_col <- rlang::as_name(facet_expr)
    } else if (rlang::is_string(facet_expr)) {
      facet_col <- facet_expr
    } else {
      stop("`facet` must be a column name (facet = sex) or a single string (facet = \"sex\").")
    }
    
    if (!facet_col %in% names(data)) {
      stop(sprintf("Facet column '%s' not found in `data`.", facet_col))
    }
  }
  
  
  # Convert mapping to a list
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }

  validate_geom_pop_inputs(data, mapping_list, icon, size, quality, inherited_data)
  
  warn_geom_pop_inputs(data, mapping_list, inherited_mapping_list, icon, .missing_size)
  
  if (!"icon" %in% names(mapping_list)) {
    mapping_list[["icon"]] <- as.name("icon")
  }
  
  if (!"icon" %in% names(data)) {
    data$icon <- icon
  }
  
  # Handle dynamic size column without requiring I()
  if ("size" %in% names(mapping_list)) {
    size_var <- rlang::as_name(mapping_list[["size"]])  # Extract variable name from the quosure
    if (!size_var %in% names(data)) {
      stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    }
    data$size <- data[[size_var]] * 0.03  # Apply scaling
    mapping_list[["size"]] <- NULL  # remove from aesthetic to avoid ggimage error
  } else {
    data$size <- size * 0.03  # fallback to default size if not mapped
  }
  
  data <- data %>% mutate(pos = as.numeric(row_number()))
  
  sample_size <- length(unique(data$pos))
  
  df_coordinates_final <- fetch_df_coordinates()
  
  df_coordinates_filtered <- df_coordinates_final %>%
    filter(size == sample_size)
  
  df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
  
  df_merged <- left_join(df_coordinates_filtered, data, by = "pos")
  
  if (!is.null(data) && arrange && !has_facet) {
    
    df_order <- data %>% select(n , prop)
    
    data <- data %>%
      mutate(original_order = row_number()) %>%
      arrange(type, original_order) %>%
      mutate(pos = row_number()) %>%
      select(-original_order, -n , -prop)
    
    data <- bind_cols(data, df_order) 
    
    sample_size <- length(unique(data$pos))
    
    df_coordinates_final <- fetch_df_coordinates()
    
    df_coordinates_filtered <- df_coordinates_final %>%
      filter(size == sample_size)
    
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- left_join(df_coordinates_filtered, data, by = "pos")
    
  } 
  else if (!is.null(data) && arrange && has_facet) {
    
    
     
     
    
    df_order <- data %>% select(n , prop)
    
    data <- data %>%
      group_by(.data[[facet_col]]) %>%
      mutate(original_order = row_number()) %>%
      ungroup() %>%
      arrange(type, original_order,  .data[[facet_col]]) %>%  # Sort by the specified columns
      group_by(.data[[facet_col]]) %>%  # Group by the specified columns
      mutate(pos = row_number()) %>%  # Calculate a sequential row number without restarting
      select(-n, -prop) %>% 
      ungroup()
    
    data <- bind_cols(data, df_order)
    
    sample_size <- data %>%
      group_by(.data[[facet_col]]) %>%
      summarise(sample_size = n_distinct(pos), .groups = "drop")
    
    df_coordinates_final <- fetch_df_coordinates()
    
    df_coordinates_filtered <- df_coordinates_final %>%
      rowwise() %>%
      filter(size %in% sample_size$sample_size) %>%
      ungroup()
    
    
    data <- data %>%
      left_join(sample_size %>% rename(coord_size = sample_size), by = facet_col)
    
    # Ensure consistent data types
    data$coord_size <- as.character(data$coord_size)
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- dplyr::left_join(
      df_coordinates_filtered,
      data,
      by = c("pos" = "pos", "size" = "coord_size")
    )
    
    
  } else if (!is.null(data) && !arrange && has_facet) {
     
     
    #browser()
    data <- data %>%
      group_by(.data[[facet_col]]) %>%
      mutate(pos = row_number()) %>%
      ungroup()
    
    sample_size <- data %>%
      group_by(.data[[facet_col]]) %>%
      summarise(sample_size = n_distinct(pos), .groups = "drop")
    
    df_coordinates_final <- fetch_df_coordinates()
    
    df_coordinates_filtered <- df_coordinates_final %>%
      rowwise() %>%
      filter(size %in% sample_size$sample_size) %>%
      ungroup()
    
    data <- data %>%
      left_join(sample_size %>% rename(coord_size = sample_size), by = facet_col)
    
    # Ensure consistent data types
    data$coord_size <- as.character(data$coord_size)
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- dplyr::left_join(
      df_coordinates_filtered,
      data,
      by = c("pos" = "pos", "size" = "coord_size")
    )
    
    
  }
  
  
  
  # Get the row count of the merged table
  N <- nrow(df_merged)
  
  # Prepare the vector to fill in your new column
  v_name_icon <- unique(data$icon)
  
  #Format to merge with the data
  df_icon <- tibble(
    image = c(v_name_icon, rep(NA, max(0, N - length(v_name_icon))))
  )[seq_len(N), ]
  
  #Final data
  df_final <- bind_cols(df_merged, df_icon)
  
  #if type has NA, drop the row
  df_final <- df_final %>% filter(!is.na(type))
  
  
  if (!"x1" %in% colnames(df_final) || !"y1" %in% colnames(df_final)) {
    stop("x1 or y1 columns are missing after merging. Check that pos matches between data and df_coordinates_final.")
  }
  
  # Generate the PNG every time with the given height — always overwrites
  df_final <- df_final %>%
    rowwise() %>%
    mutate(
      image = {
        svg_path <- file.path("inst", "figures", "svg", paste0(icon, ".svg"))
        png_path <- file.path("inst", "figures", "png", paste0(icon, ".png"))
        
        # Create directories if needed
        if (!dir.exists(dirname(png_path))) {
          dir.create(dirname(png_path), recursive = TRUE)
        }
        
        if (file.exists(svg_path)) {
          svg_path
        } else {
          fontawesome::fa_png(icon, file = png_path, height = quality)  # always overwrite
          png_path
        }
      }
    ) %>%
    ungroup()
  
  # Check if the icon column is present in the data
  icon_expr <- mapping_list[["icon"]]
  
  # Set required mappings
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["x"]] <- as.name("x1")
  mapping_list[["y"]] <- as.name("y1")
  
  # Construct aes without altering existing ones
  final_mapping <- do.call(aes, mapping_list)
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  # Set the size aesthetic
  size_internal <- data$size
  
  # Draw image points
  ggimage::geom_image(
    mapping      = final_mapping,
    data         = df_final,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "height",
    key_glyph    = if (legend_icons) draw_key_pop_image else key_fn,
    ...
  )
}
