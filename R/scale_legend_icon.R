#' Legend helper for geom_pop/geom_icon_point legends
#'
#' A convenience function to set appropriate legend key sizes for icon-based legends.
#' This is equivalent to using theme(legend.key.size = ...) but provides sensible
#' defaults for population icon plots.
#'
#' @param size Numeric. Legend key size in specified units (default 10).
#' @param unit Character. Unit for legend key sizing (default "mm").
#' @param spacing Numeric. Spacing between legend items as fraction of size (default 0.2).
#' @param size_multiplier Numeric. Multiplier to apply to the size for spacing calculations (default 2).
#' @param ... Additional theme arguments.
#'
#' @return A ggplot2 theme object that can be added to a plot.
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' df <- data.frame(
#'   type = rep(c("A", "B"), each = 10),
#'   icon = rep(c("circle", "square"), each = 10)
#' )
#' ggplot(df, aes(icon = icon, color = type)) +
#'   geom_pop() +
#'   scale_legend_icon(size = 20)
#' }
#'
#' @export
scale_legend_icon <- function(size = 10, unit = "mm", spacing = 0.2,
                              size_multiplier = 2, ...) {
  # Validate all parameters
  validated <- validate_scale_legend_icon(size, unit, spacing)

  # Apply multiplier to the validated size
  actual_size <- validated$size * size_multiplier

  # Return theme with multiplied size
  ggplot2::theme(
    legend.key.size = grid::unit(actual_size, validated$unit),
    legend.key.height = grid::unit(actual_size, validated$unit),
    legend.key.width = grid::unit(actual_size, validated$unit),
    legend.key = ggplot2::element_rect(fill = NA, colour = NA),
    legend.spacing.x = grid::unit(actual_size * validated$spacing, validated$unit),
    legend.spacing.y = grid::unit(actual_size * validated$spacing, validated$unit),
    ...
  )
}

#' @export
#' @importFrom ggplot2 ggplot_add
ggplot_add.ggpop_legend_icon <- function(object, plot, ...) {
  if (is.null(object$margin)) object$margin <- object$margin_default

  key_value <- object$size

  if (!is.numeric(key_value) || length(key_value) != 1 || is.na(key_value) || key_value <= 0) {
    key_value <- object$size_default
  }

  # Apply the theme changes now
  plot <- plot +
    ggplot2::theme(
      plot.margin = object$margin,
      legend.key.size = grid::unit(key_value, object$unit),
      legend.key.width = grid::unit(key_value, object$unit),
      legend.key.height = grid::unit(key_value, object$unit)
    )

  plot
}


#' @export
ggplot_add.ggpop_geom_pop <- function(object, plot, object_name, ...) {
  # add the layer
  plot <- plot + object$layer

  # Expose geom_pop's internally computed coordinates (x1, y1) so that
  # downstream layers (geom_text, geom_label, etc.) can inherit x and y
  # without the user specifying them explicitly.
  if (!is.null(object$df_pop)) {
    plot$data <- object$df_pop
    plot$mapping[["icon"]] <- NULL                        # consumed by geom_pop
    if (!"x" %in% names(plot$mapping)) plot$mapping[["x"]] <- as.name("x1")
    if (!"y" %in% names(plot$mapping)) plot$mapping[["y"]] <- as.name("y1")
  }

  # When alpha is mapped, inject scale_alpha_identity() so ggplot2 passes raw
  # values through unchanged rather than rescaling via scale_alpha_continuous.
  # Only inject if no alpha scale has been added yet by the user.
  if (isTRUE(object$has_alpha_mapping) && is.null(plot$scales$get_scales("alpha"))) {
    plot <- plot + ggplot2::scale_alpha_identity()
  }

  # If geom_pop had an explicit facet=, automatically add facet_wrap(~facet_col)
  if (!is.null(object$facet_col) && nzchar(object$facet_col)) {
    # If plot already has a facet, do not override it
    if (!inherits(plot$facet, "FacetNull")) {
      return(plot)
    }

    fml <- stats::as.formula(paste0("~", object$facet_col))
    plot <- plot + ggplot2::facet_wrap(fml)
  }

  plot
}


#' @export
#' @importFrom ggplot2 ggplot_add
ggplot_add.ggpop_icon_point_layer <- function(object, plot, object_name, ...) {
  plot$layers <- append(plot$layers, list(object))

  vals <- vapply(plot$layers, function(l) {
    if (inherits(l, "ggpop_icon_point_layer") &&
      identical(l$ggpop_layer_type, "icon_point")) {
      isTRUE(l$ggpop_legend_icons)
    } else {
      NA
    }
  }, logical(1), USE.NAMES = FALSE)

  vals <- vals[!is.na(vals)]

  if (length(vals) > 1 && any(vals) && any(!vals)) {
    cli::cli_abort(
      c(
        "{.fn geom_icon_point}: mixed {.field legend_icons} settings detected.",
        "x" = "Some {.fn geom_icon_point} layers use {.val TRUE} and others use {.val FALSE}.",
        "i" = "Use consistent settings across all {.fn geom_icon_point} layers."
      ),
      call = NULL
    )
  }

  # When alpha is mapped in any icon_point layer, inject scale_alpha_identity()
  # so ggplot2 passes raw values through unchanged instead of rescaling.
  # Only inject if no alpha scale has been added yet by the user.
  has_alpha <- any(vapply(plot$layers, function(l) {
    isTRUE(l$ggpop_has_alpha_mapping)
  }, logical(1), USE.NAMES = FALSE))

  if (has_alpha && is.null(plot$scales$get_scales("alpha"))) {
    plot <- plot + ggplot2::scale_alpha_identity()
  }

  plot
}
