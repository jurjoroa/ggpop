#' Legend helper for geom_pop icon legends
#'
#' @param size Numeric. Legend key size (default 10).
#' @param margin ggplot2::margin() for plot margin (default margin_default).
#' @param size_default Numeric. Fallback size used when size is invalid (default 10).
#' @param margin_default ggplot2::margin() used when margin is NULL.
#' @param unit Character. Unit for legend key sizing (default "mm").
#' @param ... Additional arguments forwarded to ggplot2::guide_legend()
#' @export
scale_legend_icon <- function(
    size = 10,
    margin = NULL,
    size_default = 10,
    margin_default = ggplot2::margin(0, 0, 0, 0),
    unit = "mm",
    ...
) {
  structure(
    list(
      size = size,
      margin = margin,
      size_default = size_default,
      margin_default = margin_default,
      unit = unit,
      guide_args = list(...)
    ),
    class = "ggpop_legend_icon"
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
  
  plot
}
