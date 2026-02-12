#' Custom Key Glyph for Icon Points
#' @keywords internal
#' @noRd
key_glyph_icon_point <- function(key_data, params, size) {
  if (!("colour" %in% names(key_data)) & ("color" %in% names(key_data))) {
    key_data$colour <- key_data$color
  }
  
  if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
  key_data$alpha[is.na(key_data$alpha)] <- 1
  
  if (!("colour" %in% names(key_data))) key_data$colour <- "black"
  key_data$colour[is.na(key_data$colour)] <- "black"
  
  lbl <- NA_character_
  if ("label" %in% names(key_data)) lbl <- as.character(key_data$label[1])
  if (is.na(lbl) || !nzchar(lbl)) lbl <- NA_character_
  
  icon_by_legend <- params$icon_by_legend
  plot_obj <- params$plot_obj
  
  ic <- NA_character_
  if (!is.na(lbl) && !is.null(icon_by_legend) && lbl %in% names(icon_by_legend)) {
    ic <- icon_by_legend[[lbl]]
  }
  
  if (is.na(ic) || !nzchar(ic)) {
    breaks <- if (!is.null(icon_by_legend)) names(icon_by_legend) else character(0)
    if (!is.null(plot_obj)) {
      sc <- plot_obj$scales$get_scales("colour")
      if (is.null(sc)) sc <- plot_obj$scales$get_scales("color")
      if (!is.null(sc)) {
        br <- sc$get_breaks()
        br <- br[!is.na(br)]
        if (length(br)) breaks <- as.character(br)
      }
    }
    
    if (length(breaks) > 0 && !is.null(icon_by_legend)) {
      icon_levels <- unname(icon_by_legend[breaks])
      
      idx <- NA_integer_
      if (".id" %in% names(key_data)) idx <- as.integer(key_data$.id[1])
      if (is.na(idx) && "group" %in% names(key_data)) idx <- as.integer(key_data$group[1])
      if (is.na(idx)) idx <- 1L
      
      idx <- max(1L, min(length(icon_levels), idx))
      ic <- as.character(icon_levels[idx])
    }
  }
  
  if (is.na(ic) || !nzchar(ic)) ic <- "circle"
  
  key_data$icon <- ic
  draw_key_pop_image(key_data, params, size)
}

