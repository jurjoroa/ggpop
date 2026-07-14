# *****************************************************************************
#
# Script: test-15_legend-canvas.R
#
# Purpose: Test legend_canvas() - assembles grid/group/symbol sections of a
#          df_legend data frame into one composite legend ggplot
#
# Author: Jorge Roa
#
# Date Created: 08-Jul-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers issue #385: legend_canvas() in legend-canvas.R
#   - `type` only drives rendering for group_section/symbol_section rows
#     (routed through key_legend()); grid_section rows are always icons and
#     ignore `type` entirely - see MEMORY.md for the full mechanics writeup
#   - group_section rows now respect their own `type`, defaulting to "swatch"
#     when missing/blank (fixed 2026-07-08; previously hardcoded to "swatch")
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")

# Pure helpers (no shared state) - inspect constructed layers without building
# or rendering the plot.
geom_classes <- function(p) vapply(p$layers, function(l) class(l$geom)[1], character(1))

text_labels <- function(p) {
  unlist(lapply(p$layers, function(l) {
    if (!inherits(l$geom, "GeomText")) {
      return(character(0))
    }
    labs <- character(0)
    # entry labels live in the layer data; annotate() titles live in aes_params
    if (!is.null(l$data) && is.data.frame(l$data) && "label" %in% names(l$data)) {
      labs <- c(labs, as.character(l$data$label))
    }
    if (!is.null(l$aes_params$label)) {
      labs <- c(labs, as.character(l$aes_params$label))
    }
    labs
  }))
}

x_range <- function(p) p$coordinates$limits$x
y_range <- function(p) p$coordinates$limits$y

# Deterministic geometry summary of a composite legend - every layer's geom,
# its data positions, and any size/position aes_params, plus the canvas limits.
# Rendering-derived output (the fitted border, which depends on the graphics
# device) is excluded on purpose; this locks the layout maths only.
legend_geometry <- function(p) {
  num <- function(v) round(as.numeric(v), 4)
  layers <- lapply(p$layers, function(l) {
    out <- list(geom = class(l$geom)[1])
    d <- l$data
    if (is.data.frame(d) && nrow(d) > 0) {
      for (col in intersect(c("x", "y", "xmin", "xmax", "ymin", "ymax", "xend", "yend"), names(d))) {
        out[[col]] <- num(d[[col]])
      }
    }
    ap <- l$aes_params
    for (nm in intersect(c("size", "x", "y", "xmin", "xmax", "ymin", "ymax"), names(ap))) {
      out[[paste0("p_", nm)]] <- num(ap[[nm]])
    }
    out
  })
  list(
    xlim = num(p$coordinates$limits$x),
    ylim = num(p$coordinates$limits$y),
    n_layers = length(p$layers),
    layers = layers
  )
}

grid_rows <- function(type = "icon") {
  data.frame(
    section = "grid", type = type,
    label = c("A", "B"), icon = c("square-inset", "circle-inset"),
    row = c(1, 1), col = c(1, 2), color = NA,
    stringsAsFactors = FALSE
  )
}

canvas_args <- list(
  col_spacing = 1, row_spacing = 1, label_gap = 0.2,
  marker_size = 3, label_size = 2.5
)

# ******************************************************************************
# 01 grid-only canvas ------------------------------------------------------------
# ******************************************************************************

