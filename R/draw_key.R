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
  
  grobs <- lapply(seq_along(data$colour), function(i) {
    
    icon_path <- paste0("inst/figures/key/", data$icon[i], ".png") #hack with paste0
    
    if (file.exists(icon_path)) {
      temp_icon_path <- icon_path
    } else {
      temp_icon_path <- paste0("inst/figures/key/", data$icon[i], ".png")
      
      fontawesome::fa_png(paste0(data$icon[i]), file = temp_icon_path) 
      
      rsvg::librsvg_version()
    }
    
    img <- magick::image_read(icon_path)
    
    img <- magick::image_quantize(img, colorspace = "gray")
    
    img <- magick::image_colorize(img, opacity = data$alpha[i] * 100, color = data$colour[i])
    
    # Create the grob for this icon
    grid::rasterGrob(
      x = .5, y = .5,
      image = img)
  })
  # class to gList
  class(grobs) <- "gList"
  
  # grob containing the icons
  grid::gTree(children = grobs, name = "image_key")
}
