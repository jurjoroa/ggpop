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
#' @export
draw_key_pop_image <- function(data, params, size, stroke_width = NULL) {
  
  cache_dir <- file.path(tempdir(), "ggpop-legend-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  # Normalize color column name
  if (!("colour" %in% names(data)) && ("color" %in% names(data))) {
    data$colour <- data$color
  }
  
  png_px <- 480L
  use_stroke <- !is.null(stroke_width) && is.numeric(stroke_width) && stroke_width > 0
  max_fill <- 0.90
  
  grobs <- lapply(seq_along(data$colour), function(i) {
    
    # Extract color and alpha FIRST (we'll need them for recoloring)
    this_col <- data$colour[i]
    if (is.na(this_col) || !nzchar(as.character(this_col))) this_col <- "black"
    
    this_alpha <- data$alpha[i]
    if (is.na(this_alpha) || !is.finite(this_alpha)) this_alpha <- 1
    
    # Prefer precomputed PNG path (from StatIconPoint) if present
    this_img <- if ("image" %in% names(data)) as.character(data$image[i]) else NA_character_
    has_img <- length(this_img) == 1L && !is.na(this_img) && nzchar(this_img) && file.exists(this_img)
    
    if (has_img) {
      # Load the precomputed image (which is in black)
      img <- magick::image_read(this_img)
      
      # RECOLOR IT to match the legend color!
      img <- magick::image_quantize(img, colorspace = "gray")
      img <- magick::image_colorize(img, opacity = this_alpha * 100, color = this_col)
      
      ras <- as.raster(img)
      
    } else {
      # Fallback: create icon on the fly
      this_icon <- as.character(data$icon[i])
      if (length(this_icon) != 1L || is.na(this_icon) || !nzchar(this_icon)) {
        this_icon <- "user"
      }
      
      if (use_stroke) {
        # Convert color to hex
        this_col_hex <- tryCatch({
          rgb_vals <- grDevices::col2rgb(this_col) / 255
          grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
        }, error = function(e) "#000000")
        
        # Apply alpha to color
        rgb_vals <- grDevices::col2rgb(this_col_hex) / 255
        rgba_color <- grDevices::rgb(
          rgb_vals[1], rgb_vals[2], rgb_vals[3],
          alpha = this_alpha
        )
        
        # Build cache key
        color_hex  <- gsub("#", "", this_col_hex)
        alpha_str  <- sprintf("%.2f", this_alpha)
        stroke_str <- sprintf("%.0f", stroke_width)
        
        png_path <- file.path(
          cache_dir,
          paste0(
            this_icon, "_c", color_hex, "_a", alpha_str,
            "_sw", stroke_str, "_", png_px, "px.png"
          )
        )
        
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
        
      } else {
        png_path <- file.path(cache_dir, paste0(this_icon, "__legend__", png_px, "px.png"))
        
        if (!file.exists(png_path)) {
          fontawesome::fa_png(this_icon, file = png_path, height = png_px)
        }
        
        img <- magick::image_read(png_path)
        img <- magick::image_quantize(img, colorspace = "gray")
        img <- magick::image_colorize(img, opacity = this_alpha * 100, color = this_col)
        
        ras <- as.raster(img)
      }
    }
    
    # Smart sizing based on aspect ratio
    img_info <- magick::image_info(img)
    aspect_ratio <- img_info$width / img_info$height
    
    if (aspect_ratio > 1) {
      icon_width  <- grid::unit(max_fill, "npc")
      icon_height <- grid::unit(max_fill / aspect_ratio, "npc")
    } else if (aspect_ratio < 1) {
      icon_height <- grid::unit(max_fill, "npc")
      icon_width  <- grid::unit(max_fill * aspect_ratio, "npc")
    } else {
      icon_width  <- grid::unit(max_fill, "npc")
      icon_height <- grid::unit(max_fill, "npc")
    }
    
    grid::rasterGrob(
      x = 0.5, y = 0.5,
      image = ras,
      width = icon_width,
      height = icon_height,
      interpolate = TRUE
    )
  })
  
  class(grobs) <- "gList"
  
  nm_parts <- c(
    "image_key",
    if ("icon" %in% names(data)) paste0(as.character(data$icon), collapse = "_") else "noicon",
    if ("colour" %in% names(data)) paste0(as.character(data$colour), collapse = "_") else "nocol",
    if ("alpha" %in% names(data)) paste0(as.character(data$alpha), collapse = "_") else "noalpha"
  )
  if (use_stroke) nm_parts <- c(nm_parts, paste0("sw", stroke_width))
  
  nm <- paste(nm_parts, collapse = "__")
  nm <- gsub("[^A-Za-z0-9_]", "_", nm)
  
  grid::gTree(children = grobs, name = nm)
}

#' Key glyph for icon point legend
#' @keywords internal
key_glyph_icon_point <- function(key_data, params, size) {
  # normalize colour/alpha
  if (!("colour" %in% names(key_data)) && ("color" %in% names(key_data))) {
    key_data$colour <- key_data$color
  }
  if (!("alpha" %in% names(key_data))) key_data$alpha <- 1
  key_data$alpha[is.na(key_data$alpha)] <- 1
  if (!("colour" %in% names(key_data))) key_data$colour <- "black"
  key_data$colour[is.na(key_data$colour)] <- "black"
  
  # Use .id field to match
  lbl <- NA_character_
  if (".id" %in% names(key_data)) {
    lbl <- as.character(key_data$.id[1])
  }
  
  # Look up the icon for this ID
  icon_map <- NULL
  if (!is.null(params$build_id)) {
    id <- as.character(params$build_id)
    if (exists(id, envir = .ggpop_env$legend_icon_map, inherits = FALSE)) {
      icon_map <- get(id, envir = .ggpop_env$legend_icon_map, inherits = FALSE)
    }
  }
  
  # Try to get icon and image from stored map using ID
  if (!is.null(icon_map) && !is.na(lbl) && is.list(icon_map)) {
    if ("by_id" %in% names(icon_map) && lbl %in% names(icon_map$by_id)) {
      key_data$icon <- unname(icon_map$by_id[[lbl]])
    }
    if ("images_by_id" %in% names(icon_map) && lbl %in% names(icon_map$images_by_id)) {
      key_data$image <- unname(icon_map$images_by_id[[lbl]])
    }
  }
  
  # Fallback
  if (!("icon" %in% names(key_data)) || is.na(key_data$icon)) {
    key_data$icon <- "user"
  }
  
  draw_key_pop_image(key_data, params, size)
}