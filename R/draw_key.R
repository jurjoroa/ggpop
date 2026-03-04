#' Custom Key Glyph for Icon Points
#'
#' Builds a legend key grob for icon-based points by resolving the correct icon
#' for each legend entry and delegating rendering to `draw_key_pop_image()`.
#'
#' Resolution order is configurable via `legend_resolution_order`:
#'   1) `"label"`         exact match on `key_data$label`
#'   2) `"scale_breaks"`  match against ggplot2 scale breaks (colour/color)
#'   3) `"index"`         select by position using `legend_index_fields`
#'   4) `"fallback"`      use `legend_fallback_icon`
#'
#' @param key_data Legend key data provided by ggplot2 (must include colour/color;
#'   may include label, .id, group, alpha).
#' @param params   List passed from the geom/guide (expects `icon_by_legend`,
#'   `plot_obj`, and optional `stroke_width`).
#' @param size     Size passed by ggplot2 for key rendering.
#' @param legend_fallback_icon Character. Icon used if no match is found
#'   (default: `"circle"`).
#' @param legend_default_colour Character. Fallback colour when none provided
#'   in key data (default: `"black"`).
#' @param legend_default_alpha Numeric. Fallback alpha when missing/NA
#'   (default: `1`).
#' @param legend_resolution_order Character vector defining match order.
#'   Defaults to `c("label", "scale_breaks", "index", "fallback")`.
#' @param legend_index_fields Character vector of key-data fields used to
#'   select icon position when using `"index"` mode (default: `c(".id", "group")`).
#' @param legend_scale_aesthetics Character vector of scale aesthetics to search
#'   for breaks (default: `c("colour", "color")`).
#'
#' @return A grob produced by `draw_key_pop_image()`.
#' @keywords internal
#' @noRd
key_glyph_icon_point <- function(
  key_data,
  params,
  size,
  legend_fallback_icon = "circle",
  legend_default_colour = "black",
  legend_default_alpha = 1,
  legend_resolution_order = c("label", "scale_breaks", "index", "fallback"),
  legend_index_fields = c(".id", "group"),
  legend_scale_aesthetics = c("colour", "color")
) {
  # Normalize color column
  if (!("colour" %in% names(key_data)) & ("color" %in% names(key_data))) {
    key_data$colour <- key_data$color
  }

  # Default alpha
  if (!("alpha" %in% names(key_data))) key_data$alpha <- legend_default_alpha
  key_data$alpha[is.na(key_data$alpha)] <- legend_default_alpha

  # Default colour
  if (!("colour" %in% names(key_data))) key_data$colour <- legend_default_colour
  key_data$colour[is.na(key_data$colour)] <- legend_default_colour

  # Extract label
  lbl <- NA_character_
  if ("label" %in% names(key_data)) lbl <- as.character(key_data$label[1])
  if (is.na(lbl) || !nzchar(lbl)) lbl <- NA_character_

  icon_by_legend <- params$icon_by_legend
  plot_obj <- params$plot_obj

  ic <- NA_character_

  for (mode in legend_resolution_order) {
    if (mode == "label" && !is.na(lbl) && !is.null(icon_by_legend) && lbl %in% names(icon_by_legend)) {
      ic <- icon_by_legend[[lbl]]
      break
    }

    if (mode == "scale_breaks" && !is.null(plot_obj) && !is.null(icon_by_legend)) {
      breaks <- names(icon_by_legend)
      for (aes_name in legend_scale_aesthetics) {
        sc <- plot_obj$scales$get_scales(aes_name)
        if (!is.null(sc)) {
          br <- sc$get_breaks()
          br <- br[!is.na(br)]
          if (length(br)) {
            breaks <- as.character(br)
            break
          }
        }
      }

      if (length(breaks)) {
        icon_levels <- unname(icon_by_legend[breaks])
        idx <- NA_integer_
        for (field in legend_index_fields) {
          if (field %in% names(key_data)) {
            idx <- as.integer(key_data[[field]][1])
            if (!is.na(idx)) break
          }
        }
        if (is.na(idx)) idx <- 1L
        idx <- max(1L, min(length(icon_levels), idx))
        ic <- as.character(icon_levels[idx])
        if (!is.na(ic) && nzchar(ic)) break
      }
    }

    if (mode == "index" && !is.null(icon_by_legend)) {
      icon_levels <- unname(icon_by_legend)
      idx <- NA_integer_
      for (field in legend_index_fields) {
        if (field %in% names(key_data)) {
          idx <- as.integer(key_data[[field]][1])
          if (!is.na(idx)) break
        }
      }
      if (is.na(idx)) idx <- 1L
      idx <- max(1L, min(length(icon_levels), idx))
      ic <- as.character(icon_levels[idx])
      if (!is.na(ic) && nzchar(ic)) break
    }

    if (mode == "fallback") {
      ic <- legend_fallback_icon
      break
    }
  }

  if (is.na(ic) || !nzchar(ic)) ic <- legend_fallback_icon

  key_data$icon <- as.character(ic)[1]

  alpha_by_legend <- params$alpha_by_legend
  if (!is.null(alpha_by_legend)) {
    if (!is.na(lbl) && lbl %in% names(alpha_by_legend)) {
      key_data$alpha <- alpha_by_legend[[lbl]]
    } else {
      alpha_levels <- unname(alpha_by_legend)
      idx <- NA_integer_
      for (field in legend_index_fields) {
        if (field %in% names(key_data)) {
          idx <- as.integer(key_data[[field]][1])
          if (!is.na(idx)) break
        }
      }
      if (is.na(idx)) idx <- 1L
      idx <- max(1L, min(length(alpha_levels), idx))
      key_data$alpha <- alpha_levels[idx]
    }
  }

  stroke_width <- params$stroke_width

  draw_key_pop_image(key_data, params, size, stroke_width = stroke_width)
}

