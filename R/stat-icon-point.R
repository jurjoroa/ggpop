#' @importFrom ggplot2 ggproto Stat
StatIconPoint <- ggplot2::ggproto(
  "StatIconPoint", ggplot2::Stat,
  
  required_aes = c("x", "y"),
  
  compute_panel = function(data, scales,
                           icon = NULL, size = 1, dpi = 50,
                           legend_icons = TRUE,
                           build_id = NULL) {
    
    as_single_chr <- function(x, default = NA_character_) {
      if (length(x) == 0) return(default)
      x <- as.character(x[[1]])
      if (is.na(x) || !nzchar(x)) return(default)
      x
    }
    
    # ---- icon presence ----
    icon_param_ok <- !is.null(icon) && nzchar(as.character(icon))
    if (!("icon" %in% names(data))) {
      if (!icon_param_ok) {
        cli::cli_abort(c(
          "{.fn geom_icon_point}: no icon specified.",
          "x" = "Map {.code aes(icon = ...)} or set {.arg icon=}."
        ), call = NULL)
      }
      data$icon <- as.character(icon)
    }
    
    # ---- size handling ----
    if ("size" %in% names(data)) {
      # When size is mapped as an aesthetic, scale it way down
      data$icon_size <- data$size * 0.002
    } else {
      # When size is a parameter, scale it down so size=1 looks normal
      data$icon_size <- size * 0.03  # Adjust this multiplier to taste
    }
    
    # ---- compute image paths (cached) ----
    local_dpi <- dpi
    cache_dir <- file.path(tempdir(), "ggpop-icons")
    if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)
    
    data$image <- vapply(seq_len(nrow(data)), function(i) {
      
      this_icon <- as_single_chr(data$icon[i], default = NA_character_)
      if (is.na(this_icon)) return(NA_character_)
      
      this_color <- as_single_chr(
        if ("colour" %in% names(data)) data$colour[i] else
          if ("color" %in% names(data)) data$color[i] else
            "black",
        default = "black"
      )
      
      this_alpha <- suppressWarnings(as.numeric(
        if ("alpha" %in% names(data)) data$alpha[i] else 1
      ))
      if (!is.finite(this_alpha)) this_alpha <- 1
      
      this_color <- tryCatch({
        rgb_vals <- grDevices::col2rgb(this_color) / 255
        grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
      }, error = function(e) "#000000")
      
      rgb_vals <- grDevices::col2rgb(this_color) / 255
      rgba_color <- grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha = this_alpha)
      
      color_hex <- gsub("#", "", this_color)
      alpha_str <- sprintf("%.2f", this_alpha)
      dpi_str   <- sprintf("%.0f", local_dpi)
      
      png_path <- file.path(cache_dir, paste0(
        this_icon, "_c", color_hex, "_a", alpha_str, "_d", dpi_str, ".png"
      ))
      
      if (!file.exists(png_path)) {
        fontawesome::fa_png(this_icon, file = png_path, height = local_dpi, fill = rgba_color)
      }
      
      png_path
    }, character(1))
    
    # ---- Store mapping by category VALUE (not group) ----
    if (isTRUE(legend_icons) &&
        !is.null(build_id) && nzchar(as.character(build_id))) {
      
      color_col <- NULL
      if ("colour" %in% names(data)) color_col <- "colour"
      else if ("color" %in% names(data)) color_col <- "color"
      
      if (!is.null(color_col) && "icon" %in% names(data) && "image" %in% names(data)) {
        # Get unique category -> icon mappings
        df_map <- unique(data[, c(color_col, "icon", "image"), drop = FALSE])
        df_map <- df_map[!is.na(df_map[[color_col]]) & 
                           !is.na(df_map$icon) & 
                           !is.na(df_map$image), ]
        
        if (nrow(df_map) > 0) {
          # Store by category value AND create ordered lookup
          categories <- as.character(df_map[[color_col]])
          
          # Create factor to get the same order ggplot2 will use
          if (is.factor(data[[color_col]])) {
            # Use existing factor levels
            all_levels <- levels(data[[color_col]])
            categories_ordered <- all_levels[all_levels %in% categories]
          } else {
            # For character vectors, ggplot2 uses ALPHABETICAL order for discrete scales
            categories_ordered <- sort(unique(as.character(data[[color_col]])))
          }
          
          # Create ID mapping: 1, 2, 3, ... matching ggplot2's legend order
          id_map <- stats::setNames(seq_along(categories_ordered), categories_ordered)
          
          # Build the icon and image maps by both category AND by ID
          icon_map <- list(
            by_category = stats::setNames(
              as.character(df_map$icon),
              as.character(df_map[[color_col]])
            ),
            by_id = stats::setNames(
              as.character(df_map$icon[match(categories_ordered, df_map[[color_col]])]),
              as.character(seq_along(categories_ordered))
            ),
            images_by_category = stats::setNames(
              as.character(df_map$image),
              as.character(df_map[[color_col]])
            ),
            images_by_id = stats::setNames(
              as.character(df_map$image[match(categories_ordered, df_map[[color_col]])]),
              as.character(seq_along(categories_ordered))
            ),
            category_to_id = id_map
          )
          
          message("\n=== STAT DEBUG ===")
          message("Categories in order: ", paste(categories_ordered, collapse = ", "))
          message("Icon map by ID:")
          print(icon_map$by_id)
          message("Image map by ID (first 50 chars):")
          print(sapply(icon_map$images_by_id, function(x) substr(x, 1, 50)))
          message("==================\n")
          
          assign(as.character(build_id), icon_map, envir = .ggpop_env$legend_icon_map)
        }
      }
    }
    
    data
  }
)
