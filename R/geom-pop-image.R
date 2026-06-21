#' Recolor a cached icon PNG at draw time
#'
#' Bakes the resolved (scale-trained) colour into an icon PNG so it can be drawn
#' without relying on \pkg{ggimage}'s draw-time tinting. The solid fill is baked
#' via \code{generate_icon_png()} with \code{alpha = 1} (a fully opaque fill is
#' the only form \code{fontawesome::fa_png()} renders reliably). Transparency is
#' then applied separately with \code{magick::image_fx()} - the same route the
#' legend key uses - because an RGBA fill with \code{alpha < 1} produces SVG that
#' \pkg{rsvg} cannot parse.
#'
#' @param icon Font Awesome icon name.
#' @param color Resolved colour (name or hex) for the icon fill.
#' @param alpha Numeric transparency value in \code{[0, 1]}.
#' @param dpi Numeric DPI used for rendering.
#' @param stroke_width Numeric. Stroke width in pixels. If NULL or 0, no stroke.
#'
#' @return A file path to the cached PNG, or \code{NA_character_} if icon is
#'   missing.
#' @keywords internal
#' @noRd
recolor_icon_for_draw <- function(icon, color, alpha, dpi, stroke_width = NULL,
                                  icon_path = NULL) {
  base_path <- generate_icon_png(
    icon,
    color,
    alpha = 1,
    dpi,
    stroke_width = stroke_width,
    icon_path = icon_path
  )

  if (is.na(base_path)) {
    return(NA_character_)
  }

  if (is.na(alpha) || !is.finite(alpha) || alpha >= 1) {
    return(base_path)
  }

  hex_color <- gsub("#", "", normalize_color(color))
  cache_dir <- file.path(tempdir(), "ggpop-icons")
  if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE)

  stroke_tag <- if (!is.null(stroke_width) && stroke_width > 0) {
    paste0("_sw", sprintf("%.0f", stroke_width))
  } else {
    ""
  }

  alpha_path <- file.path(
    cache_dir,
    paste0(
      gsub("[^A-Za-z0-9]+", "-", icon), "_c", hex_color,
      "_a", sprintf("%.2f", alpha),
      "_d", sprintf("%.0f", dpi),
      stroke_tag, "_draw.png"
    )
  )

  if (!file.exists(alpha_path)) {
    img <- magick::image_read(base_path)
    img <- magick::image_fx(
      img,
      expression = paste0("a*", alpha),
      channel = "Alpha"
    )
    magick::image_write(img, alpha_path)
  }

  alpha_path
}

#' Build a draw-time-recoloring image geom for icon layers
#'
#' Returns a per-layer \pkg{ggproto} object that subclasses the layer's own
#' \pkg{ggimage} \code{GeomImage} instance. At draw time it re-bakes each row's
#' PNG with the scale-trained \code{colour} (and \code{alpha}) and then drops the
#' \code{colour} aesthetic before delegating to the parent's \code{draw_panel}.
#' Dropping \code{colour} stops \pkg{ggimage} from tinting the PNG itself, whose
#' tint depends on the \pkg{magick}/ImageMagick build and silently renders icons
#' black when RGBA conversion fails (#380). \code{dpi} and \code{stroke_width}
#' are captured in this factory's environment so they do not need to travel
#' through the layer's geom parameters.
#'
#' @param parent_geom The \code{GeomImage} instance from the built layer.
#' @param dpi Numeric DPI used for rendering.
#' @param stroke_width Numeric. Stroke width in pixels. If NULL or 0, no stroke.
#'
#' @return A \code{ggproto} \code{Geom} object inheriting from \code{parent_geom}.
#' @keywords internal
#' @noRd
make_geom_pop_image <- function(parent_geom, dpi, stroke_width = NULL,
                                icon_path = NULL) {
  # Declare `icon` as a known aesthetic so ggplot2 carries the icon-name column
  # through to draw_panel instead of dropping it as "unknown".
  icon_aware_aes <- parent_geom$default_aes
  icon_aware_aes["icon"] <- list(NULL)

  ggplot2::ggproto(
    "GeomPopImage",
    parent_geom,
    default_aes = icon_aware_aes,
    draw_panel = function(self, data, panel_params, coord, by = "width",
                          na.rm = FALSE, .fun = NULL, image_fun = NULL,
                          hjust = 0.5, nudge_x = 0, nudge_y = 0, asp = 1, ...) {
      if ("icon" %in% names(data)) {
        for (i in seq_len(nrow(data))) {
          this_icon <- data$icon[i]
          if (is.na(this_icon) || !nzchar(as.character(this_icon))) next

          this_color <- if ("colour" %in% names(data)) data$colour[i] else NA
          if (is.na(this_color) || !nzchar(as.character(this_color))) {
            this_color <- "black"
          }

          this_alpha <- if ("alpha" %in% names(data)) data$alpha[i] else 1
          if (is.na(this_alpha) || !is.finite(this_alpha)) this_alpha <- 1

          recolored <- recolor_icon_for_draw(
            as.character(this_icon), this_color, this_alpha, dpi, stroke_width,
            icon_path = icon_path
          )
          if (!is.na(recolored)) data$image[i] <- recolored
        }
      }

      # Icons are baked with the resolved colour, so drop the colour aesthetic
      # to stop ggimage from tinting the PNG at draw time (its tint silently
      # renders black on some magick/ImageMagick builds - see #380).
      data$colour <- NULL

      ggplot2::ggproto_parent(parent_geom, self)$draw_panel(
        data, panel_params, coord,
        by = by, na.rm = na.rm, .fun = .fun, image_fun = image_fun,
        hjust = hjust, nudge_x = nudge_x, nudge_y = nudge_y, asp = asp, ...
      )
    }
  )
}
