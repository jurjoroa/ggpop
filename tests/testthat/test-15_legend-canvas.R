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
    if (inherits(l$geom, "GeomText") && !is.null(l$data) && "label" %in% names(l$data)) {
      as.character(l$data$label)
    } else {
      character(0)
    }
  }))
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
  df <- rbind(
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
