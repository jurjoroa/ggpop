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
#' @param group_width     Width of the colour tile section (scaled by
#'   \code{scale}).
#' @param group_gap       Gap between the tile right edge and \code{x = 0}
#'   (scaled by \code{scale}).
#' @param group_label_size Label size inside tiles; inherits \code{label_size}
#'   (after scaling) when \code{NA}.
#' @param group_label_color Label colour inside tiles (default \code{"white"}).
#' @param group_swatch_height Tile height as fraction of \code{row_spacing}
#'   (default \code{0.44}).
#' @param symbol_section  Value of \code{section} identifying typed-symbol rows.
#'   \code{NULL} skips the symbol section.
#' @param symbol_right_gap Gap between icon grid right edge and symbol section
#'   (default \code{0.30}; scaled by \code{scale}).
#' @param symbol_key_width Width of the key symbol area (default \code{0.20};
#'   scaled by \code{scale}).
#' @param symbol_label_gap Gap between key symbol and label; inherits
#'   \code{label_gap} (after scaling) when \code{NULL}.
#' @param col_spacing Horizontal distance between icon grid columns.
#' @param row_spacing Vertical distance between rows.
#' @param label_gap   Default gap between key symbol and label.
#' @param marker_size Icon size for the grid.
#' @param label_size  Default label text size.
#' @param label_fontface Font face for every title and label in the legend
#'   (grid title, group title/tile labels, symbol title/labels) - default
#'   \code{"plain"}.  Common values: \code{"plain"}, \code{"bold"},
#'   \code{"italic"}.  Does not affect the \code{"point"}-type \code{"*"}
#'   glyph, which is always bold.
#' @param scale       Multiplier applied to every length and size:
#'   \code{col_spacing}, \code{row_spacing}, \code{label_gap},
#'   \code{marker_size}, \code{label_size} (and its \code{df_legend} column),
#'   \code{group_width}, \code{group_gap}, \code{group_label_size},
#'   \code{symbol_right_gap}, \code{symbol_key_width}, and
#'   \code{symbol_label_gap}.  Because it scales the whole legend uniformly,
#'   every length can be written as a plain multiple of one base module and
#'   \code{scale} sizes the result (default \code{1}).
#' @param label_scale Extra multiplier applied on top of \code{scale} to the
#'   text sizes only - \code{label_size}, \code{group_label_size}, and the
#'   \code{label_size} column in \code{df_legend} - leaving marker and spacing
#'   sizes untouched.  Use to enlarge/shrink every label relative to the
#'   markers from one place (default \code{1}).
#' @param dpi     Icon render resolution (default \code{300}).
#' @param xlim    Length-2 numeric; x limits of the canvas.  Auto-computed
#'   when \code{NULL}.
#' @param ylim    Length-2 numeric; y limits of the canvas.  Auto-computed
#'   when \code{NULL} to enclose whichever section reaches deepest - the grid
#'   rows, the group tiles, or the symbol keys - so a group/symbol block with
#'   more entries than the grid has rows is not clipped.
#' @param x_margin Length-2 numeric: left/right padding added to auto x range
#'   (default \code{c(1.00, 1.00)}, i.e. centred).  Ignored when \code{xlim}
#'   is supplied directly; overridden when \code{align} is set.  A
#'   \code{symbol_section}'s labels extend right of \code{x_right} with no
#'   accounting for label width, so the default is sized generously enough
#'   to hold typical labels without clipping - not the smallest margin that
#'   centres the nominal content bounds.
#' @param align Optional convenience for biasing \code{x_margin}: one of
#'   \code{"center"} (equal left/right padding), \code{"left"} (small left /
#'   large right padding), or \code{"right"} (large left / small right
#'   padding).  Redistributes \code{sum(x_margin)} between the two sides -
#'   the total padding is unchanged, only its left/right split.  \code{NULL}
#'   (default) leaves \code{x_margin} untouched.
#' @param y_margin Length-2 numeric: top/bottom padding as multiples of
#'   (scaled) \code{row_spacing} (default \code{c(1.1, 1.1)}, i.e. centred).
#'   Ignored when \code{ylim} is supplied directly; overridden when
#'   \code{valign} is set.
#' @param valign Optional convenience for biasing \code{y_margin}: one of
#'   \code{"center"} (equal top/bottom padding), \code{"top"} (small top /
#'   large bottom padding), or \code{"bottom"} (large top / small bottom
#'   padding).  Redistributes \code{sum(y_margin)} between the two sides,
#'   the same way \code{align} redistributes \code{x_margin}.  \code{NULL}
#'   (default) leaves \code{y_margin} untouched.
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
  label_fontface = "plain",
  scale       = 1,
  label_scale = 1,
  dpi      = 300,
  xlim     = NULL,
  ylim     = NULL,
  x_margin = c(1.00, 1.00),
  align    = NULL,
  y_margin = c(1.1, 1.1),
  valign   = NULL,
  clip     = "off"
) {
  cs  <- col_spacing  * scale
  rs  <- row_spacing  * scale
  lg  <- label_gap    * scale
  ms  <- marker_size  * scale
  ls  <- label_size   * scale * label_scale

  # Group/symbol section lengths scale with the grid too, so `scale` sizes the
  # whole legend uniformly (every length is in one unit).
  gw  <- if (is.null(group_width)) NULL else group_width * scale
  gg  <- group_gap        * scale
  srg <- symbol_right_gap * scale
  skw <- symbol_key_width * scale

  icon_rows   <- df_legend[df_legend$section == grid_section, ]
  n_cols      <- max(icon_rows$col, na.rm = TRUE)
  n_rows      <- max(icon_rows$row, na.rm = TRUE)
  grid_end    <- (n_cols - 1) * cs

  # ---- auto xlim / ylim ------------------------------------------------------
  if (is.null(xlim)) {
    x_margin <- resolve_margin_align(x_margin, align, "left", "right", "align")

    x_left  <- if (!is.null(group_section) && !is.null(group_width))
                 -(gw + gg) else 0
    x_right <- if (!is.null(symbol_section))
                 grid_end + srg + skw
               else grid_end
    xlim <- c(x_left - x_margin[[1L]], x_right + x_margin[[2L]])
  }

  if (is.null(ylim)) {
    y_margin <- resolve_margin_align(y_margin, valign, "top", "bottom", "valign")

    # The canvas must enclose whichever section reaches deepest: the grid
    # (rows), the group tiles (one per entry from y = 0), or the symbol keys
    # (first entry sits in the title slot, the rest from y = 0).  Sizing on the
    # grid alone let taller group/symbol blocks spill below the border.
    depths <- n_rows - 1L
    if (!is.null(group_section)) {
      n_group <- sum(df_legend$section == group_section)
      if (n_group > 0L) depths <- c(depths, n_group - 1L)
    }
    if (!is.null(symbol_section)) {
      n_symbol <- sum(df_legend$section == symbol_section)
      if (n_symbol > 0L) depths <- c(depths, max(n_symbol - 2L, 0L))
    }
    depth <- max(depths)

    ylim <- c(-depth * rs - rs * y_margin[[2L]],
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
    layout         = "grid",
    title          = grid_title,
    marker_size    = ms,
    label_size     = ls,
    label_fontface = label_fontface,
    dpi            = dpi,
    col_spacing    = cs,
    row_spacing    = rs,
    label_gap      = lg
  ) + ggplot2::coord_cartesian(xlim = xlim, ylim = ylim, clip = clip)

  # ---- group / colour tiles --------------------------------------------------
  if (!is.null(group_section)) {
    grp <- df_legend[df_legend$section == group_section, ]
    if (is.null(group_width))
      cli::cli_abort("{.arg group_width} is required when {.arg group_section} is set.")
    grp_x     <- -(gw + gg)
    grp_ls    <- if (is.na(group_label_size)) ls else group_label_size * scale * label_scale

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
      x              = grp_x,
      y_start        = 0,
      title          = group_title %||% group_section,
      row_spacing    = rs,
      key_width      = gw,
      label_gap      = lg,
      label_size     = grp_ls,
      label_inside   = TRUE,
      label_color    = group_label_color,
      label_fontface = label_fontface,
      title_color    = "black",
      swatch_height  = group_swatch_height
    )
  }

  # ---- typed-symbol section --------------------------------------------------
  if (!is.null(symbol_section)) {
    sym <- df_legend[df_legend$section == symbol_section, ]
    sym_x  <- grid_end + srg
    sym_lg <- if (is.null(symbol_label_gap)) lg else symbol_label_gap * scale

    sym_entries <- data.frame(
      type  = as.character(sym$type),
      label = as.character(sym$label),
      color = as.character(sym$color),
      stringsAsFactors = FALSE
    )
    if ("label_size" %in% names(sym) && any(!is.na(sym$label_size)))
      sym_entries$label_size <- as.numeric(sym$label_size) * scale * label_scale
    if ("lineheight"  %in% names(sym) && any(!is.na(sym$lineheight)))
      sym_entries$lineheight  <- as.numeric(sym$lineheight)

    p <- p + key_legend(
      sym_entries,
      x              = sym_x,
      row_spacing    = rs,
      key_width      = skw,
      label_gap      = sym_lg,
      label_size     = ls,
      label_fontface = label_fontface
    )
  }

  p
}


