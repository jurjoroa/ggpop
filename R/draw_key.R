##' Key drawing function for population-based image keys
##'
##' This function creates a custom key for displaying population-based image icons 
##' in the legend of a ggplot2 plot. Each group can be assigned a different icon 
##' based on the information in the `data$icon` column, and the icons can be colorized 
##' according to the specified `colour` and `alpha` aesthetics.
##'
##' @name draw_key_pop_image
##' @title Key drawing function for population-based image keys
##' @param data A data frame containing the scaled aesthetics for the key. 
##'             It must include a `colour` column for color, an `alpha` column for transparency, 
##'             and an `icon` column with the names of the icon files (without extension) to be used.
##' @param params A list of additional parameters supplied to the geom.
##' @param size The width and height of the key in mm. This value is not used directly in this function.
##' @return A grid grob containing the image icons with the specified colors and transparency.
##' @importFrom magick image_read image_quantize image_colorize
##' @importFrom grid rasterGrob gTree
##' 
##' @details
#' This function relies on `ggimage:::color_image` and `ggplot2:::ggname`, which are internal functions.
#' Their use is necessary for correct functionality, and no exported alternatives exist.
#' We acknowledge the potential risks associated with `:::` usage, but at present, these functions
#' provide essential behavior for rendering images within ggplot2.
##' @export
draw_key_pop_image <- function(data, params, size) {
  
  rsvg::librsvg_version()
  
  cache_dir <- file.path(tempdir(), "ggpop-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  grobs <- lapply(seq_along(data$colour), function(i) {
    
    this_icon <- as.character(data$icon[i])
    if (is.na(this_icon) || !nzchar(this_icon)) this_icon <- "user"
    
    pkg_png <- system.file("figures/key", paste0(this_icon, ".png"), package = "ggpop")
    
    if (nzchar(pkg_png) && file.exists(pkg_png)) {
      png_path <- pkg_png
    } else {
      png_path <- file.path(cache_dir, paste0(this_icon, ".png"))
      if (!file.exists(png_path)) {
        fontawesome::fa_png(this_icon, file = png_path, height = 120)
      }
    }
    
    img <- magick::image_read(png_path)
    img <- magick::image_quantize(img, colorspace = "gray")
    img <- magick::image_colorize(
      img,
      opacity = data$alpha[i] * 100,
      color   = data$colour[i]
    )
    
    grid::rasterGrob(x = 0.5, y = 0.5, image = img)
  })
  
  class(grobs) <- "gList"
  grid::gTree(children = grobs, name = "image_key")
}
