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
  # compare structurally: identical() on whole ggplots is brittle (internal
  # ggproto/scales environments differ even for the same plot)
  testthat::expect_s3_class(composite$main, "ggplot")
  testthat::expect_s3_class(composite$strip, "ggplot")
  testthat::expect_identical(composite$main$layers, main$layers)
  testthat::expect_identical(composite$strip$layers, strip$layers)
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

# ******************************************************************************
# 05 visual snapshot: SimCRC-style icon scatter + full grid/group/symbol legend -
# ******************************************************************************

testthat::test_that("legend_strip composite of an icon scatter + grid/group/symbol legend_canvas renders (snapshot, #393)", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("rsvg")
  testthat::skip_if_not_installed("magick")

  df_points <- data.frame(
    x     = c(1, 2, 3, 4),
    y     = c(1, 2, 1.5, 2.5),
    icon  = c("square-inset", "circle-inset", "square-inset", "circle-inset"),
    group = c("A", "A", "B", "B"),
    stringsAsFactors = FALSE
  )
  group_colors <- c(A = "palevioletred1", B = "lightseagreen")

  p_main <- ggplot2::ggplot(df_points, ggplot2::aes(x, y)) +
    geom_icon_point(
      ggplot2::aes(icon = icon, colour = group),
      size = 3, dpi = 120, legend_icons = FALSE, show.legend = FALSE
    ) +
    ggplot2::scale_colour_manual(values = group_colors, guide = "none") +
    ggplot2::theme_classic()

  df_legend <- rbind(
    data.frame(
      section = "grid", type = "icon",
      label = c("A", "B"), icon = c("square-inset", "circle-inset"),
      row = c(1, 1), col = c(1, 2), color = NA,
      stringsAsFactors = FALSE
    ),
    data.frame(
      section = "group", type = "swatch",
      label = names(group_colors), color = unname(group_colors),
      icon = NA, row = NA, col = NA,
      stringsAsFactors = FALSE
    ),
    data.frame(
      section = "key",
      type    = c("line", "point"),
      label   = c("Trend", "Flagged"),
      icon = NA, row = NA, col = NA,
      color   = c("black", "black"),
      stringsAsFactors = FALSE
    )
  )

  p_legend <- legend_canvas(
    df_legend,
    group_section  = "group", group_title = "Group", group_width = 0.3,
    symbol_section = "key", symbol_key_width = 0.2,
    col_spacing = 1, row_spacing = 1, label_gap = 0.2,
    marker_size = 3, label_size = 2.5, dpi = 120
  )

  path <- tempfile(fileext = ".png")
  ggplot2::ggsave(
    path, p_main + legend_strip(p_legend, height = 1.2),
    width = 6, height = 5, dpi = 120, bg = "white"
  )
  testthat::expect_snapshot_file(path, "legend-strip-simcrc-style.png")
})

# ******************************************************************************
# 06 patchwork main support -------------------------------------------------------
# ******************************************************************************

testthat::test_that("composite_grob() renders every panel of a patchwork main, not just the last", {
  testthat::skip_if_not_installed("patchwork")

  p1 <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(data.frame(x = 2, y = 2), ggplot2::aes(x, y)) + ggplot2::geom_point()
  p_patch <- p1 + p2 + patchwork::plot_layout(nrow = 1)

  g_wrong <- ggplot2::ggplotGrob(p_patch)
  g_right <- composite_grob(p_patch)

  testthat::expect_gt(length(g_right$grobs), length(g_wrong$grobs))
})

testthat::test_that("legend_strip composite with a patchwork main renders without error", {
  testthat::skip_if_not_installed("patchwork")

  p1 <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  p2 <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) + ggplot2::geom_point()
  p_main <- p1 + p2 + patchwork::plot_layout(nrow = 1)
  strip  <- ggplot2::ggplot(data.frame(x = 1, y = 1), ggplot2::aes(x, y)) +
    ggplot2::geom_point() + ggplot2::theme_void()
  composite <- p_main + legend_strip(strip, height = 1)

  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path, width = 8, height = 5)
  on.exit(grDevices::dev.off(), add = TRUE)

  testthat::expect_no_error(print(composite))
})

testthat::test_that("composite_grob() errors clearly when patchwork isn't installed", {
  testthat::local_mocked_bindings(requireNamespace = function(...) FALSE, .package = "base")

  p1 <- structure(list(), class = c("patchwork", "gg", "ggplot"))
  testthat::expect_error(composite_grob(p1), "patchwork")
})
