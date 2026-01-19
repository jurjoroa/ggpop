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
                     stroke_width = NULL,  # NEW PARAMETER
                     ...) {
  
  inherited_data <- tryCatch(
    ggplot2::ggplot_build(ggplot2::last_plot())$plot$data,
    error = function(e) NULL
  )
  
  plot_obj <- tryCatch(ggplot2::ggplot_build(ggplot2::last_plot())$plot, error = function(e) NULL)
  inherited_mapping_list <- if (!is.null(plot_obj$mapping)) as.list(plot_obj$mapping) else list()
  
  
  # -------------------------------------------------
  # HARD STOP: only one geom_pop() per plot
  # -------------------------------------------------
  if (!is.null(plot_obj) && length(plot_obj$layers) > 0) {
    # Check if any existing layer is a geom_pop
    has_geom_pop <- any(vapply(plot_obj$layers, function(layer) {
      inherits(layer$geom, "GeomImage") && 
        !is.null(layer$aes_params) || 
        inherits(layer, "ggpop_geom_pop") ||
        ("ggpop_geom_pop" %in% class(layer))
    }, logical(1)))
    
    if (has_geom_pop) {
      stop(
        paste0(
          "[geom_pop] Multiple geom_pop() layers detected.\n\n",
          "Why this is an error:\n",
          "- Only ONE geom_pop() layer is allowed per plot.\n",
          "- Multiple layers create legend conflicts where only the last layer's icons are shown.\n",
          "Fix:\n",
          "Option 1: Combine all data into one geom_pop() call:\n",
          "  df_all <- bind_rows(df1, df2, df3)\n",
          "  ggplot() + geom_pop(data = df_all, aes(icon = icon, color = group))\n\n",
          "Option 2: Create separate plots and combine with patchwork:\n",
          "  library(patchwork)\n",
          "  p1 <- ggplot() + geom_pop(data = df1, ...)\n",
          "  p2 <- ggplot() + geom_pop(data = df2, ...)\n",
          "  p1 | p2\n\n",
          "Option 3: Use faceting if appropriate:\n",
          "  ggplot() + geom_pop(data = df_all, aes(...)) + facet_wrap(~ group)\n"
        ),
        call. = FALSE
      )
    }
  }
  
  
  .missing_size <- missing(size)
  
  if (is.null(data)) {
    data <- ggplot2::ggplot_build(ggplot2::last_plot())$plot$data
  }
  
  # --- infer facet from facet_wrap/facet_grid if facet= not supplied ---
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
  # NOTE:
  # We do NOT hard-stop here based on ggplot facet_wrap/grid,
  # because ggplot adds facets after layers (left-to-right).
  # The mandatory check is enforced by your validator on the final plot.
  #
  # We DO still prevent mismatches when we can detect a facet already.
  # -------------------------------------------------
  .facet_explicit <- !(rlang::is_missing(facet_expr) || rlang::is_null(facet_expr))
  if (.facet_explicit) {
    inferred_plot_facet <- infer_facet_var(plot_obj)
    if (!is.null(inferred_plot_facet) && !identical(inferred_plot_facet, facet_col)) {
      stop(
        paste0(
          "[geom_pop] Facet mismatch.\n\n",
          "geom_pop(facet = ", facet_col, ") but the plot is faceted by `", inferred_plot_facet, "`.\n\n",
          "Fix:\n",
          "- Make them match, e.g. `facet_wrap(~ ", facet_col, ")`.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  # -------------------------------------------------
  # HARD STOP: arrange must be logical
  # -------------------------------------------------
  if (!is.logical(arrange) || length(arrange) != 1 || is.na(arrange)) {
    stop(
      paste0(
        "[geom_pop] Invalid `arrange` parameter.\n\n",
        "Why this is an error:\n",
        "- `arrange` must be a single logical value (TRUE or FALSE).\n",
        "- You provided: ", 
        if (is.character(arrange)) paste0('"', arrange, '"') else deparse(arrange),
        " (", class(arrange)[1], ")\n\n",
        "Fix:\n",
        "- Use `arrange = TRUE` to sort icons by group.\n",
        "- Use `arrange = FALSE` for randomized layouts (default).\n"
      ),
      call. = FALSE
    )
  }
  
  
  # -------------------------------------------------
  # HARD STOP: dpi too low -> blurry icons
  # -------------------------------------------------
  if (is.numeric(dpi) && length(dpi) == 1 && !is.na(dpi) && is.finite(dpi)) {
    if (dpi < 30) {
      stop(
        paste0(
          "[geom_pop] `dpi = ", dpi, "` is too low.\n",
          "Icons will look blurry when rendered with fontawesome::fa_png().\n\n",
          "Fix:\n",
          "- Use dpi >= 30 (recommended: 50-200 for crisp icons).\n",
          "- If you want smaller icons, change `size`, not `dpi`.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  # -------------------------------------------------
  # SOFT WARNING (single, ASCII-safe)
  # -------------------------------------------------
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
          "  Icons are positioned per ", facet_col, ".\n",
          "  If the final plot is not faceted with facet_wrap() or facet_grid(), ",
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
        "or patchwork.\n\n",
        "If you want one pooled circle:\n",
        "- Re-run process_data() without high_group_var.\n"
      ),
      call. = FALSE
    )
  }
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # Combine inherited and layer mappings for checking
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # -------------------------------------------------
  # WARNING: size specified both in aes() and as argument
  # -------------------------------------------------
  if ("size" %in% names(combined_mapping) && !missing(size)) {
    warning(
      paste0(
        "[geom_pop] `size` was provided both inside aes() and as a parameter.\n\n",
        "What happens:\n",
        "- `aes(size = <variable>)` controls icon size per row.\n",
        "- The argument `geom_pop(aes(), size = ", size, ")` will be ignored.\n\n",
        "Tip:\n",
        "- Use ONLY `aes(size = <variable>)` for data-driven sizes, OR\n",
        "- Remove `size` from aes() and set a fixed size via geom_pop(size = ...).\n"
      ),
      call. = FALSE
    )
  }
  
  # -------------------------------------------------
  # HARD STOP: icon is mandatory
  # -------------------------------------------------
  icon_mapped  <- "icon" %in% names(combined_mapping)
  has_icon_col <- "icon" %in% names(data)
  
  if (!icon_mapped && !has_icon_col) {
    stop(
      paste0(
        "[geom_pop] No icon specified.\n\n",
        "Fix:\n",
        "- Provide `aes(icon = <column>)`, OR\n",
        "- Add an `icon` column to `data`.\n"
      ),
      call. = FALSE
    )
  }
  
  if ("image" %in% names(mapping_list)) {
    stop("Please do not specify the 'image' aesthetic directly. Use 'icon' instead.")
  }
  
  # -------------------------------------------------
  # MODE DETECTION (keep process_data users working; support raw users too)
  # -------------------------------------------------
  processed_mode <- "type" %in% names(data)
  
  if (!processed_mode) {
    
    # FIXED: Check COMBINED mapping (inherited + layer)
    .get_mapped_var <- function(aes_name) {
      if (aes_name %in% names(combined_mapping)) {
        tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
      } else {
        NULL
      }
    }
    
    group_var_m <- .get_mapped_var("group")
    col_var_m   <- .get_mapped_var("colour")
    if (is.null(col_var_m)) col_var_m <- .get_mapped_var("color")
    
    src_var <- group_var_m %||% col_var_m
    
    if (is.null(src_var)) {
      stop(
        paste0(
          "[geom_pop] Raw data detected.\n\n",
          "Why this is an error:\n",
          "- Your data was not created with `process_data()`.\n",
          "- `geom_pop()` needs a grouping variable to build the circle layout.\n\n",
          "Fix:\n",
          "- Map `aes(group = <variable>)` (recommended), OR\n",
          "- Map `aes(color = <variable>)`.\n\n",
          "Example:\n",
          "  ggplot() +\n",
          "    geom_pop(\n",
          "      data = df,\n",
          "      aes(icon = icon, group = sex),\n",
          "      size = 4\n",
          "    )\n"
        ),
        call. = FALSE
      )
    }
    
    if (!src_var %in% names(data)) {
      stop(
        paste0(
          "[geom_pop] Raw data detected, but mapped grouping variable '", src_var,
          "' was not found in `data`.\n",
          "Fix: ensure the column exists or update your aes().\n"
        ),
        call. = FALSE
      )
    }
    
    data$type <- as.character(data[[src_var]])
  }
  
  validate_geom_pop_inputs(data, mapping_list, icon, size, dpi, inherited_data)
  
  warn_geom_pop_inputs(
    data,
    mapping_list,
    inherited_mapping_list,
    icon          = icon,
    missing_size  = .missing_size,
    size          = size,
    legend_icons  = legend_icons,
    dpi           = dpi,
    arrange       = arrange
  )
  
  if (!"icon" %in% names(mapping_list)) mapping_list[["icon"]] <- as.name("icon")
  if (!"icon" %in% names(data)) data$icon <- icon
  
  # size  (icon_size to avoid collision with coord size)
  if ("size" %in% names(combined_mapping)) {
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    if (!size_var %in% names(data)) stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    data$icon_size <- data[[size_var]] * 0.03
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.03
  }
  
  # If user didn't pass facet=, but data has multiple `group`s, treat as faceting by `group`
  if (!has_facet && "group" %in% names(data) && dplyr::n_distinct(data$group) > 1) {
    has_facet <- TRUE
    facet_col <- "group"
  }
  
  # -------------------------------------------------
  # Randomize order when arrange = FALSE (seedable)
  # -------------------------------------------------
  if (!isTRUE(arrange)) {
    
    if (!is.null(seed)) {
      if (!is.numeric(seed) || length(seed) != 1 || is.na(seed)) {
        stop("[geom_pop] `seed` must be a single numeric value.", call. = FALSE)
      }
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
  }
  
  # Final data
  df_final <- df_merged %>% dplyr::filter(!is.na(.data$type))
  
  if (!"x1" %in% names(df_final) || !"y1" %in% names(df_final)) {
    stop("x1 or y1 columns are missing after merging. Check that pos matches between data and df_coordinates_final.")
  }
  
  # -------------------------------------------------
  # HARD STOP: missing / empty icons are not allowed
  # -------------------------------------------------
  if ("icon" %in% names(df_final)) {
    bad_icon <- is.na(df_final$icon) | !nzchar(as.character(df_final$icon))
    if (any(bad_icon)) {
      n_bad <- sum(bad_icon)
      stop(
        paste0(
          "[geom_pop] Invalid icon values detected.\n\n",
          "Found ", n_bad, " row(s) with missing or empty `icon` values.\n\n",
          "Fix:\n",
          "- Ensure `icon` is non-missing for all rows.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  # -------------------------------------------------
  # HARD STOP: alpha must be in aes(), not as parameter
  # -------------------------------------------------
  if ("alpha" %in% names(list(...))) {
    stop(
      paste0(
        "[geom_pop] `alpha` cannot be used as a parameter.\n\n",
        "Why this is an error:\n",
        "- `alpha` must be mapped inside aes() to work correctly with icon coloring.\n",
        "- Parameter-based alpha creates conflicts between PNG transparency and rendering.\n\n",
        "Fix:\n",
        "- For fixed transparency, add an alpha column:\n",
        "  data$alpha_val <- 0.5\n",
        "  geom_pop(aes(icon = icon, group = sex, color = sex, alpha = alpha_val))\n\n",
        "- For variable transparency:\n",
        "  geom_pop(aes(icon = icon, group = sex, color = sex, alpha = confidence))\n\n",
        "- If you want get rid of alpha legend entries, use `guides(alpha = `none`)`.\n"
      ),
      call. = FALSE
    )
  }
  
  
  # -------------------------------------------------
  # HARD STOP: fill aesthetic is not supported
  # -------------------------------------------------
  if ("fill" %in% names(combined_mapping)) {
    stop(
      paste0(
        "[geom_pop] `fill` aesthetic is not supported.\n\n",
        "Why this is an error:\n",
        "- To keep the API simple, only `color` or `colour` are supported for icon coloring.\n",
        "- FontAwesome icons are colored via the `fill` parameter internally, but we map\n",
        "  the `color` aesthetic to it.\n\n",
        "Fix:\n",
        "- Use `aes(color = <variable>)` or `aes(colour = <variable>)` instead.\n\n",
        "Example:\n",
        "  geom_pop(aes(icon = icon, group = sex, color = sex))  # ✓ Correct\n",
        "  geom_pop(aes(icon = icon, group = sex, fill = sex))   # ✗ Not allowed\n"
      ),
      call. = FALSE
    )
  }
  
  # -------------------------------------------------
  # Capture parameters in local scope BEFORE rowwise
  # -------------------------------------------------
  local_stroke_width <- stroke_width  # ← DEFINE HERE, BEFORE df_final pipe
  local_dpi <- dpi
  
  # ---- build per-row PNG path with color + alpha + stroke support ----
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
          
          # Build cache key with color, alpha, and stroke
          color_hex <- gsub("#", "", this_color)
          alpha_str <- sprintf("%.2f", this_alpha)
          
          cache_parts <- c(
            this_icon,
            paste0("c", color_hex),
            paste0("a", alpha_str)
          )
          
          # Add stroke to cache key if provided (use LOCAL variable)
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
          
          # Generate PNG if not cached (use LOCAL variables)
          if (!file.exists(png_path)) {
            if (!is.null(local_stroke_width) && local_stroke_width > 0) {
              # With stroke - SAME COLOR AS FILL
              fontawesome::fa_png(
                this_icon,
                file = png_path,
                height = local_dpi,
                fill = rgba_color,
                stroke = rgba_color,  # ← Same color as fill
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
  
  # -------------------------------------------------
  # LEGEND (FIXED): map icons by the ACTUAL legend variable
  # -------------------------------------------------
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
  
  # -------------------------------------------------
  # LEGEND: Capture stroke_width for key glyph
  # -------------------------------------------------
  local_stroke_width_for_legend <- stroke_width  # Capture in outer scope
  
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
    by           = "height",
    key_glyph    = if (legend_icons) key_glyph_pop else key_fn,
    ...
  )
  
  # Tag the layer so your validator can enforce faceting on the FINAL plot
  layer_out$params$.ggpop_facet <- if (.facet_explicit) facet_col else NULL
  
  structure(
    list(layer = layer_out, facet_col = if (.facet_explicit) facet_col else NULL),
    class = "ggpop_geom_pop"
  )
  
}