testthat::test_that("grid-only canvas returns a ggplot", {
  p <- do.call(legend_canvas, c(list(df_legend = grid_rows()), canvas_args))
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("grid_section type value is ignored - icon rows render regardless", {
  df_banana <- grid_rows(type = "banana")
  p <- do.call(legend_canvas, c(list(df_legend = df_banana), canvas_args))
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 02 group_section ----------------------------------------------------------------
# ******************************************************************************

testthat::test_that("group_section requires group_width", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  args <- c(list(df_legend = df, group_section = "modality"), canvas_args)
  testthat::expect_error(do.call(legend_canvas, args), "group_width")
})

testthat::test_that("group_title defaults to group_section value when NULL", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  args <- c(list(df_legend = df, group_section = "modality", group_width = 0.3), canvas_args)
  p <- do.call(legend_canvas, args)
  testthat::expect_true("modality" %in% text_labels(p))
})

testthat::test_that("group_title overrides group_section for the displayed title", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  args <- c(
    list(df_legend = df, group_section = "modality", group_title = "Modality", group_width = 0.3),
    canvas_args
  )
  p <- do.call(legend_canvas, args)
  labels <- text_labels(p)
  testthat::expect_true("Modality" %in% labels)
  testthat::expect_false("modality" %in% labels)
})

testthat::test_that("group_section rows default to swatch when type column is missing", {
  testthat::skip_if_not_installed("dplyr")
  # bind_rows (not rbind) so the group row can legitimately omit `type`
  df <- dplyr::bind_rows(
    grid_rows(),
    data.frame(section = "modality", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  args <- c(list(df_legend = df, group_section = "modality", group_width = 0.3), canvas_args)
  p <- do.call(legend_canvas, args)
  testthat::expect_true("GeomRect" %in% geom_classes(p))
})

testthat::test_that("group_section rows honour an explicit non-swatch type", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "ef_group", type = "line", label = "Trend", icon = NA, row = NA, col = NA, color = "black")
  )
  args <- c(list(df_legend = df, group_section = "ef_group", group_width = 0.3), canvas_args)
  p <- do.call(legend_canvas, args)
  testthat::expect_true("GeomSegment" %in% geom_classes(p))
  testthat::expect_false("GeomRect" %in% geom_classes(p))
})

# ******************************************************************************
# 03 symbol_section ----------------------------------------------------------------
# ******************************************************************************

testthat::test_that("symbol_section renders each row's own type", {
  df <- rbind(
    grid_rows(),
    data.frame(
      section = "ef",
      type    = c("line", "swatch", "point"),
      label   = c("Efficient frontier", "Grey zone", "Near efficient"),
      icon    = NA, row = NA, col = NA,
      color   = c("black", "grey75", "black"),
      stringsAsFactors = FALSE
    )
  )
  args <- c(
    list(df_legend = df, symbol_section = "ef", symbol_key_width = 0.2),
    canvas_args
  )
  p <- do.call(legend_canvas, args)
  classes <- geom_classes(p)
  testthat::expect_true("GeomSegment" %in% classes)
  testthat::expect_true("GeomRect" %in% classes)
  testthat::expect_true("GeomText" %in% classes)
  testthat::expect_true("Near efficient" %in% text_labels(p))
})

# ******************************************************************************
# 04 visual snapshot of a full grid + group + symbol canvas ----------------------
# ******************************************************************************

testthat::test_that("legend_canvas composite renders (snapshot)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink"),
    data.frame(
      section = "ef",
      type    = c("line", "point"),
      label   = c("Efficient frontier", "Near efficient"),
      icon    = NA, row = NA, col = NA,
      color   = c("black", "black"),
      stringsAsFactors = FALSE
    )
  )

  p <- legend_canvas(
    df,
    group_section  = "modality", group_title = "Modality", group_width = 0.3,
    symbol_section = "ef", symbol_key_width = 0.2,
    col_spacing = 1, row_spacing = 1, label_gap = 0.2,
    marker_size = 3, label_size = 2.5, dpi = 120
  )

  path <- tempfile(fileext = ".png")
  ggplot2::ggsave(path, p, width = 6, height = 1.5, dpi = 120, bg = "white")
  testthat::expect_snapshot_file(path, "legend-canvas-composite.png")
})

# ******************************************************************************
# 05 x_margin / align centering ---------------------------------------------------
# ******************************************************************************

testthat::test_that("default x_margin centres content symmetrically (#393)", {
  p <- do.call(legend_canvas, c(list(df_legend = grid_rows()), canvas_args))
  xlim <- x_range(p)
  grid_end <- 1  # (n_cols - 1) * col_spacing = (2 - 1) * 1
  left_pad  <- 0 - xlim[[1]]
  right_pad <- xlim[[2]] - grid_end
  testthat::expect_equal(left_pad, right_pad)
})

