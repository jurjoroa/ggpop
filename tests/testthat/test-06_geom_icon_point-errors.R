# *****************************************************************************
#
# Script: test-06_geom_icon_point-errors.R
#
# Purpose: Test errors (hard stops) produced by geom_icon_point().
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 26-Jan-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests ONLY errors (hard stops).
#   - We avoid matching exact error text to keep tests robust.
#   - We use ggplot() + geom_icon_point() directly whenever the error occurs pre-build.
#   - For integration-level failures (render/build), we call ggplot_build() or ggplotGrob().
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ------------------------------------------------------------------------------
# Test fixtures (minimal, stable)
# ------------------------------------------------------------------------------

df_scatter <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(2, 4, 3, 5, 6),
  icon = c("circle", "star", "circle", "star", "heart"),
  category = c("A", "B", "A", "B", "C"),
  point_size = c(2, 3, 2, 4, 3),
  stringsAsFactors = FALSE
)

df_no_icon <- data.frame(
  x = c(1, 2, 3, 4),
  y = c(2, 4, 3, 5),
  category = c("A", "B", "A", "B"),
  stringsAsFactors = FALSE
)

.build_plot <- function(p) ggplot2::ggplot_build(p)
.grob_plot <- function(p) ggplot2::ggplotGrob(p)

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 geom_icon_point -----------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Errors: input validation (hard stops) ---------------------------------
# ******************************************************************************

### 03.01.01 dpi inputs --------------------------------------------------------

testthat::test_that("Error: dpi too low", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = 20)
  )
})

testthat::test_that("Error: non-numeric dpi", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = "high")
  )
})

testthat::test_that("Error: vector dpi", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = c(50, 100))
  )
})

testthat::test_that("Error: NA dpi", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = NA)
  )
})

testthat::test_that("Error: Inf dpi", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(dpi = Inf)
  )
})

### 03.01.02 icon inputs -------------------------------------------------------

testthat::test_that("Error: icon not specified (no aes, no column, no parameter)", {
  testthat::expect_error(
    ggplot2::ggplot(df_no_icon, ggplot2::aes(x = x, y = y)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: invalid icon values (NA)", {
  df_bad_icon <- df_scatter
  df_bad_icon$icon[2] <- NA

  testthat::expect_error(
    ggplot2::ggplot(df_bad_icon, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: icon with whitespace only", {
  df_whitespace <- df_scatter
  df_whitespace$icon[2] <- "   "

  testthat::expect_error(
    ggplot2::ggplot(df_whitespace, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: icon with empty string", {
  df_empty <- df_scatter
  df_empty$icon[3] <- ""

  testthat::expect_error(
    ggplot2::ggplot(df_empty, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: icon aesthetic maps to non-existent column", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = nonexistent_column)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: icon is not specified", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y)) +
      geom_icon_point()
  )
})

### 03.01.03 image aesthetic (forbidden) ---------------------------------------

testthat::test_that("Error: image aesthetic is not allowed", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, image = icon)) +
      geom_icon_point()
  )
})

### 03.01.04 size inputs -------------------------------------------------------

testthat::test_that("Error: size variable not in data", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon, size = nonexistent_var)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: size is NA", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = NA)
  )
})

testthat::test_that("Error: size is Inf", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = Inf)
  )
})

testthat::test_that("Error: size is negative", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = -1)
  )
})

testthat::test_that("Error: size is zero", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = 0)
  )
})

testthat::test_that("Error: size is character", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = "large")
  )
})

testthat::test_that("Error: size is vector", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(size = c(3, 5))
  )
})


### 03.01.05 alpha inputs -------------------------------------------------------

testthat::test_that("Error: alpha = -0.1 throws error (ggplot pattern)", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = -0.1, color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})

testthat::test_that("Error: alpha = 1.5 throws error (geom pattern)", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = df_scatter,
        ggplot2::aes(x = x, y = y, icon = icon, color = category),
        alpha = 1.5
      ),
    regexp = "Invalid `alpha` value"
  )
})

testthat::test_that("Error: alpha = NA throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = NA, color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})
p <- ggplot2::ggplot(df_scatter, ggplot2::aes(icon = icon)) +
  geom_icon_point()

testthat::test_that("Error: alpha = NULL throws error", {
  testthat::expect_warning({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = NULL, color = "blue")
    ggplot2::ggplot_build(p)
    
  })
})

testthat::test_that("Error: alpha = point_size (bare name) throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = point_size, color = "blue")
  )
})

