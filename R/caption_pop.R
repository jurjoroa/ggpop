#' Add Custom Captions with Icons to a geom_pop object
#'
#' The `caption_pop` function allows you to add custom captions to a `geom_pop` object. 
#' The function generates a caption based on the images used in the plot. 
#' The caption includes the number of individuals represented by each image. 
#' The function also allows you to specify the size of the caption text and 
#' the icons used in the caption.
#'
#' @param caption_size Numeric. The font size of the caption text. Default is `3`.
#' @param icon_size Numeric. The width of the images (icons) in pixels within the caption. Default is `20`.
#' @param hjust Numeric. The horizontal justification of the caption. Values range from `0` (left) to `1` (right).
#'               Default is `0.5`.
#' @param text Named list or named vector. Custom text descriptions for each icon. The names should correspond
#'             to the `image` identifiers in the plot data. If `NULL`, defaults to `"persons"`.
#' @import ggplot2
#' @import ggtext
#'         
#'@export
caption_pop <- function(caption_size = 1, icon_size = 1, hjust = 0.5, text = NULL) {

  icon_size <- icon_size * 10
  caption_size <- caption_size * 18
  
  #--- Get the last plot from geom_pop ---
  last_plot <- ggplot2::last_plot()
  data <- last_plot$layers[[1]]$data
  
  #--- Compute counts (ceiling of sum / number of rows) ---
  first_group <- ceiling(sum(data$n[1], na.rm = TRUE) / nrow(data))
  second_group <- ceiling(sum(data$n[2], na.rm = TRUE) / nrow(data))
  third_group <- ceiling(sum(data$n[3], na.rm = TRUE) / nrow(data))
  fourth_group <- ceiling(sum(data$n[4], na.rm = TRUE) / nrow(data))
  
  # Helper function to get text description for an image
  get_text <- function(image) {
    if (!is.null(text) && image %in% names(text)) {
      return(text[[image]])
    }
    return("persons") # Default fallback
  }
  
  # Helper function to split and process text to format the words with the icons
  process_text <- function(image) {
    words <- unlist(strsplit(get_text(image), " "))
    if (length(words) > 2) {
      c(words[1], words[2], paste(words[3:length(words)], collapse = " "))
    } else {
      c(words, "")
    }
  }
  
  # Generate caption based on available images
  if (!is.na(data$image[1]) && !is.na(data$image[2]) && !is.na(data$image[3]) && !is.na(data$image[4])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", icon_size, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<span style='color: transparent;'>U+0020;</span>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", icon_size, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3],
      "<br>",
      process_text(data$image[3])[1],
      paste0("<img src='man/figures/", data$image[3], ".png' width='", icon_size, "'/>"),
      process_text(data$image[3])[2],
      third_group,
      process_text(data$image[3])[3],
      "<span style='color: transparent;'>U+0020;</span>",
      process_text(data$image[4])[1],
      paste0("<img src='man/figures/", data$image[4], ".png' width='", icon_size, "'/>"),
      process_text(data$image[4])[2],
      fourth_group,
      process_text(data$image[4])[3])
  } else if (!is.na(data$image[1]) && !is.na(data$image[2]) && !is.na(data$image[3])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", icon_size, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", icon_size, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3],
      "<br>",
      process_text(data$image[3])[1],
      paste0("<img src='man/figures/", data$image[3], ".png' width='", icon_size, "'/>"),
      process_text(data$image[3])[2],
      third_group,
      process_text(data$image[3])[3]
    )
  } else if (!is.na(data$image[1]) && !is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", icon_size, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", icon_size, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3]
    )
  } else if (!is.na(data$image[1])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", icon_size, "'/>"),
      process_text(data$image[1])[2],
      first_group + second_group,
      process_text(data$image[1])[3]
    )
  } else if (!is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", icon_size, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3]
    )
  } else {
    stop("No valid images found.")
  }
  
  #--- Return a list of ggplot2 commands to modify your plot ---
  list(
    labs(caption = caption_text),
    theme(plot.caption = ggtext::element_markdown(size = caption_size, hjust = hjust))
  )
}