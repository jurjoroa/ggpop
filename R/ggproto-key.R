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

#' Draw key for icon point
#' @keywords internal
#' @noRd
draw_key_pop_image <- function(data, params, size) {
  dpi <- params$dpi %||% 50
  
  ic <- if ("icon" %in% names(data)) as.character(data$icon[1]) else "circle"
  
  this_color <- as.character(data$colour[1])
  this_alpha <- as.numeric(data$alpha[1])
  
  this_color <- tryCatch({
    rgb_vals <- grDevices::col2rgb(this_color) / 255
    grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3])
  }, error = function(e) "#000000")
  
  rgb_vals <- grDevices::col2rgb(this_color) / 255
  rgba_color <- grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha = this_alpha)
  
  cache_dir <- file.path(tempdir(), "ggpop-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  png_path <- file.path(cache_dir, paste0(ic, "_", gsub("#", "", this_color), "_", 
                                          sprintf("%.2f", this_alpha), "_", dpi, ".png"))
  
  if (!file.exists(png_path)) {
    fontawesome::fa_png(ic, file = png_path, height = dpi, fill = rgba_color)
  }
  
  img <- png::readPNG(png_path)
  grid::rasterGrob(img, x = 0.5, y = 0.5, width = grid::unit(1, "npc"), 
                   height = grid::unit(1, "npc"), interpolate = TRUE)
}