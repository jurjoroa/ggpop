#' Get color from row data
#' @keywords internal
#' @noRd
get_row_color <- function(row_data) {
  if ("colour" %in% names(row_data)) {
    as.character(row_data$colour)
  } else if ("color" %in% names(row_data)) {
    as.character(row_data$color)
  } else {
    "black"
  }
}

#' Get alpha from row data
#' @keywords internal
#' @noRd
get_row_alpha <- function(row_data) {
  if ("alpha" %in% names(row_data)) {
    as.numeric(row_data$alpha)
  } else {
    1.0
  }
}

#' Normalize color to hex
#' @keywords internal
#' @noRd
normalize_color <- function(color) {
  tryCatch({
    if (is.na(color) || !nzchar(color)) {
      "#000000"
    } else {
      rgb_vals <- grDevices::col2rgb(color) / 255
      grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
    }
  }, error = function(e) "#000000")
}

#' Create RGBA color string
#' @keywords internal
#' @noRd
create_rgba_color <- function(hex_color, alpha) {
  rgb_vals <- grDevices::col2rgb(hex_color) / 255
  grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha = alpha)
}

#' Generate cache path for icon PNG
#' @keywords internal
#' @noRd
generate_icon_cache_path <- function(icon, color, alpha, dpi) {
  cache_dir <- file.path(tempdir(), "ggpop-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
  
  color_hex <- gsub("#", "", color)
  alpha_str <- sprintf("%.2f", alpha)
  dpi_str <- sprintf("%.0f", dpi)
  
  file.path(cache_dir, paste0(icon, "_", color_hex, "_", alpha_str, "_", dpi_str, ".png"))
}

#' Generate and cache icon PNG
#' @keywords internal
#' @noRd
generate_icon_png <- function(icon, color, alpha, dpi) {
  if (is.na(icon) || !nzchar(icon)) {
    return(NA_character_)
  }
  
  # Normalize color
  hex_color <- normalize_color(color)
  
  # Create RGBA color
  rgba_color <- create_rgba_color(hex_color, alpha)
  
  # Get cache path
  png_path <- generate_icon_cache_path(icon, hex_color, alpha, dpi)
  
  # Generate PNG if not cached
  if (!file.exists(png_path)) {
    fontawesome::fa_png(icon, file = png_path, height = dpi, fill = rgba_color)
  }
  
  png_path
}

#' Add image paths to data for icon rendering
#' @keywords internal
#' @noRd
add_icon_images <- function(data, dpi) {
  data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        this_color <- get_row_color(.)
        this_alpha <- get_row_alpha(.)
        generate_icon_png(this_icon, this_color, this_alpha, dpi)
      }
    ) %>%
    dplyr::ungroup()
}