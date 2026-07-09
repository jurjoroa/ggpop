#' Build icon grid rows from plot data
#'
#' Derives the icon row/column positions from the unique combinations in
#' \code{df}, returning a plain data frame ready to \code{rbind()} with
#' group and symbol rows before passing to \code{\link{legend_canvas}}.
#'
#' @param df       Data frame used in the ggplot call.
#' @param icon     Column name holding icon names.
#' @param label    Column name holding cell labels.
#' @param row      Column whose unique values define grid rows.
#' @param col      Column whose unique values define grid columns.
#' @param label_fn Optional function applied to label values before display.
#' @param section  Value for the \code{section} column (default \code{"grid"}).
#'
#' @return A data frame with columns \code{section}, \code{type},
#'   \code{label}, \code{color}, \code{icon}, \code{row}, \code{col}.
#'   Rows are sorted by row then column (factor level order respected).
#'
#' @examples
#' \donttest{
#' # df_icons <- icon_grid(
#' #   df, icon = "icon", label = "AgeLabel",
#' #   row = "StartAge", col = "StopAge",
#' #   label_fn = function(x) gsub(" ", "", x)
#' # )
#' }
#'
#' @seealso \code{\link{legend_canvas}}
#' @export
icon_grid <- function(df, icon, label, row, col, label_fn = NULL, section = "grid") {
  if (!is.null(label_fn) && !is.function(label_fn))
    cli::cli_abort("{.arg label_fn} must be a function.")

  ordered_levels <- function(v) {
    if (is.factor(v)) levels(v)[levels(v) %in% as.character(v)] else sort(unique(v))
  }
  row_vals <- ordered_levels(df[[row]])
  col_vals <- ordered_levels(df[[col]])

  g <- unique(df[, c(row, col, icon, label)])
  g <- g[order(match(g[[row]], row_vals), match(g[[col]], col_vals)), ]

  labels <- as.character(g[[label]])
  if (!is.null(label_fn)) labels <- label_fn(labels)

  data.frame(
    section = section,
    type    = "icon",
    label   = labels,
    color   = NA_character_,
    icon    = as.character(g[[icon]]),
    row     = match(g[[row]], row_vals),
    col     = match(g[[col]], col_vals),
    stringsAsFactors = FALSE
  )
}


