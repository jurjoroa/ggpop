# *****************************************************************************
#
# Script: test-11_advanced-scenarios.R
#
# Purpose: Test advanced scenarios for geom_pop and geom_icon_point
#
# Author: GitHub Copilot (Test Coverage Analysis)
#
# Date Created: 14-Feb-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests advanced usage patterns
#   - Multiple layers, faceting, seed reproducibility, custom scales
#   - Integration scenarios not covered by basic tests
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")

# ******************************************************************************
# 02 Test fixtures -------------------------------------------------------------
# ******************************************************************************

df_scatter <- data.frame(
  x = 1:10,
  y = 1:10,
  icon = rep(c("circle", "star"), 5),
  category = rep(c("A", "B"), 5),
  stringsAsFactors = FALSE
)

df_pop <- data.frame(
  sex = rep(c("M", "F"), each = 20),
  icon = rep(c("male", "female"), each = 20),
  stringsAsFactors = FALSE
)

# ******************************************************************************
# 03 Multiple geom_icon_point layers ------------------------------------------
# ******************************************************************************

testthat::test_that("Multiple geom_icon_point layers work together", {
  df1 <- df_scatter[1:5, ]
  df2 <- df_scatter[6:10, ]
  
  p <- ggplot2::ggplot() +
    geom_icon_point(
      data = df1,
      ggplot2::aes(x = x, y = y, icon = icon),
      size = 2,
      color = "blue"
    ) +
    geom_icon_point(
      data = df2,
      ggplot2::aes(x = x, y = y, icon = icon),
      size = 3,
      color = "red"
    )
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_equal(length(p$layers), 2)
})

testthat::test_that("geom_icon_point can be combined with geom_point", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_point(color = "gray", alpha = 0.3) +
    geom_icon_point(ggplot2::aes(icon = icon), size = 2)
  
  testthat::expect_s3_class(p, "ggplot")
  testthat::expect_equal(length(p$layers), 2)
})

testthat::test_that("geom_icon_point works with stat layers", {
  testthat::skip_on_cran()
  
  df_trend <- data.frame(
    x = 1:20,
    y = 1:20 + rnorm(20, sd = 2),
    icon = "circle",
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_trend, ggplot2::aes(x = x, y = y)) +
    ggplot2::geom_smooth(method = "lm", se = FALSE, color = "gray") +
    geom_icon_point(ggplot2::aes(icon = icon), size = 1.5)
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 04 geom_icon_point faceting -------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point works with facet_wrap", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::facet_wrap(~ category)
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot2::ggplot_build(p)
  testthat::expect_true(!is.null(built))
})

testthat::test_that("geom_icon_point works with facet_grid", {
  df_grid <- df_scatter
  df_grid$row_facet <- rep(c("R1", "R2"), 5)
  
  p <- ggplot2::ggplot(df_grid, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::facet_grid(row_facet ~ category)
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot2::ggplot_build(p)
  testthat::expect_true(!is.null(built))
})

testthat::test_that("geom_icon_point respects facet scales", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::facet_wrap(~ category, scales = "free")
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 05 Seed reproducibility tests ----------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop with seed produces reproducible results", {
  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 12345,
      arrange = FALSE
    )
  
  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 12345,
      arrange = FALSE
    )
  
  # Extract layer data
  data1 <- p1$layer[[1]]$layer$data
  data2 <- p2$layer[[1]]$layer$data
  
  # Should have same ordering
  testthat::expect_equal(data1$x1, data2$x1)
  testthat::expect_equal(data1$y1, data2$y1)
})

testthat::test_that("geom_pop with different seeds produces different results", {
  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 111,
      arrange = FALSE
    )
  
  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 222,
      arrange = FALSE
    )
  
  data1 <- p1$layer[[1]]$layer$data
  data2 <- p2$layer[[1]]$layer$data
  
  # Should have different ordering
  testthat::expect_false(all(data1$x1 == data2$x1))
})

testthat::test_that("geom_pop with arrange=TRUE ignores seed", {
  p1 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 111,
      arrange = TRUE
    )
  
  p2 <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      seed = 222,
      arrange = TRUE
    )
  
  data1 <- p1$layer[[1]]$layer$data
  data2 <- p2$layer[[1]]$layer$data
  
  # Should be identical (arrange overrides seed)
  testthat::expect_equal(data1$type, data2$type)
})

# ******************************************************************************
# 06 Custom color scales ------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point works with scale_color_manual", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_color_manual(values = c("A" = "red", "B" = "blue"))
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot2::ggplot_build(p)
  testthat::expect_true(!is.null(built))
})

