# *****************************************************************************
#
# Script: test-13_marker-legend.R
#
# Purpose: Test marker_legend() - the standalone composite legend builder
#
# Author: Jorge Roa
#
# Date Created: 21-Jun-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers issue #385: marker_legend() and its internal helpers in
#     marker_legend.R (validate_marker_legend_entries, resolve_marker_legend_layout)
#   - Normal data-driven legends use the native path (legend_icons +
#     scale_legend_icon); marker_legend() is only for standalone composites.
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")

# ******************************************************************************
# 01 validate_marker_legend_entries -------------------------------------------
# ******************************************************************************

testthat::test_that("marker_legend rejects malformed entries", {
  testthat::expect_error(
    marker_legend(list(icon = "star", label = "A")),
    "data frame"
  )
  testthat::expect_error(
    marker_legend(data.frame(icon = "star")),
    "label"
  )
  testthat::expect_error(
    marker_legend(data.frame(icon = character(0), label = character(0))),
    "no rows"
  )
  testthat::expect_error(
    marker_legend(data.frame(icon = "star", label = "A"), layout = "grid"),
    "row"
  )
})

# ******************************************************************************
# 02 resolve_marker_legend_layout ---------------------------------------------
# ******************************************************************************

testthat::test_that("column layout auto-fills ncol and defaults colour", {
  df <- data.frame(
    icon = letters[1:4], label = LETTERS[1:4], stringsAsFactors = FALSE
  )
  pos <- resolve_marker_legend_layout(
    df, "column", ncol = 2, col_spacing = 10, row_spacing = 1,
    default_color = "black"
  )
  testthat::expect_length(unique(pos$x), 2)
  testthat::expect_equal(pos$colour, rep("black", 4))
})

testthat::test_that("column layout honours explicit column and colour", {
  df <- data.frame(
    icon = c("a", "b"), label = c("A", "B"),
    colour = c("#FF0000", "#00FF00"), column = c(1, 2),
    stringsAsFactors = FALSE
  )
  pos <- resolve_marker_legend_layout(
    df, "column", ncol = 1, col_spacing = 10, row_spacing = 1,
    default_color = "black"
  )
  testthat::expect_equal(pos$colour, c("#FF0000", "#00FF00"))
  testthat::expect_equal(pos$x, c(0, 10))
})

testthat::test_that("grid layout places cells by row and col", {
  df <- data.frame(
    icon = c("a", "b", "c"), label = c("A", "B", "C"),
    row = c(1, 2, 1), col = c(1, 1, 2), stringsAsFactors = FALSE
  )
  pos <- resolve_marker_legend_layout(
    df, "grid", ncol = 1, col_spacing = 5, row_spacing = 2,
    default_color = "black"
  )
  testthat::expect_equal(pos$x, c(0, 0, 5))
  testthat::expect_equal(pos$y, c(0, -2, 0))
})

testthat::test_that("blank colour falls back to default", {
  df <- data.frame(
    icon = c("a", "b"), label = c("A", "B"),
    color = c("", NA), stringsAsFactors = FALSE
  )
  pos <- resolve_marker_legend_layout(
    df, "column", ncol = 1, col_spacing = 10, row_spacing = 1,
    default_color = "navy"
  )
  testthat::expect_equal(pos$colour, c("navy", "navy"))
})

# ******************************************************************************
# 03 marker_legend() return type ----------------------------------------------
# ******************************************************************************

testthat::test_that("marker_legend returns a ggplot from Font Awesome names alone", {
  df <- data.frame(
    icon = c("person", "person-dress", "star"),
    label = c("Men", "Women", "Highlighted"),
    colour = c("#1B9E77", "#D95F02", "#E7298A"),
    stringsAsFactors = FALSE
  )
  p <- marker_legend(df, title = "Groups")
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 04 visual snapshot of a standalone composite legend -------------------------
# ******************************************************************************

testthat::test_that("marker_legend composite renders (snapshot)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  # Two semantic colour-columns of bundled markers - the kind of standalone
  # composite ggplot2 guides cannot produce in one figure.
  pink <- "#FF1493"
  green <- "#006400"
  df_legend <- rbind(
    data.frame(
      column = 1, colour = pink,
      icon = c("square-inset", "circle-hollow", "square-cross", "circle-solid"),
      label = c("Start 45y", "Start 50y", "Stop 80y", "Stop 85y")
    ),
    data.frame(
      column = 2, colour = green,
      icon = c("square-inset", "square-hollow", "square-cross", "square-solid"),
      label = c("Begin 45y", "Begin 50y", "End 80y", "End 85y")
    ),
    stringsAsFactors = FALSE
  )

  p <- marker_legend(
    df_legend, marker_size = 3, label_size = 2.6, dpi = 120, col_spacing = 12
  )

  path <- tempfile(fileext = ".png")
  ggplot2::ggsave(path, p, width = 7, height = 2, dpi = 120, bg = "white")
  testthat::expect_snapshot_file(path, "marker-legend-composite.png")
})
