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
#' @import dplyr
#' @export
geom_icon_point <- function(mapping = NULL, data = NULL, stat = "identity",
                            position = "identity", na.rm = FALSE, show.legend = NA,
                            inherit.aes = TRUE, icon = NULL,
                            size = 3, dpi = 50, legend_icons = TRUE, ...) {
  
  # -------------------------------------------------
  # HANDLE COMMON USAGE: geom_icon_point(data, aes(...))
  # -------------------------------------------------
  if (!is.null(mapping) && !inherits(mapping, "uneval") && 
      (is.data.frame(mapping) || (is.list(mapping) && !inherits(mapping, "uneval")))) {
    # User did: geom_icon_point(df, aes(...))
    # Swap them
    temp <- mapping
    mapping <- data
    data <- temp
  }
  
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
  
  # Ensure data is a data frame
  if (!is.data.frame(data)) {
    stop("[geom_icon_point] `data` must be a data frame.", call. = FALSE)
  }
  
  # -------------------------------------------------
  # HARD STOP: empty data frame
  # -------------------------------------------------
  if (nrow(data) == 0) {
    stop(
      "[geom_icon_point] Empty data (0 rows). Cannot create plot with no data points.",
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
          "[geom_icon_point] `dpi = ", dpi, "` is too low.\n",
          "Icons will look blurry when rendered with fontawesome::fa_png().\n\n",
          "Fix:\n",
          "- Use dpi >= 30 (recommended: 50-200 for crisp icons).\n",
          "- If you want smaller icons, change `size`, not `dpi`.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  mapping_list <- if (!is.null(mapping)) as.list(mapping) else list()
  
  # Combine inherited and layer mappings
  combined_mapping <- c(inherited_mapping_list, mapping_list)
  
  # -------------------------------------------------
  # HARD STOP: image aesthetic is not allowed
  # -------------------------------------------------
  if ("image" %in% names(combined_mapping)) {
    stop(
      paste0(
        "[geom_icon_point] The 'image' aesthetic is not allowed.\n\n",
        "Why this is an error:\n",
        "- geom_icon_point() uses 'icon' aesthetic, not 'image'.\n",
        "- 'image' is used internally by ggimage::geom_image().\n\n",
        "Fix:\n",
        "- Use `aes(icon = ...)` instead of `aes(image = ...)`\n\n",
        "Example:\n",
        "  # Wrong:\n",
        "  ggplot(data, aes(x = x, y = y, image = icon_col)) +\n",
        "    geom_icon_point()\n\n",
        "  # Correct:\n",
        "  ggplot(data, aes(x = x, y = y, icon = icon_col)) +\n",
        "    geom_icon_point()\n"
      ),
      call. = FALSE
    )
  }
  
  
  # -------------------------------------------------
  # HARD STOP: size parameter validation
  # -------------------------------------------------
  if (!missing(size)) {
    # Type check
    if (!is.numeric(size) || length(size) != 1) {
      stop(
        sprintf("[geom_icon_point] size must be a single numeric value, got %s", class(size)[1]),
        call. = FALSE
      )
    }
    
    # Value checks
    if (is.na(size) || !is.finite(size) || size <= 0) {
      stop(
        sprintf(
          "[geom_icon_point] Invalid size (%s). Must be positive and finite (e.g., size = 3)",
          if (is.na(size)) "NA" else size
        ),
        call. = FALSE
      )
    }
  }
  
  
  # -------------------------------------------------
  # WARNING: size specified both in aes() and as argument
  # -------------------------------------------------
  if ("size" %in% names(combined_mapping) && !missing(size)) {
    warning(
      paste0(
        "[geom_icon_point] `size` was provided both inside aes() and as a parameter.\n\n",
        "What happens:\n",
        "- `aes(size = <variable>)` controls icon size per row.\n",
        "- The argument `geom_icon_point(aes(), size = ", size, ")` will be ignored.\n\n",
        "Tip:\n",
        "- Use ONLY `aes(size = <variable>)` for data-driven sizes, OR\n",
        "- Remove `size` from aes() and set a fixed size via geom_icon_point(size = ...).\n"
      ),
      call. = FALSE
    )
  }
  
  # -------------------------------------------------
  # SOFT WARNING: size too large
  # -------------------------------------------------
  if (size > 15) {
    warning(
      paste0(
        "[geom_icon_point] Very large `size` value.\n\n",
        "Why you are seeing this warning:\n",
        "- size = ", size, " is unusually large.\n",
        "- Icons may overlap or extend beyond the plot area.\n\n",
        "Typical values:\n",
        "- Small icons: 1-2\n",
        "- Medium icons: 3-5 (default: 3)\n",
        "- Large icons: 6-10\n\n",
        "If this is intentional, you can ignore this warning.\n"
      ),
      call. = FALSE
    )
  }
  
  # -------------------------------------------------
  # SOFT WARNING: size too small
  # -------------------------------------------------
  if (size < 0.9) {
    warning(
      paste0(
        "[geom_icon_point] Very small `size` value.\n\n",
        "Why you are seeing this warning:\n",
        "- size = ", size, " is very small.\n",
        "- Icons may be difficult to see or distinguish.\n\n",
        "Recommended:\n",
        "- Use size >= 0.9 for visible icons\n",
        "- Default is 3\n",
        "- Typical range: 1-10\n\n",
        "If this is intentional, you can ignore this warning.\n"
      ),
      call. = FALSE
    )
  }
  

  # -------------------------------------------------
  # HARD STOP: icon is mandatory and must be explicit
  # -------------------------------------------------
  icon_mapped  <- "icon" %in% names(combined_mapping)
  has_icon_param <- !is.null(icon) && nzchar(as.character(icon))
  
  # Icon must be EXPLICITLY mapped or provided as parameter
  # Having an 'icon' column in data is NOT enough - user must map it!
  if (!icon_mapped && !has_icon_param) {
    stop(
      paste0(
        "[geom_icon_point] No icon specified.\n\n",
        "You must EXPLICITLY specify an icon:\n\n",
        "1. Map to a column:\n",
        "   ggplot(data, aes(x = x, y = y, icon = icon_column)) +\n",
        "     geom_icon_point()\n\n",
        "2. Provide a parameter:\n",
        "   ggplot(data, aes(x = x, y = y)) +\n",
        "     geom_icon_point(icon = \"circle\")\n\n",
        "Note: Having an 'icon' column in your data is NOT enough.\n",
        "      You must explicitly map it with aes(icon = icon).\n"
      ),
      call. = FALSE
    )
  }
  
  # Add icon to data ONLY if parameter was provided
  if (has_icon_param && !"icon" %in% names(data)) {
    data$icon <- icon
  }
  
  # Add icon mapping
  if (!"icon" %in% names(mapping_list)) {
    if ("icon" %in% names(inherited_mapping_list)) {
      # Icon is mapped in ggplot()
      mapping_list[["icon"]] <- inherited_mapping_list[["icon"]]
    } else if (has_icon_param) {
      # Icon parameter provided, map to the data column we just created
      mapping_list[["icon"]] <- as.name("icon")
    } else {
      stop(
        "[geom_icon_point] Internal error: No icon mapping available.",
        call. = FALSE
      )
    }
  }
  
  # Handle size (icon_size to avoid collision with coord size)
  # Check COMBINED mapping for size
  if ("size" %in% names(combined_mapping)) {
    # Get size variable from either layer or inherited mapping
    size_var <- if ("size" %in% names(mapping_list)) {
      rlang::as_name(mapping_list[["size"]])
    } else {
      rlang::as_name(inherited_mapping_list[["size"]])
    }
    
    if (!size_var %in% names(data)) {
      stop(paste0("Variable '", size_var, "' used for size not found in the dataset."))
    }
    
    data$icon_size <- data[[size_var]] * 0.02
    
    # Remove size from layer mapping (but keep in inherited if it's there)
    mapping_list[["size"]] <- NULL
  } else {
    data$icon_size <- size * 0.02
  }
  
  # -------------------------------------------------
  # HARD STOP: missing / empty icons are not allowed
  # -------------------------------------------------
  if ("icon" %in% names(data)) {
    bad_icon <- is.na(data$icon) | !nzchar(as.character(data$icon))
    if (any(bad_icon)) {
      n_bad <- sum(bad_icon)
      stop(
        paste0(
          "[geom_icon_point] Invalid icon values detected.\n\n",
          "Found ", n_bad, " row(s) with missing or empty `icon` values.\n\n",
          "Fix:\n",
          "- Ensure `icon` is non-missing for all rows.\n"
        ),
        call. = FALSE
      )
    }
  }
  
  
  # -------------------------------------------------
  # HARD STOP & SOFT WARNING: dpi validation
  # -------------------------------------------------
  if (!is.numeric(dpi) || length(dpi) != 1) {
    stop(
      paste0(
        "[geom_icon_point] Invalid `dpi` parameter.\n\n",
        "Expected: Single numeric value (e.g., dpi = 50)\n",
        "Received: ", 
        if (!is.numeric(dpi)) {
          paste0(class(dpi)[1], " (", deparse(dpi)[1], ")")
        } else {
          paste0("vector of length ", length(dpi))
        },
        "\n\n",
        "Fix:\n",
        "- Use: dpi = 50 (default)\n",
        "- Recommended range: 30-300\n"
      ),
      call. = FALSE
    )
  }
  
  if (is.na(dpi) || !is.finite(dpi)) {
    stop(
      paste0(
        "[geom_icon_point] Invalid `dpi` value: ", dpi, "\n\n",
        "dpi cannot be NA, Inf, or -Inf.\n\n",
        "Fix:\n",
        "- Use a finite numeric value: dpi = 50\n"
      ),
      call. = FALSE
    )
  }
  
  if (dpi < 30) {
    stop(
      paste0(
        "[geom_icon_point] `dpi = ", dpi, "` is too low.\n\n",
        "Icons will look blurry when rendered.\n\n",
        "Fix:\n",
        "- Use dpi >= 30 (recommended: 50-200)\n",
        "- For smaller icons, change `size`, not `dpi`\n"
      ),
      call. = FALSE
    )
  }
  
  if (dpi > 300) {
    warning(
      paste0(
        "[geom_icon_point] High `dpi` value (", dpi, ").\n\n",
        "This may cause:\n",
        "- Slower rendering\n",
        "- Increased memory usage\n\n",
        "Recommended: 50-200 (screen), 100-300 (print)\n\n",
        "Tip: For output quality, use ggsave(..., dpi = 300) instead.\n"
      ),
      call. = FALSE
    )
  }
  
  # -------------------------------------------------
  # FINAL CHECK: icon column must exist in data
  # -------------------------------------------------
  if (!"icon" %in% names(data)) {
    stop(
      "[geom_icon_point] Internal error: icon column is missing from data.",
      call. = FALSE
    )
  }
  
  # ---- build per-row PNG path from per-row icon ----
  
  # Capture DPI in local scope BEFORE rowwise
  local_dpi <- dpi
  
  data <- data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        if (is.na(this_icon) || !nzchar(this_icon)) {
          NA_character_
        } else {
          
          # Get color from aes mapping (if any)
          this_color <- if ("colour" %in% names(.)) {
            as.character(.data$colour)
          } else if ("color" %in% names(.)) {
            as.character(.data$color)
          } else {
            "black"
          }
          
          # Get alpha from aes mapping (if any)
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
          
          # Apply alpha to color
          rgb_vals <- grDevices::col2rgb(this_color) / 255
          rgba_color <- grDevices::rgb(
            rgb_vals[1], 
            rgb_vals[2], 
            rgb_vals[3], 
            alpha = this_alpha
          )
          
          cache_dir <- file.path(tempdir(), "ggpop-icons")
          if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
          
          # Build cache key with color, alpha, AND DPI
          color_hex <- gsub("#", "", this_color)
          alpha_str <- sprintf("%.2f", this_alpha)
          dpi_str <- sprintf("%.0f", local_dpi)  # ← Use local_dpi
          
          cache_parts <- c(
            this_icon,
            paste0("c", color_hex),
            paste0("a", alpha_str),
            paste0("d", dpi_str)  # ← Include DPI in filename
          )
          
          png_path <- file.path(
            cache_dir, 
            paste0(paste(cache_parts, collapse = "_"), ".png")
          )
          
          # Generate PNG if not cached
          if (!file.exists(png_path)) {
            fontawesome::fa_png(
              this_icon,
              file = png_path,
              height = local_dpi,  # ← Use local_dpi
              fill = rgba_color
            )
          }
          
          png_path
        }
      }
    ) %>%
    dplyr::ungroup()
  
  # -------------------------------------------------
  # LEGEND: map icons by the ACTUAL legend variable
  # -------------------------------------------------
  .get_mapped_var_combined <- function(aes_name) {
    if (aes_name %in% names(combined_mapping)) {
      tryCatch(rlang::as_name(combined_mapping[[aes_name]]), error = function(e) NULL)
    } else {
      NULL
    }
  }
  
  legend_var <- .get_mapped_var_combined("colour")
  if (is.null(legend_var)) legend_var <- .get_mapped_var_combined("color")
  if (is.null(legend_var)) legend_var <- .get_mapped_var_combined("group")
  
  # Fallback to icon if we have multiple icons
  if (is.null(legend_var) || !legend_var %in% names(data)) {
    if ("icon" %in% names(data) && dplyr::n_distinct(data$icon) > 1) {
      legend_var <- "icon"
    } else {
      legend_var <- NULL
    }
  }
  
  icon_by_legend <- if (!is.null(legend_var)) {
    data %>%
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
      ) %>%
      { stats::setNames(.$icon, .$.legend) }
  } else {
    stats::setNames(icon, "default")
  }
  
  
  # -------------------------------------------------
  # SOFT WARNING: multiple icons per legend group
  # -------------------------------------------------
  if (legend_icons && !is.null(legend_var) && legend_var %in% names(data)) {
    # Check if any legend group has multiple different icons
    icon_counts <- data %>%
      dplyr::mutate(
        .legend = as.character(.data[[legend_var]]),
        icon    = as.character(icon)
      ) %>%
      dplyr::filter(!is.na(.legend), nzchar(.legend), !is.na(icon), nzchar(icon)) %>%
      dplyr::group_by(.legend) %>%
      dplyr::summarise(
        n_icons = dplyr::n_distinct(icon),
        icons = paste(sort(unique(icon)), collapse = ", "),
        .groups = "drop"
      ) %>%
      dplyr::filter(n_icons > 1)
    
    if (nrow(icon_counts) > 0) {
      # Build detailed message showing which groups have issues
      problem_groups <- icon_counts %>%
        dplyr::mutate(
          msg = paste0("  - ", .legend, ": ", icons, " (", n_icons, " different icons)")
        ) %>%
        dplyr::pull(msg) %>%
        paste(collapse = "\n")
      
      warning(
        paste0(
          "[geom_icon_point] Multiple icons per legend group.\n\n",
          "Why you are seeing this warning:\n",
          "- Some legend groups (mapped via `", legend_var, "`) contain multiple different icons.\n",
          "- The legend will only show ONE icon per group (the most frequent one).\n\n",
          "Affected groups:\n",
          problem_groups, "\n\n",
          "What happens:\n",
          "- For each group, the most common icon is selected for the legend.\n",
          "- In the plot, all icons are displayed as mapped.\n",
          "- The legend may not accurately represent all icons in each group.\n\n",
          "Recommended fixes:\n",
          "1. Use one icon per legend group:\n",
          "   - Ensure each value of `", legend_var, "` has only one icon type.\n\n",
          "2. Map icon as the legend variable:\n",
          "   - Use `aes(color = icon)` to show all icons in the legend.\n\n",
          "3. Disable icon legends:\n",
          "   - Use `legend_icons = FALSE` to show standard point markers.\n\n",
          "Example fix:\n",
          "  # Make sure each category uses one icon:\n",
          "  df <- df %>%\n",
          "    group_by(", legend_var, ") %>%\n",
          "    mutate(icon = first(icon))  # Use first icon for consistency\n"
        ),
        call. = FALSE
      )
    }
  }
  
  key_glyph_icon_point <- function(key_data, params, size) {
    
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
    
    # Get icon_by_legend from params (passed through)
    icon_by_legend <- params$icon_by_legend
    plot_obj <- params$plot_obj
    
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
    
    if (is.na(ic) || !nzchar(ic)) ic <- "circle"
    
    key_data$icon <- ic
    draw_key_pop_image(key_data, params, size)
  }
  
  # -------------------------------------------------
  # THE ONLY REAL CHANGE: use x and y from aes instead of x1/y1
  # -------------------------------------------------
  mapping_list[["image"]] <- as.name("image")
  mapping_list[["icon"]]  <- NULL
  # Keep x and y as they are (from user's aes)
  
  final_mapping <- do.call(ggplot2::aes, mapping_list)
  
  size_internal <- data$icon_size
  
  key_fn <- function(data, params, size = 5) {
    data$size <- 5
    ggplot2::draw_key_point(data, params, size)
  }
  
  layer_out <- ggimage::geom_image(
    mapping      = final_mapping,
    data         = data,
    size         = size_internal,
    stat         = stat,
    position     = position,
    na.rm        = na.rm,
    inherit.aes  = inherit.aes,
    by           = "height",
    key_glyph    = if (legend_icons) key_glyph_icon_point else key_fn,
    ...
  )
  
  # Pass icon_by_legend to layer params so key glyph can access it
  layer_out$geom_params$icon_by_legend <- icon_by_legend
  layer_out$geom_params$plot_obj <- plot_obj
  layer_out$geom_params$dpi <- dpi
  
  layer_out
}
