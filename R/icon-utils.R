#' Get color from row data
#'
#' Extracts the color value from a data row, checking \code{colour} first,
#' then \code{color}. Falls back to \code{default_color} when neither exists.
#'
#' @param row_data A single row (list/data frame row) from the plotting data.
#' @param default_color Fallback color when no color columns exist.
#'
#' @return A character scalar representing the color.
#' @keywords internal
#' @noRd
get_row_color <- function(row_data, default_color = "black") {
  if ("colour" %in% names(row_data)) {
    as.character(row_data$colour)
  } else if ("color" %in% names(row_data)) {
    as.character(row_data$color)
  } else {
    default_color
  }
}

#' Get alpha from row data
#'
#' Extracts the \code{alpha} value from a data row. Defaults to
#' \code{default_alpha} when no \code{alpha} column exists.
#'
#' @param row_data A single row (list/data frame row) from the plotting data.
#' @param default_alpha Fallback alpha when no alpha column exists.
#'
#' @return A numeric scalar between 0 and 1.
#' @keywords internal
#' @noRd
get_row_alpha <- function(row_data, default_alpha = 1.0) {
  if ("alpha" %in% names(row_data)) {
    as.numeric(row_data$alpha)
  } else {
    default_alpha
  }
}

#' Normalize color to hex
#'
#' Converts a color to a normalized hex string. Returns \code{fallback_hex} when
#' the input is missing, empty, or invalid.
#'
#' @param color A color name or hex string.
#' @param fallback_hex Fallback hex color when input is invalid.
#'
#' @return A hex color string.
#' @keywords internal
#' @noRd
normalize_color <- function(color, fallback_hex = "#000000") {
  tryCatch(
    {
      if (is.na(color) || !nzchar(color)) {
        fallback_hex
      } else {
        rgb_vals <- grDevices::col2rgb(color) / 255
        grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], maxColorValue = 1)
      }
    },
    error = function(e) fallback_hex
  )
}

#' Create RGBA color string
#'
#' Builds an RGBA string from a hex color and alpha value.
#'
#' @param hex_color Hex color string.
#' @param alpha Numeric transparency value in \code{[0, 1]}.
#'
#' @return An RGBA color string.
#' @keywords internal
#' @noRd
create_rgba_color <- function(hex_color, alpha) {
  rgb_vals <- grDevices::col2rgb(hex_color) / 255
  grDevices::rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha = alpha)
}

#' Generate cache path for icon PNG
#'
#' Creates a deterministic file path for caching rendered icon PNGs based on
#' icon name, color, alpha, DPI, and optional stroke settings.
#'
#' @param icon Icon name.
#' @param color Hex color string.
#' @param alpha Numeric transparency value.
#' @param dpi Numeric DPI used for rendering.
#' @param stroke_width Numeric. Stroke width in pixels. If NULL or 0, no stroke.
#' @param cache_dir_name Cache directory name under \code{tempdir()}.
#' @param alpha_format Format string for alpha.
#' @param dpi_format Format string for dpi.
#' @param stroke_width_tag Tag used for stroke width in cache key.
#' @param stroke_color_tag Tag used for stroke color in cache key.
#'
#' @return A file path where the cached PNG should live.
#' @keywords internal
#' @noRd
generate_icon_cache_path <- function(icon,
                                     color,
                                     alpha,
                                     dpi,
                                     stroke_width = NULL,
                                     cache_dir_name = "ggpop-icons",
                                     alpha_format = "%.2f",
                                     dpi_format = "%.0f",
                                     stroke_width_tag = "sw",
                                     stroke_color_tag = "sc") {
  cache_dir <- file.path(tempdir(), cache_dir_name)
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)

  color_hex <- gsub("#", "", color)
  alpha_str <- sprintf(alpha_format, alpha)
  dpi_str <- sprintf(dpi_format, dpi)

  cache_parts <- c(
    icon,
    paste0("c", color_hex),
    paste0("a", alpha_str),
    paste0("d", dpi_str)
  )

  if (!is.null(stroke_width) && stroke_width > 0) {
    cache_parts <- c(
      cache_parts,
      paste0(stroke_width_tag, sprintf(dpi_format, stroke_width)),
      paste0(stroke_color_tag, color_hex) # Stroke color same as fill
    )
  }

  file.path(cache_dir, paste0(paste(cache_parts, collapse = "_"), ".png"))
}