testthat::test_that("align = 'left' biases padding toward the right", {
  args <- c(list(df_legend = grid_rows(), align = "left"), canvas_args)
  xlim <- x_range(do.call(legend_canvas, args))
  left_pad  <- 0 - xlim[[1]]
  right_pad <- xlim[[2]] - 1
  testthat::expect_lt(left_pad, right_pad)
})

testthat::test_that("align = 'right' biases padding toward the left", {
  args <- c(list(df_legend = grid_rows(), align = "right"), canvas_args)
  xlim <- x_range(do.call(legend_canvas, args))
  left_pad  <- 0 - xlim[[1]]
  right_pad <- xlim[[2]] - 1
  testthat::expect_gt(left_pad, right_pad)
})

testthat::test_that("align = 'center' matches the symmetric default", {
  default_xlim <- x_range(do.call(legend_canvas, c(list(df_legend = grid_rows()), canvas_args)))
  center_xlim  <- x_range(do.call(legend_canvas, c(list(df_legend = grid_rows(), align = "center"), canvas_args)))
  testthat::expect_equal(center_xlim, default_xlim)
})

testthat::test_that("explicit x_margin is honoured when align is not set", {
  args <- c(list(df_legend = grid_rows(), x_margin = c(0.425, 0.675)), canvas_args)
  xlim <- x_range(do.call(legend_canvas, args))
  testthat::expect_equal(xlim, c(0 - 0.425, 1 + 0.675))
})

testthat::test_that("align overrides an explicit x_margin, preserving its total", {
  args <- c(
    list(df_legend = grid_rows(), x_margin = c(0.425, 0.675), align = "left"),
    canvas_args
  )
  xlim <- x_range(do.call(legend_canvas, args))
  total     <- 0.425 + 0.675
  left_pad  <- 0 - xlim[[1]]
  right_pad <- xlim[[2]] - 1
  testthat::expect_equal(left_pad + right_pad, total)
  testthat::expect_lt(left_pad, right_pad)
})

testthat::test_that("invalid align value errors", {
  args <- c(list(df_legend = grid_rows(), align = "top"), canvas_args)
  testthat::expect_error(do.call(legend_canvas, args), "align")
})

# ******************************************************************************
# 06 y_margin / valign centering ---------------------------------------------------
# ******************************************************************************

testthat::test_that("default y_margin centres content symmetrically", {
  p <- do.call(legend_canvas, c(list(df_legend = grid_rows()), canvas_args))
  ylim <- y_range(p)
  top_content    <- 0.85  # row_spacing * 0.85 title row, row_spacing = 1
  bottom_content <- 0     # -(n_rows - 1) * row_spacing, n_rows = 1
  top_pad    <- ylim[[2]] - top_content
  bottom_pad <- bottom_content - ylim[[1]]
  testthat::expect_equal(top_pad, bottom_pad)
})

testthat::test_that("valign = 'top' biases padding toward the bottom", {
  args <- c(list(df_legend = grid_rows(), valign = "top"), canvas_args)
  ylim <- y_range(do.call(legend_canvas, args))
  top_pad    <- ylim[[2]] - 0.85
  bottom_pad <- 0 - ylim[[1]]
  testthat::expect_lt(top_pad, bottom_pad)
})

testthat::test_that("valign = 'bottom' biases padding toward the top", {
  args <- c(list(df_legend = grid_rows(), valign = "bottom"), canvas_args)
  ylim <- y_range(do.call(legend_canvas, args))
  top_pad    <- ylim[[2]] - 0.85
  bottom_pad <- 0 - ylim[[1]]
  testthat::expect_gt(top_pad, bottom_pad)
})

testthat::test_that("valign = 'center' matches the symmetric default", {
  default_ylim <- y_range(do.call(legend_canvas, c(list(df_legend = grid_rows()), canvas_args)))
  center_ylim  <- y_range(do.call(legend_canvas, c(list(df_legend = grid_rows(), valign = "center"), canvas_args)))
  testthat::expect_equal(center_ylim, default_ylim)
})

