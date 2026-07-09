# *****************************************************************************
#
# Script: test-16_key-legend.R
#
# Purpose: Test key_legend() - adds swatch/line/point key entries to a legend
#          canvas, and its internal normalize/validate/position helpers
#
# Author: Jorge Roa
#
# Date Created: 08-Jul-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers issue #385: key_legend() in key_legend.R
#   - Only "swatch", "line", "point" are valid types here; "icon" belongs to
#     legend_canvas()'s grid path instead (see test-15_legend-canvas.R)
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")

geom_classes <- function(p) vapply(p$layers, function(l) class(l$geom)[1], character(1))

# ******************************************************************************
# 01 normalize_key_legend_entries -----------------------------------------------
# ******************************************************************************

testthat::test_that("fills in default linetype, linewidth, and pch", {
  df <- data.frame(type = "line", label = "Trend", color = "black", stringsAsFactors = FALSE)
  norm <- ggpop:::normalize_key_legend_entries(df)
  testthat::expect_equal(norm$linetype, "solid")
  testthat::expect_equal(norm$linewidth, 0.8)
  testthat::expect_true(is.na(norm$pch))
})

testthat::test_that("maps colour to color when color is absent", {
  df <- data.frame(type = "swatch", label = "Grey zone", colour = "grey75", stringsAsFactors = FALSE)
  norm <- ggpop:::normalize_key_legend_entries(df)
  testthat::expect_equal(norm$color, "grey75")
})

testthat::test_that("accepts a named list where names supply the type", {
  entries <- list(
    swatch = "Grey zone",
    line   = list(label = "Trend", color = "blue")
  )
  norm <- ggpop:::normalize_key_legend_entries(entries)
  testthat::expect_equal(norm$type, c("swatch", "line"))
  testthat::expect_equal(norm$label, c("Grey zone", "Trend"))
})

testthat::test_that("rejects non-data-frame, non-list entries", {
  testthat::expect_error(ggpop:::normalize_key_legend_entries("not entries"), "data frame")
})

testthat::test_that("rejects entries missing required columns", {
  testthat::expect_error(
    ggpop:::normalize_key_legend_entries(data.frame(type = "swatch")),
    "missing required column"
  )
})

testthat::test_that("rejects invalid type values", {
  testthat::expect_error(
    ggpop:::normalize_key_legend_entries(
      data.frame(type = "banana", label = "X", color = "black", stringsAsFactors = FALSE)
    ),
    "invalid value"
  )
})

# ******************************************************************************
# 02 key_legend_y_positions ------------------------------------------------------
# ******************************************************************************

testthat::test_that("y_start = NULL places entry 1 at the title row", {
  obj <- list(entries = data.frame(x = 1:3), row_spacing = 2, title_frac = 0.85, y_start = NULL)
  y <- ggpop:::key_legend_y_positions(obj)
  testthat::expect_equal(y, c(2 * 0.85, 0, -2))
})

testthat::test_that("y_start = 0 places entry 1 at row 1", {
  obj <- list(entries = data.frame(x = 1:3), row_spacing = 2, title_frac = 0.85, y_start = 0)
  y <- ggpop:::key_legend_y_positions(obj)
  testthat::expect_equal(y, c(0, -2, -4))
})

# ******************************************************************************
# 03 key_legend() object -------------------------------------------------------
# ******************************************************************************

testthat::test_that("key_legend returns a ggpop_key_legend object", {
  ef <- data.frame(type = "point", label = "Near efficient", color = "black", stringsAsFactors = FALSE)
  obj <- key_legend(ef, row_spacing = 1, key_width = 0.3)
  testthat::expect_s3_class(obj, "ggpop_key_legend")
  testthat::expect_equal(obj$title_color, obj$label_color) # inherits label_color when NULL
})

# ******************************************************************************
# 04 type dispatch --------------------------------------------------------------
# ******************************************************************************

