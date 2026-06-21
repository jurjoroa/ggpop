#' Build a standalone composite legend of icon markers
#'
#' @description
#' For an ordinary legend keyed to your plot data you do \strong{not} need this
#' function - map an aesthetic and let ggplot2 build the legend natively:
#' \code{geom_icon_point(..., legend_icons = TRUE) + scale_legend_icon()}.
#'
#' Use \code{marker_legend()} only for a \emph{standalone composite} legend that
#' ggplot2's guide system cannot express - a multi-column grouped legend
#' decoupled from any plot, often combined with extra annotations and exported
#' at fixed pixel dimensions (for example the screening-strategy
#' \code{Legend_*.png} figures).
#'
#' @details
#' Lays out icon + label entries into a self-contained \code{ggplot} object.
#' Each entry is drawn with \code{\link{geom_icon_point}}, so any icon source is
#' accepted - Font Awesome names, bundled ggpop markers, or user-supplied
#' \code{.svg} paths (see \code{\link{ggpop_markers}}) - and the three may be
#' mixed in a single legend. The result is a plain \code{ggplot} you can extend
#' with further \code{ggplot2::annotate()} layers (frontier segments, colour
#' bands, asterisks) and export at any size with \code{ggplot2::ggsave()}.
#'
#' @param entries A data frame of legend rows. Must contain an \code{icon}
#'   column (icon source per row) and a \code{label} column (text shown beside
#'   the marker). An optional \code{colour} (or \code{color}) column sets the
#'   marker colour per row as a literal value. For \code{layout = "grid"} the
#'   data frame must also contain integer \code{row} and \code{col} columns.
#' @param layout Legend arrangement. \code{"column"} (default) auto-arranges
#'   the rows into \code{ncol} columns, filling each column top to bottom.
#'   \code{"grid"} places each entry at its explicit \code{row}/\code{col} cell.
#' @param ncol Number of columns for \code{layout = "column"}. Ignored when an
#'   explicit \code{column} field is supplied in \code{entries}.
#' @param title Optional bold title drawn centred above the legend.
#' @param marker_size Icon size passed to \code{\link{geom_icon_point}}.
#' @param label_size Text size for the labels.
#' @param dpi Icon rendering resolution passed to \code{\link{geom_icon_point}}.
#' @param icon_path Optional folder of user \code{.svg} markers, referenced by
#'   bare name in the \code{icon} column. See \code{\link{geom_icon_point}}.
#' @param col_spacing Horizontal distance between columns.
#' @param row_spacing Vertical distance between rows.
#' @param label_gap Horizontal gap between a marker and its label.
#' @param default_color Marker colour used for rows with no \code{colour} value.
#'
#' @return A \code{ggplot} object with \code{theme_void()} applied.
#'
#' @examples
#' \donttest{
#' # For a normal data-driven legend, prefer the native path instead:
#' #   geom_icon_point(aes(icon = icon, colour = group), legend_icons = TRUE) +
#' #   scale_legend_icon()
#'
#' # marker_legend() is for a STANDALONE composite legend - here two semantic
#' # colour-columns, the kind ggplot2 guides cannot produce in one figure.
#' df_legend <- data.frame(
#'   column = c(1, 1, 2, 2),
#'   icon   = c("square-inset", "circle-solid", "square-hollow", "diamond-cross"),
#'   label  = c("Start 45y", "Start 50y", "Stop 75y", "Stop 80y"),
#'   colour = c("#FF1493", "#FF1493", "#006400", "#006400"),
#'   stringsAsFactors = FALSE
#' )
#' marker_legend(df_legend, col_spacing = 12)
#' }
#'
#' @seealso \code{\link{geom_icon_point}}, \code{\link{ggpop_markers}}
#' @export
marker_legend <- function(entries,
                          layout = c("column", "grid"),
                          ncol = 1,
                          title = NULL,
                          marker_size = 3,
                          label_size = 2.8,
                          dpi = 300,
                          icon_path = NULL,
                          col_spacing = 10,
                          row_spacing = 1,
                          label_gap = 0.6,
                          default_color = "black") {
  layout <- match.arg(layout)
  validate_marker_legend_entries(entries, layout)

  df_pos <- resolve_marker_legend_layout(
    entries,
    layout = layout,
    ncol = ncol,
    col_spacing = col_spacing,
    row_spacing = row_spacing,
    default_color = default_color
  )

  p <- ggplot2::ggplot() +
    geom_icon_point(
      data = df_pos,
      mapping = ggplot2::aes(x = x, y = y, icon = icon, colour = colour),
      size = marker_size,
      dpi = dpi,
      icon_path = icon_path,
      legend_icons = FALSE,
      show.legend = FALSE
    ) +
    ggplot2::geom_text(
      data = df_pos,
      mapping = ggplot2::aes(x = x + label_gap, y = y, label = label),
      hjust = 0,
      size = label_size
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::theme_void()

  # Layout-derived limits keep the marker-to-label gap stable across any number
  # of columns/rows; clip = "off" lets long labels overflow into the margin.
  x_min <- min(df_pos$x)
  x_max <- max(df_pos$x)
  y_min <- min(df_pos$y)
  y_max <- max(df_pos$y)
  has_title <- !is.null(title)

  p <- p +
    ggplot2::coord_cartesian(
      xlim = c(x_min - col_spacing * 0.2, x_max + col_spacing),
      ylim = c(y_min - row_spacing, y_max + row_spacing * (if (has_title) 1.8 else 0.6)),
      clip = "off"
    )

  if (has_title) {
    p <- p +
      ggplot2::annotate(
        "text",
        x = x_min,
        y = y_max + row_spacing * 1.4,
        label = title,
        hjust = 0,
        fontface = "bold",
        size = label_size * 1.3
      )
  }

  p
}

# *****************************************************************************
# Internal helpers ------------------------------------------------------------
# *****************************************************************************

#' Validate the entries data frame for marker_legend()
#'
#' @param entries Candidate entries data frame.
#' @param layout Resolved layout string.
#' @return Invisibly \code{TRUE}; aborts otherwise.
#' @keywords internal
#' @noRd
validate_marker_legend_entries <- function(entries, layout) {
  if (!is.data.frame(entries)) {
    cli::cli_abort(c(
      "{.arg entries} must be a data frame.",
      x = "You supplied {.cls {class(entries)}}."
    ))
  }
  required <- c("icon", "label")
  if (layout == "grid") {
    required <- c(required, "row", "col")
  }
  missing <- setdiff(required, names(entries))
  if (length(missing) > 0) {
    cli::cli_abort(c(
      "{.arg entries} is missing required column{?s}: {.field {missing}}.",
      i = "For {.val grid} layout, supply integer {.field row} and {.field col} columns."
    ))
  }
  if (nrow(entries) == 0) {
    cli::cli_abort("{.arg entries} has no rows.")
  }
  invisible(TRUE)
}

#' Compute x/y positions and a colour column for the legend entries
#'
#' @param entries Validated entries data frame.
#' @param layout Resolved layout string.
#' @param ncol Number of columns for column layout.
#' @param col_spacing Horizontal column distance.
#' @param row_spacing Vertical row distance.
#' @param default_color Fallback marker colour.
#' @return A data frame with \code{x}, \code{y}, \code{icon}, \code{label},
#'   \code{colour} columns.
#' @keywords internal
#' @noRd
resolve_marker_legend_layout <- function(entries, layout, ncol,
                                         col_spacing, row_spacing,
                                         default_color) {
  df_pos <- entries

  # Per-row colour: colour > color > default, taken literally (identity scale)
  if ("colour" %in% names(df_pos)) {
    v_colour <- as.character(df_pos$colour)
  } else if ("color" %in% names(df_pos)) {
    v_colour <- as.character(df_pos$color)
  } else {
    v_colour <- rep(default_color, nrow(df_pos))
  }
  v_colour[is.na(v_colour) | !nzchar(v_colour)] <- default_color
  df_pos$colour <- v_colour

  if (layout == "grid") {
    df_pos$x <- (as.integer(df_pos$col) - 1L) * col_spacing
    df_pos$y <- -(as.integer(df_pos$row) - 1L) * row_spacing
    return(df_pos)
  }

  # Column layout: honour an explicit `column` field, else auto-fill ncol.
  n <- nrow(df_pos)
  if ("column" %in% names(df_pos)) {
    v_col <- as.integer(df_pos$column)
  } else {
    per_col <- ceiling(n / max(ncol, 1L))
    v_col <- ((seq_len(n) - 1L) %/% per_col) + 1L
  }
  df_pos$column <- v_col

  # Row index within each column, in input order.
  v_row <- integer(n)
  for (cc in unique(v_col)) {
    idx <- which(v_col == cc)
    v_row[idx] <- seq_along(idx)
  }

  df_pos$x <- (v_col - 1L) * col_spacing
  df_pos$y <- -(v_row - 1L) * row_spacing
  df_pos
}
