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
#' @param dpi Height (in **pixels**) of the PNG icon when rendered with `fontawesome::fa_png()`.
#'        Higher values produce sharper icons. Defaults to 50. This affects **image dpi**, not icon size in the plot.
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
                     dpi = 50,
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
  
  # --- infer facet from facet_wrap/facet_grid if facet= not supplied ---
  infer_facet_var <- function(plot_obj) {
    
    if (is.null(plot_obj) || is.null(plot_obj$facet)) return(NULL)
    
    f <- plot_obj$facet
    
    # facet_wrap: f$params$facets is usually a quosure list
    if (!is.null(f$params$facets) && length(f$params$facets) == 1) {
      q <- f$params$facets[[1]]
      nm <- tryCatch(rlang::as_name(rlang::get_expr(q)), error = function(e) NULL)
      if (!is.null(nm) && nzchar(nm)) return(nm)
    }
    
    # facet_grid: rows/cols stored in f$params$rows / f$params$cols
    pick_one <- function(x) {
      if (is.null(x) || length(x) != 1) return(NULL)
      tryCatch(rlang::as_name(rlang::get_expr(x[[1]])), error = function(e) NULL)
    }
    
    r <- pick_one(f$params$rows)
    c <- pick_one(f$params$cols)
    
    # allow exactly one variable overall (rows OR cols)
    if (!is.null(r) && is.null(c)) return(r)
    if (is.null(r) && !is.null(c)) return(c)
    
    NULL
  }
  
  # --- facet handling ---
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
    if (rlang::is_symbol(facet_expr)) facet_col <- rlang::as_name(facet_expr)
    else if (rlang::is_string(facet_expr)) facet_col <- facet_expr
    else stop("`facet` must be a column name (facet = variable) or a single string (facet = \"variable\").")
  }
  
  if (has_facet && !is.null(facet_col) && !facet_col %in% names(data)) {
    stop(sprintf("Facet column '%s' not found in `data`.", facet_col))
  }
  
  # -------------------------------------------------
  # SOFT WARNING (single, ASCII-safe)
  # -------------------------------------------------
  # This warning covers two common situations that can lead to icon overlap:
  # (1) Multiple groups created by process_data(high_group_var = ...)
  #     without faceting the plot.
  # (2) Explicit use of facet inside geom_pop(), which is advanced usage
  #     and may require careful layout choices.
  #
  # NOTE:
  # At layer build time we cannot reliably detect facet_wrap() added later,
  # so this warning is intentionally conservative.
  # -------------------------------------------------
  
  # ASCII-safe helper
  `%||%` <- function(x, y) if (is.null(x) || !nzchar(as.character(x))) y else x
  
  facet_expr <- rlang::enexpr(facet)
  
  .has_multi_groups <- "group" %in% names(data) &&
    dplyr::n_distinct(data$group) > 1
  
  .facet_explicit <- !(rlang::is_missing(facet_expr) || rlang::is_null(facet_expr))
  
  .group_var_msg <- if (.facet_explicit) {
    facet_col
  } else if (.has_multi_groups) {
    "group"
  } else {
    NULL
  }
  
  if (.has_multi_groups || .facet_explicit) {
    
    warning(
      paste0(
        "[geom_pop] Facet / grouping caution.\n\n",
        
        "Why you are seeing this warning:\n",
        
        if (.has_multi_groups && !.facet_explicit) paste0(
          "- The data contains multiple groups in data$group ",
          "(often created by process_data(high_group_var = ...)).\n",
          "  If the plot is not faceted, icons from different groups ",
          "may overlap in the same panel.\n\n"
        ) else "",
        
        if (.facet_explicit) paste0(
          "- You provided facet = ", facet_col, " inside geom_pop().\n",
          "  Icons are positioned per ", facet_col, ", but if the plot ",
          "is not actually faceted with facet_wrap() or facet_grid(), ",
          "everything may render into a single panel.\n\n"
        ) else "",
        
        "Recommended patterns:\n",
        
        if (!is.null(.group_var_msg)) paste0(
          "- Facet in ggplot2:\n",
          "  ggplot() + geom_pop(..., facet = ", .group_var_msg,
          ") + facet_wrap(~ ", .group_var_msg, ")\n\n"
        ) else "",
        
        "- Alternative layout:\n",
        "  Create one plot per subgroup and combine them with cowplot ",
        "or patchwork. This is often more predictable than faceting ",
        "when drawing icon-based circles.\n\n",
        
        "If you want one pooled circle:\n",
        "- Re-run process_data() without high_group_var.\n"
      ),
      call. = FALSE
    )
  }
  
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }
  
  validate_geom_pop_inputs(data, mapping_list, icon, size, dpi, inherited_data)
  
  warn_geom_pop_inputs(
    data, mapping_list, inherited_mapping_list,
    icon = icon,
    missing_size = .missing_size,
    legend_icons = legend_icons,
    dpi = dpi
  )
  
  if (!"icon" %in% names(mapping_list)) mapping_list[["icon"]] <- as.name("icon")
  if (!"icon" %in% names(data)) data$icon <- icon
  
  # size  (icon_size to avoid collision with coord size)
  if ("size" %in% names(mapping_list)) {
    size_var <- rlang::as_name(mapping_list[["size"]])
    if (!size_var %in% names(data)) stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  # -------------------------------------------------
  # UPDATED pos + facet behavior (both implementations)
  #
  # 1) If facet is NOT provided, we pool into ONE circle:
  #    - Always assign global pos (prevents overlap from pre-existing per-group pos)
  #
  # 2) If `process_data(high_group_var=...)` was used, it creates `group`.
  #    - If there are multiple groups, we treat it as faceted internally by `group`,
  #      even if `facet_wrap(~ group)` is added after geom_pop().
  # -------------------------------------------------
  
  # If user didn't pass facet=, but data has multiple `group`s, treat as faceting by `group`
  if (!has_facet && "group" %in% names(data) && dplyr::n_distinct(data$group) > 1) {
    has_facet <- TRUE
    facet_col <- "group"
  }
  
  if (!has_facet) {
    # Always override any existing `pos` (prevents overlap when pooling)
    data <- data %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number()))
  } else {
    # Always make pos per-facet group (override any existing pos to be safe)
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number())) %>%
      dplyr::ungroup()
  }
  
  # ---- ENFORCE MAX ICONS ----
  MAX_ICONS <- 1000L
  
  if (!has_facet) {
    n_icons <- dplyr::n_distinct(data$pos)
    if (n_icons > MAX_ICONS) {
      stop(
        sprintf(
          "[geom_pop] Too many icons requested (%d). Max is %d.\n  Fix: reduce `sample_size` in `process_data(..., sample_size = %d)`.",
          n_icons, MAX_ICONS, MAX_ICONS
        ),
        call. = FALSE
      )
    }
  } else {
    # allow up to 1000 icons PER facet group
    per_group <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::summarise(n_icons = dplyr::n_distinct(pos), .groups = "drop")
    
    too_big <- per_group %>% dplyr::filter(n_icons > MAX_ICONS)
    
    if (nrow(too_big) > 0) {
      bad <- paste0(too_big[[facet_col]], " (", too_big$n_icons, ")", collapse = ", ")
      stop(
        sprintf(
          "[geom_pop] Too many icons in facet group(s). Max is %d per group.\n  Offenders: %s\n  Fix: reduce `sample_size` per group in `process_data(..., high_group_var = ..., sample_size = %d)`.",
          MAX_ICONS, bad, MAX_ICONS
        ),
        call. = FALSE
      )
    }
  }
  
  sample_size <- length(unique(data$pos))
  
  df_coordinates_final <- fetch_df_coordinates()
  df_coordinates_filtered <- df_coordinates_final %>%
    dplyr::filter(size == sample_size) %>%
    dplyr::rename(coord_size = size)
  df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
  
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
    df_coordinates_filtered <- df_coordinates_final %>%
      dplyr::filter(size == sample_size) %>%
      dplyr::rename(coord_size = size)
    df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
    
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
          if (file.exists(png_path)) unlink(png_path)
          fontawesome::fa_png(this_icon, file = png_path, height = dpi)
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # ---- LEGEND FIX: inject icon into key-glyph using .id ----
  # ---- LEGEND FIX: respect scale breaks order (works with breaks + labels) ----
  
  colour_var <- NULL
  if ("colour" %in% names(mapping_list)) {
    colour_var <- rlang::as_name(mapping_list[["colour"]])
  } else if ("color" %in% names(mapping_list)) {
    colour_var <- rlang::as_name(mapping_list[["color"]])
  }
  
  icon_var <- rlang::as_name(mapping_list[["icon"]])
  
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
  
  .icon_levels_cache <- NULL
  
  key_glyph_pop <- function(key_data, params, size) {
    
    if (is.null(.icon_levels_cache)) {
      
      built <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot()),
                        error = function(e) NULL)
      
      breaks <- NULL
      if (!is.null(built) && !is.null(colour_var)) {
        sc <- built$plot$scales$get_scales("colour")
        if (is.null(sc)) sc <- built$plot$scales$get_scales("color")
        if (!is.null(sc)) {
          breaks <- sc$get_breaks()
          breaks <- breaks[!is.na(breaks)]
        }
      }
      
      if (is.null(breaks) && !is.null(colour_var) && colour_var %in% names(df_final)) {
        breaks <- unique(as.character(df_final[[colour_var]]))
      }
      
      if (!is.null(icon_by_group) && !is.null(breaks)) {
        .icon_levels_cache <<- unname(icon_by_group[as.character(breaks)])
      } else {
        .icon_levels_cache <<- unique(as.character(df_final[[icon_var]]))
      }
    }
    
    if (".id" %in% names(key_data)) {
      idx <- as.integer(key_data$.id)
    } else if ("group" %in% names(key_data)) {
      idx <- as.integer(key_data$group)
    } else {
      idx <- 1L
    }
    
    idx <- pmax(1L, pmin(length(.icon_levels_cache), idx))
    key_data$icon <- as.character(.icon_levels_cache[idx][1])
    
    draw_key_pop_image(key_data, params, size)
  }
  
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
