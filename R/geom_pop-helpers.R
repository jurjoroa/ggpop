#' Handle size aesthetic vs parameter for geom_pop
#'
#' Determines whether `size` is mapped in the aesthetics or passed as a fixed
#' parameter, then computes the internal `icon_size` used for rendering.
#'
#' @param data Data frame of plotting data.
#' @param combined_mapping Combined mapping list (inherited + layer mapping).
#' @param mapping_list Mapping list for the current layer.
#' @param inherited_mapping_list Mapping list inherited from the plot.
#' @param size Fixed size parameter from `geom_pop()`.
#' @param size_scale Numeric multiplier applied to icon sizes.
#'
#' @return A list with:
#' \itemize{
#'   \item \code{data}: input data with an added \code{icon_size} column
#'   \item \code{mapping_list}: updated mapping list with \code{size} removed if mapped
#' }
#' @keywords internal
#' @noRd
handle_size_aesthetic_pop <- function(data,
                                      combined_mapping,
                                      mapping_list,
                                      inherited_mapping_list,
                                      size,
                                      size_scale = 0.03) {
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }

    if (!size_var %in% names(data)) {
      cli::cli_abort(
        "Variable {.field {size_var}} used for size not found in the dataset.",
        call = NULL
      )
    }

    data$icon_size <- data[[size_var]] * size_scale
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * size_scale
  }

  list(data = data, mapping_list = mapping_list)
}

#' Shuffle data (if arrange = FALSE), respecting facets
#'
#' Randomizes row order when \code{arrange = FALSE}. If faceting is active,
#' shuffles within each facet group.
#'
#' @param data Data frame of plotting data.
#' @param has_facet Logical; whether faceting is active.
#' @param facet_col Character; facet column name.
#' @param arrange Logical; if FALSE, shuffle data.
#' @param seed Optional numeric seed for reproducible shuffling.
#'
#' @return Data frame with rows potentially shuffled.
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
#'
#' Adds a sequential \code{pos} column used for icon placement, either globally
#' or within each facet.
#'
#' @param data Data frame of plotting data.
#' @param has_facet Logical; whether faceting is active.
#' @param facet_col Character; facet column name.
#'
#' @return Data frame with \code{pos} column added.
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
#'
#' Builds a custom legend key function that chooses an icon based on the legend
#' label and renders it with the pop key drawing routine.
#'
#' @param icon_by_legend Named character vector mapping legend labels to icons.
#' @param plot_obj ggplot object (used to resolve scale breaks).
#' @param stroke_width Numeric; outline width in pixels.
#' @param alpha_by_legend Named numeric vector mapping legend labels to alpha values.
#'   When provided, overrides the alpha from \code{key_data} for each matched label.
#' @param fallback_icon Icon name to use when no legend icon is resolved.
#'
#' @return A function suitable for ggplot2's \code{key_glyph} argument.
#' @keywords internal
#' @noRd
make_pop_key_glyph <- function(icon_by_legend, plot_obj, stroke_width,
                               alpha_by_legend = NULL,
                               fallback_icon = "user",
                               icon_path = NULL) {
  local_stroke_width_for_legend <- stroke_width
  local_alpha_by_legend <- alpha_by_legend
  local_icon_path <- icon_path

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

    if (!is.null(local_alpha_by_legend)) {
      if (!is.na(lbl) && lbl %in% names(local_alpha_by_legend)) {
        key_data$alpha <- local_alpha_by_legend[[lbl]]
      } else {
        alpha_levels <- unname(local_alpha_by_legend)
        idx <- NA_integer_
        if (".id" %in% names(key_data)) idx <- as.integer(key_data$.id[1])
        if (is.na(idx) && "group" %in% names(key_data)) idx <- as.integer(key_data$group[1])
        if (is.na(idx)) idx <- 1L
        idx <- max(1L, min(length(alpha_levels), idx))
        key_data$alpha <- alpha_levels[idx]
      }
    }

    if (is.na(ic) || !nzchar(ic)) ic <- fallback_icon

    key_data$icon <- ic

    draw_key_pop_image(key_data, params, size, stroke_width = local_stroke_width_for_legend,
      icon_path = local_icon_path)
  }
}

#' Merge population data with circle coordinates
#'
#' Joins population data with precomputed circle coordinates, handling arrangement
#' and faceting differences.
#'
#' @param data Data frame of plotting data.
#' @param has_facet Logical; whether faceting is active.
#' @param facet_col Character; facet column name.
#' @param arrange Logical; whether to arrange by group.
#'
#' @return A list with:
#' \itemize{
#'   \item \code{data}: possibly reordered input data
#'   \item \code{df_merged}: merged coordinates + data
#' }
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
#'
#' Determines whether faceting is active and which column is used for faceting.
#' This version expects a pre-computed facet expression.
#'
#' @param plot_obj ggplot object (typically from the calling context).
#' @param facet_expr Quosure or expression for facet; may be missing or NULL.
#'
#' @return A list with:
#' \itemize{
#'   \item \code{has_facet}: logical indicating whether faceting is used
#'   \item \code{facet_col}: facet column name (character) or NULL
#'   \item \code{facet_explicit}: logical indicating whether facet was explicitly provided
#'   \item \code{inferred_plot_facet}: facet column inferred from plot (character or NULL)
#' }
#' @keywords internal
#' @noRd
resolve_facet_info <- function(plot_obj, facet_expr) {
  infer_facet_var <- function(plot_obj) {
    if (is.null(plot_obj) || is.null(plot_obj$facet)) {
      return(NULL)
    }
    f <- plot_obj$facet

    if (!is.null(f$params$facets) && length(f$params$facets) == 1) {
      q <- f$params$facets[[1]]
      nm <- tryCatch(rlang::as_name(rlang::get_expr(q)), error = function(e) NULL)
      if (!is.null(nm) && nzchar(nm)) {
        return(nm)
      }
    }

    pick_one <- function(x) {
      if (is.null(x) || length(x) != 1) {
        return(NULL)
      }
      tryCatch(rlang::as_name(rlang::get_expr(x[[1]])), error = function(e) NULL)
    }

    r <- pick_one(f$params$rows)
    c <- pick_one(f$params$cols)

    if (!is.null(r) && is.null(c)) {
      return(r)
    }
    if (is.null(r) && !is.null(c)) {
      return(c)
    }

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
        "`facet` must be a column name (facet = variable) or a string (facet = \"variable\").",
        call = NULL
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
#'
#' Returns `y` if `x` is NULL or empty; otherwise returns `x`.
#'
#' @param x Primary value.
#' @param y Fallback value.
#'
#' @return `x` if non-empty, otherwise `y`.
#' @keywords internal
#' @noRd
`%||%` <- function(x, y) if (is.null(x) || !nzchar(as.character(x))) y else x
