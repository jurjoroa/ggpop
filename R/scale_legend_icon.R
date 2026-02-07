#' Legend helper for geom_pop icon legends
#'
#' @param size Numeric. Legend key size in mm (this controls icon size).
#' @param margin ggplot2::margin() for plot margin (defaults to bottom padding).
#' @param ... Additional arguments forwarded to ggplot2::guide_legend()
#' @export
scale_legend_icon <- function(size = 10, margin = NULL, ...) {
  structure(
    list(
      size = size,
      margin = margin,
      guide_args = list(...)
    ),
    class = "ggpop_legend_icon"
  )
}

#' @export
#' @importFrom ggplot2 ggplot_add
ggplot_add.ggpop_legend_icon <- function(object, plot, ...) {
  if (is.null(object$margin)) object$margin <- ggplot2::margin(0, 0, 0, 0)

  key_mm <- object$size

  if (!is.numeric(key_mm) || length(key_mm) != 1 || is.na(key_mm) || key_mm <= 0) key_mm <- 10

  # Apply the theme changes now
  plot <- plot +
    ggplot2::theme(
      plot.margin = object$margin,
      legend.key.size = grid::unit(key_mm, "mm"),
      legend.key.width = grid::unit(key_mm, "mm"),
      legend.key.height = grid::unit(key_mm, "mm")
    )

  plot
}


#' @export
ggplot_add.ggpop_geom_pop <- function(object, plot, object_name, ...) {
  # add the layer
  plot <- plot + object$layer

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
ggplot_add.ggpop_icon_point_layer <- function(object, plot, object_name) {
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
  
  plot
}