testthat::test_that("Error: alpha = 'high' throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = "high", color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})

testthat::test_that("Error: alpha = c(0.5, 0.8) throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = c(0.5, 0.8), color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})

testthat::test_that("Error: alpha = Inf throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = Inf, color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})

testthat::test_that("Error: alpha = -Inf throws error", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(alpha = -Inf, color = "blue"),
    regexp = "Invalid `alpha` value"
  )
})


### 03.01.06 data inputs -------------------------------------------------------

testthat::test_that("Error: data is not a data frame", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = "not a data frame",
        ggplot2::aes(x = x, y = y, icon = icon)
      )
  )
})

testthat::test_that("Error: data is NULL with no inherited data", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = NULL,
        ggplot2::aes(x = x, y = y, icon = icon)
      )
  )
})

testthat::test_that("Error: data is a list (not data frame)", {
  bad_data <- list(x = 1:5, y = 1:5, icon = "circle")

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = bad_data,
        ggplot2::aes(x = x, y = y, icon = icon)
      )
  )
})

testthat::test_that("Error: data is a matrix", {
  mat <- matrix(1:10, ncol = 2)
  colnames(mat) <- c("x", "y")

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = mat,
        ggplot2::aes(x = x, y = y, icon = icon)
      )
  )
})

testthat::test_that("Error: data is a vector", {
  vec <- c(1, 2, 3, 4, 5)

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = vec,
        ggplot2::aes(x = x, y = y, icon = icon)
      )
  )
})

# ******************************************************************************
## 03.02 Errors: coordinate validation -----------------------------------------
# ******************************************************************************

### 03.02.01 missing x aesthetic -----------------------------------------------

testthat::test_that("Error: missing x aesthetic (from ggimage)", {
  testthat::expect_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(y = y, icon = icon)) +
      geom_icon_point()
    ggplot2::ggplot_build(p) # Build to trigger ggimage error
  })
})

### 03.02.02 missing y aesthetic -----------------------------------------------

testthat::test_that("Error: missing y aesthetic (from ggimage)", {
  testthat::expect_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, icon = icon)) +
      geom_icon_point()
    ggplot2::ggplot_build(p) # Build to trigger ggimage error
  })
})

### 03.02.03 x/y variables not in data -----------------------------------------

testthat::test_that("Error: x variable not in data", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = nonexistent_x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: y variable not in data", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = nonexistent_y, icon = icon)) +
      geom_icon_point()
  )
})

# ******************************************************************************
## 03.03 Integration errors (build/render) -------------------------------------
# ******************************************************************************

### 03.03.01 unknown icon name (fontawesome render failure) --------------------

testthat::test_that("Integration: unknown icon name fails (build/render)", {
  df_unknown <- df_scatter
  df_unknown$icon <- "this_icon_does_not_exist_fontawesome"

  testthat::expect_error(
    ggplot2::ggplot(df_unknown, ggplot2::aes(x = x, y = y, icon = icon, color = category)) +
      geom_icon_point(legend_icons = TRUE)
  )
})

### 03.03.02 empty data frame (integration) ------------------------------------

testthat::test_that("Error: empty data frame", {
  df_empty <- data.frame(
    x = numeric(0),
    y = numeric(0),
    icon = character(0),
    stringsAsFactors = FALSE
  )

  # Empty data might not error immediately but should fail at build
  testthat::expect_error(
    ggplot2::ggplot(df_empty, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

# ******************************************************************************
## 03.04 Data type validation --------------------------------------------------
# ******************************************************************************

testthat::test_that("Error: data is an environment", {
  env <- new.env()
  env$x <- 1:5
  env$y <- 1:5
  env$icon <- "circle"

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = env,
        ggplot2::aes(x = x, y = y, icon = icon)
      ),
    regexp = "data.*must be.*data.*frame",
    ignore.case = TRUE
  )
})

testthat::test_that("Error: data is a function", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = mean,
        ggplot2::aes(x = x, y = y, icon = icon)
      ),
    regexp = "data.*must be.*data.*frame",
    ignore.case = TRUE
  )
})

testthat::test_that("Error: data is a named list (looks like data frame but isn't)", {
  bad_list <- list(
    x = c(1, 2, 3, 4, 5),
    y = c(2, 4, 3, 5, 6),
    icon = c("circle", "star", "circle", "star", "heart")
  )

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = bad_list,
        ggplot2::aes(x = x, y = y, icon = icon)
      ),
    regexp = "data.*must be.*data.*frame",
    ignore.case = TRUE
  )
})

testthat::test_that("Error: data is an array", {
  arr <- array(1:15, dim = c(5, 3))

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = arr,
        ggplot2::aes(x = x, y = y, icon = icon)
      ),
    regexp = "data.*must be.*data.*frame",
    ignore.case = TRUE
  )
})