testthat::test_that("geom_pop works with scale_color_manual", {
  p <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex, color = sex),
      size = 2
    ) +
    ggplot2::scale_color_manual(values = c("M" = "#3498db", "F" = "#e74c3c"))
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("geom_icon_point works with scale_color_viridis", {
  testthat::skip_if_not_installed("viridis")
  
  df_numeric_color <- df_scatter
  df_numeric_color$value <- 1:10
  
  p <- ggplot2::ggplot(df_numeric_color, ggplot2::aes(x = x, y = y, icon = icon, color = value)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_color_viridis_c()
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 07 Coordinate systems -------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point works with coord_flip", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::coord_flip()
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot2::ggplot_build(p)
  testthat::expect_true(!is.null(built))
})

testthat::test_that("geom_icon_point works with coord_fixed", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::coord_fixed(ratio = 1)
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("geom_icon_point works with coord_cartesian limits", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::coord_cartesian(xlim = c(0, 15), ylim = c(0, 15))
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 08 Theme interactions -------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point works with theme_minimal", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::theme_minimal()
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("geom_icon_point works with custom theme", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
    geom_icon_point(size = 2) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid = ggplot2::element_blank()
    )
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("geom_pop works with theme_void", {
  p <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex),
      size = 2
    ) +
    ggplot2::theme_void()
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 09 Legend positioning -------------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point legend can be positioned", {
  positions <- c("top", "bottom", "left", "right", "none")
  
  for (pos in positions) {
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(size = 2) +
      ggplot2::theme(legend.position = pos)
    
    testthat::expect_s3_class(p, "ggplot")
  }
})

testthat::test_that("geom_pop legend can be positioned", {
  p <- ggplot2::ggplot() +
    geom_pop(
      data = df_pop,
      ggplot2::aes(icon = icon, group = sex, color = sex),
      size = 2
    ) +
    ggplot2::theme(legend.position = "bottom")
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 10 Scale transformations ----------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point works with log-scale axes", {
  df_log <- data.frame(
    x = 10^(1:5),
    y = 10^(1:5),
    icon = "circle",
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot(df_log, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_x_log10() +
    ggplot2::scale_y_log10()
  
  testthat::expect_s3_class(p, "ggplot")
  built <- ggplot2::ggplot_build(p)
  testthat::expect_true(!is.null(built))
})

testthat::test_that("geom_icon_point works with reversed axes", {
  p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
    geom_icon_point(size = 2) +
    ggplot2::scale_x_reverse() +
    ggplot2::scale_y_reverse()
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 11 Large icon volume tests --------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop handles near-maximum icon count", {
  df_large <- data.frame(
    sex = rep(c("M", "F"), length.out = 999),
    icon = rep(c("male", "female"), length.out = 999),
    stringsAsFactors = FALSE
  )
  
  p <- ggplot2::ggplot() +
    geom_pop(
      data = df_large,
      ggplot2::aes(icon = icon, group = sex),
      size = 1
    )
  
  testthat::expect_s3_class(p, "ggplot")
})

testthat::test_that("geom_pop with facets handles large total count", {
  df_faceted_large <- data.frame(
    sex = rep(c("M", "F"), length.out = 800),
    icon = rep(c("male", "female"), length.out = 800),
    region = rep(c("A", "B"), each = 400),
    stringsAsFactors = FALSE
  )
  
  # 400 per facet = 800 total (within limits)
  suppressWarnings({
    p <- ggplot2::ggplot() +
      geom_pop(
        data = df_faceted_large,
        ggplot2::aes(icon = icon, group = sex),
        facet = region,
        size = 1
      )
  })
  
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# 12 NA handling in aesthetics ------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_icon_point handles NA in color aesthetic", {
  df_na_color <- df_scatter
  df_na_color$category[c(2, 4)] <- NA
  
  testthat::expect_warning({
    tmp <- tempfile(fileext = ".png")
    png(tmp)
    print(
      ggplot2::ggplot(df_na_color, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
        geom_icon_point(size = 2)
    )
    dev.off()
    unlink(tmp)
  })
})

testthat::test_that("geom_icon_point handles NA in size aesthetic", {
  df_na_size <- df_scatter
  df_na_size$size_var <- c(1, 2, NA, 3, 4, 1, 2, 3, 4, 5)
  
  testthat::expect_warning({
    tmp <- tempfile(fileext = ".png")
    png(tmp)
    print(
      ggplot2::ggplot(df_na_size, ggplot2::aes(x = x, y = y, icon = icon, size = size_var)) +
        geom_icon_point()
    )
    dev.off()
    unlink(tmp)
  })
})

# ******************************************************************************
# 13 Reserved column names ----------------------------------------------------
# ******************************************************************************

testthat::test_that("geom_pop detects all reserved column names", {
  reserved_names <- c("x1", "y1", "pos", "coord_size", "icon_size", "image", "original_order")
  
  for (col_name in reserved_names) {
    df_reserved <- df_pop
    df_reserved[[col_name]] <- 1:nrow(df_reserved)
    
    testthat::expect_error(
      ggplot2::ggplot() +
        geom_pop(
          data = df_reserved,
          ggplot2::aes(icon = icon, group = sex)
        ),
      regexp = "reserved"
    )
  }
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