#' Draw a border tightly around a composite legend's rendered content
#'
#' @description
#' \code{\link{legend_canvas}} positions its sections from nominal geometry,
#' but text labels overflow their anchor points by an amount that depends on
#' the font, the label strings, and the final output size - none of which are
#' known when the layers are built.  A border drawn from that nominal geometry
#' therefore clips the labels.  \code{legend_box()} sidesteps this by rendering
#' the legend once at the intended output size, measuring the true pixel extent
#' of the drawn content, mapping it back to data coordinates, and adding a
#' border rectangle around it.
#'
#' Because it renders once to measure, the border reflects exactly what will be
#' drawn - long labels, mixed fonts, any content - with no per-figure hand
#' tuning.
#'
#' @param plot A \code{ggplot} (typically \code{\link{legend_canvas}} output)
#'   whose coordinate system supplies fixed \code{xlim}/\code{ylim}
#'   (\code{legend_canvas()} always does).  Add \code{legend_box()} last, after
#'   any other layers, so it encloses everything.
#' @param width,height Physical size in inches of the region the legend will be
#'   drawn in for the final export - pass the same values used there so the
#'   measured text width matches.  For a \code{\link{legend_strip}} legend this
#'   is the full figure width and the strip \code{height}.
#' @param padding Length-2 numeric: gap between content and border, as
#'   fractions of the measured content width and height
#'   (default \code{c(0.02, 0.12)}).
#' @param colour Border colour (default \code{"black"}).
#' @param linewidth Border line width (default \code{0.7}).
#' @param fill Border fill (default \code{NA}, i.e. transparent).
#' @param threshold Grayscale ink cutoff (0-255) for detecting content;
#'   pixels darker than this count as content (default \code{150}).
#' @param dpi Resolution of the internal measurement render (default
#'   \code{150}); higher is more precise but slower.
#'
#' @return \code{plot} with a border \code{ggplot2::annotate("rect", ...)}
#'   layer added.
#'
#' @seealso \code{\link{legend_canvas}}, \code{\link{legend_strip}}
#' @importFrom ggplot2 coord_cartesian theme margin annotate ggsave
#' @export
legend_box <- function(plot, width, height,
                       padding   = c(0.02, 0.12),
                       colour    = "black",
                       linewidth = 0.7,
                       fill      = NA,
                       threshold = 150,
                       dpi       = 150) {
  xr <- plot$coordinates$limits$x
  yr <- plot$coordinates$limits$y
  if (is.null(xr) || is.null(yr)) {
    cli::cli_abort(c(
      "{.arg plot} must have fixed x and y limits for {.fn legend_box}.",
      i = "Pass a {.fn legend_canvas} result, or set {.fn ggplot2::coord_cartesian} {.arg xlim}/{.arg ylim}."
    ))
  }
  if (!requireNamespace("magick", quietly = TRUE)) {
    cli::cli_abort("{.fn legend_box} needs the {.pkg magick} package.")
  }

  tmp <- tempfile(fileext = ".png")
  on.exit(unlink(tmp), add = TRUE)
  measure_plot <- suppressMessages(
    plot +
      ggplot2::coord_cartesian(xlim = xr, ylim = yr, expand = FALSE, clip = "off") +
      ggplot2::theme(plot.margin = ggplot2::margin(0, 0, 0, 0))
  )
  ggplot2::ggsave(tmp, measure_plot, width = width, height = height, dpi = dpi, bg = "white")

  bmp <- magick::image_data(magick::image_read(tmp), channels = "gray")
  storage.mode(bmp) <- "integer"
  px_w <- dim(bmp)[2]
  px_h <- dim(bmp)[3]
  col_ink <- which(apply(bmp[1, , ], 1, function(cc) any(cc < threshold)))
  row_ink <- which(apply(bmp[1, , ], 2, function(rr) any(rr < threshold)))
  if (!length(col_ink) || !length(row_ink)) {
    cli::cli_abort("{.fn legend_box} found no content to enclose.")
  }

  px_to_x <- function(px) xr[[1L]] + (px / px_w) * (xr[[2L]] - xr[[1L]])
  px_to_y <- function(py) yr[[2L]] - (py / px_h) * (yr[[2L]] - yr[[1L]])
  cx_lo <- px_to_x(min(col_ink))
  cx_hi <- px_to_x(max(col_ink))
  cy_hi <- px_to_y(min(row_ink))
  cy_lo <- px_to_y(max(row_ink))
  pad_x <- (cx_hi - cx_lo) * padding[[1L]]
  pad_y <- (cy_hi - cy_lo) * padding[[2L]]

  plot +
    ggplot2::annotate(
      "rect",
      xmin = cx_lo - pad_x, xmax = cx_hi + pad_x,
      ymin = cy_lo - pad_y, ymax = cy_hi + pad_y,
      fill = fill, colour = colour, linewidth = linewidth
    )
}