#' Key drawing function for population-based image keys
#'
#' Creates a legend key grob for population-based icon rendering. Each key entry
#' uses the icon in `data$icon`, colored by `data$colour` (or `data$color`) and
#' alpha in `data$alpha`. Icons are rendered as FontAwesome PNGs and cached to
#' avoid repeated rendering across draws.
#'
#' Resolution/fallback behavior:
#' - Missing icon -> `fallback_icon`
#' - Missing colour -> `fallback_colour`
#' - Missing alpha -> `fallback_alpha`
#'
#' Rendering behavior:
#' - If `stroke_width` is provided (> 0), icons are rendered directly via
#'   `fontawesome::fa_png()` with stroke support.
#' - Otherwise icons are rendered and colorized via `magick` for speed.
#'
#' @name draw_key_pop_image
#' @title Key drawing function for population-based image keys
#' @param data A data frame containing scaled aesthetics for the key.
#'   Must include: `icon` and either `colour` or `color`.
#'   Optional: `alpha`.
#' @param params A list of additional parameters supplied to the geom.
#' @param size The width and height of the key in mm (from theme legend.key.size).
#' @param stroke_width Numeric. Width of icon outline in pixels. If NULL or 0, no outline is drawn.
#' @param cache_dir Directory to cache rendered icons (default: tempdir()/ggpop-legend-icons).
#' @param png_px Integer. PNG size in pixels used for icon rendering.
#' @param max_fill Numeric in (0, 1]. Fraction of legend cell occupied by the icon.
#' @param fallback_icon Character. Default icon if missing/invalid (default: "user").
#' @param fallback_colour Character. Default colour if missing (default: "black").
#' @param fallback_alpha Numeric. Default alpha if missing (default: 1).
#' @return A grid grob containing the image icons with the specified colors and transparency.
#' @importFrom magick image_read image_quantize image_colorize image_info
#' @importFrom grid rasterGrob gTree unit convertUnit
#' @importFrom grDevices as.raster
#' @keywords internal
#' @noRd
draw_key_pop_image <- function(
  data,
  params,
  size,
  stroke_width = NULL,
  cache_dir = file.path(tempdir(), "ggpop-legend-icons"),
  png_px = 480L,
  max_fill = 0.9,
  fallback_icon = "user",
  fallback_colour = "black",
  fallback_alpha = 1
) {
  # Cache directory for legend icons
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)

  # Normalize color column name
  if (!("colour" %in% names(data)) && ("color" %in% names(data))) {
    data$colour <- data$color
  }

  # Configuration
  use_stroke <- !is.null(stroke_width) && is.numeric(stroke_width) && stroke_width > 0

  key_size_mm <- tryCatch(
    {
      if (inherits(size, "unit")) {
        as.numeric(grid::convertUnit(size, "mm"))
      } else if (is.numeric(size)) {
        size # Already in mm
      } else {
        10 # Fallback default
      }
    },
    error = function(e) {
      10 # Fallback if conversion fails
    }
  )

  target_size_mm <- key_size_mm * max_fill

  # Create grobs for each icon
  grobs <- lapply(seq_along(data$colour), function(i) {
    this_icon <- as.character(data$icon[i])
    if (is.na(this_icon) || !nzchar(this_icon)) this_icon <- fallback_icon

    this_col <- data$colour[i]
    if (is.na(this_col) || !nzchar(as.character(this_col))) this_col <- fallback_colour

    this_alpha <- data$alpha[i]
    if (is.na(this_alpha) || !is.finite(this_alpha)) this_alpha <- fallback_alpha

    # Render with stroke (uses FontAwesome directly)
    if (use_stroke) {
      this_col_hex <- tryCatch(
        {
          rgb_vals <- grDevices::col2rgb(this_col) / 255
          grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
        },
        error = function(e) "#000000"
      )

      color_hex <- gsub("#", "", this_col_hex)
      stroke_str <- sprintf("%.0f", stroke_width)

      png_path <- file.path(
        cache_dir,
        paste0(
          this_icon, "_c", color_hex,
          "_sw", stroke_str, "_", png_px, "px.png"
        )
      )

      if (!file.exists(png_path)) {
        fontawesome::fa_png(
          this_icon,
          file = png_path,
          height = png_px,
          fill = this_col_hex,
          stroke = this_col_hex,
          stroke_width = stroke_width
        )
      }

      img <- magick::image_read(png_path)

      if (is.finite(this_alpha) && this_alpha < 1) {
        img <- magick::image_fx(
          img,
          expression = paste0("a*", this_alpha),
          channel = "Alpha"
        )
      }

      ras <- as.raster(img)

      # Render without stroke (uses magick for colorization)
    } else {
      png_path <- file.path(
        cache_dir,
        paste0(this_icon, "__legend__", png_px, "px.png")
      )

      if (!file.exists(png_path)) {
        fontawesome::fa_png(this_icon, file = png_path, height = png_px)
      }

      img <- magick::image_read(png_path)
      img <- magick::image_quantize(img, colorspace = "gray")
      img <- magick::image_colorize(img, opacity = 100, color = this_col)

      if (is.finite(this_alpha) && this_alpha < 1) {
        img <- magick::image_fx(
          img,
          expression = paste0("a*", this_alpha),
          channel = "Alpha"
        )
      }

      ras <- as.raster(img)
    }

    # Smart size calculation based on aspect ratio
    # Use absolute mm units based on the theme's legend.key.size
    img_info <- magick::image_info(img)
    aspect_ratio <- img_info$width / img_info$height

    if (aspect_ratio > 1) {
      # Wide icon: constrain width, scale height
      icon_width <- grid::unit(target_size_mm, "mm")
      icon_height <- grid::unit(target_size_mm / aspect_ratio, "mm")
    } else if (aspect_ratio < 1) {
      # Tall icon: constrain height, scale width
      icon_height <- grid::unit(target_size_mm, "mm")
      icon_width <- grid::unit(target_size_mm * aspect_ratio, "mm")
    } else {
      # Square icon
      icon_width <- grid::unit(target_size_mm, "mm")
      icon_height <- grid::unit(target_size_mm, "mm")
    }

    grid::rasterGrob(
      x = 0.5, y = 0.5,
      image = ras,
      width = icon_width,
      height = icon_height,
      interpolate = TRUE
    )
  })

  # Finalize gTree
  class(grobs) <- "gList"

  nm_parts <- c(
    "image_key",
    paste0(as.character(data$icon), collapse = "_"),
    paste0(as.character(data$colour), collapse = "_"),
    paste0(as.character(data$alpha), collapse = "_")
  )

  if (use_stroke) {
    nm_parts <- c(nm_parts, paste0("sw", stroke_width))
  }

  nm <- paste(nm_parts, collapse = "__")
  nm <- gsub("[^A-Za-z0-9_]", "_", nm)

  grid::gTree(children = grobs, name = nm)
}
