#' @importFrom ggplot2 ggproto Stat
#' @import dplyr

# Scale factor for converting size parameter to icon display size
ICON_SIZE_SCALE_FACTOR <- 0.03

StatIconPoint <- ggplot2::ggproto(
  "StatIconPoint", ggplot2::Stat,
  
  required_aes = c("x", "y", "icon"),
  
  compute_panel = function(data, scales, dpi = 50, size_param = 1, size_var = NULL) {
    # Compute icon_size from either mapped variable or parameter
    if (!is.null(size_var) && size_var %in% names(data)) {
      data$icon_size <- data[[size_var]] * ICON_SIZE_SCALE_FACTOR
    } else {
      data$icon_size <- size_param * ICON_SIZE_SCALE_FACTOR
    }
    
    # Generate PNG paths for icons with caching
    cache_dir <- file.path(tempdir(), "ggpop-icons")
    if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
    
    # Process each row to generate image paths
    data <- data %>%
      dplyr::rowwise() %>%
      dplyr::mutate(
        image = {
          this_icon <- as.character(.data$icon)
          if (is.na(this_icon) || !nzchar(this_icon)) {
            NA_character_
          } else {
            this_color <- if ("colour" %in% names(.)) {
              as.character(.data$colour)
            } else if ("color" %in% names(.)) {
              as.character(.data$color)
            } else {
              "black"
            }
            
            this_alpha <- if ("alpha" %in% names(.)) {
              as.numeric(.data$alpha)
            } else {
              1.0
            }
            
            this_color <- tryCatch({
              if (is.na(this_color) || !nzchar(this_color)) {
                "#000000"
              } else {
                rgb_vals <- grDevices::col2rgb(this_color) / 255
                grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
              }
            }, error = function(e) "#000000")
            
            # Recompute rgb_vals from the validated color
            rgba_color <- if (this_color == "#000000") {
              grDevices::rgb(0, 0, 0, alpha = this_alpha)
            } else {
              rgb_vals <- grDevices::col2rgb(this_color) / 255
              grDevices::rgb(
                rgb_vals[1],
                rgb_vals[2],
                rgb_vals[3],
                alpha = this_alpha
              )
            }
            
            color_hex <- gsub("#", "", this_color)
            alpha_str <- sprintf("%.2f", this_alpha)
            dpi_str <- sprintf("%.0f", dpi)
            
            cache_parts <- c(
              this_icon,
              paste0("c", color_hex),
              paste0("a", alpha_str),
              paste0("d", dpi_str)
            )
            
            png_path <- file.path(
              cache_dir,
              paste0(paste(cache_parts, collapse = "_"), ".png")
            )
            
            if (!file.exists(png_path)) {
              fontawesome::fa_png(
                this_icon,
                file = png_path,
                height = dpi,
                fill = rgba_color
              )
            }
            
            png_path
          }
        }
      ) %>%
      dplyr::ungroup()
    
    data
  }
)

# Backward compatibility
StatIconIdentity <- StatIconPoint
