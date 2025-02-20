##' Key drawing function for population-based image keys
##'
##' This function creates a custom key for displaying population-based image icons 
##' in the legend of a ggplot2 plot. Each group can be assigned a different icon 
##' based on the information in the `data$icon` column, and the icons can be colorized 
##' according to the specified `colour` and `alpha` aesthetics.
##'
##' @name draw_key_pop_image
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
  # If each group has a different icon in data$icon
  grobs <- lapply(seq_along(data$colour), function(i) {
    # Path to the icon file
    icon_path <- paste0("inst/figures/", data$icon[i], ".png")
    # Read the image
    img <- magick::image_read(icon_path)
    # Convert image to grayscale to remove existing colors
    img <- magick::image_quantize(img, colorspace = "gray")
    # Colorize the image using the specified color and transparency
    img <- magick::image_colorize(img, opacity = data$alpha[i] * 100, color = data$colour[i])
    # Apply colorization (if applicable) based on 'colour' and 'alpha' aesthetics
    # Create the grob for this icon
    grid::rasterGrob(
      x = 0.5, y = 0.5,
      image = img,
      width = 1, height = 1
    )
  })
  # Set the grobs' class to gList
  class(grobs) <- "gList"
  
  # Return a named ggplot2 grob containing the icons
  grid::gTree(children = grobs, name = "image_key")
}