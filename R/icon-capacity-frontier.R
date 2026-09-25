#' Build an icon frontier panel with a capacity threshold
#'
#' Draws a capacity band and threshold behind the frontier line and icon
#' points. Each entry in `label_sets` selects rows and supplies its own
#' arguments to [ggrepel::geom_text_repel()], while the common label styling
#' stays consistent. The input data determines which rows are on the frontier.
#'
#' @param data A nonempty data frame.
#' @param x,y Numeric columns for the horizontal and vertical axes.
#' @param icon Column of icon names accepted by [geom_icon_point()].
#' @param colour Column whose values are names in `palette`.
#' @param frontier Logical column or expression selecting the line rows.
#' @param label Column or expression containing text labels.
#' @param bold Logical column or expression selecting bold labels.
#' @param palette Named character vector of colours.
#' @param capacity Positive numeric threshold on the y axis.
#' @param label_sets A list of lists. Each inner list has a logical `rows`
#'   vector selecting labels and may include arguments to
#'   [ggrepel::geom_text_repel()], such as `nudge_y`, `direction`, or `ylim`.
#' @param capacity_label Text placed just below the threshold at the leftmost
#'   x value. `NULL` omits it.
#' @param capacity_label_offset Vertical distance below `capacity` for that
#'   label.
#' @param deliverable_label Italic text placed halfway up the capacity band.
#'   `NULL` omits it.
#' @param x_expand,y_expand Length-two multiplicative axis expansions.
#' @param xlab,ylab Axis titles.
#' @param icon_size,dpi Icon size and rendering resolution.
#' @param line_width,label_size Frontier line width and direct-label size.
#' @param x_breaks,y_breaks Break functions for each axis.
#' @param y_labels Label function for the y axis.
#' @param band_fill Fill colour below the capacity threshold.
#' @param capacity_colour Colour of the threshold and its annotation.
#' @param segment_colour Colour of label-repulsion segments.
#' @param plot_theme A ggplot theme. The default uses a 13-point classic theme
#'   with black axis text.
#'
#' @return A ggplot.
#' @examples
#' df_data <- data.frame(
#'   effect = 1:3, demand = c(100, 200, 350),
#'   icon = c("square-inset", "circle-hollow", "diamond-solid"),
#'   group = c("A", "B", "C"), frontier = c(TRUE, TRUE, FALSE),
#'   label = c("A", "B", "C"), bold = c(FALSE, TRUE, FALSE)
#' )
#' icon_capacity_frontier(
#'   df_data, x = effect, y = demand, icon = icon, colour = group,
#'   frontier = frontier, label = label, bold = bold,
#'   palette = c(A = "#1090F3", B = "#DF4601", C = "#08B8A2"),
#'   capacity = 250, label_sets = list(list(rows = df_data$frontier)),
#'   capacity_label = "Capacity", dpi = 120
#' )
#' @seealso [icon_frontiers()]
#' @export
icon_capacity_frontier <- function(
    data, x, y, icon, colour, frontier, label, bold, palette, capacity,
    label_sets, capacity_label = NULL, capacity_label_offset = 60,
    deliverable_label = NULL, x_expand = c(0.03, 0.08),
    y_expand = c(0, 0.04), xlab = NULL, ylab = NULL,
    icon_size = 1.4, dpi = 120, line_width = 0.6, label_size = 3.1,
    x_breaks = scales::breaks_pretty(8),
    y_breaks = scales::breaks_pretty(8),
    y_labels = scales::label_number(big.mark = ","),
    band_fill = "grey93", capacity_colour = "grey30",
    segment_colour = "grey55", plot_theme = NULL) {
  if (!is.data.frame(data) || !nrow(data)) {
    cli::cli_abort("{.arg data} must be a nonempty data frame.")
  }
  if (!is.character(palette) || !length(palette) ||
      is.null(names(palette)) || anyNA(palette) ||
      any(!nzchar(palette)) || anyNA(names(palette)) ||
      any(!nzchar(names(palette))) || anyDuplicated(names(palette))) {
    cli::cli_abort("{.arg palette} must be a named character vector of colours.")
  }
  if (!is.numeric(capacity) || length(capacity) != 1L ||
      !is.finite(capacity) || capacity <= 0) {
    cli::cli_abort("{.arg capacity} must be one positive finite number.")
  }
  if (!is.list(label_sets) || !length(label_sets)) {
    cli::cli_abort("{.arg label_sets} must be a nonempty list of row selections.")
  }
  if ((!is.null(capacity_label) &&
       (!is.character(capacity_label) || length(capacity_label) != 1L ||
        is.na(capacity_label))) ||
      (!is.null(deliverable_label) &&
       (!is.character(deliverable_label) || length(deliverable_label) != 1L ||
        is.na(deliverable_label)))) {
    cli::cli_abort("Capacity annotations must be one text label or NULL.")
  }
  if (!is.numeric(x_expand) || !is.numeric(y_expand) ||
      length(x_expand) != 2L || length(y_expand) != 2L ||
      anyNA(x_expand) || anyNA(y_expand) ||
      any(!is.finite(x_expand)) || any(!is.finite(y_expand))) {
    cli::cli_abort("{.arg x_expand} and {.arg y_expand} need two finite numbers each.")
  }
  sizes <- c(icon_size, dpi, line_width, label_size)
  if (!is.numeric(sizes) || length(sizes) != 4L ||
      anyNA(sizes) || any(!is.finite(sizes)) || any(sizes <= 0) ||
      !is.numeric(capacity_label_offset) ||
      length(capacity_label_offset) != 1L ||
      !is.finite(capacity_label_offset)) {
    cli::cli_abort("Plot sizes and capacity label offset must be finite numbers.")
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
  x_values <- rlang::eval_tidy(xq, data = data)
  y_values <- rlang::eval_tidy(yq, data = data)
  frontier_rows <- rlang::eval_tidy(frontierq, data = data)
  bold_rows <- rlang::eval_tidy(boldq, data = data)
  n <- nrow(data)
  if (!is.numeric(x_values) || !is.numeric(y_values) ||
      length(x_values) != n || length(y_values) != n ||
      anyNA(x_values) || anyNA(y_values) ||
      any(!is.finite(x_values)) || any(!is.finite(y_values)) ||
      !is.logical(frontier_rows) || length(frontier_rows) != n ||
      anyNA(frontier_rows) || !is.logical(bold_rows) ||
      length(bold_rows) != n || anyNA(bold_rows)) {
    cli::cli_abort("Axes must be numeric and {.arg frontier}/{.arg bold} must be complete logical vectors.")
  }
  df_frontier <- data[frontier_rows, , drop = FALSE]

  p <- ggplot2::ggplot(data, ggplot2::aes(x = !!xq, y = !!yq)) +
    ggplot2::annotate(
      "rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = capacity,
      fill = band_fill
    ) +
    ggplot2::geom_hline(
      yintercept = capacity, linetype = "dashed", colour = capacity_colour,
      linewidth = line_width
    ) +
    ggplot2::geom_line(data = df_frontier, linewidth = line_width) +
    geom_icon_point(
      ggplot2::aes(icon = !!iconq, colour = !!colourq),
      size = icon_size, dpi = dpi, show.legend = FALSE
    )

  for (label_set in label_sets) {
    if (!is.list(label_set) || is.null(label_set$rows) ||
        !is.logical(label_set$rows) || length(label_set$rows) != n ||
        anyNA(label_set$rows) || is.null(names(label_set)) ||
        any(!nzchar(names(label_set))) || anyDuplicated(names(label_set))) {
      cli::cli_abort("Each {.arg label_sets} entry needs a complete logical {.field rows} vector.")
    }
    df_labels <- data[label_set$rows, , drop = FALSE]
    label_options <- label_set[setdiff(names(label_set), "rows")]
    if (any(c("mapping", "data") %in% names(label_options))) {
      cli::cli_abort("{.arg label_sets} cannot replace label mappings or data.")
    }
    args <- list(
      mapping = ggplot2::aes(
        label = !!labelq, fontface = ifelse(!!boldq, "bold", "plain")
      ),
      data = df_labels, size = label_size,
      min.segment.length = 0, segment.colour = segment_colour,
      box.padding = 0.3, max.overlaps = Inf, seed = 1
    )
    args[names(label_options)] <- label_options
    p <- p + do.call(ggrepel::geom_text_repel, args)
  }

  if (!is.null(capacity_label)) {
    p <- p + ggplot2::annotate(
      "text", x = min(x_values), y = capacity - capacity_label_offset,
      vjust = 1, hjust = 0, size = label_size, colour = capacity_colour,
      lineheight = 0.9, label = capacity_label
    )
  }
  if (!is.null(deliverable_label)) {
    p <- p + ggplot2::annotate(
      "text", x = min(x_values), y = capacity / 2, hjust = 0,
      size = 3.4, fontface = "italic", colour = capacity_colour,
      label = deliverable_label
    )
  }

  p + ggplot2::scale_colour_manual(values = palette) +
    ggplot2::scale_x_continuous(
      breaks = x_breaks, expand = ggplot2::expansion(mult = x_expand)
    ) +
    ggplot2::scale_y_continuous(
      labels = y_labels, breaks = y_breaks,
      expand = ggplot2::expansion(mult = y_expand)
    ) +
    ggplot2::labs(x = xlab, y = ylab) + plot_theme
}
