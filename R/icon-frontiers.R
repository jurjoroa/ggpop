#' Build matching icon frontier panels from named datasets
#'
#' Applies the same line, icon, label, scale, and theme settings to each data
#' frame. The `frontier` expression and label nudges are evaluated separately
#' for each frame, so panels keep their own efficient strategies and ranges.
#'
#' @param data A named, nonempty list of data frames.
#' @param x,y Numeric columns for the horizontal and vertical axes.
#' @param icon Column of icon names accepted by [geom_icon_point()].
#' @param colour Column whose values are names in `palette`.
#' @param frontier Logical expression selecting the rows joined by the line
#'   and given direct labels.
#' @param label Column or expression containing direct text labels.
#' @param bold Logical column or expression selecting bold labels.
#' @param palette Named character vector of colours.
#' @param label_nudge Length-two numeric vector of x/y nudges as fractions of
#'   each frame's x/y ranges.
#' @param x_expand Length-two multiplicative expansion for the x axis.
#' @param y_labels Label function for the y axis.
#' @param xlab,ylab Axis titles.
#' @param icon_size,dpi Icon size and rendering resolution.
#' @param line_width,label_size Frontier line width and direct-label size.
#' @param x_breaks,y_breaks Break functions for each axis.
#' @param plot_theme A ggplot theme. The default uses a 13-point classic theme
#'   with black axis text.
#'
#' @return A named list of ggplots in the same order as `data`.
#' @examples
#' df_a <- data.frame(x = 1:2, y = 1:2, icon = c("square-inset", "circle-solid"),
#'                    group = c("A", "B"), status = c(TRUE, TRUE),
#'                    label = c("A", "B"), bold = c(FALSE, TRUE))
#' df_b <- transform(df_a, y = y * 2)
#' plots <- icon_frontiers(
#'   list(a = df_a, b = df_b), x = x, y = y, icon = icon, colour = group,
#'   frontier = status, label = label, bold = bold,
#'   palette = c(A = "#1090F3", B = "#DF4601"), dpi = 120
#' )
#' @seealso [geom_icon_point()]
#' @export
icon_frontiers <- function(data, x, y, icon, colour, frontier, label, bold,
                           palette, label_nudge = c(0.012, -0.018),
                           x_expand = c(0.03, 0.16),
                           y_labels = scales::label_number(big.mark = ","),
                           xlab = NULL, ylab = NULL,
                           icon_size = 1.4, dpi = 120,
                           line_width = 0.6, label_size = 3.1,
                           x_breaks = scales::breaks_pretty(8),
                           y_breaks = scales::breaks_pretty(8),
                           plot_theme = NULL) {
  if (!is.list(data) || !length(data) || is.null(names(data)) ||
      anyNA(names(data)) || any(!nzchar(names(data))) ||
      anyDuplicated(names(data)) ||
      !all(vapply(data, is.data.frame, logical(1)))) {
    cli::cli_abort("{.arg data} must be a named, nonempty list of data frames.")
  }
  if (!is.character(palette) || !length(palette) ||
      is.null(names(palette)) || anyNA(palette) ||
      any(!nzchar(palette)) ||
      anyNA(names(palette)) || any(!nzchar(names(palette))) ||
      anyDuplicated(names(palette))) {
    cli::cli_abort("{.arg palette} must be a named character vector of colours.")
  }
  if (!is.numeric(label_nudge) || length(label_nudge) != 2L ||
      anyNA(label_nudge) || any(!is.finite(label_nudge)) ||
      !is.numeric(x_expand) || length(x_expand) != 2L ||
      anyNA(x_expand) || any(!is.finite(x_expand))) {
    cli::cli_abort("{.arg label_nudge} and {.arg x_expand} must each have two finite numbers.")
  }
  sizes <- c(icon_size, dpi, line_width, label_size)
  if (!is.numeric(sizes) || length(sizes) != 4L ||
      anyNA(sizes) || any(!is.finite(sizes)) || any(sizes <= 0)) {
    cli::cli_abort("Icon, line, and label sizes must be positive finite numbers.")
  }
  if (is.null(plot_theme)) {
    plot_theme <- ggplot2::theme_classic(base_size = 13) +
      ggplot2::theme(axis.text = ggplot2::element_text(colour = "black"))
  }

  xq <- rlang::enquo(x)
  yq <- rlang::enquo(y)
  iconq <- rlang::enquo(icon)
  colourq <- rlang::enquo(colour)
  frontierq <- rlang::enquo(frontier)
  labelq <- rlang::enquo(label)
  boldq <- rlang::enquo(bold)

  lapply(data, function(df_data) {
    n <- nrow(df_data)
    if (!n) cli::cli_abort("Each data frame in {.arg data} must have rows.")
    x_values <- rlang::eval_tidy(xq, data = df_data)
    y_values <- rlang::eval_tidy(yq, data = df_data)
    frontier_rows <- rlang::eval_tidy(frontierq, data = df_data)
    bold_rows <- rlang::eval_tidy(boldq, data = df_data)
    if (!is.numeric(x_values) || !is.numeric(y_values) ||
        length(x_values) != n || length(y_values) != n ||
        anyNA(x_values) || anyNA(y_values) ||
        any(!is.finite(x_values)) || any(!is.finite(y_values)) ||
        !is.logical(frontier_rows) || length(frontier_rows) != n ||
        anyNA(frontier_rows) ||
        !is.logical(bold_rows) || length(bold_rows) != n ||
        anyNA(bold_rows)) {
      cli::cli_abort("Frontier axes must be numeric and {.arg frontier}/{.arg bold} must be complete logical vectors.")
    }
    df_frontier <- df_data[frontier_rows, , drop = FALSE]

    ggplot2::ggplot(df_data, ggplot2::aes(x = !!xq, y = !!yq)) +
      ggplot2::geom_line(data = df_frontier, linewidth = line_width) +
      geom_icon_point(
        ggplot2::aes(icon = !!iconq, colour = !!colourq),
        size = icon_size, dpi = dpi, show.legend = FALSE
      ) +
      ggplot2::geom_text(
        ggplot2::aes(label = !!labelq,
                     fontface = ifelse(!!boldq, "bold", "plain")),
        data = df_frontier, hjust = 0, vjust = 1, size = label_size,
        nudge_x = label_nudge[[1L]] * diff(range(x_values)),
        nudge_y = label_nudge[[2L]] * diff(range(y_values))
      ) +
      ggplot2::scale_colour_manual(values = palette) +
      ggplot2::scale_x_continuous(
        breaks = x_breaks, expand = ggplot2::expansion(mult = x_expand)
      ) +
      ggplot2::scale_y_continuous(labels = y_labels, breaks = y_breaks) +
      ggplot2::labs(x = xlab, y = ylab) +
      plot_theme
  })
}