testthat::test_that("Error: data is a nested list structure", {
  nested_list <- list(
    group1 = list(x = 1, y = 2, icon = "circle"),
    group2 = list(x = 3, y = 4, icon = "star")
  )

  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = nested_list,
        ggplot2::aes(x = x, y = y, icon = icon)
      ),
    regexp = "data.*must be.*data.*frame",
    ignore.case = TRUE
  )
})

# ******************************************************************************
## 03.05 Edge cases: parameter combinations ------------------------------------
# ******************************************************************************

### 03.05.01 Multiple invalid parameters ---------------------------------------

testthat::test_that("Error: multiple invalid parameters at once", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(
        size = -5, # Invalid size
        dpi = "high" # Invalid dpi
      )
  )
})

### 03.05.02 All parameters invalid --------------------------------------------

testthat::test_that("Error: all parameters invalid", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = "not_a_df",
        ggplot2::aes(x = x, y = y, icon = icon),
        size = NA,
        dpi = -10
      )
  )
})

# ******************************************************************************
## 03.06 Aesthetic validation --------------------------------------------------
# ******************************************************************************

### 03.06.01 Invalid aesthetic mappings ----------------------------------------

testthat::test_that("Error: mapping to non-existent columns", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(
      x = nonexistent_x,
      y = nonexistent_y,
      icon = nonexistent_icon
    )) +
      geom_icon_point()
  )
})

### 03.06.02 Required aesthetics missing ---------------------------------------

testthat::test_that("Error: both x and y missing", {
  testthat::expect_error({
    p <- ggplot2::ggplot(df_scatter, ggplot2::aes(icon = icon)) +
      geom_icon_point()
    ggplot2::ggplot_build(p)
  })
})

# ******************************************************************************
## 03.07 Legend parameters -----------------------------------------------------
# ******************************************************************************

### 03.07.01 Invalid legend_icons parameter ------------------------------------

testthat::test_that("Error: invalid legend_icons parameter (character)", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(legend_icons = "yes")
  )
})

testthat::test_that("Error: invalid legend_icons parameter (numeric)", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(legend_icons = 1)
  )
})

testthat::test_that("Error: invalid legend_icons parameter (vector)", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(legend_icons = c(TRUE, FALSE))
  )
})

testthat::test_that("Error: invalid legend_icons parameter (NA)", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point(legend_icons = NA)
  )
})

# ******************************************************************************
## 03.08 Real-world error scenarios --------------------------------------------
# ******************************************************************************

### 03.08.01 Typos in column names ---------------------------------------------

testthat::test_that("Error: typo in icon column name", {
  testthat::expect_error(
    ggplot2::ggplot(df_scatter, ggplot2::aes(x = x, y = y, icon = icno)) + # typo: icno
      geom_icon_point()
  )
})


### 03.08.02 Case sensitivity issues -------------------------------------------

testthat::test_that("Error: wrong case in column name", {
  df_case <- df_scatter
  names(df_case)[3] <- "ICON" # All caps

  testthat::expect_error(
    ggplot2::ggplot(df_case, ggplot2::aes(x = x, y = y, icon = icon)) + # lowercase
      geom_icon_point()
  )
})

### 03.08.03 Partial data corruption ------------------------------------------

testthat::test_that("Error: partially NA icon column", {
  df_partial_na <- df_scatter
  df_partial_na$icon[c(2, 4)] <- NA

  testthat::expect_error(
    ggplot2::ggplot(df_partial_na, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

testthat::test_that("Error: mixed valid and empty icons", {
  df_mixed <- df_scatter
  df_mixed$icon[2] <- ""
  df_mixed$icon[4] <- "   "

  testthat::expect_error(
    ggplot2::ggplot(df_mixed, ggplot2::aes(x = x, y = y, icon = icon)) +
      geom_icon_point()
  )
})

# ******************************************************************************
## 03.11 Combined error scenarios ----------------------------------------------
# ******************************************************************************

### 03.11.01 Invalid data AND invalid parameters -------------------------------

testthat::test_that("Error: invalid data type AND invalid size", {
  testthat::expect_error(
    ggplot2::ggplot() +
      geom_icon_point(
        data = list(x = 1:5, y = 1:5, icon = "circle"), # Invalid data
        ggplot2::aes(x = x, y = y, icon = icon),
        size = NA # Invalid size
      )
  )
})

### 03.11.02 Missing aesthetics AND invalid parameters -------------------------

testthat::test_that("Error: missing icon AND invalid dpi", {
  testthat::expect_error(
    ggplot2::ggplot(df_no_icon, ggplot2::aes(x = x, y = y)) +
      geom_icon_point(dpi = "very high")
  )
})


# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
