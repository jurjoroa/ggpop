# *****************************************************************************
#
# Script: test-geom_pop-warnings.R
#
# Purpose: Test warnings produced by geom_pop().
#
# Author: Jorge Roa
#
# Email: jorgeroa@stanford.edu
#
# Date Created: 02-Jan-2026
#
# *****************************************************************************
#
# Notes:
#   - This file tests ONLY warnings (non-fatal behavior).
#   - We avoid matching warning text to keep tests robust.
#   - We use ggplot() + geom_pop() directly.
#
# *****************************************************************************

# ******************************************************************************
# 01 Load inputs ---------------------------------------------------------------
# ******************************************************************************

testthat::skip_if_not_installed("ggplot2")
testthat::skip_if_not_installed("dplyr")
testthat::skip_if_not_installed("ggimage")
testthat::skip_if_not_installed("fontawesome")

# ******************************************************************************
## 01.01 Test dataframes -------------------------------------------------------
# ******************************************************************************

df_raw <- data.frame(
  sex  = c("male", "female", "male", "female"),
  icon = c("male", "female", "male", "female"),
  stringsAsFactors = FALSE
)

df_processed <- data.frame(
  type = c("male", "female", "male", "female"),
  icon = c("male", "female", "male", "female"),
  stringsAsFactors = FALSE
)

# Helpers (only where needed)
.build_plot <- function(p) ggplot2::ggplot_build(p)

# ******************************************************************************
# 02 Start tests ---------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
# 03 geom_pop ------------------------------------------------------------------
# ******************************************************************************

# ******************************************************************************
## 03.01 Warnings: parameter conflicts -----------------------------------------
# ******************************************************************************

### 03.01.01 size specified both inside aes() and as argument ------------------

testthat::test_that("Warning: size inside aes() overrides geom_pop(size = ...)", {
  df_sz <- df_raw
  df_sz$size <- c(5, 2, 5, 2)
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_sz,
        ggplot2::aes(icon = icon, size = size, color = sex),
        size = 10,
        dpi  = 100
      )
  )
})


# ******************************************************************************
## 03.02 Warnings: facet/grouping cautions -------------------------------------
# ******************************************************************************

### 03.02.01 facet/group caution when multiple groups exist --------------------

testthat::test_that("Warning: facet/group caution (data has group column)", {
  df_grp <- df_raw
  df_grp$group <- df_grp$sex
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_grp,
        ggplot2::aes(icon = icon, group = group)
      )
  )
})

### 03.02.02 facet/group caution when facet is passed inside geom_pop ----------

testthat::test_that("Warning: facet specified inside geom_pop()", {
  df_facet <- df_processed
  df_facet$status <- c("A", "A", "B", "B")
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data  = df_facet,
        ggplot2::aes(icon = icon, group = type),
        facet = status
      )
  )
})

### 03.02.03 facet variable has only one level ---------------------------------

testthat::test_that("Warning: facet variable has single level", {
  df_single <- df_raw
  df_single$region <- "North"
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_single,
        ggplot2::aes(icon = icon, group = sex),
        facet = region,
        dpi = 60
      )
  )
})

# ******************************************************************************
## 03.03 Warnings: unsupported aesthetics --------------------------------------
# ******************************************************************************

### 03.03.01 x/y aesthetics ignored --------------------------------------------

testthat::test_that("Warning: x/y mapped are ignored", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex, x = sex, y = sex),
        dpi = 60
      )
  )
})



### 03.03.02 stroke_width aesthetic mapped (use color instead) -------------------------

testthat::test_that("Warning: stroke_width aesthetic mapped (ignored)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex, color = sex, stroke_width = 8),
        dpi = 60
      )
  )
})

# ******************************************************************************
## 03.04 Warnings: dpi values --------------------------------------------------
# ******************************************************************************

### 03.04.01 dpi very high -----------------------------------------------------

testthat::test_that("Warning: dpi very high", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 800
      )
  )
})

### 03.04.02 dpi borderline low (30-50) ----------------------------------------

testthat::test_that("Warning: dpi borderline low (30-50)", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        dpi = 35
      )
  )
})

# ******************************************************************************
## 03.05 Warnings: size parameters ---------------------------------------------
# ******************************************************************************

### 03.05.01 negative size parameter -------------------------------------------

testthat::test_that("Edge case: size = 0.1 triggers small value warning", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 0.1
      )
  )
})

testthat::test_that("Edge case: size = 16 triggers large value warning", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 16
      )
  )
})

testthat::test_that("Edge case: size = 0.5 (boundary) does not warn", {
  testthat::expect_no_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 0.5
      )
  )
})

testthat::test_that("Edge case: size = 15 (boundary) does not warn", {
  testthat::expect_no_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 15
      )
  )
})

testthat::test_that("Edge case: size = 0.49 triggers warning", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 0.49
      )
  )
})

testthat::test_that("Edge case: size = 15.01 triggers warning", {
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_raw,
        ggplot2::aes(icon = icon, group = sex),
        size = 15.01
      )
  )
})

# ******************************************************************************
## 03.06 Warnings: icon-related ------------------------------------------------
# ******************************************************************************

### 03.06.01 multiple icons per legend group -----------------------------------

testthat::test_that("Warning: multiple icons per color group", {
  df_icons <- data.frame(
    sex  = c("A", "A", "B", "B"),
    icon = c("male", "female", "male", "female"),
    stringsAsFactors = FALSE
  )
  
  testthat::expect_warning(
    ggplot2::ggplot() +
      geom_pop(
        data = df_icons,
        ggplot2::aes(icon = icon, group = sex, color = sex),
        legend_icons = TRUE,
        dpi = 60
      )
  )
})



# ******************************************************************************
## 03.08 Smoke: warnings should still allow build ------------------------------
# ******************************************************************************

### 03.08.01 build succeeds even if a warning is emitted -----------------------

testthat::test_that("Build: plot still builds when warning occurs", {
  df_grp <- df_raw
  df_grp$group <- df_grp$sex
  
  testthat::expect_warning(
    p <- ggplot2::ggplot() +
      geom_pop(
        data = df_grp,
        ggplot2::aes(icon = icon, group = group),
        dpi = 60
      )
  )
  
  # Verify the plot object was created despite warning
  testthat::expect_s3_class(p, "ggplot")
})

# ******************************************************************************
# END --------------------------------------------------------------------------
# ******************************************************************************
