#' Specify a composite legend with external colour keys
#'
#' Stores icon-grid rows, named colour keys, and typed symbol rows as content.
#' [legend_render()] lays out the content and fits its border at the requested
#' physical size. The specification can later be reused for related legends.
#'
#' @param grid A data frame from [icon_grid()].
#' @param keys Named character vector of colour values. Names are key labels.
#' @param symbols Named character vector of `"line"`, `"point"`, `"swatch"`, or
#'   `"text"` types, or a data frame accepted by [key_legend()]. A text row has
#'   a label but no visible key.
#' @param key_columns Number of colour-key columns, filled from top to bottom.
#' @param grid_title,group_title Optional titles for the icon grid and colour
#'   keys.
#' @param group_key_width,group_label_gap,swatch_height Dimensions of the
#'   external colour keys in grid coordinates. `swatch_height` is a fraction of
#'   one row.
#' @param group_gap Gap from the rightmost colour-key label to the icon grid.
#' @param key_column_gap Gap between colour-key columns.
#' @param group_title_nudge Horizontal adjustment to the centred group title.
#' @param xlim Optional fixed horizontal canvas limits. `NULL` centres the
#'   measured content automatically.
#' @param label_size Text size in millimetres.
#' @param marker_size Icon size passed to [geom_icon_point()].
#' @param dpi Icon rendering resolution.
#' @param ratios Layout proportions from [legend_ratios()].
#' @param border,border_padding Border colour and padding passed to
#'   [legend_box()]. Use `border = NA` to omit the border.
#'
#' @return A `ggpop_legend_spec` object to pass to [legend_render()].
#' @examples
#' grid <- data.frame(
#'   row = c(1, 2), col = c(1, 1),
#'   icon = c("square-inset", "circle-solid"),
#'   label = c("A", "B")
#' )
#' spec <- legend_spec(grid, keys = c(Group1 = "#1090F3", Group2 = "#DF4601"),
#'                     symbols = c(Frontier = "line"), key_columns = 2)
#' legend_render(spec, width = 7, height = 1.5)
#' @seealso [legend_canvas()], [legend_composite()]
#' @export
legend_spec <- function(grid, keys = NULL, symbols = NULL, key_columns = 1L,
                        grid_title = NULL, group_title = NULL,
                        group_key_width = 0.2375, group_label_gap = 0.1187,
                        group_gap = 0.591, key_column_gap = 0.317,
                        group_title_nudge = 0,
                        swatch_height = 0.56, xlim = NULL,
                        label_size = 3.634,
                        marker_size = 3.717, dpi = 120,
                        ratios = legend_ratios(), border = "#231F20",
                        border_padding = c(0.018, 0.09)) {
  if (!is.data.frame(grid) || !all(c("row", "col", "icon", "label") %in% names(grid)) ||
      !nrow(grid) || !is.numeric(grid$row) || !is.numeric(grid$col) ||
      anyNA(grid$row) || anyNA(grid$col) ||
      any(grid$row < 1) || any(grid$col < 1) ||
      any(grid$row %% 1 != 0) || any(grid$col %% 1 != 0)) {
    cli::cli_abort("{.arg grid} must contain positive row/col positions, icons, and labels.")
  }
  grid$section <- "grid"
  if (!is.null(keys) && (!is.character(keys) || is.null(names(keys)) ||
                        anyNA(keys) || any(!nzchar(keys)) ||
                        anyNA(names(keys)) || any(!nzchar(names(keys))))) {
    cli::cli_abort("{.arg keys} must be a named, nonempty character vector of colours.")
  }
  if (length(key_columns) != 1L || is.na(key_columns) ||
      !is.numeric(key_columns) || !is.finite(key_columns) ||
      key_columns < 1 || key_columns != as.integer(key_columns) ||
      (length(keys) && key_columns > length(keys))) {
    cli::cli_abort("{.arg key_columns} must be a positive integer no larger than the number of keys.")
  }
  dimensions <- c(group_key_width, group_label_gap, group_gap,
                  key_column_gap, swatch_height, label_size, marker_size, dpi)
  if (!is.numeric(dimensions) || length(dimensions) != 8L ||
      anyNA(dimensions) || any(!is.finite(dimensions)) ||
      any(dimensions <= 0)) {
    cli::cli_abort("Legend sizes and spacing must be positive finite numbers.")
  }
  if (!is.null(xlim) && (!is.numeric(xlim) || length(xlim) != 2L ||
                        anyNA(xlim) || any(!is.finite(xlim)) ||
                        xlim[1L] >= xlim[2L])) {
    cli::cli_abort("{.arg xlim} must be two increasing finite numbers.")
  }
  if (!is.numeric(group_title_nudge) || length(group_title_nudge) != 1L ||
      !is.finite(group_title_nudge)) {
    cli::cli_abort("{.arg group_title_nudge} must be one finite number.")
  }
  valid_border <- length(border) == 1L &&
    (is.na(border) || (is.character(border) && nzchar(border)))
  if (!valid_border ||
      !is.numeric(border_padding) || length(border_padding) != 2L ||
      anyNA(border_padding) || any(!is.finite(border_padding)) ||
      any(border_padding < 0)) {
    cli::cli_abort("{.arg border} and {.arg border_padding} must describe a valid border.")
  }

  if (is.character(symbols)) {
    if (is.null(names(symbols)) || any(!nzchar(names(symbols)))) {
      cli::cli_abort("Character {.arg symbols} must have labels as names.")
    }
    symbols <- data.frame(type = unname(symbols), label = names(symbols),
                          color = "black", stringsAsFactors = FALSE)
  }
  if (!is.null(symbols)) {
    if (is.data.frame(symbols) &&
        !"color" %in% names(symbols) && !"colour" %in% names(symbols)) {
      symbols$color <- "black"
    }
    symbols <- normalize_key_legend_entries(symbols)
  }

  structure(list(
    grid = grid, keys = keys, symbols = symbols,
    key_columns = as.integer(key_columns),
    grid_title = grid_title, group_title = group_title,
    group_key_width = group_key_width, group_label_gap = group_label_gap,
    group_gap = group_gap, key_column_gap = key_column_gap,
    group_title_nudge = group_title_nudge, xlim = xlim,
    swatch_height = swatch_height, label_size = label_size,
    marker_size = marker_size, dpi = dpi, ratios = ratios,
    border = border, border_padding = border_padding
  ), class = "ggpop_legend_spec")
}

