#' Create a circular representative population chart
#'
#' Draws a circular representative population chart based on the proportion of the groups,
#' where each point (person) represents a determined number of individuals.
#' Every person is represented by an image with a given icon.
#'
#' @section Aesthetics:
#' geom_pop employs the following aesthetics:
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
#' @param dpi Height (in **pixels**) of the PNG icon when rendered with `fontawesome::fa_png()`.
#'        Higher values produce sharper icons. Defaults to 50. This affects **image dpi**, not icon size in the plot.
#' @param group_var The variable used to group individuals.
#' @param sample_size The total number of individuals (points) to be drawn.
#' @param arrange Logical; if TRUE, the output data is arranged by group.
#' @param seed Optional numeric seed used only when `arrange = FALSE` (randomized layouts).
#' @param sum_var Optional variable to sum over instead of counting.
#' @param facet Optional facetting variable. NOTE: final plot must be faceted; enforce with
#'        `validate_geom_pop_faceting(p)` after building the ggplot object.
#' @param legend_icons Logical; if TRUE, the legend will display the selected icons by the user.
#' @param stroke_width Numeric. Width of the black outline/border around icons in pixels.
#'
#' @return A ggplot layer with a circular representative population chart.
#'
#' @import dplyr
#' @export
geom_pop <- function(mapping = NULL, data = NULL, stat = "identity",
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, icon = "ggmale",
                     group_var = NULL, sample_size = NULL, arrange = FALSE,
                     seed = NULL,
                     sum_var = NULL,
                     facet = NULL,
                     size = 3,
                     dpi = 50,
                     legend_icons = TRUE,
                     stroke_width = NULL,
                     ...) {
  
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
  # VALIDATION: Layer & Data
  # ==============================================================================
  
  # Only one geom_pop per plot
  validate_single_geom_pop(plot_obj)
  
  # Data must be a data frame
  validate_data_is_dataframe(data)
  
  # No reserved column names
  validate_no_reserved_columns(data)
  
  # ==============================================================================
  # VALIDATION: Parameters
  # ==============================================================================
  
  dots <- list(...)
  validate_all_parameters(
    stroke_width = stroke_width,
    dpi = dpi,
    size = size,
    missing_size = .missing_size,
    arrange = arrange,
    legend_icons = legend_icons,
    seed = seed,
    dots = dots
  )
  
  # ==============================================================================
  # FACETING: Infer and validate
  # ==============================================================================
  
  # Helper: infer facet from facet_wrap/facet_grid
  infer_facet_var <- function(plot_obj) {
    if (is.null(plot_obj) || is.null(plot_obj$facet)) return(NULL)
    
    f <- plot_obj$facet
    
    if (!is.null(f$params$facets) && length(f$params$facets) == 1) {
      q <- f$params$facets[[1]]
      nm <- tryCatch(rlang::as_name(rlang::get_expr(q)), error = function(e) NULL)
      if (!is.null(nm) && nzchar(nm)) return(nm)
    }
    
    pick_one <- function(x) {
      if (is.null(x) || length(x) != 1) return(NULL)
      tryCatch(rlang::as_name(rlang::get_expr(x[[1]])), error = function(e) NULL)
    }
    
    r <- pick_one(f$params$rows)
    c <- pick_one(f$params$cols)
    
    if (!is.null(r) && is.null(c)) return(r)
    if (is.null(r) && !is.null(c)) return(c)
    
    NULL
  }
  
  facet_expr <- rlang::enexpr(facet)
  
  if (rlang::is_missing(facet_expr) || rlang::is_null(facet_expr)) {
    inferred <- infer_facet_var(plot_obj)
    if (!is.null(inferred)) {
      has_facet <- TRUE
      facet_col <- inferred
    } else {
      has_facet <- FALSE
      facet_col <- NULL
    }
  } else {
    has_facet <- TRUE
    if (rlang::is_symbol(facet_expr)) {
      facet_col <- rlang::as_name(facet_expr)
    } else if (rlang::is_string(facet_expr)) {
      facet_col <- facet_expr
    } else {
      cli::cli_abort(
        "`facet` must be a column name (facet = variable) or a string (facet = \"variable\")."
      )
    }
  }
  
  .facet_explicit <- !(rlang::is_missing(facet_expr) || rlang::is_null(facet_expr))
  
  # Validate facet column exists
  validate_facet_column(data, facet_col)
  
  # Validate facet consistency with plot
  inferred_plot_facet <- infer_facet_var(plot_obj)
  validate_facet_consistency(facet_col, inferred_plot_facet, .facet_explicit)
  
  # ==============================================================================
  # VALIDATION: Aesthetic Mappings
  # ==============================================================================
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # Validate icon aesthetic and get icon variable name
  icon_var <- validate_all_aesthetics(mapping_list, inherited_mapping_list, data)
  
  # Validate icon column has valid values
  validate_icon_column(data, icon_var)
  
  # ==============================================================================
  # DATA PREPARATION: Mode detection and type assignment
  # ==============================================================================
  
  processed_mode <- "type" %in% names(data)
  
  if (!processed_mode) {
    # Raw data mode - need grouping variable
    validate_raw_data_grouping(data, mapping_list, inherited_mapping_list)
    
    # Get grouping variable
    .get_mapped_var <- function(aes_name) {
      if (aes_name %in% names(combined_mapping)) {
        tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
      } else {
        NULL
      }
    }
    
    `%||%` <- function(x, y) if (is.null(x) || !nzchar(as.character(x))) y else x
    
    group_var_m <- .get_mapped_var("group")
    col_var_m <- .get_mapped_var("colour")
    if (is.null(col_var_m)) col_var_m <- .get_mapped_var("color")
    
    src_var <- group_var_m %||% col_var_m
    
    # Assign type from grouping variable
    data$type <- as.character(data[[src_var]])
  }
  
  # ==============================================================================
  # WARNINGS: Soft checks
  # ==============================================================================
  
  warn_all_geom_pop(
    combined_mapping = combined_mapping,
    missing_size = .missing_size,
    size = size,
    data = data,
    facet_explicit = .facet_explicit,
    facet_col = facet_col
  )
  
  # ==============================================================================
  # SIZE HANDLING
  # ==============================================================================
  
  if (!"icon" %in% names(mapping_list)) {
    mapping_list[["icon"]] <- as.name("icon")
  }
  
  # Handle size aesthetic vs parameter
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    
    if (!size_var %in% names(data)) {
      cli::cli_abort(
        "Variable {.field {size_var}} used for size not found in the dataset."
      )
    }
    
    data$icon_size <- data[[size_var]] * 0.0075
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.0075
  }
  
  # ==============================================================================
  # FACETING FINALIZATION
  # ==============================================================================
  
  # Auto-detect multi-group data as faceted
  if (!has_facet && "group" %in% names(data) && dplyr::n_distinct(data$group) > 1) {
    has_facet <- TRUE
    facet_col <- "group"
  }
  
  # ==============================================================================
  # DATA ARRANGEMENT & POSITIONING
  # ==============================================================================
  
  # Randomize order when arrange = FALSE (seedable)
  if (!isTRUE(arrange)) {
    if (!is.null(seed)) {
      set.seed(seed)
    }
    
    if (!has_facet) {
      data <- data[sample.int(nrow(data)), , drop = FALSE]
    } else {
      data <- data %>%
        dplyr::group_by(.data[[facet_col]]) %>%
        dplyr::slice_sample(prop = 1) %>%
        dplyr::ungroup()
    }
  }
  
  # Assign position numbers
  if (!has_facet) {
    data <- data %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number()))
  } else {
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number())) %>%
      dplyr::ungroup()
  }
  
  # ==============================================================================
  # VALIDATION: Maximum icons check
  # ==============================================================================
  
  validate_max_icons(data, has_facet, facet_col, max_icons = 1000L)
  
  # ==============================================================================
  # COORDINATE SYSTEM: Fetch and merge
  # ==============================================================================
  
  sample_size <- length(unique(data$pos))
  
  df_coordinates_final <- fetch_df_coordinates()
  df_coordinates_filtered <- df_coordinates_final %>%
    dplyr::filter(size == sample_size) %>%
    dplyr::rename(coord_size = size)
  df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
  
  df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
  
  has_np <- all(c("n", "prop") %in% names(data))
  
  # ==============================================================================
  # ARRANGEMENT LOGIC (if arrange = TRUE)
  # ==============================================================================
  
  if (!is.null(data) && arrange && !has_facet) {
    if (has_np) df_order <- data %>% dplyr::select(n, prop)
    
    data <- data %>%
      dplyr::mutate(original_order = dplyr::row_number()) %>%
      dplyr::arrange(type, original_order) %>%
      dplyr::mutate(pos = dplyr::row_number()) %>%
      dplyr::select(-original_order) %>%
      dplyr::select(-dplyr::any_of(c("n", "prop")))
    
    if (has_np) data <- dplyr::bind_cols(data, df_order)
    
    sample_size <- length(unique(data$pos))
    
    df_coordinates_final <- fetch_df_coordinates()
    df_coordinates_filtered <- df_coordinates_final %>%
      dplyr::filter(size == sample_size) %>%
      dplyr::rename(coord_size = size)
    df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
    
    df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
    
  } else if (!is.null(data) && arrange && has_facet) {
    if (has_np) df_order <- data %>% dplyr::select(n, prop)
    
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(original_order = dplyr::row_number()) %>%
      dplyr::ungroup() %>%
      dplyr::arrange(type, original_order, .data[[facet_col]]) %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = dplyr::row_number()) %>%
      dplyr::ungroup() %>%
      dplyr::select(-dplyr::any_of(c("n", "prop")))
    
    if (has_np) data <- dplyr::bind_cols(data, df_order)
    
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
  
  # ==============================================================================
  # FINAL DATA PREPARATION
  # ==============================================================================
  
  df_final <- df_merged %>% dplyr::filter(!is.na(.data$type))
  
  # Validate coordinates exist
  if (!"x1" %in% names(df_final) || !"y1" %in% names(df_final)) {
    cli::cli_abort(
      c(
        "x1 or y1 columns are missing after merging.",
        "i" = "Check that pos matches between data and df_coordinates_final."
      )
    )
  }
  
  # ==============================================================================
  # ICON RENDERING: Generate PNG paths with caching
  # ==============================================================================
  
  # Capture parameters in local scope BEFORE rowwise
  local_stroke_width <- stroke_width
  local_dpi <- dpi
  
  # Build per-row PNG path with color + alpha + stroke support
  df_final <- df_final %>%
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
          
          # Apply alpha to color for fill
          rgb_vals <- grDevices::col2rgb(this_color) / 255
          rgba_color <- grDevices::rgb(
            rgb_vals[1],
            rgb_vals[2],
            rgb_vals[3],
            alpha = this_alpha
          )
          
          cache_dir <- file.path(tempdir(), "ggpop-icons")
          if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
          
          # Build cache key with color, alpha, stroke, AND DPI
          color_hex <- gsub("#", "", this_color)
          alpha_str <- sprintf("%.2f", this_alpha)
          dpi_str <- sprintf("%.0f", local_dpi)
          
          cache_parts <- c(
            this_icon,
            paste0("c", color_hex),
            paste0("a", alpha_str),
            paste0("d", dpi_str)
          )
          
          # Add stroke to cache key if provided
          if (!is.null(local_stroke_width) && local_stroke_width > 0) {
            stroke_color_for_cache <- color_hex  # Same as fill color
            cache_parts <- c(
              cache_parts,
              paste0("sw", local_stroke_width),
              paste0("sc", stroke_color_for_cache)
            )
          }
          
          png_path <- file.path(
            cache_dir,
            paste0(paste(cache_parts, collapse = "_"), ".png")
          )
          
          # Generate PNG if not cached
          if (!file.exists(png_path)) {
            if (!is.null(local_stroke_width) && local_stroke_width > 0) {
              # With stroke - same color as fill
              fontawesome::fa_png(
                this_icon,
                file = png_path,
                height = local_dpi,
                fill = rgba_color,
                stroke = rgba_color,
                stroke_width = local_stroke_width
              )
            } else {
              # No stroke (solid fill only)
              fontawesome::fa_png(
                this_icon,
                file = png_path,
                height = local_dpi,
                fill = rgba_color
              )
            }
          }
          
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # ==============================================================================
  # LEGEND SETUP: Map icons by legend variable
  # ==============================================================================
  
  .get_mapped_var2 <- function(aes_name) {
    if (aes_name %in% names(mapping_list)) {
      tryCatch(rlang::as_name(mapping_list[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  legend_var <- .get_mapped_var2("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var2("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var2("group")
  if (is.null(legend_var) || !legend_var %in% names(df_final)) legend_var <- "type"
  
  
  warn_multiple_icons_per_group(df_final, legend_var, icon_var)
  
  
  icon_by_legend <- df_final %>%
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
    )
  
  icon_by_legend <- stats::setNames(icon_by_legend$icon, icon_by_legend$.legend)
  
  # ==============================================================================
  # LEGEND KEY GLYPH: Custom icon rendering
  # ==============================================================================
  
  # Capture stroke_width for key glyph
  local_stroke_width_for_legend <- stroke_width
  
  key_glyph_pop <- function(key_data, params, size) {
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
    
    if (is.na(ic) || !nzchar(ic)) ic <- "user"
    
    key_data$icon <- ic
    
    # Pass stroke_width to legend renderer
    draw_key_pop_image(key_data, params, size, stroke_width = local_stroke_width_for_legend)
  }
  
  # ==============================================================================
  # FINAL MAPPING & LAYER CONSTRUCTION
  # ==============================================================================
  
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["x"]]     <- as.name("x1")
  mapping_list[["y"]]     <- as.name("y1")
  mapping_list[["icon"]]  <- NULL
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  size_internal <- df_final$icon_size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  layer_out <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = df_final,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "width",
    asp          = 1,
    key_glyph    = if (legend_icons) key_glyph_pop else key_fn,
    ...
  )
  
  # Tag the layer so validator can enforce faceting on the FINAL plot
  layer_out$params$.ggpop_facet <- if (.facet_explicit) facet_col else NULL
  
  structure(
    list(layer = layer_out, facet_col = if (.facet_explicit) facet_col else NULL),
    class = "ggpop_geom_pop"
  )
}
