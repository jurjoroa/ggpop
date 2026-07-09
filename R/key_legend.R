#' Add typed symbol entries to a legend canvas
#'
#' @description
#' Adds a column of symbol + label entries to an existing \code{ggplot} canvas
#' (typically the output of \code{\link{marker_legend}}) using the same
#' \code{ggplot2::annotate()} approach.  The coordinate system is shared with
#' the base plot, so positions integrate seamlessly with the rest of the legend.
#'
#' Three entry types are supported:
#' \describe{
#'   \item{swatch}{A filled rectangle (colour bands, modality tiles).}
#'   \item{line}{A horizontal segment (frontier or trend lines).}
#'   \item{point}{A bold \code{"*"} glyph rendered as text.}
#' }
#' A fourth entry kind, \code{icon}, exists in \code{\link{legend_canvas}}'s
#' \code{df_legend} vocabulary but is not a \code{key_legend()} type - icon
#' rows are rendered separately via \code{\link{marker_legend}}.
#'
#' \strong{Two y-placement modes:}
#' \itemize{
#'   \item \code{y_start = NULL} (default) — first entry is placed at the
#'     section-title row (\code{row_spacing * title_frac}), matching the
#'     position where \code{marker_legend()} puts section headers.  Use this
#'     when entry\,1 is both the title and its own symbol (e.g. the
#'     "Efficient frontier" line entry).
#'   \item \code{y_start = 0} — first entry at row\,1, second at
#'     \code{-row_spacing}, etc.  Use this with a text-only \code{title}.
#' }
#'
#' @param entries A data frame with columns \code{type} (\code{"swatch"},
#'   \code{"line"}, or \code{"point"}), \code{label}, and \code{color}
#'   (or \code{colour}).  Optional columns: \code{linetype} (default
#'   \code{"solid"}), \code{linewidth} (default \code{0.8}), \code{pch}
#'   (default \code{NA} → draws \code{"*"} for \code{type = "point"}).
#' @param x Left edge of the key-symbol column in plot coordinates.
#' @param y_start Y coordinate of the first entry.  \code{NULL} (default)
#'   places entry\,1 at \code{row_spacing * title_frac}.
#' @param title Optional text-only section title drawn at
#'   \code{row_spacing * title_frac}, centred over the key column.
#' @param title_frac Y-fraction used for the section-title row
#'   (default \code{0.85}, matching \code{marker_legend()}).
#' @param row_spacing Vertical distance between rows.  Match the
#'   \code{row_spacing} passed to \code{\link{marker_legend}}.
#' @param key_width Horizontal width of the key symbol area.
#' @param label_gap Gap between the key symbol and the label text.
#' @param label_size Text size (passed to \code{ggplot2::annotate()}).
#' @param label_color Colour of label text.
#' @param swatch_height Height of swatch rectangles as a fraction of
#'   \code{row_spacing} (default \code{0.45}).
#' @param point_size Size multiplier for point glyphs relative to
#'   \code{label_size} (default \code{1.6}).
#'
#' @return A \code{ggpop_key_legend} object.  Add it to any \code{ggplot}
#'   with \code{+} to inject the annotate layers onto that canvas.  Print it
#'   (or use it standalone) to render a self-contained legend panel.
#'
#' @examples
#' \donttest{
#' library(ggplot2)
#' s  <- 0.78
#' rs <- 0.34 * s
#'
#' ef <- data.frame(
#'   type  = c("line",               "swatch",    "point"),
#'   label = c("Efficient frontier", "Grey zone",  "Near efficient"),
#'   color = c("black",              "grey50",     "black"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Standalone panel:
#' print(key_legend(ef, row_spacing = rs, key_width = 0.22))
#'
#' # Added to a marker_legend canvas:
#' # p <- marker_legend(age_entries, ...) +
#' #        key_legend(ef, x = 1.10, row_spacing = rs, key_width = 0.22)
#' }
#'
#' @seealso \code{\link{marker_legend}}
#' @importFrom ggplot2 ggplot annotate coord_cartesian theme_void ggplot_add
#' @importFrom rlang caller_env
#' @importFrom cli cli_abort
#' @export
key_legend <- function(
  entries,
  x             = 0,
  y_start       = NULL,
  title         = NULL,
  title_frac    = 0.85,
  row_spacing   = 1,
  key_width     = 1.2,
  label_gap     = 0.3,
  label_size    = 2.8,
  label_color   = "black",
  label_inside  = FALSE,
  title_color   = NULL,
  swatch_height = 0.45,
  point_size    = 1.6
) {
  entries <- normalize_key_legend_entries(entries)

  structure(
    list(
      entries       = entries,
      x             = x,
      y_start       = y_start,
      title         = title,
      title_frac    = title_frac,
      row_spacing   = row_spacing,
      key_width     = key_width,
      label_gap     = label_gap,
      label_size    = label_size,
      label_color   = label_color,
      label_inside  = label_inside,
      title_color   = title_color %||% label_color,
      swatch_height = swatch_height,
      point_size    = point_size
    ),
    class = "ggpop_key_legend"
  )
}