testthat::test_that("explicit y_margin is honoured when valign is not set", {
  args <- c(list(df_legend = grid_rows(), y_margin = c(0.6, 1.1)), canvas_args)
  ylim <- y_range(do.call(legend_canvas, args))
  testthat::expect_equal(ylim, c(0 - 1.1, 0.85 + 0.6))
})

testthat::test_that("valign overrides an explicit y_margin, preserving its total", {
  args <- c(
    list(df_legend = grid_rows(), y_margin = c(0.6, 1.1), valign = "top"),
    canvas_args
  )
  ylim <- y_range(do.call(legend_canvas, args))
  total      <- 0.6 + 1.1
  top_pad    <- ylim[[2]] - 0.85
  bottom_pad <- 0 - ylim[[1]]
  testthat::expect_equal(top_pad + bottom_pad, total)
  testthat::expect_lt(top_pad, bottom_pad)
})

testthat::test_that("invalid valign value errors", {
  args <- c(list(df_legend = grid_rows(), valign = "middle"), canvas_args)
  testthat::expect_error(do.call(legend_canvas, args), "valign")
})

# ******************************************************************************
# 07 label_fontface -----------------------------------------------------------
# ******************************************************************************

testthat::test_that("label_fontface defaults to plain throughout", {
  p <- do.call(legend_canvas, c(list(df_legend = grid_rows(), grid_title = "Ages"), canvas_args))
  text_layers <- Filter(function(l) inherits(l$geom, "GeomText"), p$layers)
  fontfaces <- vapply(text_layers, function(l) l$aes_params$fontface %||% "plain", character(1))
  testthat::expect_true(all(fontfaces == "plain"))
})

testthat::test_that("label_fontface reaches the grid title/labels and the group title/tiles", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  args <- c(
    list(df_legend = df, grid_title = "Ages", group_section = "modality", group_width = 0.3, label_fontface = "bold"),
    canvas_args
  )
  p <- do.call(legend_canvas, args)
  title_labels <- c("Ages", "modality", "FIT")
  for (lbl in title_labels) {
    layer <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, lbl), p$layers)
    testthat::expect_equal(layer$aes_params$fontface, "bold", label = paste("fontface for", lbl))
  }
})

# ******************************************************************************
# 08 label_scale --------------------------------------------------------------
# ******************************************************************************

group_title_size <- function(p) {
  layer <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, "modality"), p$layers)
  layer$aes_params$size
}
marker_icon_size <- function(p) {
  layer <- Find(function(l) inherits(l$geom, "GeomPopImage"), p$layers)
  unique(layer$data$icon_size)
}

testthat::test_that("label_scale multiplies text size but leaves marker size untouched", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "modality", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink")
  )
  base <- c(list(df_legend = df, group_section = "modality", group_width = 0.3), canvas_args)
  p1 <- do.call(legend_canvas, base)
  p2 <- do.call(legend_canvas, c(base, list(label_scale = 2)))

  testthat::expect_equal(group_title_size(p2), group_title_size(p1) * 2)
  testthat::expect_equal(marker_icon_size(p2), marker_icon_size(p1))
})

testthat::test_that("label_scale defaults to 1 (no change)", {
  p1 <- do.call(legend_canvas, c(list(df_legend = grid_rows(), grid_title = "Ages"), canvas_args))
  p2 <- do.call(legend_canvas, c(list(df_legend = grid_rows(), grid_title = "Ages", label_scale = 1), canvas_args))
  s1 <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, "Ages"), p1$layers)$aes_params$size
  s2 <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, "Ages"), p2$layers)$aes_params$size
  testthat::expect_equal(s1, s2)
})

# ******************************************************************************
# 09 legend_box ---------------------------------------------------------------
# ******************************************************************************

testthat::test_that("legend_box errors when the plot has no fixed limits", {
  p <- ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point()
  testthat::expect_error(legend_box(p, width = 4, height = 4), "limits")
})

