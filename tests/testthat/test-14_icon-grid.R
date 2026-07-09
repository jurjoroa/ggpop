# *****************************************************************************
#
# Script: test-14_icon-grid.R
#
# Purpose: Test icon_grid() - derives icon grid rows from plot data for
#          legend_canvas()
#
# Author: Jorge Roa
#
# Date Created: 08-Jul-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers issue #385: icon_grid() in legend-canvas.R
#   - icon_grid() output is meant to be rbind()-able with group/symbol rows
#     before being passed to legend_canvas()
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")

# ******************************************************************************
# 01 basic derivation -----------------------------------------------------------
# ******************************************************************************

testthat::test_that("derives row/col positions from unique combinations", {
  df <- data.frame(
    start_age = c(45, 45, 50, 50),
    stop_age  = c(70, 75, 70, 75),
    icon      = c("square-inset", "square-hollow", "circle-inset", "circle-hollow"),
    label     = c("45-70y", "45-75y", "50-70y", "50-75y"),
    stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "start_age", col = "stop_age")

  testthat::expect_equal(
    names(g), c("section", "type", "label", "color", "icon", "row", "col")
  )
  testthat::expect_equal(g$row, c(1, 1, 2, 2))
  testthat::expect_equal(g$col, c(1, 2, 1, 2))
  testthat::expect_equal(g$icon, df$icon)
  testthat::expect_equal(g$label, df$label)
})

testthat::test_that("section defaults to 'grid' and type is always 'icon'", {
  df <- data.frame(
    r = c(1, 2), c = c(1, 1), icon = c("a", "b"), label = c("A", "B"),
    stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "r", col = "c")
  testthat::expect_equal(unique(g$section), "grid")
  testthat::expect_equal(unique(g$type), "icon")
  testthat::expect_true(all(is.na(g$color)))
})

testthat::test_that("custom section value is honoured", {
  df <- data.frame(
    r = 1, c = 1, icon = "a", label = "A", stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "r", col = "c", section = "once_only")
  testthat::expect_equal(g$section, "once_only")
})

# ******************************************************************************
# 02 deduplication --------------------------------------------------------------
# ******************************************************************************

testthat::test_that("collapses duplicate row/col/icon/label combinations", {
  df <- data.frame(
    r = c(1, 1, 1, 2), c = c(1, 1, 1, 1),
    icon = c("a", "a", "a", "b"), label = c("A", "A", "A", "B"),
    stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "r", col = "c")
  testthat::expect_equal(nrow(g), 2)
})

# ******************************************************************************
# 03 row/col ordering ------------------------------------------------------------
# ******************************************************************************

testthat::test_that("non-factor row/col use sorted unique order", {
  df <- data.frame(
    r = c(55, 45, 50), c = 1,
    icon = c("a", "b", "c"), label = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "r", col = "c")
  # sorted unique r: 45, 50, 55 -> rows 1, 2, 3
  testthat::expect_equal(g$row[g$label == "B"], 1) # r = 45
  testthat::expect_equal(g$row[g$label == "C"], 2) # r = 50
  testthat::expect_equal(g$row[g$label == "A"], 3) # r = 55
})

testthat::test_that("factor row/col preserve factor level order, not sort order", {
  df <- data.frame(
    r = factor(c("55-70y", "45-70y", "50-70y"), levels = c("55-70y", "45-70y", "50-70y")),
    c = 1,
    icon = c("a", "b", "c"), label = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )

  g <- icon_grid(df, icon = "icon", label = "label", row = "r", col = "c")
  # factor level order is 55, 45, 50 -> rows 1, 2, 3 respectively
  testthat::expect_equal(g$row[g$label == "A"], 1) # r = "55-70y"
  testthat::expect_equal(g$row[g$label == "B"], 2) # r = "45-70y"
  testthat::expect_equal(g$row[g$label == "C"], 3) # r = "50-70y"
})

# ******************************************************************************
# 04 label_fn --------------------------------------------------------------------
# ******************************************************************************

testthat::test_that("label_fn transforms labels after derivation", {
  df <- data.frame(
    r = 1, c = 1, icon = "a", label = "45 - 70 y", stringsAsFactors = FALSE
  )

  g <- icon_grid(
    df, icon = "icon", label = "label", row = "r", col = "c",
    label_fn = function(x) gsub(" ", "", x)
  )
  testthat::expect_equal(g$label, "45-70y")
})

testthat::test_that("label_fn must be a function", {
  df <- data.frame(
    r = 1, c = 1, icon = "a", label = "A", stringsAsFactors = FALSE
  )

  testthat::expect_error(
    icon_grid(df, icon = "icon", label = "label", row = "r", col = "c", label_fn = "not_a_function"),
    "function"
  )
})