testthat::test_that("swatch entries render as a filled rect", {
  df <- data.frame(type = "swatch", label = "Grey zone", color = "grey75", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  testthat::expect_equal(geom_classes(p), "GeomRect")
})

testthat::test_that("line entries render as a segment", {
  df <- data.frame(type = "line", label = "Efficient frontier", color = "black", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  testthat::expect_equal(geom_classes(p), "GeomSegment")
})

testthat::test_that("point entries render as text, default glyph is an asterisk", {
  df <- data.frame(type = "point", label = "Near efficient", color = "black", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  testthat::expect_equal(geom_classes(p), "GeomText")
  # first layer is the point glyph itself (label layer is added second)
  testthat::expect_equal(p$layers[[1]]$data$label, "*")
})

testthat::test_that("point entries honour a custom pch character", {
  df <- data.frame(
    type = "point", label = "Flagged", color = "black", pch = "†",
    stringsAsFactors = FALSE
  )
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  testthat::expect_equal(p$layers[[1]]$data$label, "†")
})

testthat::test_that("mixed types in one entries data frame each dispatch correctly", {
  df <- data.frame(
    type  = c("line", "swatch", "point"),
    label = c("Efficient frontier", "Grey zone", "Near efficient"),
    color = c("black", "grey75", "black"),
    stringsAsFactors = FALSE
  )
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  classes <- geom_classes(p)
  testthat::expect_true(all(c("GeomSegment", "GeomRect", "GeomText") %in% classes))
})

testthat::test_that("unsupported type errors through the public entry point", {
  df <- data.frame(type = "banana", label = "X", color = "black", stringsAsFactors = FALSE)
  testthat::expect_error(
    key_legend(df, row_spacing = 1, key_width = 0.3),
    "invalid value"
  )
})

# ******************************************************************************
# 05 label_inside placement ------------------------------------------------------
# ******************************************************************************

testthat::test_that("label_inside centers the label inside a swatch instead of beside it", {
  df <- data.frame(type = "swatch", label = "FIT", color = "pink", stringsAsFactors = FALSE)

  p_outside <- ggplot2::ggplot() + key_legend(df, x = 0, row_spacing = 1, key_width = 0.3, label_gap = 0.05)
  p_inside  <- ggplot2::ggplot() + key_legend(df, x = 0, row_spacing = 1, key_width = 0.3, label_gap = 0.05, label_inside = TRUE)

  label_layer <- function(p) p$layers[[which(geom_classes(p) == "GeomText")]]

  testthat::expect_equal(label_layer(p_outside)$data$x, 0.3 + 0.05) # x + key_width + label_gap
  testthat::expect_equal(label_layer(p_inside)$data$x, 0.15)        # x + key_width / 2
})

testthat::test_that("label_inside has no effect on non-swatch types", {
  df <- data.frame(type = "line", label = "Trend", color = "black", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, x = 0, row_spacing = 1, key_width = 0.3, label_gap = 0.05, label_inside = TRUE)
  label_layer <- p$layers[[which(geom_classes(p) == "GeomText")]]
  testthat::expect_equal(label_layer$data$x, 0.3 + 0.05) # still outside - label_inside gates on type == "swatch"
})

# ******************************************************************************
# 06 title rendering -------------------------------------------------------------
# ******************************************************************************

testthat::test_that("title is drawn as its own text layer when provided", {
  df <- data.frame(type = "swatch", label = "FIT", color = "pink", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3, title = "Modality")
  labels <- unlist(lapply(p$layers, function(l) if (inherits(l$geom, "GeomText")) l$data$label else NULL))
  testthat::expect_true("Modality" %in% labels)
})

testthat::test_that("no title layer is added when title is NULL", {
  df <- data.frame(type = "swatch", label = "FIT", color = "pink", stringsAsFactors = FALSE)
  p <- ggplot2::ggplot() + key_legend(df, row_spacing = 1, key_width = 0.3)
  # one entry => exactly 2 layers (key + label), no extra title layer
  testthat::expect_length(p$layers, 2)
})

# ******************************************************************************
# 07 print.ggpop_key_legend (standalone render) ---------------------------------
# ******************************************************************************

testthat::test_that("print.ggpop_key_legend does not error", {
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit(grDevices::dev.off(), add = TRUE)

  ef <- data.frame(type = "point", label = "Near efficient", color = "black", stringsAsFactors = FALSE)
  testthat::expect_no_error(print(key_legend(ef, row_spacing = 1, key_width = 0.3)))
})