#' Render a composite legend specification
#'
#' @param spec A [legend_spec()] object.
#' @param width,height Physical legend size in inches.
#'
#' @return A ggplot with a border fitted to the final content.
#' @examples
#' grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
#' spec <- legend_spec(grid, keys = c(Group = "#1090F3"))
#' legend_render(spec, width = 7, height = 1.5)
#' @seealso [legend_spec()]
#' @export
legend_render <- function(spec, width, height) {
  if (!inherits(spec, "ggpop_legend_spec")) {
    cli::cli_abort("{.arg spec} must come from {.fn legend_spec}.")
  }
  if (!is.numeric(width) || !is.numeric(height) ||
      length(width) != 1L || length(height) != 1L ||
      !is.finite(width) || !is.finite(height) || width <= 0 || height <= 0) {
    cli::cli_abort("{.arg width} and {.arg height} must be positive inches.")
  }

  grid <- spec$grid
  keys <- spec$keys
  symbols <- spec$symbols
  ratios <- spec$ratios
  n_grid_cols <- max(grid$col)
  n_grid_rows <- max(grid$row)
  grid_end <- (n_grid_cols - 1) * ratios$col_spacing
  symbol_x <- grid_end + ratios$symbol_right_gap

  # Translate text widths from physical inches to plot coordinates. The canvas
  # preserves the established grid pitch as its number of columns changes.
  x_range <- if (is.null(spec$xlim))
    (grid_end + 8.685) * width / 10.06 else diff(spec$xlim)
  to_data <- x_range / width
  text_width <- function(labels) {
    if (!length(labels)) return(numeric())
    vapply(as.character(labels), function(label) {
      grob <- grid::textGrob(label, gp = grid::gpar(
        fontsize = spec$label_size * 72.27 / 25.4
      ))
      grid::convertWidth(grid::grobWidth(grob), "in", valueOnly = TRUE) * to_data
    }, numeric(1))
  }

  key_x <- numeric()
  key_cols <- integer()
  key_rows <- integer()
  group_right <- -spec$group_gap
  if (length(keys)) {
    rows_per_col <- ceiling(length(keys) / spec$key_columns)
    key_cols <- ceiling(seq_along(keys) / rows_per_col)
    key_rows <- (seq_along(keys) - 1L) %% rows_per_col
    widths <- vapply(seq_len(spec$key_columns), function(col) {
      spec$group_key_width + spec$group_label_gap +
        max(text_width(names(keys)[key_cols == col]))
    }, numeric(1))
    key_x <- numeric(spec$key_columns)
    key_x[spec$key_columns] <- group_right - widths[spec$key_columns]
    if (spec$key_columns > 1L) {
      for (col in rev(seq_len(spec$key_columns - 1L))) {
        key_x[col] <- key_x[col + 1L] - spec$key_column_gap - widths[col]
      }
    }
  }

  group_title_x <- if (length(key_x))
    (min(key_x) + group_right) / 2 + spec$group_title_nudge else 0
  group_title_left <- if (length(key_x) && !is.null(spec$group_title))
    group_title_x - text_width(spec$group_title) / 2 else 0
  grid_right <- grid_end + ratios$label_gap + max(text_width(grid$label))
  symbol_right <- if (is.null(symbols) || !nrow(symbols)) 0 else
    symbol_x + ratios$symbol_key_width + ratios$symbol_label_gap +
      max(text_width(symbols$label))
  left_bound <- min(0, key_x, group_title_left)
  right_bound <- max(grid_right, symbol_right, group_right)
  x_range <- max(x_range, right_bound - left_bound + 1.2)
  center <- (left_bound + right_bound) / 2
  xlim <- if (is.null(spec$xlim)) center + c(-1, 1) * x_range / 2 else spec$xlim

  n_key_rows <- if (length(key_rows)) max(key_rows) + 1L else 0L
  n_symbol_rows <- if (is.null(symbols)) 0L else nrow(symbols)
  depth <- max(n_grid_rows - 1L, n_key_rows - 1L, n_symbol_rows - 2L, 0L)
  ylim <- c(-depth - 1.1, 1.95) * ratios$row_spacing

  p <- suppressMessages(legend_canvas(
    grid, grid_title = spec$grid_title,
    col_spacing = ratios$col_spacing, row_spacing = ratios$row_spacing,
    label_gap = ratios$label_gap, marker_size = spec$marker_size,
    label_size = spec$label_size, dpi = spec$dpi,
    xlim = xlim, ylim = ylim
  )) + ggplot2::scale_x_continuous(expand = c(0, 0)) +
    ggplot2::scale_y_continuous(expand = c(0, 0))

  if (length(keys)) {
    if (!is.null(spec$group_title)) {
      p <- p + ggplot2::annotate(
        "text", x = group_title_x, y = 0.85,
        label = spec$group_title, size = spec$label_size
      )
    }
    for (col in seq_len(spec$key_columns)) {
      selected <- key_cols == col
      entries <- data.frame(type = "swatch", label = names(keys)[selected],
                            color = unname(keys[selected]))
      p <- p + key_legend(
        entries, x = key_x[col], y_start = 0,
        row_spacing = ratios$row_spacing,
        key_width = spec$group_key_width,
        label_gap = spec$group_label_gap,
        label_size = spec$label_size,
        swatch_height = spec$swatch_height
      )
    }
  }
  if (!is.null(symbols) && nrow(symbols)) {
    p <- p + key_legend(
      symbols, x = symbol_x, row_spacing = ratios$row_spacing,
      key_width = ratios$symbol_key_width,
      label_gap = ratios$symbol_label_gap,
      label_size = spec$label_size
    )
  }
  if (is.na(spec$border)) return(p)
  legend_box(p, width = width, height = height,
             padding = spec$border_padding, colour = spec$border)
}