#' Build a composite legend from a plain data frame
#'
#' Renders a legend from a data frame that combines icon grid rows (built with
#' \code{\link{icon_grid}}), colour tile rows, and typed-symbol rows via
#' \code{rbind()}.  Layout parameters determine where each section is
#' positioned.  The \code{scale} parameter multiplies all size and spacing
#' values so the data frame can be written in round numbers.
#'
#' @param df_legend Data frame with columns \code{section}, \code{type},
#'   \code{label}, \code{color}, \code{icon}, \code{row}, \code{col}.
#'   Optional columns: \code{label_size}, \code{lineheight}.  \code{type}
#'   selects how a row renders and which columns it needs:
#'   \describe{
#'     \item{icon}{An icon marker (via \code{\link{geom_icon_point}}) placed
#'       at \code{row}/\code{col}.  Only meaningful inside \code{grid_section};
#'       requires \code{icon}, \code{row}, \code{col}.}
#'     \item{swatch}{A filled rectangle - colour tiles, frontier bands.
#'       Requires \code{color}.}
#'     \item{line}{A horizontal line segment - e.g. an efficient-frontier
#'       sample.  Requires \code{color}.}
#'     \item{point}{A bold \code{"*"} glyph (or a custom character via an
#'       optional \code{pch} column).  Requires \code{color}.}
#'   }
#'   \code{swatch}/\code{line}/\code{point} rows are rendered by
#'   \code{\link{key_legend}} - add a new type there, not here.  \code{icon}
#'   rows go through \code{\link{marker_legend}} instead, a separate path.
#' @param grid_section    Value of \code{section} identifying icon grid rows
#'   (default \code{"grid"}).
#' @param grid_title      Title drawn above the icon grid (\code{NULL} = none).
#' @param group_section   Value of \code{section} identifying colour tile rows.
#'   \code{NULL} skips the group section.
#' @param group_title     Title drawn above the colour tiles.  Inherits
#'   \code{group_section} when \code{NULL}.
#' @param group_width     Width of the colour tile section.
#' @param group_gap       Gap between the tile right edge and \code{x = 0}.
#' @param group_label_size Label size inside tiles; inherits \code{label_size}
#'   (after scaling) when \code{NA}.
#' @param group_label_color Label colour inside tiles (default \code{"white"}).
#' @param group_swatch_height Tile height as fraction of \code{row_spacing}
#'   (default \code{0.44}).
#' @param symbol_section  Value of \code{section} identifying typed-symbol rows.
#'   \code{NULL} skips the symbol section.
#' @param symbol_right_gap Gap between icon grid right edge and symbol section
#'   (default \code{0.30}).
#' @param symbol_key_width Width of the key symbol area (default \code{0.20}).
#' @param symbol_label_gap Gap between key symbol and label; inherits
#'   \code{label_gap} (after scaling) when \code{NULL}.
#' @param col_spacing Horizontal distance between icon grid columns.
#' @param row_spacing Vertical distance between rows.
#' @param label_gap   Default gap between key symbol and label.
#' @param marker_size Icon size for the grid.
#' @param label_size  Default label text size.
#' @param scale       Multiplier applied to \code{col_spacing},
#'   \code{row_spacing}, \code{label_gap}, \code{marker_size},
#'   \code{label_size}, and the \code{label_size} column in \code{df_legend}.
#'   Use to scale the whole legend without touching individual values (default
#'   \code{1}).
#' @param dpi     Icon render resolution (default \code{300}).
#' @param xlim    Length-2 numeric; x limits of the canvas.  Auto-computed
#'   when \code{NULL}.
#' @param ylim    Length-2 numeric; y limits of the canvas.  Auto-computed
#'   when \code{NULL}.
#' @param x_margin Length-2 numeric: left/right padding added to auto x range
#'   (default \code{c(0.10, 1.00)}).
#' @param y_margin Length-2 numeric: top/bottom padding as multiples of
#'   (scaled) \code{row_spacing} (default \code{c(0.6, 1.1)}).
#' @param clip    Passed to \code{coord_cartesian} (default \code{"off"}).
#'
#' @return A \code{ggplot} ready to save or pass to \code{\link{legend_strip}}.
#'
#' @seealso \code{\link{icon_grid}}, \code{\link{key_legend}},
#'   \code{\link{legend_strip}}
#' @importFrom ggplot2 coord_cartesian
#' @export
legend_canvas <- function(
  df_legend,
  grid_section        = "grid",
  grid_title          = NULL,
  group_section       = NULL,
  group_title         = NULL,
  group_width         = NULL,
  group_gap           = 0.08,
  group_label_size    = NA_real_,
  group_label_color   = "white",
  group_swatch_height = 0.44,
  symbol_section      = NULL,
  symbol_right_gap    = 0.30,
  symbol_key_width    = 0.20,
  symbol_label_gap    = NULL,
  col_spacing,
  row_spacing,
  label_gap,
  marker_size,
  label_size,
  scale    = 1,
  dpi      = 300,
  xlim     = NULL,
  ylim     = NULL,
  x_margin = c(0.10, 1.00),
  y_margin = c(0.6, 1.1),
  clip     = "off"
) {
  cs  <- col_spacing  * scale
  rs  <- row_spacing  * scale
  lg  <- label_gap    * scale
  ms  <- marker_size  * scale
  ls  <- label_size   * scale

  icon_rows   <- df_legend[df_legend$section == grid_section, ]
  n_cols      <- max(icon_rows$col, na.rm = TRUE)
  n_rows      <- max(icon_rows$row, na.rm = TRUE)
  grid_end    <- (n_cols - 1) * cs

  # ---- auto xlim / ylim ------------------------------------------------------
  if (is.null(xlim)) {
    x_left  <- if (!is.null(group_section) && !is.null(group_width))
                 -(group_width + group_gap) else 0
    x_right <- if (!is.null(symbol_section))
                 grid_end + symbol_right_gap + symbol_key_width
               else grid_end
    xlim <- c(x_left - x_margin[[1L]], x_right + x_margin[[2L]])
  }

  if (is.null(ylim)) {
    ylim <- c(-(n_rows - 1) * rs - rs * y_margin[[2L]],
               rs * 0.85 + rs * y_margin[[1L]])
  }

  # ---- icon grid (base canvas) -----------------------------------------------
  grid_entries <- data.frame(
    row   = as.integer(icon_rows$row),
    col   = as.integer(icon_rows$col),
    icon  = as.character(icon_rows$icon),
    label = as.character(icon_rows$label),
    stringsAsFactors = FALSE
  )

  p <- marker_legend(
    grid_entries,
    layout      = "grid",
    title       = grid_title,
    marker_size = ms,
    label_size  = ls,
    dpi         = dpi,
    col_spacing = cs,
    row_spacing = rs,
    label_gap   = lg
  ) + ggplot2::coord_cartesian(xlim = xlim, ylim = ylim, clip = clip)

  # ---- group / colour tiles --------------------------------------------------
  if (!is.null(group_section)) {
    grp <- df_legend[df_legend$section == group_section, ]
    if (is.null(group_width))
      cli::cli_abort("{.arg group_width} is required when {.arg group_section} is set.")
    grp_x     <- -(group_width + group_gap)
    grp_ls    <- if (is.na(group_label_size)) ls else group_label_size * scale

    grp_type <- if ("type" %in% names(grp)) as.character(grp$type) else rep(NA_character_, nrow(grp))
    grp_type[is.na(grp_type) | !nzchar(grp_type)] <- "swatch"

    grp_entries <- data.frame(
      type  = grp_type,
      label = as.character(grp$label),
      color = as.character(grp$color),
      stringsAsFactors = FALSE
    )

    p <- p + key_legend(
      grp_entries,
      x             = grp_x,
      y_start       = 0,
      title         = group_title %||% group_section,
      row_spacing   = rs,
      key_width     = group_width,
      label_gap     = lg,
      label_size    = grp_ls,
      label_inside  = TRUE,
      label_color   = group_label_color,
      title_color   = "black",
      swatch_height = group_swatch_height
    )
  }

  # ---- typed-symbol section --------------------------------------------------
  if (!is.null(symbol_section)) {
    sym <- df_legend[df_legend$section == symbol_section, ]
    sym_x  <- grid_end + symbol_right_gap
    sym_lg <- if (is.null(symbol_label_gap)) lg else symbol_label_gap * scale

    sym_entries <- data.frame(
      type  = as.character(sym$type),
      label = as.character(sym$label),
      color = as.character(sym$color),
      stringsAsFactors = FALSE
    )
    if ("label_size" %in% names(sym) && any(!is.na(sym$label_size)))
      sym_entries$label_size <- as.numeric(sym$label_size) * scale
    if ("lineheight"  %in% names(sym) && any(!is.na(sym$lineheight)))
      sym_entries$lineheight  <- as.numeric(sym$lineheight)

    p <- p + key_legend(
      sym_entries,
      x           = sym_x,
      row_spacing = rs,
      key_width   = symbol_key_width,
      label_gap   = sym_lg,
      label_size  = ls
    )
  }

  p
}
