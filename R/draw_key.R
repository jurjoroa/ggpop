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
#' @importFrom magick image_read image_quantize image_colorize
#' @importFrom grid rasterGrob gTree
#' @importFrom grDevices as.raster
#' @details
#' This function relies on `ggimage:::color_image` and `ggplot2:::ggname`, which are internal functions.
#' Their use is necessary for correct functionality, and no exported alternatives exist.
#' We acknowledge the potential risks associated with `:::` usage, but at present, these functions
#' provide essential behavior for rendering images within ggplot2.
#' 
#' NOTE: Legend icons are always rendered at a FIXED size, regardless of any size aesthetic
#' mapped in the plot. This ensures consistent legend appearance.
#' 
#' If `stroke_width` is provided, icons are rendered directly with FontAwesome's stroke
#' parameter for consistent appearance between plot and legend.
#' @export
draw_key_pop_image <- function(data, params, size, stroke_width = NULL) {
  
  cache_dir <- file.path(tempdir(), "ggpop-legend-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  if (!("colour" %in% names(data)) && ("color" %in% names(data))) data$colour <- data$color
  
  # High-res PNG for legend keys (crisp even when key box is large)
  png_px <- 480L
  
  # Determine stroke usage OUTSIDE the lapply
  use_stroke <- !is.null(stroke_width) && is.numeric(stroke_width) && stroke_width > 0
  
  grobs <- lapply(seq_along(data$colour), function(i) {
    
    this_icon <- as.character(data$icon[i])
    if (is.na(this_icon) || !nzchar(this_icon)) this_icon <- "user"
    
    this_col <- data$colour[i]
    if (is.na(this_col) || !nzchar(as.character(this_col))) this_col <- "black"
    
    this_alpha <- data$alpha[i]
    if (is.na(this_alpha) || !is.finite(this_alpha)) this_alpha <- 1
    
    # -------------------------------------------------
    # Decision: use stroke or colorize?
    # -------------------------------------------------
    if (use_stroke) {
      # -------------------------------------------------
      # Path 1: Generate PNG with FontAwesome stroke (consistent with plot)
      # -------------------------------------------------
      
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
        paste0(this_icon, "_c", color_hex, "_a", alpha_str, "_sw", stroke_str, "_", png_px, "px.png")
      )
      
      # Generate if not cached
      if (!file.exists(png_path)) {
        fontawesome::fa_png(
          this_icon,
          file = png_path,
          height = png_px,
          fill = rgba_color,
          stroke = rgba_color,  # ← CHANGED: same as fill instead of "black"
          stroke_width = stroke_width
        )
      }
      
      # Read and use directly (no colorization needed)
      img <- magick::image_read(png_path)
      ras <- as.raster(img)
      
    } else {
      # -------------------------------------------------
      # Path 2: Generate black PNG and colorize with magick (legacy approach)
      # -------------------------------------------------
      
      png_path <- file.path(cache_dir, paste0(this_icon, "__legend__", png_px, "px.png"))
      if (!file.exists(png_path)) {
        fontawesome::fa_png(this_icon, file = png_path, height = png_px)
      }
      
      img <- magick::image_read(png_path)
      img <- magick::image_quantize(img, colorspace = "gray")
      img <- magick::image_colorize(img, opacity = this_alpha * 100, color = this_col)
      
      ras <- as.raster(img)
    }
    
    # IMPORTANT: Legend icons always have FIXED size (ignoring data$size)
    # This ensures consistent legend appearance regardless of size mapping in plot
    # Icons scale relative to the key box (npc), not absolute mm
    grid::rasterGrob(
      x = 0.5, y = 0.5,
      image = ras,
      width  = grid::unit(0.9, "npc"),
      height = grid::unit(0.9, "npc"),
      interpolate = TRUE
    )
  })
  
  class(grobs) <- "gList"
  
  # Build unique name for gTree
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
