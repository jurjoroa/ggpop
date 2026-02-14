#' Resolve faceting info for geom_pop
#' @keywords internal
#' @noRd
resolve_facet_info <- function(plot_obj, facet) {
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
  
  list(
    has_facet = has_facet,
    facet_col = facet_col,
    facet_explicit = !(rlang::is_missing(facet_expr) || rlang::is_null(facet_expr)),
    inferred_plot_facet = infer_facet_var(plot_obj)
  )
}

#' Handle size aesthetic vs parameter for geom_pop
#' @keywords internal
#' @noRd
handle_size_aesthetic_pop <- function(data, combined_mapping, mapping_list, inherited_mapping_list, size) {
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
  
  list(data = data, mapping_list = mapping_list)
}

#' Shuffle data (if arrange = FALSE), respecting facets
#' @keywords internal
#' @noRd
maybe_shuffle_pop_data <- function(data, has_facet, facet_col, arrange, seed) {
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
  
  data
}

#' Assign position indices
#' @keywords internal
#' @noRd
assign_pop_positions <- function(data, has_facet, facet_col) {
  if (!has_facet) {
    data <- data %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number()))
  } else {
    data <- data %>%
      dplyr::group_by(.data[[facet_col]]) %>%
      dplyr::mutate(pos = as.numeric(dplyr::row_number())) %>%
      dplyr::ungroup()
  }
  
  data
}

#' Create pop key glyph function
#' @keywords internal
#' @noRd
make_pop_key_glyph <- function(icon_by_legend, plot_obj, stroke_width) {
  local_stroke_width_for_legend <- stroke_width
  
  function(key_data, params, size) {
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
}

#' Merge population data with circle coordinates
#' @keywords internal
#' @noRd
merge_pop_coordinates <- function(data, has_facet, facet_col, arrange) {
  has_np <- all(c("n", "prop") %in% names(data))
  
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
    
  } else {
    sample_size <- length(unique(data$pos))
    
    df_coordinates_final <- fetch_df_coordinates()
    df_coordinates_filtered <- df_coordinates_final %>%
      dplyr::filter(size == sample_size) %>%
      dplyr::rename(coord_size = size)
    df_coordinates_filtered$coord_size <- as.character(df_coordinates_filtered$coord_size)
    
    df_merged <- dplyr::left_join(df_coordinates_filtered, data, by = "pos")
  }
  
  list(data = data, df_merged = df_merged)
}


#' Resolve faceting info for geom_pop
#' @keywords internal
#' @noRd
resolve_facet_info <- function(plot_obj, facet_expr) {
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
  
  list(
    has_facet = has_facet,
    facet_col = facet_col,
    facet_explicit = !(rlang::is_missing(facet_expr) || rlang::is_null(facet_expr)),
    inferred_plot_facet = infer_facet_var(plot_obj)
  )
}

#' Null-or-empty coalesce
#' @keywords internal
#' @noRd
`%||%` <- function(x, y) if (is.null(x) || !nzchar(as.character(x))) y else x