#' Select content from a composite legend specification
#'
#' Creates a new specification without changing `spec`. Grid rows are
#' renumbered from one so the selected grid stays compact. Render the result
#' with [legend_render()] after selecting its final content.
#'
#' @param spec A [legend_spec()] object.
#' @param grid_rows Grid row positions to keep, in display order. `NULL` keeps
#'   every row.
#' @param keys Names of colour keys to keep, in display order. `NULL` keeps all.
#' @param symbols Symbol labels to keep, in display order. `NULL` keeps all.
#' @param key_columns Number of colour-key columns in the result. When `keys`
#'   is supplied, the default is one; otherwise the original count is kept.
#' @param group_gap,group_title_nudge,xlim Optional layout overrides. Each
#'   inherits from `spec` when omitted. Set `xlim = NULL` to recompute the
#'   horizontal limits for the selected content.
#'
#' @return A new `ggpop_legend_spec` object.
#' @examples
#' grid <- data.frame(row = c(1, 2), col = c(1, 1),
#'                    icon = c("square-inset", "circle-solid"),
#'                    label = c("A", "B"))
#' spec <- legend_spec(grid, keys = c(One = "#1090F3", Two = "#DF4601"))
#' legend_subset(spec, grid_rows = 1, keys = "One")
#' @seealso [legend_spec()], [legend_add_key()], [legend_render()]
#' @export
legend_subset <- function(spec, grid_rows = NULL, keys = NULL, symbols = NULL,
                          key_columns = NULL, group_gap = spec$group_gap,
                          group_title_nudge = spec$group_title_nudge,
                          xlim = spec$xlim) {
  if (!inherits(spec, "ggpop_legend_spec")) {
    cli::cli_abort("{.arg spec} must come from {.fn legend_spec}.")
  }
  result <- spec

  if (!is.null(grid_rows)) {
    available <- unique(spec$grid$row)
    if (!is.numeric(grid_rows) || !length(grid_rows) || anyNA(grid_rows) ||
        anyDuplicated(grid_rows) ||
        any(!grid_rows %in% available)) {
      cli::cli_abort("{.arg grid_rows} must select existing grid rows once each.")
    }
    result$grid <- spec$grid[spec$grid$row %in% grid_rows, , drop = FALSE]
    result$grid$row <- match(result$grid$row, grid_rows)
  }
  if (!is.null(keys)) {
    if (!is.character(keys) || anyNA(keys) || anyDuplicated(keys) ||
        any(!keys %in% names(spec$keys))) {
      cli::cli_abort("{.arg keys} must select existing colour-key names once each.")
    }
    result$keys <- spec$keys[keys]
  }
  if (!is.null(symbols)) {
    if (!is.character(symbols) || anyNA(symbols) ||
        anyDuplicated(symbols) ||
        any(!symbols %in% spec$symbols$label)) {
      cli::cli_abort("{.arg symbols} must select existing symbol labels once each.")
    }
    result$symbols <- if (is.null(spec$symbols)) NULL else
      spec$symbols[match(symbols, spec$symbols$label), , drop = FALSE]
  }

  if (is.null(key_columns)) {
    key_columns <- if (is.null(keys)) spec$key_columns else 1L
  }
  if (!is.numeric(key_columns) || length(key_columns) != 1L ||
      !is.finite(key_columns) || key_columns < 1 ||
      key_columns != as.integer(key_columns) ||
      (length(result$keys) && key_columns > length(result$keys))) {
    cli::cli_abort("{.arg key_columns} must fit the selected colour keys.")
  }
  result$key_columns <- as.integer(key_columns)

  if (!is.numeric(group_gap) || length(group_gap) != 1L ||
      !is.finite(group_gap) || group_gap <= 0) {
    cli::cli_abort("{.arg group_gap} must be positive.")
  }
  if (!is.numeric(group_title_nudge) || length(group_title_nudge) != 1L ||
      !is.finite(group_title_nudge)) {
    cli::cli_abort("{.arg group_title_nudge} must be finite.")
  }
  if (!is.null(xlim) && (!is.numeric(xlim) || length(xlim) != 2L ||
                        anyNA(xlim) || any(!is.finite(xlim)) ||
                        xlim[1L] >= xlim[2L])) {
    cli::cli_abort("{.arg xlim} must be two increasing finite numbers.")
  }
  result$group_gap <- group_gap
  result$group_title_nudge <- group_title_nudge
  result$xlim <- xlim
  result
}