testthat::test_that("legend_box adds a fitted border rect (render)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  p <- do.call(legend_canvas, c(list(df_legend = grid_rows(), grid_title = "Ages"), canvas_args))
  n_before <- length(p$layers)
  pb <- legend_box(p, width = 5, height = 1.5)

  testthat::expect_length(pb$layers, n_before + 1L)
  testthat::expect_s3_class(pb$layers[[length(pb$layers)]]$geom, "GeomRect")

  # the border encloses the plot's content, so it sits within the coord limits
  rect <- pb$layers[[length(pb$layers)]]
  testthat::expect_true(rect$data$xmin >= p$coordinates$limits$x[[1]])
  testthat::expect_true(rect$data$xmax <= p$coordinates$limits$x[[2]])
})

# ******************************************************************************
# 10 legend_ratios / legend_composite -----------------------------------------
# ******************************************************************************

testthat::test_that("legend_ratios returns the proportion ladder", {
  r <- legend_ratios()
  testthat::expect_type(r, "list")
  testthat::expect_true(all(c(
    "col_spacing", "row_spacing", "label_gap", "group_width", "group_gap",
    "symbol_right_gap", "symbol_key_width", "symbol_label_gap",
    "group_label", "label"
  ) %in% names(r)))
})

testthat::test_that("legend_composite builds a grid-only legend (no group/symbol) without a border", {
  df <- grid_rows()
  p <- legend_composite(df, width = 5, height = 1.5, border = NA)
  testthat::expect_s3_class(p, "ggplot")
  # border = NA => no border rect layer added
  testthat::expect_false(any(vapply(
    p$layers, function(l) inherits(l$geom, "GeomRect"), logical(1)
  )))
})

testthat::test_that("legend_composite scales symbol label_size by the text base", {
  testthat::skip_if_not_installed("dplyr")
  df <- dplyr::bind_rows(
    grid_rows(),
    data.frame(
      section = "symbol", type = "line", label = "Trend",
      color = "black", label_size = 0.5, stringsAsFactors = FALSE
    )
  )
  # em ratio 0.5 * text 4 => effective 2 on that row (base_width = width => k = 1)
  p <- legend_composite(df, width = 5, height = 1.5, text = 4, base_width = 5, border = NA)
  lab <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, "Trend"), p$layers)
  testthat::expect_equal(lab$aes_params$size, 2)
})

testthat::test_that("legend_composite scales sizes by width / base_width", {
  testthat::skip_if_not_installed("dplyr")
  df <- dplyr::bind_rows(
    grid_rows(),
    data.frame(
      section = "symbol", type = "line", label = "Trend",
      color = "black", label_size = 0.5, stringsAsFactors = FALSE
    )
  )
  size_of <- function(p) {
    lab <- Find(function(l) inherits(l$geom, "GeomText") && identical(l$aes_params$label, "Trend"), p$layers)
    lab$aes_params$size
  }
  # base_width = 5: at width 5, k = 1; at width 10, k = 2 => sizes double
  base <- legend_composite(df, width = 5, height = 1.5, text = 4, base_width = 5, border = NA)
  dbl <- legend_composite(df, width = 10, height = 1.5, text = 4, base_width = 5, border = NA)
  testthat::expect_equal(size_of(base), 2)
  testthat::expect_equal(size_of(dbl), 4)
})

testthat::test_that("legend_composite adds a fitted border by default (render)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  df <- rbind(
    grid_rows(),
    data.frame(section = "group", type = "swatch", label = "FIT", icon = NA, row = NA, col = NA, color = "pink", stringsAsFactors = FALSE)
  )
  p <- legend_composite(df, width = 6, height = 1.5, group_title = "Modality")
  testthat::expect_s3_class(p$layers[[length(p$layers)]]$geom, "GeomRect")
})

testthat::test_that("legend_composite warns when group swatches render banner-wide", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "group", type = "swatch", label = "FIT",
               icon = NA, row = NA, col = NA, color = "pink")
  )
  # small content_range vs width stretches the swatch into a banner
  testthat::expect_warning(
    legend_composite(df, width = 10, height = 1, content_range = 1.2, border = NA),
    class = "ggpop_swatch_aspect_warning"
  )
})

testthat::test_that("legend_composite is quiet at natural (unstretched) proportions", {
  df <- rbind(
    grid_rows(),
    data.frame(section = "group", type = "swatch", label = "FIT",
               icon = NA, row = NA, col = NA, color = "pink")
  )
  testthat::expect_no_warning(
    legend_composite(df, width = 6, height = 1.5, border = NA)
  )
})

