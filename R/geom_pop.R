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
                     size = 1,
                     dpi = 50,
                     legend_icons = TRUE,
                     stroke_width = NULL,
                     ...) {
  
  # ---------------------------------------------------------------------------
  # 01 Setup: plot context + inherited mappings
  # ---------------------------------------------------------------------------
  context <- extract_plot_context()
  plot_obj <- context$plot_obj
  inherited_mapping_list <- context$inherited_mappings
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # ---------------------------------------------------------------------------
  # 02 Validation: layer + data
  # ---------------------------------------------------------------------------
  validate_single_geom_pop(plot_obj)
  validate_data_is_dataframe(data)
  validate_data_not_empty(data)
  validate_no_reserved_columns(data)
  
  # ---------------------------------------------------------------------------
  # 03 Validation: parameters
  # ---------------------------------------------------------------------------
  dots <- list(...)
  
  if ("alpha" %in% names(dots)) {
    validate_alpha_parameter(dots$alpha)
  }
  
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
  
  # ---------------------------------------------------------------------------
  # 04 Faceting: infer + validate
  # ---------------------------------------------------------------------------
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
  
  validate_facet_column(data, facet_col)
  inferred_plot_facet <- infer_facet_var(plot_obj)
  validate_facet_consistency(facet_col, inferred_plot_facet, .facet_explicit)
  
  # ---------------------------------------------------------------------------
  # 05 Validation: aesthetics (shared with geom_icon_point)
  # ---------------------------------------------------------------------------
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  validate_no_fill_aesthetic(combined_mapping)
  
  validate_no_image_aesthetic(mapping_list)
  
  validate_stroke_width_not_aesthetic(combined_mapping)
  
  icon_info <- resolve_icon_variable(mapping_list, inherited_mapping_list,
                                     combined_mapping, icon, data)
  icon_var <- icon_info$icon_var
  data <- icon_info$data
  has_icon_param <- icon_info$has_icon_param
  
  mapping_list <- add_icon_to_mapping(mapping_list, inherited_mapping_list, icon_var)
  data <- normalize_icon_column(data, icon_var)
  
  # ---------------------------------------------------------------------------
  # 06 Data preparation: detect mode + assign type
  # ---------------------------------------------------------------------------
  processed_mode <- "type" %in% names(data)
  
  if (!processed_mode) {
    validate_raw_data_grouping(data, mapping_list, inherited_mapping_list)
    
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
    
    data$type <- as.character(data[[src_var]])
  }
  
  # ---------------------------------------------------------------------------
  # 07 Warnings (shared)
  # ---------------------------------------------------------------------------
  
  warn_all_geom_pop(
    combined_mapping = combined_mapping,
    missing_size = .missing_size,
    size = size,
    data = data,
    facet_explicit = .facet_explicit,
    facet_col = facet_col,
    dots = dots 
  )
  
  # ---------------------------------------------------------------------------
  # 08 Size handling
  # ---------------------------------------------------------------------------
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
    
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  # ---------------------------------------------------------------------------
  # 09 Faceting finalization
  # ---------------------------------------------------------------------------
  if (!has_facet && "group" %in% names(data) && dplyr::n_distinct(data$group) > 1) {
    has_facet <- TRUE
    facet_col <- "group"
  }
  
  # ---------------------------------------------------------------------------
  # 10 Data arrangement + positioning
  # ---------------------------------------------------------------------------
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
  
  if (!has_facet) {
    data <- data %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number()))
  } else {
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number())) %>%
      dplyr::ungroup()
  }
  
  # ---------------------------------------------------------------------------
  # 11 Validation: max icons
  # ---------------------------------------------------------------------------
  validate_max_icons(data, has_facet, facet_col, max_icons = 1000L)
  
  # ---------------------------------------------------------------------------
  # 12 Coordinate system: fetch + merge
  # ---------------------------------------------------------------------------
  sample_size <- length(unique(data$pos))
  
  df_coordinates_final <- fetch_df_coordinates()
  df_coordinates_filtered <- df_coordinates_final %>%
    dplyr::filter(size == sample_size) %>%
    dplyr::rename(coord_size = size)
  df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
  
  df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
  
  has_np <- all(c("n", "prop") %in% names(data))
  
  # ---------------------------------------------------------------------------
  # 13 Arrangement logic (if arrange = TRUE)
  # ---------------------------------------------------------------------------
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
  
  # ---------------------------------------------------------------------------
  # 14 Final data preparation
  # ---------------------------------------------------------------------------
  df_final <- df_merged %>% dplyr::filter(!is.na(.data$type))
  
  if (!"x1" %in% names(df_final) || !"y1" %in% names(df_final)) {
    cli::cli_abort(
      c(
        "x1 or y1 columns are missing after merging.",
        "i" = "Check that pos matches between data and df_coordinates_final."
      )
    )
  }
  
  # ---------------------------------------------------------------------------
  # 15 Icon rendering: PNG generation + caching (shared)
  # ---------------------------------------------------------------------------
  df_final <- add_icon_images(df_final, dpi, stroke_width)
  
  # ---------------------------------------------------------------------------
  # 16 Legend setup (shared)
  # ---------------------------------------------------------------------------
  legend_var <- detect_legend_variable(combined_mapping, df_final)
  icon_by_legend <- create_icon_by_legend(df_final, legend_var, icon, has_icon_param)
  
  warn_multiple_icons_per_group(df_final, legend_var, "icon")
  
  # ---------------------------------------------------------------------------
  # 17 Legend key glyph: custom icon rendering
  # ---------------------------------------------------------------------------
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
    
    draw_key_pop_image(key_data, params, size, stroke_width = local_stroke_width_for_legend)
  }
  
  # ---------------------------------------------------------------------------
  # 18 Final mapping + layer construction
  # ---------------------------------------------------------------------------
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
  
  # ---------------------------------------------------------------------------
  # 19 Return layer + facet metadata
  # ---------------------------------------------------------------------------
  layer_out$params$.ggpop_facet <- if (.facet_explicit) facet_col else NULL
  
  structure(
    list(layer = layer_out, facet_col = if (.facet_explicit) facet_col else NULL),
    class = "ggpop_geom_pop"
  )
}