#' Add a typed symbol row to a composite legend specification
#'
#' The new row is appended to the symbol section without changing `spec`.
#' Render the returned specification to measure its border after the new row.
#'
#' @param spec A [legend_spec()] object.
#' @param label Text beside the symbol.
#' @param type One of `"line"`, `"point"`, `"swatch"`, or `"text"`.
#' @param colour Colour of the symbol.
#' @param linetype,linewidth Line style and width for a line row.
#' @param pch Character or numeric point glyph for a point row.
#'
#' @return A new `ggpop_legend_spec` object.
#' @examples
#' grid <- data.frame(row = 1, col = 1, icon = "square-inset", label = "A")
#' spec <- legend_spec(grid, symbols = c(Frontier = "line"))
#' legend_add_key(spec, "Capacity", type = "line", linetype = "dashed")
#' @seealso [legend_spec()], [legend_subset()], [legend_render()]
#' @export
legend_add_key <- function(spec, label, type = "line", colour = "black",
                           linetype = "solid", linewidth = 0.8, pch = NA) {
  if (!inherits(spec, "ggpop_legend_spec")) {
    cli::cli_abort("{.arg spec} must come from {.fn legend_spec}.")
  }
  if (!is.character(label) || length(label) != 1L ||
      is.na(label) || !nzchar(label) ||
      (!is.null(spec$symbols) && label %in% spec$symbols$label)) {
    cli::cli_abort("{.arg label} must be a new, nonempty symbol label.")
  }
  if (!is.character(colour) || length(colour) != 1L ||
      is.na(colour) || !nzchar(colour) ||
      !is.numeric(linewidth) || length(linewidth) != 1L ||
      !is.finite(linewidth) || linewidth <= 0) {
    cli::cli_abort("{.arg colour} and {.arg linewidth} must describe a visible key.")
  }
  entry <- data.frame(type = type, label = label, color = colour,
                      linetype = linetype, linewidth = linewidth, pch = pch,
                      stringsAsFactors = FALSE)
  entry <- normalize_key_legend_entries(entry)
  result <- spec
  result$symbols <- dplyr::bind_rows(spec$symbols, entry)
  result
}
