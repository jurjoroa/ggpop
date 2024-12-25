caption_pop <- function(size_caption = 3, size_image = 20, hjust = 0.6, text = NULL) {
  
  #--- Ensure `data` exists ---
  if (is.null(data)) {
    stop("Data must be provided to generate captions.")
  }
  
  #--- Get the last plot and its data ---
  last_plot <- ggplot2::last_plot()
  data <- last_plot$layers[[1]]$data
  
  #--- Compute counts (ceiling of sum / number of rows) ---
  first_group <- ceiling(sum(data$n[1], na.rm = TRUE) / nrow(data))
  second_group <- ceiling(sum(data$n[2], na.rm = TRUE) / nrow(data))
  third_group <- ceiling(sum(data$n[3], na.rm = TRUE) / nrow(data))
  
  # Helper function to get text description for an image
  get_text <- function(image) {
    if (!is.null(text) && image %in% names(text)) {
      return(text[[image]])
    }
    return("persons") # Default fallback
  }
  
  # Helper function to split and process text
  process_text <- function(image) {
    words <- unlist(strsplit(get_text(image), " "))
    if (length(words) > 2) {
      c(words[1], words[2], paste(words[3:length(words)], collapse = " "))
    } else {
      c(words, "")
    }
  }
  
  # Generate caption based on available images
  if (!is.na(data$image[1]) && !is.na(data$image[2]) && !is.na(data$image[3])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3],
      "<br>",
      "<br>",
      process_text(data$image[3])[1],
      paste0("<img src='man/figures/", data$image[3], ".png' width='", size_image, "'/>"),
      process_text(data$image[3])[2],
      third_group,
      process_text(data$image[3])[3]
    )
  } else if (!is.na(data$image[1]) && !is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group,
      process_text(data$image[1])[3],
      "<br>",
      "<br>",
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
      process_text(data$image[2])[2],
      second_group,
      process_text(data$image[2])[3]
    )
  } else if (!is.na(data$image[1])) {
    caption_text <- paste(
      process_text(data$image[1])[1],
      paste0("<img src='man/figures/", data$image[1], ".png' width='", size_image, "'/>"),
      process_text(data$image[1])[2],
      first_group + second_group,
      process_text(data$image[1])[3]
    )
  } else if (!is.na(data$image[2])) {
    caption_text <- paste(
      process_text(data$image[2])[1],
      paste0("<img src='man/figures/", data$image[2], ".png' width='", size_image, "'/>"),
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
    theme(plot.caption = ggtext::element_markdown(size = size_caption, hjust = hjust))
  )
}