#' Default proportion ladder for \code{\link{legend_composite}}
#'
#' @description
#' Returns the fixed layout proportions used by \code{\link{legend_composite}}
#' as a named list.  Lengths are multiples of the layout module (see the
#' \code{module} argument there); the two \code{*_label} entries are multiples
#' of the text base (\code{text} there).  Override individual entries and pass
#' the result back via \code{legend_composite(ratios = ...)}.
#'
#' @return A named list of proportions.
#' @seealso \code{\link{legend_composite}}
#' @export
legend_ratios <- function() {
  list(
    col_spacing      = 0.986,   # x module
    row_spacing      = 1.000,   # x module
    label_gap        = 0.167,   # x module
    group_width      = 1.065,   # x module
    group_gap        = 0.365,   # x module
    symbol_right_gap = 0.875,   # x module
    symbol_key_width = 0.567,   # x module
    symbol_label_gap = 0.060,   # x module
    group_label      = 0.933,   # x text
    label            = 1.000    # x text
  )
}


#' Build a bordered composite legend in one call
#'
#' @description
#' Opinionated wrapper over \code{\link{legend_canvas}} + \code{\link{legend_box}}
#' for the recurring three-section legend (an icon grid, a block of colour
#' tiles, and a small typed-symbol key).  You supply the \emph{content}
#' (\code{df_legend}) and the strip size; the wrapper applies a fixed
#' proportion ladder (\code{\link{legend_ratios}}) driven by three base sizes,
#' centres the content in the strip, and fits a border to the rendered result.
#'
#' Every layout length is a multiple of one \code{module}; every text size is a
#' multiple of one \code{text} base; icons use one \code{marker} size.  A
#' \code{label_size} column on the symbol-section rows is read as multiples of
#' \code{text}.
#'
#' The base sizes are calibrated for a \code{base_width}-inch strip and are
#' scaled by \code{width / base_width}, so a legend keeps identical proportions
#' at any output \code{width} - pass your width and the text, markers, and
#' layout all follow.  The group and symbol blocks may hold more entries than
#' the grid has rows; the border grows to enclose whichever section runs
#' deepest.
#'
#' The group colour swatches are rectangles in data coordinates, so shrinking
#' \code{content_range} to make sparse content fill a wide strip stretches them
#' into banners while the fixed-size icons stay put.  \code{legend_composite()}
#' warns (class \code{"ggpop_swatch_aspect_warning"}) when the rendered swatch
#' aspect ratio gets banner-like, pointing you to raise \code{content_range} or
#' reduce \code{width} - keep sparse legends compact rather than stretched.
#'
#' @param df_legend Legend content, as for \code{\link{legend_canvas}} - grid
#'   rows plus optional group/symbol rows, identified by \code{section}.
#' @param width,height Physical size (inches) of the strip the legend will fill
#'   (passed to \code{\link{legend_box}} and used to size/centre the content).
#' @param grid_title,group_title Section titles (\code{NULL} = none / inherit).
#' @param grid_section,group_section,symbol_section \code{section} values that
#'   identify each block (defaults \code{"grid"}, \code{"group"},
#'   \code{"symbol"}).  A missing group/symbol section is skipped.
#' @param module Layout module: one row / one column pitch, in legend units.
#' @param text Base text size (ggplot mm) - the primary label size.
#' @param marker Icon marker size (\code{\link{geom_icon_point}} units).
#' @param content_range Total data-x range the strip maps to; larger renders a
#'   smaller legend.  The content is centred within it.
#' @param base_width Output width (inches) at which the base sizes
#'   (\code{module}, \code{text}, \code{marker}, \code{content_range}) are
#'   calibrated.  Every size is multiplied by \code{width / base_width} so the
#'   legend keeps identical proportions at any \code{width} (default
#'   \code{27}).  Set \code{base_width = width} to disable scaling and size in
#'   absolute units.
#' @param swatch_height Colour-tile height as a fraction of a row.
#' @param fontface Font face for all titles and labels.
#' @param border Border colour (\code{NA} to skip the border).
#' @param border_padding Length-2 \code{padding} passed to
#'   \code{\link{legend_box}}.
#' @param ratios Proportion ladder; defaults to \code{\link{legend_ratios}()}.
#' @param dpi Icon render resolution.
#'
#' @return A \code{ggplot} with a fitted border, ready for
#'   \code{\link{legend_strip}}.
#'
#' @seealso \code{\link{legend_canvas}}, \code{\link{legend_box}},
#'   \code{\link{legend_ratios}}, \code{\link{legend_strip}}
#' @export
legend_composite <- function(
  df_legend, width, height,
  grid_title     = NULL,
  group_title    = NULL,
  grid_section   = "grid",
  group_section  = "group",
  symbol_section = "symbol",
  module         = 0.44294,
  text           = 7.756,
  marker         = 4.562,
  content_range  = 7.21636,
  base_width     = 27,
  swatch_height  = 0.80,
  fontface       = "plain",
  border         = "#231F20",
  border_padding = c(0.018, 0.09),
  ratios         = legend_ratios(),
  dpi            = 300
) {
  # The base sizes are calibrated at `base_width` inches; scale every physical
  # size (text mm, marker units) and every data-unit length (module,
  # content_range) by `width / base_width` so the legend keeps identical
  # proportions at any output width.  `width == base_width` leaves them as-is;
  # `base_width == width` disables scaling for a fully custom design.
  k             <- width / base_width
  u             <- module * k
  text          <- text * k
  marker        <- marker * k
  content_range <- content_range * k

  # symbol-section per-row label_size is given in multiples of `text`
  if (!is.null(symbol_section) && "label_size" %in% names(df_legend)) {
    sel <- df_legend$section == symbol_section & !is.na(df_legend$label_size)
    df_legend$label_size[sel] <- df_legend$label_size[sel] * text
  }

  has_group  <- !is.null(group_section)  && group_section  %in% df_legend$section
  has_symbol <- !is.null(symbol_section) && symbol_section %in% df_legend$section
  n_cols   <- max(df_legend$col[df_legend$section == grid_section], na.rm = TRUE)
  grid_end <- (n_cols - 1) * ratios$col_spacing * u
  content_span <- grid_end +
    (if (has_group)  (ratios$group_width + ratios$group_gap) * u        else 0) +
    (if (has_symbol) (ratios$symbol_right_gap + ratios$symbol_key_width) * u else 0)
  x_margin <- (content_range - content_span) / 2

  p <- legend_canvas(
    df_legend,
    grid_section        = grid_section,
    grid_title          = grid_title,
    group_section       = if (has_group) group_section else NULL,
    group_title         = group_title,
    group_width         = ratios$group_width * u,
    group_gap           = ratios$group_gap * u,
    group_label_size    = ratios$group_label * text,
    group_swatch_height = swatch_height,
    symbol_section      = if (has_symbol) symbol_section else NULL,
    symbol_right_gap    = ratios$symbol_right_gap * u,
    symbol_key_width    = ratios$symbol_key_width * u,
    symbol_label_gap    = ratios$symbol_label_gap * u,
    col_spacing         = ratios$col_spacing * u,
    row_spacing         = ratios$row_spacing * u,
    label_gap           = ratios$label_gap * u,
    marker_size         = marker,
    label_size          = ratios$label * text,
    label_fontface      = fontface,
    scale               = 1,
    label_scale         = 1,
    dpi                 = dpi,
    x_margin            = c(x_margin, x_margin)
  )

  warn_swatch_aspect(p, has_group, ratios, u, swatch_height, width, height)

  if (is.na(border)) return(p)
  legend_box(p, width = width, height = height,
             padding = border_padding, colour = border)
}