#' Key drawing function for population-based image keys
#'
#' This function creates a custom key for displaying population-based image icons
#' in the legend of a ggplot2 plot. Each group can be assigned a different icon
#' based on the information in the `data$icon` column, and the icons can be colorized
#' according to the specified `colour` and `alpha` aesthetics. Optionally supports
#' black outlines via the `stroke_width` parameter.
#'
#' @name draw_key_pop_image
#' @title Key drawing function for population-based image keys
#' @param data A data frame containing the scaled aesthetics for the key.
#'             It must include a `colour` column for color, an `alpha` column for transparency,
#'             and an `icon` column with the names of the icon files (without extension) to be used.
#' @param params A list of additional parameters supplied to the geom.
#' @param size The width and height of the key in mm. This value is not used directly in this function.
#' @param stroke_width Numeric. Width of the black outline/border around icons in pixels.
#'                     If NULL or 0, no outline is drawn. Default is NULL.
#' @return A grid grob containing the image icons with the specified colors and transparency.
#' @importFrom magick image_read image_quantize image_colorize image_info
#' @importFrom grid rasterGrob gTree unit
#' @importFrom grDevices as.raster
#' @details
#' Icons are automatically scaled to fill the available legend box space while preserving
#' their aspect ratio. Wide icons fill horizontally, tall icons fill vertically.
#'
#' If `stroke_width` is provided, icons are rendered directly with FontAwesome's stroke
#' parameter for consistent appearance between plot and legend.
#' Draw key for icon point
#' @keywords internal
#' @noRd
draw_key_pop_image <- function(data, params, size, stroke_width = NULL) {
  
  # ==============================================================================
  # SETUP: Cache directory and defaults
  # ==============================================================================
  
  cache_dir <- file.path(tempdir(), "ggpop-legend-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  # Normalize color column name
  if (!("colour" %in% names(data)) && ("color" %in% names(data))) {
    data$colour <- data$color
  }
  
  # ==============================================================================
  # CONFIGURATION
  # ==============================================================================
  
  png_px <- 480L
  use_stroke <- !is.null(stroke_width) && is.numeric(stroke_width) && stroke_width > 0
  
  # Maximum fill percentage of legend box (prevents touching edges)
  max_fill <- 0.90  # Use 90% of available space
  
  # ==============================================================================
  # ICON RENDERING: Create grobs for each icon
  # ==============================================================================
  
  grobs <- lapply(seq_along(data$colour), function(i) {
    
    # Extract icon name
    this_icon <- as.character(data$icon[i])
    if (is.na(this_icon) || !nzchar(this_icon)) this_icon <- "user"
    
    # Extract color
    this_col <- data$colour[i]
    if (is.na(this_col) || !nzchar(as.character(this_col))) this_col <- "black"
    
    # Extract alpha
    this_alpha <- data$alpha[i]
    if (is.na(this_alpha) || !is.finite(this_alpha)) this_alpha <- 1
    
    # ==========================================================================
    # PATH 1: With stroke (render with FontAwesome directly)
    # ==========================================================================
    
    if (use_stroke) {
      # Convert color to hex
      this_col_hex <- tryCatch({
        rgb_vals <- grDevices::col2rgb(this_col) / 255
        grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
      }, error = function(e) "#000000")
      
      # Apply alpha to color
      rgb_vals <- grDevices::col2rgb(this_col_hex) / 255
      rgba_color <- grDevices::rgb(
        rgb_vals[1],
        rgb_vals[2],
        rgb_vals[3],
        alpha = this_alpha
      )
      
      # Build cache key
      color_hex <- gsub("#", "", this_col_hex)
      alpha_str <- sprintf("%.2f", this_alpha)
      stroke_str <- sprintf("%.0f", stroke_width)
      
      png_path <- file.path(
        cache_dir,
        paste0(this_icon, "_c", color_hex, "_a", alpha_str, 
               "_sw", stroke_str, "_", png_px, "px.png")
      )
      
      # Generate PNG if not cached
      if (!file.exists(png_path)) {
        fontawesome::fa_png(
          this_icon,
          file = png_path,
          height = png_px,
          fill = rgba_color,
          stroke = rgba_color,
          stroke_width = stroke_width
        )
      }
      
      img <- magick::image_read(png_path)
      ras <- as.raster(img)
      
      # ==========================================================================
      # PATH 2: Without stroke (use magick for colorization)
      # ==========================================================================
      
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
      img <- magick::image_colorize(img, opacity = this_alpha * 100, color = this_col)
      
      ras <- as.raster(img)
    }
    
    # ==========================================================================
    # SMART SIZE CALCULATION: Fill legend box based on icon's aspect ratio
    # ==========================================================================
    
    img_info <- magick::image_info(img)
    aspect_ratio <- img_info$width / img_info$height
    
    # Strategy: Fill the constraining dimension to max_fill, 
    # then scale the other dimension proportionally
    
    if (aspect_ratio > 1) {
      # Icon is WIDER than tall (landscape orientation)
      # → Fill width to max_fill, calculate height proportionally
      icon_width  <- grid::unit(max_fill, "npc")
      icon_height <- grid::unit(max_fill / aspect_ratio, "npc")
      
    } else if (aspect_ratio < 1) {
      # Icon is TALLER than wide (portrait orientation)
      # → Fill height to max_fill, calculate width proportionally
      icon_height <- grid::unit(max_fill, "npc")
      icon_width  <- grid::unit(max_fill * aspect_ratio, "npc")
      
    } else {
      # Icon is SQUARE (aspect_ratio == 1)
      # → Fill both dimensions equally
      icon_width  <- grid::unit(max_fill, "npc")
      icon_height <- grid::unit(max_fill, "npc")
    }
    
    # ==========================================================================
    # CREATE GROB
    # ==========================================================================
    
    grid::rasterGrob(
      x = 0.5, y = 0.5,
      image = ras,
      width = icon_width,
      height = icon_height,
      interpolate = TRUE
    )
  })
  
  # ==============================================================================
  # FINALIZE: Create gTree with unique name
  # ==============================================================================
  
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