#' Normalize icon PNG to a square canvas (uniform visual height)
#'
#' Trims transparent padding, scales to fit within \code{dpi x dpi}, and pads
#' back to a square canvas with a transparent background.
#'
#' @param png_path File path of the PNG to normalize.
#' @param dpi Target size (pixels) for the square output.
#' @param gravity Gravity used for image placement when padding.
#' @param background Background color used for padding.
#' @param output_format Output format used when writing the image.
#'
#' @return Invisible TRUE on success, FALSE if the file does not exist.
#' @keywords internal
#' @noRd
normalize_icon_png <- function(png_path,
                               dpi,
                               gravity = "center",
                               background = "none",
                               output_format = "png") {
  if (!file.exists(png_path)) {
    return(invisible(FALSE))
  }

  img <- magick::image_read(png_path)

  img <- magick::image_trim(img)
  img <- magick::image_scale(img, paste0(dpi, "x", dpi))
  img <- magick::image_extent(
    img,
    geometry = paste0(dpi, "x", dpi),
    gravity = gravity,
    color = background
  )

  magick::image_write(img, path = png_path, format = output_format)
  invisible(TRUE)
}

#' Resolve an icon string to a render source
#'
#' Classifies an icon value as a Font Awesome name, a bundled ggpop SVG marker
#' (shipped under \code{inst/icons}), or a user-supplied local \code{.svg} path.
#'
#' @param icon Icon value (Font Awesome name, bundled marker name, or SVG path).
#'
#' @return A list with \code{type} (\code{"fa"}, \code{"svg"}, or \code{"none"})
#'   and \code{path} (the SVG file path, or \code{NA_character_} for FA names).
#' @keywords internal
#' @noRd
resolve_icon_source <- function(icon) {
  icon <- as.character(icon)

  if (is.na(icon) || !nzchar(icon)) {
    return(list(type = "none", path = NA_character_))
  }

  # User-supplied local SVG file
  if (grepl("\\.svg$", icon, ignore.case = TRUE) && file.exists(icon)) {
    return(list(type = "svg", path = icon))
  }

  # Bundled ggpop marker shipped under inst/icons
  bundled <- system.file("icons", paste0(icon, ".svg"), package = "ggpop")
  if (nzchar(bundled) && file.exists(bundled)) {
    return(list(type = "svg", path = bundled))
  }

  # Otherwise treat as a Font Awesome name
  list(type = "fa", path = NA_character_)
}

#' Render an SVG icon to a single-colour PNG
#'
#' Reads an SVG, recolours its single fill colour to \code{hex_color} (monochrome
#' markers only; multi-colour SVGs render unchanged), and rasterizes to PNG. Alpha
#' is applied with \code{magick::image_fx} - never baked into the SVG fill, which
#' mirrors the legend's safe transparency path.
#'
#' @param svg_path Path to the source SVG.
#' @param png_path Destination PNG path.
#' @param hex_color Target hex colour for monochrome recolouring.
#' @param alpha Numeric transparency value in \code{[0, 1]}.
#' @param dpi Height (pixels) of the rendered PNG.
#'
#' @return The destination PNG path, invisibly.
#' @importFrom rsvg rsvg_png
#' @keywords internal
#' @noRd
render_svg_icon_png <- function(svg_path, png_path, hex_color, alpha, dpi) {
  svg_txt <- paste(readLines(svg_path, warn = FALSE), collapse = "\n")

  # Recolour the single fill colour used by bundled markers. Multi-colour
  # user SVGs have no match and render unchanged.
  svg_txt <- gsub("#000000", hex_color, svg_txt, ignore.case = TRUE)
  svg_txt <- gsub("#000\\b", hex_color, svg_txt, ignore.case = TRUE)

  tmp_svg <- tempfile(fileext = ".svg")
  writeLines(svg_txt, tmp_svg)

  # Supersample: an SVG's artwork may not fill its viewBox (markers have
  # margins), so rendering at exactly `dpi` and then trimming + scaling to
  # `dpi` would upscale the smaller content and blur the edges. Render well
  # above the target so the downstream trim/scale always downsamples - giving
  # dpi-faithful sharpness like fontawesome, for bundled and user SVGs alike.
  render_h <- min(max(as.integer(dpi) * 3L, 300L), 4000L)
  rsvg::rsvg_png(tmp_svg, file = png_path, height = render_h)

  if (is.finite(alpha) && alpha < 1) {
    img <- magick::image_fx(
      magick::image_read(png_path),
      expression = paste0("a*", alpha),
      channel = "Alpha"
    )
    magick::image_write(img, png_path)
  }

  invisible(png_path)
}