# ---- Internal ---------------------------------------------------------------

# Guardrail: a group colour swatch is a rect in data coordinates, so shrinking
# `content_range` to fill a wide strip balloons its width while the fixed-size
# icons stay put - the banner-bar look. Compute the swatch's rendered aspect
# (width:height, in inches) from the built plot's limits and warn when it goes
# banner-like. Calibrated so the dense AllModels legend (~4:1) stays quiet.
warn_swatch_aspect <- function(p, has_group, ratios, u, swatch_height, width, height,
                               threshold = 7) {
  if (!isTRUE(has_group)) return(invisible())
  xr <- p$coordinates$limits$x
  yr <- p$coordinates$limits$y
  if (is.null(xr) || is.null(yr)) return(invisible())

  swatch_w <- (ratios$group_width * u) / abs(diff(xr)) * width
  swatch_h <- (ratios$row_spacing * u * swatch_height) / abs(diff(yr)) * height
  aspect   <- swatch_w / swatch_h
  if (!is.finite(aspect) || aspect <= threshold) return(invisible())

  cli::cli_warn(
    c(
      "Group colour swatches are rendering very wide ({round(aspect)}:1).",
      "!" = "A small {.arg content_range} relative to {.arg width} stretches the swatches into banners while the fixed-size icons stay put.",
      "i" = "Increase {.arg content_range} (or reduce {.arg width}) to keep the legend compact and unstretched."
    ),
    class = "ggpop_swatch_aspect_warning"
  )
  invisible()
}

resolve_margin_align <- function(margin, align, near_side, far_side, arg_name) {
  if (is.null(align)) return(margin)

  valid <- c("center", near_side, far_side)
  if (!is.character(align) || length(align) != 1L || !align %in% valid) {
    cli::cli_abort(c(
      "{.arg {arg_name}} must be one of {.val {valid}}.",
      x = "You supplied {.val {align}}."
    ))
  }

  total <- sum(margin)
  if (align == "center")  return(c(total, total) / 2)
  if (align == near_side) return(c(total * 0.1, total * 0.9))
  c(total * 0.9, total * 0.1)
}