#' @export
ggplot_add.ggpop_key_legend <- function(object, plot, object_name) {
  layers <- build_key_legend_layers(object)
  Reduce(function(p, l) p + l, layers, init = plot)
}

#' @export
print.ggpop_key_legend <- function(x, ...) {
  obj    <- x
  layers <- build_key_legend_layers(obj)
  y_pos  <- key_legend_y_positions(obj)

  p <- Reduce(function(p, l) p + l, layers, init = ggplot2::ggplot())

  max_chars <- max(nchar(as.character(obj$entries$label)))
  x_max     <- obj$x + obj$key_width + obj$label_gap + max_chars * obj$label_size * 0.38
  y_min     <- min(y_pos) - obj$row_spacing * 0.5
  y_max_top <- if (!is.null(obj$title) || is.null(obj$y_start)) {
    obj$row_spacing * obj$title_frac + obj$row_spacing * 0.5
  } else {
    max(y_pos) + obj$row_spacing * 0.5
  }

  p <- p +
    ggplot2::coord_cartesian(
      xlim = c(obj$x - obj$key_width * 0.1, x_max),
      ylim = c(y_min, y_max_top),
      clip = "off"
    ) +
    ggplot2::theme_void()

  print(p)
  invisible(p)
}

# ---- Internal helpers -------------------------------------------------------

key_legend_y_positions <- function(obj) {
  n  <- nrow(obj$entries)
  rs <- obj$row_spacing
  if (is.null(obj$y_start)) {
    c(rs * obj$title_frac, -(seq_len(max(n - 1L, 0L)) - 1L) * rs)
  } else {
    obj$y_start - (seq_len(n) - 1L) * rs
  }
}