# ******************************************************************************
# 11 auto-enclosure of a section taller than the grid -------------------------
# ******************************************************************************

testthat::test_that("legend_canvas encloses a group block taller than the grid", {
  # grid_rows() is a single row; a 3-tile group runs to y = -2 (row_spacing 1)
  three <- rbind(
    grid_rows(),
    data.frame(
      section = "grp", type = "swatch", label = c("a", "b", "c"),
      icon = NA, row = NA, col = NA, color = c("red", "green", "blue")
    )
  )
  one <- rbind(
    grid_rows(),
    data.frame(
      section = "grp", type = "swatch", label = "a",
      icon = NA, row = NA, col = NA, color = "red"
    )
  )
  y3 <- y_range(do.call(legend_canvas, c(
    list(df_legend = three, group_section = "grp", group_width = 0.3), canvas_args
  )))
  y1 <- y_range(do.call(legend_canvas, c(
    list(df_legend = one, group_section = "grp", group_width = 0.3), canvas_args
  )))
  testthat::expect_lte(y3[[1]], -2)
  testthat::expect_gt(y1[[1]], y3[[1]])
})

testthat::test_that("legend_canvas encloses a symbol key taller than the grid", {
  df <- rbind(
    grid_rows(),
    data.frame(
      section = "ef", type = "line", label = c("w", "x", "y", "z"),
      icon = NA, row = NA, col = NA, color = "black"
    )
  )
  # 4 symbol entries occupy the title slot plus y = 0, -1, -2
  p <- do.call(legend_canvas, c(
    list(df_legend = df, symbol_section = "ef", symbol_key_width = 0.2), canvas_args
  ))
  testthat::expect_lte(y_range(p)[[1]], -2)
})

# ******************************************************************************
# 12 GOLD STANDARD - AllModels frontier compact legend geometry ---------------
# ******************************************************************************
# Locks the exact layout of the AllModels composite legend (the reference
# figure). The scatter reads external sda2028 data so it cannot live here, but
# the legend is built from inline content and IS the gold standard. Any drift
# in the layout maths (base_width scaling, section placement, sizes, limits)
# changes this snapshot. Record once with testthat::snapshot_accept(); after
# that, an unreviewed change fails the test.

testthat::test_that("AllModels frontier compact legend geometry is locked", {
  testthat::skip_if_not_installed("dplyr")
  df_legend <- dplyr::bind_rows(
    data.frame(
      section = "grid", type = "icon",
      label = c("45-70y", "45-75y", "45-80y", "45-85y",
                "50-70y", "50-75y", "50-80y", "50-85y",
                "55-70y", "55-75y", "55-80y", "55-85y"),
      icon = c("square-inset", "square-hollow", "square-cross", "square-solid",
               "circle-inset", "circle-hollow", "circle-cross", "circle-solid",
               "diamond-inset", "diamond-hollow", "diamond-cross", "diamond-solid"),
      row = rep(1:3, each = 4), col = rep(1:4, times = 3), color = NA,
      stringsAsFactors = FALSE
    ),
    data.frame(
      section = "group", type = "swatch",
      label = c("FIT", "sDNA+FIT", "HSgFOBT"),
      color = c("palevioletred1", "lightseagreen", "lightslateblue"),
      stringsAsFactors = FALSE
    ),
    data.frame(
      section = "symbol", type = c("line", "swatch", "point"),
      label = c("Efficient frontier", "3 days/person\nfrom frontier", "Near efficient"),
      color = c("black", "#C2C2C2", "black"),
      label_size = c(0.90, 0.82, 0.82), lineheight = c(NA, 0.85, NA),
      stringsAsFactors = FALSE
    )
  )
  # border = NA -> deterministic layout only (the fitted border is device-dependent)
  p <- legend_composite(
    df_legend, width = 27, height = 2.73175,
    grid_title = "Age to begin-age to end screening",
    group_title = "Modality", border = NA
  )
  testthat::expect_snapshot_value(legend_geometry(p), style = "json2")
})