#' Generate and cache icon PNG
#'
#' Renders a Font Awesome icon to a PNG, caches it by appearance settings,
#' and normalizes the output size for consistent rendering.
#'
#' @param icon Font Awesome icon name.
#' @param color Color (name or hex) used for the icon fill.
#' @param alpha Numeric transparency value.
#' @param dpi Numeric DPI used for rendering.
#' @param stroke_width Numeric. Stroke width in pixels. If NULL or 0, no stroke.
#' @param fallback_hex Fallback hex color when input is invalid.
#' @param cache_dir_name Cache directory name under \code{tempdir()}.
#' @param alpha_format Format string for alpha.
#' @param dpi_format Format string for dpi.
#' @param stroke_width_tag Tag used for stroke width in cache key.
#' @param stroke_color_tag Tag used for stroke color in cache key.
#' @param gravity Gravity used for image placement when padding.
#' @param background Background color used for padding.
#' @param output_format Output format used when writing the image.
#'
#' @return A file path to the cached PNG, or \code{NA_character_} if icon is missing.
#' @importFrom rsvg rsvg
#' @keywords internal
#' @noRd
generate_icon_png <- function(icon,
                              color,
                              alpha,
                              dpi,
                              stroke_width = NULL,
                              fallback_hex = "#000000",
                              cache_dir_name = "ggpop-icons",
                              alpha_format = "%.2f",
                              dpi_format = "%.0f",
                              stroke_width_tag = "sw",
                              stroke_color_tag = "sc",
                              gravity = "center",
                              background = "none",
                              output_format = "png") {
  if (is.na(icon) || !nzchar(icon)) {
    return(NA_character_)
  }

  hex_color <- normalize_color(color, fallback_hex = fallback_hex)
  rgba_color <- create_rgba_color(hex_color, alpha)

  # Resolve to a Font Awesome name or an SVG source (bundled marker or
  # user-supplied .svg). SVG sources use a content hash in the cache key so
  # different files sharing a basename do not collide.
  source <- resolve_icon_source(icon)
  cache_icon <- icon
  if (source$type == "svg") {
    cache_icon <- paste0(
      gsub("[^A-Za-z0-9]+", "-", tools::file_path_sans_ext(basename(source$path))),
      "-", substr(unname(tools::md5sum(source$path)), 1, 8)
    )
  }

  png_path <- generate_icon_cache_path(
    cache_icon,
    hex_color,
    alpha,
    dpi,
    stroke_width = stroke_width,
    cache_dir_name = cache_dir_name,
    alpha_format = alpha_format,
    dpi_format = dpi_format,
    stroke_width_tag = stroke_width_tag,
    stroke_color_tag = stroke_color_tag
  )

  if (!file.exists(png_path)) {
    if (source$type == "svg") {
      # Bundled marker or user SVG: recolour + rasterize (no ggimage tint).
      render_svg_icon_png(source$path, png_path, hex_color, alpha, dpi)
    } else if (!is.null(stroke_width) && stroke_width > 0) {
      # Font Awesome with stroke (stroke color same as fill)
      fontawesome::fa_png(
        icon,
        file = png_path,
        height = dpi,
        fill = rgba_color,
        stroke = rgba_color,
        stroke_width = stroke_width
      )
    } else {
      # Font Awesome, no stroke (solid fill only)
      fontawesome::fa_png(
        icon,
        file = png_path,
        height = dpi,
        fill = rgba_color
      )
    }

    # Normalize size to uniform visual height
    normalize_icon_png(
      png_path,
      dpi,
      gravity = gravity,
      background = background,
      output_format = output_format
    )
  }

  png_path
}

#' Add image paths to data for icon rendering
#'
#' Adds an \code{image} column containing cached PNG paths for each row,
#' based on icon, color, alpha, and DPI settings.
#'
#' @param data Data frame of plotting data.
#' @param dpi Numeric DPI used for rendering.
#' @param stroke_width Numeric. Stroke width in pixels. If NULL or 0, no stroke.
#' @param default_color Fallback color when no color columns exist.
#' @param default_alpha Fallback alpha when no alpha column exists.
#' @param fallback_hex Fallback hex color when input is invalid.
#' @param cache_dir_name Cache directory name under \code{tempdir()}.
#' @param alpha_format Format string for alpha.
#' @param dpi_format Format string for dpi.
#' @param stroke_width_tag Tag used for stroke width in cache key.
#' @param stroke_color_tag Tag used for stroke color in cache key.
#' @param gravity Gravity used for image placement when padding.
#' @param background Background color used for padding.
#' @param output_format Output format used when writing the image.
#'
#' @return Data frame with \code{image} column added.
#' @keywords internal
#' @noRd
add_icon_images <- function(data,
                            dpi,
                            stroke_width = NULL,
                            default_color = "black",
                            default_alpha = 1.0,
                            fallback_hex = "#000000",
                            cache_dir_name = "ggpop-icons",
                            alpha_format = "%.2f",
                            dpi_format = "%.0f",
                            stroke_width_tag = "sw",
                            stroke_color_tag = "sc",
                            gravity = "center",
                            background = "none",
                            output_format = "png") {
  data %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      image = {
        this_icon <- as.character(.data$icon)
        this_color <- get_row_color(., default_color = default_color)
        this_alpha <- get_row_alpha(., default_alpha = default_alpha)
        generate_icon_png(
          this_icon,
          this_color,
          this_alpha,
          dpi,
          stroke_width = stroke_width,
          fallback_hex = fallback_hex,
          cache_dir_name = cache_dir_name,
          alpha_format = alpha_format,
          dpi_format = dpi_format,
          stroke_width_tag = stroke_width_tag,
          stroke_color_tag = stroke_color_tag,
          gravity = gravity,
          background = background,
          output_format = output_format
        )
      }
    ) %>%
    dplyr::ungroup()
}