build_key_legend_layers <- function(obj) {
  entries   <- obj$entries
  x         <- obj$x
  kw        <- obj$key_width
  lg        <- obj$label_gap
  ls        <- obj$label_size
  lc        <- obj$label_color
  rs        <- obj$row_spacing
  tf        <- obj$title_frac
  sh        <- obj$swatch_height
  ps        <- obj$point_size
  x_sym_mid <- x + kw / 2
  x_label   <- x + kw + lg
  y_pos     <- key_legend_y_positions(obj)
  layers    <- list()

  tc <- obj$title_color %||% lc
  if (!is.null(obj$title)) {
    layers <- c(layers, list(
      ggplot2::annotate(
        "text",
        x = x_sym_mid, y = rs * tf,
        label = obj$title,
        hjust = 0.5, vjust = 0.5,
        size = ls, colour = tc
      )
    ))
  }

  for (i in seq_len(nrow(entries))) {
    row    <- entries[i, ]
    y      <- y_pos[[i]]
    col    <- as.character(row$color)
    lbl    <- as.character(row$label)
    half_h <- rs * sh / 2

    key_layer <- switch(
      row$type,
      swatch = ggplot2::annotate(
        "rect",
        xmin = x, xmax = x + kw,
        ymin = y - half_h, ymax = y + half_h,
        fill = col, colour = NA
      ),
      line = ggplot2::annotate(
        "segment",
        x = x, xend = x + kw,
        y = y, yend = y,
        linewidth = as.numeric(row$linewidth),
        colour    = col,
        linetype  = as.character(row$linetype)
      ),
      point = ggplot2::annotate(
        "text",
        x = x_sym_mid, y = y,
        label    = if (!is.na(row$pch)) as.character(row$pch) else "*",
        hjust    = 0.5, vjust = 0.5,
        size     = ls * ps,
        fontface = "bold",
        colour   = col
      ),
      cli::cli_abort(
        c(
          "{.arg entries$type} contains unsupported value {.val {row$type}}.",
          i = "Allowed types: {.val swatch}, {.val line}, {.val point}."
        ),
        call = rlang::caller_env()
      )
    )

    use_inside <- isTRUE(obj$label_inside) && row$type == "swatch"
    # Per-row overrides: label_size column, lineheight column
    row_ls <- if ("label_size" %in% names(row) && !is.na(row$label_size)) {
      as.numeric(row$label_size)
    } else ls
    row_lh <- if ("lineheight" %in% names(row) && !is.na(row$lineheight)) {
      as.numeric(row$lineheight)
    } else 1

    label_layer <- if (use_inside) {
      ggplot2::annotate(
        "text",
        x = x + kw / 2, y = y,
        label = lbl, hjust = 0.5, vjust = 0.5,
        size = row_ls, colour = lc, lineheight = row_lh
      )
    } else {
      ggplot2::annotate(
        "text",
        x = x_label, y = y,
        label = lbl, hjust = 0, vjust = 0.5,
        size = row_ls, colour = lc, lineheight = row_lh
      )
    }

    layers <- c(layers, list(key_layer, label_layer))
  }

  layers
}

normalize_key_legend_entries <- function(entries, call = rlang::caller_env()) {
  if (is.list(entries) && !is.data.frame(entries)) {
    rows <- Map(function(type, value) {
      if (!is.list(value)) value <- list(label = value)
      value$type <- value$type %||% type
      value
    }, names(entries), entries)
    cols <- unique(unlist(lapply(rows, names), use.names = FALSE))
    entries <- do.call(rbind, lapply(rows, function(row) {
      row[setdiff(cols, names(row))] <- NA
      as.data.frame(row[cols], stringsAsFactors = FALSE)
    }))
  }
  validate_key_legend_entries(entries, call = call)
  if (!"color" %in% names(entries) && "colour" %in% names(entries))
    entries$color <- entries$colour
  if (!"linetype"  %in% names(entries)) entries$linetype  <- "solid"
  if (!"linewidth" %in% names(entries)) entries$linewidth <- 0.8
  if (!"pch"       %in% names(entries)) entries$pch       <- NA_integer_
  entries
}

validate_key_legend_entries <- function(entries, call = rlang::caller_env()) {
  if (!is.data.frame(entries)) {
    cli::cli_abort("{.arg entries} must be a data frame.", call = call)
  }
  missing_cols <- setdiff(c("type", "label"), names(entries))
  if (length(missing_cols)) {
    cli::cli_abort(
      "{.arg entries} is missing required column{?s}: {.field {missing_cols}}.",
      call = call
    )
  }
  valid_types <- c("swatch", "line", "point")
  bad_types   <- setdiff(entries$type, valid_types)
  if (length(bad_types)) {
    cli::cli_abort(
      c(
        "{.arg entries$type} contains invalid value{?s}: {.val {bad_types}}.",
        i = "Allowed types: {.val {valid_types}}."
      ),
      call = call
    )
  }
  invisible(entries)
}
