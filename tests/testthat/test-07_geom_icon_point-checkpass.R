# *****************************************************************************
#
# Script: test-geom_pop-clean.R
#
# Purpose: Ensure geom_pop() works robustly for all valid scenarios
#          without warnings or errors.
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")


# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

df_scatter <- data.frame(
  x    = c(1, 2, 3, 4, 5),
  y    = c(2, 4, 3, 5, 6),
  icon = c("circle", "star", "circle", "star", "heart"),
  category = c("A", "B", "A", "B", "C"),
  point_size = c(2, 3, 2, 4, 3),
  stringsAsFactors = FALSE
)

df_scatter_no_icon <- data.frame(
  x = c(1, 2, 3, 4),
  y = c(2, 4, 3, 5),
  category = c("A", "B", "A", "B"),
  stringsAsFactors = FALSE
)

# ******************************************************************************
## 03.09 Real-world usage patterns ---------------------------------------------
# ******************************************************************************

### 03.09.01 Typical usage: data in ggplot, minimal geom params ----------------

testthat::test_that("Real-world: data in ggplot, size in geom (no warning)", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(size = 4, dpi = 72)
  )
})

### 03.09.02 Typical usage: layering with geom_point ---------------------------

testthat::test_that("Real-world: combine with geom_point (no warning)", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, color = category)) +
      ggplot2::geom_point(size = 8, alpha = 0.3) +
      geom_icon_point(ggplot2::aes(icon = icon), size = 3)
  )
})

### 03.09.03 Typical usage: faceting with icon points --------------------------

testthat::test_that("Real-world: faceted plot (no warning)", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = 4, color = "steelblue") +
      ggplot2::facet_wrap(~category)
  )
})

### 03.09.04 Advanced: icon mapping with size mapping --------------------------

testthat::test_that("Real-world: both icon and size mapped (no warning)", {
  testthat::expect_no_warning(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = point_size)) +
      geom_icon_point(color = "darkred", dpi = 100)
  )
})

### 03.09.05 Advanced: multiple icon point layers ------------------------------

testthat::test_that("Real-world: multiple layers with different data", {
  df_background <- df_scatter[1:3, ]
  df_highlight <- df_scatter[4:5, ]
  
  testthat::expect_no_warning(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_background,
        ggplot2::aes(x = x, y = y, icon = icon),
        size = 2,
        alpha = 0.3,
        color = "gray"
      ) +
      geom_icon_point(
        data = df_highlight,
        ggplot2::aes(x = x, y = y, icon = icon),
        size = 5,
        color = "red"
      )
  )
})

### 03.09.06 Edge case: empty data but valid structure -------------------------

# testthat::test_that("Edge case: empty dataframe (no warning)", {
#   df_empty <- df_scatter[0, ]
#   
#   testthat::expect_no_warning(
#     ggplot2::ggplot(df_empty, ggplot2::aes(x = x, y = y, icon = icon)) +
#       geom_icon_point(size = 3)
#   )
# })

### 03.09.07 Edge case: single point -------------------------------------------

testthat::test_that("Edge case: single point (no warning)", {
  df_single <- df_scatter[1, ]
  
  testthat::expect_no_warning(
    ggplot2::ggplot(df_single, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = 5, color = "blue")
  )
})

### 03.09.08 Complex: all aesthetics + parameters ------------------------------

testthat::test_that("Real-world: complex plot with many aesthetics", {
  testthat::expect_no_warning(
    ggplot2::ggplot(
      df_scatter, 
      ggplot2::aes(x = x, y = y, icon = icon, color = category, alpha = point_size)
    ) +
      geom_icon_point(size = 4, dpi = 100) +
      ggplot2::scale_alpha_continuous(range = c(0.3, 1)) +
      ggplot2::theme_minimal()
  )
})


# ******************************************************************************
## 03.09 Edge cases: boundary conditions ---------------------------------------
# ******************************************************************************

### 03.09.01 Single row data ---------------------------------------------------

testthat::test_that("No error: single row data (valid edge case)", {
  df_single <- df_scatter[1, ]
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_single, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

### 03.09.02 Two rows data -----------------------------------------------------

testthat::test_that("No error: two rows data (valid edge case)", {
  df_two <- df_scatter[1:2, ]
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_two, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

### 03.09.03 Very large coordinates --------------------------------------------

testthat::test_that("No error: very large coordinates (valid)", {
  df_large <- data.frame(
    x = c(1e6, 1e7, 1e8),
    y = c(1e6, 1e7, 1e8),
    icon = c("circle", "star", "heart"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_large, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

### 03.09.04 Negative coordinates ----------------------------------------------

testthat::test_that("No error: negative coordinates (valid)", {
  df_negative <- data.frame(
    x = c(-5, -3, -1, 1, 3),
    y = c(-4, -2, 0, 2, 4),
    icon = rep("circle", 5),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_negative, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

### 03.09.05 Zero coordinates --------------------------------------------------

testthat::test_that("No error: zero coordinates (valid)", {
  df_zero <- data.frame(
    x = c(0, 0, 1, 2),
    y = c(0, 1, 0, 2),
    icon = rep("circle", 4),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_no_error(
    ggplot2::ggplot(df_zero, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

# ******************************************************************************
## 03.10 Parameter validation completeness -------------------------------------
# ******************************************************************************

### 03.10.01 stat parameter (should accept valid values) -----------------------

testthat::test_that("No error: valid stat parameter", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(stat = "identity")
  )
})

### 03.10.02 position parameter (should accept valid values) -------------------

testthat::test_that("No error: valid position parameter", {
  testthat::expect_no_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(position = "identity")
  )
})

