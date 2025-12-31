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
  # pos handling:
  # - no facet   -> global pos
  # - facet      -> keep existing per-facet pos (from process_data) if present
  # -------------------------------------------------
  if (!has_facet) {
    data <- dplyr::mutate(data, pos = as.numeric(dplyr::row_number()))
  } else {
    if (!("pos" %in% names(data))) {
      data <- data %>%
        dplyr::group_by(.data[[facet_col]]) %>%
        dplyr::mutate(pos = as.numeric(dplyr::row_number())) %>%
        dplyr::ungroup()
    }
  }
  
  # --------------------------------------------------------------
  # UPDATED: robust facet inference from DATA (not ggplot object)
  # If `process_data(high_group_var=...)` was used, it creates `group`.
  # Even if ggplot facet is added after geom_pop(), treat it as faceting.
  # --------------------------------------------------------------
  if (!has_facet && "group" %in% names(data)) {
    n_groups <- dplyr::n_distinct(data$group)
    if (n_groups > 1) {
      has_facet <- TRUE
      facet_col <- "group"
    }
  }
  
  # ensure per-facet pos BEFORE enforcing limits
  if (has_facet) {
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
          "[geom_pop] Too many icons requested (%d). Max is %d.\n  → Fix: reduce `sample_size` in `process_data(..., sample_size = %d)`.",
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
          "[geom_pop] Too many icons in facet group(s). Max is %d per group.\n  Offenders: %s\n  → Fix: reduce `sample_size` per group in `process_data(..., high_group_var = ..., sample_size = %d)`.",
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



