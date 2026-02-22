# R/theme-pop.R

#' Population Plot Theme
#'
#' A minimal theme optimized for icon-based population plots. Similar to
#' \code{theme_void()} but with automatic legend key sizing, appropriate margins,
#' and sensible defaults for population visualizations.
#'
#' @param base_size Base font size in points (default: 11).
#' @param base_family Base font family (default: "").
#' @param base_line_size Base size for line elements (default: base_size/22).
#' @param base_rect_size Base size for rect elements (default: base_size/22).
#' @param legend_icon_size Size of legend icons in cm. If NULL (default),
#'   automatically calculated as base_size/20 for proportional sizing.
#' @param legend_spacing Spacing between legend items in cm (default: 0.3 * legend_icon_size).
#' @param plot_margin Plot margins. Default: margin(5.5, 5.5, 5.5, 5.5, "pt").
#'   Can be a single numeric (applied to all sides) or margin() object.
#' @param legend_position Position of legend: "none", "left", "right", "bottom", "top" (default: "right").
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' ggplot(data = df, aes(icon = icon, color = type)) +
#'   geom_pop(size = 1) +
#'   theme_pop()
#'
#' # Large text with bottom legend
#' ggplot(data = df, aes(icon = icon, color = type)) +
#'   geom_pop(size = 1) +
#'   theme_pop(base_size = 40, legend_position = "bottom")
#' }
#'
#' @export
theme_pop <- function(
  base_size = 11,
  base_family = "",
  base_line_size = base_size / 22,
  base_rect_size = base_size / 22,
  legend_icon_size = NULL,
  legend_spacing = NULL,
  plot_margin = NULL,
  legend_position = "right"
) {
  # Auto-calculate legend icon size based on base_size if not provided
  if (is.null(legend_icon_size)) {
    legend_icon_size <- base_size / 20
  }

  # Auto-calculate legend spacing if not provided
  if (is.null(legend_spacing)) {
    legend_spacing <- 0.3 * legend_icon_size
  }

  # Use normal ggplot2 default margins if not provided
  if (is.null(plot_margin)) {
    plot_margin <- ggplot2::margin(
      t = 5.5,
      r = 5.5,
      b = 5.5,
      l = 5.5,
      unit = "pt"
    )
  } else if (is.numeric(plot_margin) && length(plot_margin) == 1) {
    plot_margin <- ggplot2::margin(
      plot_margin, plot_margin, plot_margin, plot_margin, "pt"
    )
  }

  # Build theme from scratch
  ggplot2::theme(
    # Remove all axis elements
    axis.line = ggplot2::element_blank(),
    axis.text = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    axis.title = ggplot2::element_blank(),

    # Remove panel elements
    panel.background = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    panel.spacing = grid::unit(0, "pt"),

    # Remove plot background
    plot.background = ggplot2::element_blank(),

    # Title elements
    plot.title = ggplot2::element_text(
      size = base_size * 1.2,
      hjust = 0,
      vjust = 1,
      family = base_family,
      face = "bold",
      margin = ggplot2::margin(b = base_size * 0.5, unit = "pt")
    ),
    plot.subtitle = ggplot2::element_text(
      size = base_size * 0.9,
      hjust = 0,
      vjust = 1,
      family = base_family,
      margin = ggplot2::margin(b = base_size * 0.5, unit = "pt")
    ),
    plot.caption = ggplot2::element_text(
      size = base_size * 0.7,
      hjust = 1,
      vjust = 1,
      family = base_family,
      margin = ggplot2::margin(t = base_size * 0.5, unit = "pt")
    ),
    plot.tag = ggplot2::element_text(
      size = base_size * 1.2,
      hjust = 0.5,
      vjust = 0.5,
      family = base_family
    ),

    # Plot margins - normal default (5.5pt all sides)
    plot.margin = plot_margin,

    # Legend styling
    legend.background = ggplot2::element_blank(),
    legend.key = ggplot2::element_blank(),
    legend.key.size = grid::unit(legend_icon_size, "cm"),
    legend.key.height = grid::unit(legend_icon_size, "cm"),
    legend.key.width = grid::unit(legend_icon_size, "cm"),
    legend.spacing = grid::unit(legend_spacing, "cm"),
    legend.spacing.x = grid::unit(legend_spacing, "cm"),
    legend.spacing.y = grid::unit(legend_spacing, "cm"),
    legend.position = legend_position,
    legend.direction = NULL,
    legend.justification = "center",
    legend.box = NULL,
    legend.box.margin = ggplot2::margin(0, 0, 0, 0, "pt"),
    legend.box.background = ggplot2::element_blank(),
    legend.box.spacing = grid::unit(base_size, "pt"),
    legend.text = ggplot2::element_text(
      size = base_size * 0.8,
      family = base_family
    ),
    legend.title = ggplot2::element_text(
      size = base_size * 0.9,
      family = base_family
    ),
    legend.margin = ggplot2::margin(0, 0, 0, 0, "pt"),
    legend.text.align = NULL,
    legend.title.align = NULL,

    # Strip (facet) elements
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(
      size = base_size,
      family = base_family
    ),
    strip.text.x = ggplot2::element_text(
      margin = ggplot2::margin(b = base_size * 0.5, unit = "pt")
    ),
    strip.text.y = ggplot2::element_text(
      angle = -90,
      margin = ggplot2::margin(l = base_size * 0.5, unit = "pt")
    ),
    strip.placement = "inside",
    strip.switch.pad.grid = grid::unit(base_size * 0.5, "pt"),
    strip.switch.pad.wrap = grid::unit(base_size * 0.5, "pt"),

    # Complete theme
    complete = TRUE
  )
}


