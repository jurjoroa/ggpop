#' Attach a legend strip below a ggplot
#'
#' Returns a \code{ggpop_legend_strip} object. When added to a \code{ggplot}
#' with \code{+}, produces a \code{ggpop_composite} that stacks the main plot
#' above the strip at the specified physical height.  The composite works with
#' \code{ggplot2::ggsave()} and \code{print()}.  The main plot (the object
#' \code{legend_strip()} is added to) may itself be a \code{patchwork} object
#' (e.g. several panels combined with \code{+}/\code{\link[patchwork]{plot_layout}})
#' - this requires the \pkg{patchwork} package to be installed.
#'
#' @param strip_plot A \code{ggplot} to render as the bottom strip (e.g. the
#'   output of \code{\link{marker_legend}}).
#' @param height Height of the strip in inches.
#'
#' @return A \code{ggpop_legend_strip} object; add it to a \code{ggplot} with
#'   \code{+}.
#'
#' @examples
#' \donttest{
#' # p_legend <- marker_legend(entries, ...) + key_legend(...)
#' # p_full   <- p_scatter + legend_strip(p_legend, height = 1.326)
#' # ggplot2::ggsave("out.png", p_full, width = 10.5, height = 8.826, dpi = 150)
#' }
#'
#' @seealso \code{\link{marker_legend}}, \code{\link{key_legend}}
#' @importFrom ggplot2 ggplot_add
#' @export
legend_strip <- function(strip_plot, height) {
  structure(
    list(strip_plot = strip_plot, height = height),
    class = "ggpop_legend_strip"
  )
}

#' @export
ggplot_add.ggpop_legend_strip <- function(object, plot, object_name, ...) {
  structure(
    list(main = plot, strip = object$strip_plot, strip_height = object$height),
    class = "ggpop_composite"
  )
}

#' @export
print.ggpop_composite <- function(x, ...) {
  grid::grid.newpage()
  draw_composite(x)
  invisible(x)
}

#' @export
#' @importFrom grid grid.draw
grid.draw.ggpop_composite <- function(x, recording = TRUE) {
  draw_composite(x)
}

# ---- Internal ---------------------------------------------------------------

draw_composite <- function(x) {
  g_main  <- composite_grob(x$main)
  g_strip <- composite_grob(x$strip)

  grid::pushViewport(grid::viewport(
    layout = grid::grid.layout(
      nrow    = 2,
      heights = grid::unit.c(
        grid::unit(1, "null"),
        grid::unit(x$strip_height, "in")
      )
    )
  ))
  grid::pushViewport(grid::viewport(layout.pos.row = 1))
  grid::grid.draw(g_main)
  grid::popViewport()

  grid::pushViewport(grid::viewport(layout.pos.row = 2))
  grid::grid.draw(g_strip)
  grid::popViewport()
  grid::popViewport()
}

composite_grob <- function(p) {
  if (!inherits(p, "patchwork")) return(ggplot2::ggplotGrob(p))

  if (!requireNamespace("patchwork", quietly = TRUE)) {
    cli::cli_abort(c(
      "A {.cls patchwork} object was passed to {.fn legend_strip}, which requires the {.pkg patchwork} package.",
      i = "Install it with {.code install.packages(\"patchwork\")}."
    ))
  }
  # ggplot2::ggplotGrob() only sees a patchwork object's base ggplot fields
  # and silently renders just the last panel, stretched full-width - the
  # patchwork-aware grob converter is required to capture every panel.
  patchwork::patchworkGrob(p)
}
