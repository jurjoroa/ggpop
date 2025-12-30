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
  
  inherited_data <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot$data,
    error = function(e) NULL
  )
  
  plot_obj <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot())$plot, error = function(e) NULL)
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) as.list(plot_obj$mapping) else list()
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # --- facet handling ---
  facet_expr <- rlang::enexpr(facet)
  if (rlang::is_missing(facet_expr) || rlang::is_null(facet_expr)) {
    has_facet <- FALSE
    facet_col <- NULL
  } else {
    has_facet <- TRUE
    if (rlang::is_symbol(facet_expr)) facet_col <- rlang::as_name(facet_expr)
    else if (rlang::is_string(facet_expr)) facet_col <- facet_expr
    else stop("`facet` must be a column name (facet = variable) or a single string (facet = \"variable\").")
    
    if (!facet_col %in% names(data)) stop(sprintf("Facet column '%s' not found in `data`.", facet_col))
  }
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }
  
  validate_geom_pop_inputs(data, mapping_list, icon, size, quality, inherited_data)
  warn_geom_pop_inputs(data, mapping_list, inherited_mapping_list, icon, .missing_size)
  
  if (!"icon" %in% names(mapping_list)) mapping_list[["icon"]] <- as.name("icon")
  if (!"icon" %in% names(data)) data$icon <- icon
  
  # size
  if ("size" %in% names(mapping_list)) {
    size_var <- rlang::as_name(mapping_list[["size"]])
    if (!size_var %in% names(data)) stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    data$size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$size <- size * 0.03
  }
  
  data <- dplyr::mutate(data, pos = as.numeric(dplyr::row_number()))
  sample_size <- length(unique(data$pos))
  
  df_coordinates_final <- fetch_df_coordinates()
  df_coordinates_filtered <- df_coordinates_final %>% dplyr::filter(size == sample_size)
  df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
  
  df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
  
  if (!is.null(data) && arrange && !has_facet) {
    
    df_order <- data %>% dplyr::select(n, prop)
    
    data <- data %>%
      dplyr::mutate(original_order = dplyr::row_number()) %>%
      dplyr::arrange(type, original_order) %>%
      dplyr::mutate(pos = dplyr::row_number()) %>%
      dplyr::select(-original_order, -n, -prop)
    
    data <- dplyr::bind_cols(data, df_order)
    
    sample_size <- length(unique(data$pos))
    
    df_coordinates_final <- fetch_df_coordinates()
    df_coordinates_filtered <- df_coordinates_final %>% dplyr::filter(size == sample_size)
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
    
  } else if (!is.null(data) && arrange && has_facet) {
    
    df_order <- data %>% dplyr::select(n, prop)
    
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(original_order = dplyr::row_number()) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(type, original_order, .data[[facet_col]]) %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = dplyr::row_number()) %>%
      dplyr::select(-n, -prop) %>%
      dplyr::ungroup()
    
    data <- dplyr::bind_cols(data, df_order)
    
    sample_size <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::summarise(sample_size = dplyr::n_distinct(pos), .groups = "drop")
    
    df_coordinates_final <- fetch_df_coordinates()
    df_coordinates_filtered <- df_coordinates_final %>%
      dplyr::rowwise() %>%
      dplyr::filter(size %in% sample_size$sample_size) %>%
      dplyr::ungroup()
    
    data <- data %>%
      dplyr::left_join(sample_size %>% dplyr::rename(coord_size = sample_size), by = facet_col)
    
    data$coord_size <- as.character(data$coord_size)
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- dplyr::left_join(
      df_coordinates_filtered,
      data,
      by = c("pos" = "pos", "size" = "coord_size")
    )
    
  } else if (!is.null(data) && !arrange && has_facet) {
    
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = dplyr::row_number()) %>%
      dplyr::ungroup()
    
    sample_size <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::summarise(sample_size = dplyr::n_distinct(pos), .groups = "drop")
    
    df_coordinates_final <- fetch_df_coordinates()
    df_coordinates_filtered <- df_coordinates_final %>%
      dplyr::rowwise() %>%
      dplyr::filter(size %in% sample_size$sample_size) %>%
      dplyr::ungroup()
    
    data <- data %>%
      dplyr::left_join(sample_size %>% dplyr::rename(coord_size = sample_size), by = facet_col)
    
    data$coord_size <- as.character(data$coord_size)
    df_coordinates_filtered$size <- as.character(df_coordinates_filtered$size)
    
    df_merged <- dplyr::left_join(
      df_coordinates_filtered,
      data,
      by = c("pos" = "pos", "size" = "coord_size")
    )
  }
  
  # Final data
  df_final <- df_merged %>% dplyr::filter(!is.na(type))
  
  if (!"x1" %in% names(df_final) || !"y1" %in% names(df_final)) {
    stop("x1 or y1 columns are missing after merging. Check that pos matches between data and df_coordinates_final.")
  }
  
  # ---- build per-row PNG path from per-row icon ----
  df_final <- df_final %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        if (is.na(this_icon) || !nzchar(this_icon)) {
          NA_character_
        } else {
          png_path <- file.path("inst", "figures", "png", paste0(this_icon, ".png"))
          if (!dir.exists(dirname(png_path))) dir.create(dirname(png_path), recursive = TRUE)
          if (!file.exists(png_path)) fontawesome::fa_png(this_icon, file = png_path, height = quality)
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # ---- LEGEND FIX: inject icon into key-glyph using .id ----
  # ---- LEGEND FIX: respect scale breaks order (works with breaks + labels) ----
  
  # which variable controls the legend (color/colour aesthetic)
  colour_var <- NULL
  if ("colour" %in% names(mapping_list)) {
    colour_var <- rlang::as_name(mapping_list[["colour"]])
  } else if ("color" %in% names(mapping_list)) {
    colour_var <- rlang::as_name(mapping_list[["color"]])
  }
  
  icon_var <- rlang::as_name(mapping_list[["icon"]])
  
  # build a mapping: group value -> icon value (no tidyselect .data warning)
  icon_by_group <- NULL
  if (!is.null(colour_var) &&
      colour_var %in% names(df_final) &&
      icon_var   %in% names(df_final)) {
    
    icon_map <- df_final |>
      dplyr::distinct(
        .group = .data[[colour_var]],
        .icon  = .data[[icon_var]]
      )
    
    icon_by_group <- stats::setNames(as.character(icon_map$.icon),
                                     as.character(icon_map$.group))
  }
  
  # cache computed icon_levels inside the closure
  .icon_levels_cache <- NULL
  
  key_glyph_pop <- function(key_data, params, size) {
    
    # compute icon levels *in legend order* ONCE, at draw time (after scales trained)
    if (is.null(.icon_levels_cache)) {
      
      # try to read breaks from trained scale in the final plot
      built <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot()),
                        error = function(e) NULL)
      
      breaks <- NULL
      if (!is.null(built) && !is.null(colour_var)) {
        
        # try "colour" then "color"
        sc <- built$plot$scales$get_scales("colour")
        if (is.null(sc)) sc <- built$plot$scales$get_scales("color")
        
        if (!is.null(sc)) {
          breaks <- sc$get_breaks()
          breaks <- breaks[!is.na(breaks)]
        }
      }
      
      # fallback if no breaks were set
      if (is.null(breaks) && !is.null(colour_var) && colour_var %in% names(df_final)) {
        breaks <- unique(as.character(df_final[[colour_var]]))
      }
      
      # turn breaks -> icon vector in that exact order
      if (!is.null(icon_by_group) && !is.null(breaks)) {
        .icon_levels_cache <<- unname(icon_by_group[as.character(breaks)])
      } else {
        # last resort
        .icon_levels_cache <<- unique(as.character(df_final[[icon_var]]))
      }
    }
    
    # assign exactly ONE icon per legend key row using .id
    if (".id" %in% names(key_data)) {
      idx <- as.integer(key_data$.id)
    } else if ("group" %in% names(key_data)) {
      idx <- as.integer(key_data$group)
    } else {
      idx <- 1L
    }
    
    idx <- pmax(1L, pmin(length(.icon_levels_cache), idx))
    
    # force scalar icon
    key_data$icon <- as.character(.icon_levels_cache[idx][1])
    
    draw_key_pop_image(key_data, params, size)
  }
  
  # (optional) enforce df_final legend factor order for consistency (not required but helps)
  if (!is.null(colour_var) && colour_var %in% names(df_final)) {
    built <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot()),
                      error = function(e) NULL)
    
    if (!is.null(built)) {
      sc <- built$plot$scales$get_scales("colour")
      if (is.null(sc)) sc <- built$plot$scales$get_scales("color")
      if (!is.null(sc)) {
        br <- sc$get_breaks()
        br <- br[!is.na(br)]
        if (length(br)) {
          df_final[[colour_var]] <- factor(as.character(df_final[[colour_var]]),
                                           levels = as.character(br))
        }
      }
    }
  }
  
  
  # ---- mapping for ggimage ----
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["x"]]     <- as.name("x1")
  mapping_list[["y"]]     <- as.name("y1")
  mapping_list[["icon"]]  <- NULL  # IMPORTANT: ggimage doesn't know this aesthetic
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  # size aesthetic for layer
  size_internal <- data$size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  ggimage::geom_image(
    mapping      = final_mapping,
    data         = df_final,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "height",
    key_glyph    = if (legend_icons) key_glyph_pop else key_fn,
    ...
  )
}
