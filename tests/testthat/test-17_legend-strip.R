# *****************************************************************************
#
# Script: test-17_legend-strip.R
#
# Purpose: Test legend_strip() - stacks a plot above a legend canvas via grid
#          viewports (ggpop_composite)
#
# Author: Jorge Roa
#
# Date Created: 08-Jul-2026
#
# *****************************************************************************
#
# Notes:
#   - Covers issue #385: legend_strip() in legend-strip.R
#   - draw_composite() pushes/pops grid viewports directly - tests render to
#     a temp pdf/png device rather than the ambient device, and always
#     clean up with on.exit()
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")

# ******************************************************************************
# 01 legend_strip() object -------------------------------------------------------
# ******************************************************************************

testthat::test_that("legend_strip returns a ggpop_legend_strip object", {
  strip <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) + ggplot2::geom_point()
  obj <- legend_strip(strip, height = 1.5)

  testthat::expect_s3_class(obj, "ggpop_legend_strip")
  testthat::expect_identical(obj$strip_plot, strip)
  testthat::expect_equal(obj$height, 1.5)
})

# ******************************************************************************
# 02 ggplot_add.ggpop_legend_strip -----------------------------------------------
# ******************************************************************************

testthat::test_that("adding legend_strip to a ggplot produces a ggpop_composite", {
  main  <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  strip <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) + ggplot2::geom_point()

  composite <- main + legend_strip(strip, height = 1.2)

  testthat::expect_s3_class(composite, "ggpop_composite")
  testthat::expect_identical(composite$main, main)
  testthat::expect_identical(composite$strip, strip)
  testthat::expect_equal(composite$strip_height, 1.2)
})

# ******************************************************************************
# 03 rendering smoke tests --------------------------------------------------------
# ******************************************************************************

testthat::test_that("print.ggpop_composite renders without error", {
  main  <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  strip <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::theme_void()
  composite <- main + legend_strip(strip, height = 1)

  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path, width = 6, height = 5)
  on.exit(grDevices::dev.off(), add = TRUE)

  testthat::expect_no_error(print(composite))
})

testthat::test_that("grid.draw.ggpop_composite renders without error", {
  main  <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  strip <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::theme_void()
  composite <- main + legend_strip(strip, height = 1)

  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path, width = 6, height = 5)
  on.exit(grDevices::dev.off(), add = TRUE)
  grid::grid.newpage()

  testthat::expect_no_error(grid::grid.draw(composite))
})

# ******************************************************************************
# 04 visual snapshot: real plot + legend_canvas() composite ---------------------
# ******************************************************************************

testthat::test_that("legend_strip composite of a plot + legend_canvas renders (snapshot)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  p_main <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme_classic()

  df_legend <- data.frame(
    section = "grid", type = "icon",
    label = c("A", "B"), icon = c("square-inset", "circle-inset"),
    row = c(1, 1), col = c(1, 2), color = NA,
    stringsAsFactors = FALSE
  )
  p_legend <- legend_canvas(
    df_legend,
    col_spacing = 1, row_spacing = 1, label_gap = 0.2,
    marker_size = 3, label_size = 2.5, dpi = 120
  )

  path <- tempfile(fileext = ".png")
  ggplot2::ggsave(
    path, p_main + legend_strip(p_legend, height = 1),
    width = 5, height = 4, dpi = 120, bg = "white"
  )
  testthat::expect_snapshot_file(path, "legend-strip-composite.png")
})