#' Dark Population Plot Theme
#'
#' A dark variant of theme_pop() with white text on black background.
#' Perfect for presentations or dark-mode visualizations.
#'
#' @inheritParams theme_pop
#' @param bg_color Background color (default: "black").
#' @param text_color Text color (default: "white").
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' ggplot(data = df, aes(icon = icon, color = type)) +
#'   geom_pop(size = 1) +
#'   theme_pop_dark(base_size = 40)
#' }
#'
#' @export
theme_pop_dark <- function(
  base_size = 11,
  base_family = "",
  base_line_size = base_size / 22,
  base_rect_size = base_size / 22,
  legend_icon_size = NULL,
  legend_spacing = NULL,
  plot_margin = NULL,
  legend_position = "right",
  bg_color = "black",
  text_color = "white"
) {
  theme_pop(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size,
    legend_icon_size = legend_icon_size,
    legend_spacing = legend_spacing,
    plot_margin = plot_margin,
    legend_position = legend_position
  ) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = bg_color, color = NA),
      panel.background = ggplot2::element_rect(fill = bg_color, color = NA),
      legend.background = ggplot2::element_rect(fill = bg_color, color = NA),
      text = ggplot2::element_text(color = text_color),
      plot.title = ggplot2::element_text(color = text_color),
      plot.subtitle = ggplot2::element_text(color = text_color),
      plot.caption = ggplot2::element_text(color = text_color),
      legend.text = ggplot2::element_text(color = text_color),
      legend.title = ggplot2::element_text(color = text_color),
      strip.text = ggplot2::element_text(color = text_color)
    )
}


#' Minimal Population Plot Theme
#'
#' An ultra-minimal variant with no margins or legend, perfect for
#' icon arrays without annotations.
#'
#' @inheritParams theme_pop
#'
#' @return A ggplot2 theme object.
#'
#' @examples
#' \dontrun{
#' ggplot(data = df, aes(icon = icon, color = type)) +
#'   geom_pop(size = 1) +
#'   theme_pop_minimal()
#' }
#'
#' @export
theme_pop_minimal <- function(
  base_size = 11,
  base_family = ""
) {
  theme_pop(
    base_size = base_size,
    base_family = base_family,
    legend_position = "none",
    plot_margin = ggplot2::margin(0, 0, 0, 0, "pt")
  ) +
    ggplot2::theme(
      plot.title = ggplot2::element_blank(),
      plot.subtitle = ggplot2::element_blank(),
      plot.caption = ggplot2::element_blank()
    )
}
